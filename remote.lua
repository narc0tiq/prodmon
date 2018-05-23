interface = {}

interface.console = require("utils.console")


function interface.reset_gui(player)
    if not player then return end

    gui.destroy(player)
    gui.create(player)
end


function interface.on_init()
    signals.on_init()
    combinators.on_init()
    gui.on_init()
end

remote.add_interface("prodmon", interface)
