
local MAX_HISTORY_COUNT = 7

signals = {
    history = {
        item = {},
        fluid = {},
        virtual = {},
    },
}


local function get_samples_array(sig_id)
    log(serpent.block(signals.history))
    log(serpent.block(sig_id))
    if not signals.history[sig_id.type] then
        signals.history[sig_id.type] = {}
    end
    local hist = signals.history[sig_id.type]
    if not hist[sig_id.name]  then
        hist[sig_id.name] = { samples = {} }
    end

    return hist[sig_id.name].samples
end


function signals.add_sample(tick, live)
    local samples = get_samples_array(live.signal)
    local new_sample = { tick = tick, value = live.count }
    table.insert(samples, new_sample)
    log(string.format("New sample: t:%s, n:%s, t:%d, v:%d", live.signal.type, live.signal.name, tick, live.count))

    while #samples > MAX_HISTORY_COUNT do
        table.remove(samples, 1)
        log(string.format("Removed oldest sample (have %d, want %d).", #samples, MAX_HISTORY_COUNT))
    end
end


function signals.rate_of_change(signal_id)
    local samples = get_samples_array(signal_id)

    if #samples < MAX_HISTORY_COUNT then return "Insufficient Data" end
    local old = 0
    for i = 1, (MAX_HISTORY_COUNT - 1) do
        old = old + samples[i].value
    end
    local new = 0
    for i = 2, MAX_HISTORY_COUNT do
        new = new + samples[i].value
    end

    if not signals.history[signal_id.type][signal_id.name].last_tick_change then
        signals.history[signal_id.type][signal_id.name].last_tick_change = new - old
        return "Almost ready, one more update..."
    end

    local last_tick_change = signals.history[signal_id.type][signal_id.name].last_tick_change
    signals.history[signal_id.type][signal_id.name].last_tick_change = new - old

    return (last_tick_change + (new - old)) / 2
end


function signals.show_debug_state(player)
    if player.gui.left.prodmon_debug then
        player.gui.left.prodmon_debug.destroy()
    end

    local debug_table = player.gui.left.add{ type="table", name="prodmon_debug", colspan=3 }

    for type, names in pairs(signals.history) do
        for name, samples in pairs(names) do
            debug_table.add{ type="label", caption=type }
            debug_table.add{ type="label", caption=name }

            local accu = {}
            for _, sample in ipairs(samples) do
                table.insert(accu, string.format("%d: %d", sample.tick, sample.value))
            end
            debug_table.add{ type="label", caption=table.concat(accu, ", ") }
        end
    end
end
