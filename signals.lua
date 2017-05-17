
local MAX_HISTORY_COUNT = 13

signals = {
    history = {
        item = {
--            ["iron-ore"] = {
--                samples = {
--                    { tick = 0, value = 120 },
--                    { tick = 60, value = 60 },
--                    { tick = 120, value = 0 },
--                }
--            }
        },
        fluid = {},
        virtual = {},
    },
}


local function get_samples_root(sig_id)
    if not signals.history[sig_id.type] then
        signals.history[sig_id.type] = {}
    end
    local hist = signals.history[sig_id.type]
    if not hist[sig_id.name]  then
        hist[sig_id.name] = { samples = {} }
    end

    return hist[sig_id.name]
end


local function calculate_rate_of_change(signal_id)
    local samples = get_samples_root(signal_id).samples

    if #samples < 2 then return end
    local change_rates = {} -- per minute

    for i = 1, (#samples - 1) do
        local difference = samples[i].value - samples[#samples].value
        local timespan = samples[#samples].tick - samples[i].tick

        log(string.format("Weight %d, difference %d, timespan %d, unweighted change %f/min",
            #samples - i,
            difference,
            timespan,
            difference * 60 * 60 / timespan))
        change_rates[i] = (#samples - i) * difference * 60 * 60 / timespan
    end

    local change_sum = 0
    for i,v in ipairs(change_rates) do
        change_sum = change_sum + v
    end
    local sum_weights = #change_rates * (#change_rates + 1) / 2

    log(string.format("Sum of changes %f, Num samples %d, sum weights %d, New rate of change: %f", change_sum, #change_rates, sum_weights, change_sum / sum_weights))

    -- rate * ups * sec-per-min
    local rate_of_change = -(change_sum / sum_weights)
    get_samples_root(signal_id).rate_of_change_per_min = rate_of_change

    if rate_of_change >= 0 then
        get_samples_root(signal_id).estimated_to_depletion = nil
    else
        -- time to deplete: last sample / decay rate
        get_samples_root(signal_id).estimated_to_depletion = samples[#samples].value / -rate_of_change
    end
end


function signals.add_sample(tick, live)
    local samples = get_samples_root(live.signal).samples

--    if samples[#samples] and samples[#samples].value == live.count then
--        log(string.format("Ignoring duplicate value %d for %s", live.count, live.signal.name))
--        return
--    end

    local new_sample = { tick = tick, value = live.count }
    table.insert(samples, new_sample)
    log(string.format("New sample: t:%s, n:%s, t:%d, v:%d", live.signal.type, live.signal.name, tick, live.count))

    while #samples > MAX_HISTORY_COUNT do
        table.remove(samples, 1)
        log(string.format("Removed oldest sample (have %d, want %d).", #samples, MAX_HISTORY_COUNT))
    end

    calculate_rate_of_change(live.signal)
end


function signals.rate_of_change(signal_id)
    if get_samples_root(signal_id).rate_of_change_per_min == nil then
        return {"prodmon.insufficient-data"}
    end

    return {"prodmon.rate-of-change-per-min",
        string.format("%.2f", get_samples_root(signal_id).rate_of_change_per_min)}
end


function signals.estimate_to_depletion(signal_id)
    if get_samples_root(signal_id).rate_of_change_per_min == nil then
        return "ETD: unknown"
    end
    if get_samples_root(signal_id).estimated_to_depletion == nil then
        return "ETD: never"
    end

    local minutes = get_samples_root(signal_id).estimated_to_depletion
    local hours = math.floor(minutes / 60)

    if hours > 0 then
        return string.format("ETD: %d h %d m", hours, minutes % 60)
    elseif minutes > 1 then
        return string.format("ETD: %d m", minutes)
    else
        return "ETD: <1 minute!"
    end
end
