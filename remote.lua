interface = {}


function interface.reset_gui(player)
    if not player then return end

    gui.destroy(player)
    gui.create(player)
end


function interface.on_init()
    combinators.on_init()
    gui.on_init()
end


remote.add_interface("prodmon", interface)
