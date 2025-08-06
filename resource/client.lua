lib.locale()
local config = require('config')

exports('getPlayerLevels', function()
    local playerLevels = lib.callback.await('stevo_levels:server:getPlayerLevels', false)
    return playerLevels
end)

exports('getPlayerLevel', function(skill)
    local playerLevels = lib.callback.await('stevo_levels:server:getPlayerLevels', false)
    return playerLevels[skill].level
end)

exports('addPlayerXP', function(skill, amount)
    local xp, level, newLevel = lib.callback.await('stevo_levels:server:addPlayerXP', false, skill, amount)

    if newLevel then
        Bridge.Client.Notify(locale("level_up_title"), (locale("level_up")):format(level, skill), 'success')
    else 
        Bridge.Client.Notify(locale("gained_xp_title"), (locale("gained_xp")):format(amount, skill), 'success')
    end

    return true
end)


RegisterCommand(locale("levelcommand"), function()
    local playerLevels = lib.callback.await('stevo_levels:server:getPlayerLevels', false)
    local formattedContext = {}

    for id, level in pairs(playerLevels) do
        local levelConfig = config.levels[id]

        table.insert(formattedContext, {
            title = levelConfig.label,
            description = (locale("level_description")):format(level.level, level.xp, levelConfig.levels[level.level].xptolevelup),
            iconColor = levelConfig.iconColor,
            colorScheme = levelConfig.colorScheme,
            progress = level.xp / levelConfig.levels[level.level].xptolevelup * 100,
            icon = levelConfig.icon
        })
    end

    lib.registerContext({
        id = 'stevo_levels',
        title = locale("level_title"),
        options = formattedContext
    })

    lib.showContext('stevo_levels')
end, false)

