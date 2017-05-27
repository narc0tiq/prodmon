
local MAX_HISTORY_COUNT = 16

signals = {
    history = {
--        player = { -- force
--            ["some-combinator"] = { -- monitor name
--                item = { -- signal type
--                    ["iron-ore"] = { -- signal name
--                        samples = { -- samples
--                            { tick = 0, value = 120 },
--                            { tick = 60, value = 60 },
--                            { tick = 120, value = 0 },
--                        },
--                        update_rate = 300, -- ticks
--                        latest = 0, -- speeds the calculation of % filled
--                        largest_seen = 120, -- represents 100% filled
--                    },
--                },
--                fluid = {},
--                virtual = {},
--            },
--        },
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


local function reduce(tbl, func)
    if not tbl then return nil end

    local candidate = nil
    for _,v in pairs(tbl) do
        if candidate == nil or func(v, candidate) then
            candidate = v
        end
    end
    return candidate
end


local function largest_value_of(t)
    return reduce(t, function(new, current) return new > current end)
end


local function smallest_value_of(t)
    return reduce(t, function(new, current) return new < current end)
end


-- Potentially change the update rate of a signal, if it shows signs of changing
-- more often than the currently-recorded rate.
-- A signal's update rate controls the number and size of the buckets that samples
-- are split into before rate-of-change analysis. In particular, signals from a
-- mining drill are only updated every 300 ticks, and this is the default.
-- Update rate can only ever decrease, and must show consistent faster change
-- (more than (MAX_HISTORY_COUNT / 2) + 1 samples taken less than update_rate
-- apart).
-- NB: Signal update rates can only get shorter, never longer (but will reset
-- on load).
local function check_update_rate(sample_root)
    local update_rate = sample_root.update_rate or 300
    local samples = sample_root.samples

    local faster_update_candidates = {}

    for i = 1, (#samples - 1) do
        local timespan = samples[i+1].tick - samples[i].tick
        local difference = samples[i+1].value - samples[i].value

        if timespan < 0 then
            log(string.format("WTF, there are two samples in the wrong order: %d and %d at ticks %d and %d. Ignored.",
                samples[i+1].value, samples[i].value, samples[i+1].tick, samples[i].tick))
        -- less than update_rate (but not 0 ticks) apart...
        elseif timespan > 0 and timespan < update_rate then
            -- ...and showing any difference at all...
            if samples[i].value - samples[i+1].value ~= 0 then
                -- then record a possible update_rate diff
                table.insert(faster_update_candidates, timespan)
            end
        -- TODO: need a way to slow down the updates if the update rate is too fast
        end
    end

    log(string.format("Have %d faster update candidates, need %d to change.",
        #faster_update_candidates, MAX_HISTORY_COUNT / 2 + 1))

    -- showing _consistent_ change...
    if #faster_update_candidates > MAX_HISTORY_COUNT / 2 + 1 then
        -- ...then pick the largest stored timespan between diffs
        -- (still smaller than the current update_rate)
        local new_rate = largest_value_of(faster_update_candidates)
        log(string.format("Speeding up to sample rate %d", new_rate))
        sample_root.update_rate = new_rate
    end
end


local function bucketize_samples(samples, update_rate)
    -- Pick the largest value for each bucket formed from
    -- taking each sample tick and bucketing at
    -- sample.tick - sample.tick % update_rate
    local buckets = {}
    local offset = samples[1].tick % update_rate

    for _, sample in ipairs(samples) do
        local current_bucket_tick = sample.tick - offset - (sample.tick - offset) % update_rate
        local last_bucket = buckets[#buckets]

        if #buckets == 0 or last_bucket.tick ~= current_bucket_tick then
            table.insert(buckets, {
                value = sample.value,
                tick = current_bucket_tick,
            })
        else
            if last_bucket.value < sample.value then
                last_bucket.value = sample.value
            end
        end
    end

    return buckets
end


local function change_per_min_between_samples(old, new)
    local diff = new.value - old.value
    local duration = new.tick - old.tick

    if duration == 0 then return 0 end

    return diff * 60 * 60 / duration
    --     (    ^ per minute       )
end



local function calculate_rate_of_change(signal_id)
    local sample_root = get_samples_root(signal_id)
    local samples = sample_root.samples

    if #samples < 2 then
        sample_root.rate_of_change_per_min = nil
        sample_root.estimated_to_depletion = nil
        return
    end

    check_update_rate(sample_root)

    local update_rate = sample_root.update_rate or 300

    log(string.format("Updating %s, update rate %d ticks", signal_id.name, update_rate))

    local buckets = bucketize_samples(samples, update_rate)
    if #buckets < 3 then
        sample_root.rate_of_change_per_min = nil
        sample_root.estimated_to_depletion = nil
        return
    end


    -- Weighted average: older samples' change rates have more impact than newer
    local sum_weighted_change_rates = 0
    local sum_weights = 0
    for i = 1, #buckets - 1 do
        local change_rate = change_per_min_between_samples(buckets[i], buckets[i + 1])
        local weight = #buckets - i

        log(string.format("Weight %d, difference %d, duration %d, unweighted change %f/min",
            weight,
            buckets[i].value - buckets[i+1].value,
            buckets[i+1].tick - buckets[i].tick,
            change_rate))

        sum_weighted_change_rates = sum_weighted_change_rates + weight * change_rate
        sum_weights = sum_weights + weight
    end


    local rate_of_change = sum_weighted_change_rates / sum_weights
    sample_root.rate_of_change_per_min = rate_of_change
    log(string.format("Final sum_weights: %d, sum_weighted_change_rates: %f. New change rate: %f/min",
        sum_weights, sum_weighted_change_rates, rate_of_change))

end


function signals.add_sample(tick, live)
    local sample_root = get_samples_root(live.signal)
    sample_root.latest = live.count
    if not sample_root.largest_seen or sample_root.largest_seen < live.count then
        sample_root.largest_seen = live.count
    end

    local samples = sample_root.samples

    local new_sample = { tick = tick, value = live.count }
    table.insert(samples, new_sample)

    while #samples > MAX_HISTORY_COUNT do
        table.remove(samples, 1)
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
    local sample_root = get_samples_root(signal_id)
    if sample_root.rate_of_change_per_min == nil then
        return "ETD/F: unknown"
    end

    local rate_of_change = sample_root.rate_of_change_per_min
    local title = "ETD" -- estimated time to depletion
    local minutes = 0

    if rate_of_change == 0 then
        return "ETD/F: never"
    elseif sample_root.rate_of_change_per_min > 0 then
        title = "ETF" -- estimated time to full
        minutes = (sample_root.largest_seen - sample_root.latest) / rate_of_change
    else -- rate_of_change is negative (decaying)
        minutes = sample_root.latest / -rate_of_change
    end

    local hours = math.floor(minutes / 60)

    if hours > 0 then
        return string.format("%s: %d h %d m", title, hours, minutes % 60)
    elseif minutes > 1 then
        return string.format("%s: %d m", title, minutes)
    else
        return string.format("%s: <1 minute!", title)
    end
end


function signals.percent_remaining(signal_id)
    local sample_root = get_samples_root(signal_id)

    if not sample_root.largest_seen or not sample_root.latest then return "-- %" end

    return sample_root.latest * 100 / sample_root.largest_seen
end


function signals.on_tick(e)
    MAX_HISTORY_COUNT = settings.global["prodmon-sample-count"].value
end
