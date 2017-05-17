interface = {}


function interface.reset_gui(player)
    if not player then return end

    gui.destroy(player)
    gui.create(player)
end


remote.add_interface("prodmon", interface)
