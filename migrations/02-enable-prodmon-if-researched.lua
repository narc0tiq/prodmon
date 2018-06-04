for index, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes

    if technologies["circuit-network"].researched then
        recipes["production-monitor"].enabled = true
        recipes["production-monitor"].reload()
    end
end
