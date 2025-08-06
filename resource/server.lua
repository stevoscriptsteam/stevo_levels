lib.locale()
local config = require('config')
local playerLevelsDB = {}
local databaseLoaded = false

local function updatePlayerLevelsDB(id, data, force)

    while not databaseLoaded and not force do
        Wait(100)
    end

    if not playerLevelsDB[id] then
        MySQL.insert('INSERT INTO `stevo_levels` (`identifier`, `data`) VALUES (?, ?)', {
            id,
            json.encode(data)
        })
    else
        MySQL.update('UPDATE `stevo_levels` SET `data` = ? WHERE `identifier` = ?', {
            json.encode(data),
            id
        })
    end

    playerLevelsDB[id] = data
end

local function doesLevelExist(level)
    if level > #config.levels then return false end
    return true
end

local function addPlayerXP(source, skill, amount)
    local identifier = Bridge.Server.GetPlayerIdentifier(source)
    local newLevel = false

    if not playerLevelsDB[identifier] then
        local data = {}

        for id, skill in pairs(config.levels) do
            data[id] = {level = 1, xp = 0}
        end
        
        updatePlayerLevelsDB(identifier, data)
    end

    playerLevelsDB[identifier][skill].xp = playerLevelsDB[identifier][skill].xp + tonumber(amount)

    if playerLevelsDB[identifier][skill].xp > config.levels[skill].levels[playerLevelsDB[identifier][skill].level].xptolevelup then
        if doesLevelExist(playerLevelsDB[identifier][skill].level + 1) then
            newLevel = true
            playerLevelsDB[identifier][skill] = {
                level = playerLevelsDB[identifier][skill].level + 1,
                xp = (playerLevelsDB[identifier][skill].xp - config.levels[skill].levels[playerLevelsDB[identifier][skill].level - 1].xptolevelup),
                xptolevelup = config.levels[skill].levels[playerLevelsDB[identifier][skill].level].xptolevelup
            }
        else 
            playerLevelsDB[identifier][skill].xp = config.levels[skill].levels[playerLevelsDB[identifier][skill].level].xptolevelup
        end
    end


    updatePlayerLevelsDB(identifier, playerLevelsDB[identifier])

    if config.logs then
        lib.logger(source, 'levels_add_xp', ('Player %s (%s) gained %s xp in %s'):format(GetPlayerName(source), identifier, amount, skill))
    end

    return playerLevelsDB[identifier][skill].xp, playerLevelsDB[identifier][skill].level, newLevel
end

lib.callback.register('stevo_levels:server:getPlayerLevels', function(source)
    local identifier = Bridge.Server.GetPlayerIdentifier(source)

    if not identifier then return {} end

    if not playerLevelsDB[identifier] then
        local data = {}

        for id, skill in pairs(config.levels) do
            data[id] = {level = 1, xp = 0}
        end
        
        updatePlayerLevelsDB(identifier, data)
    end

    return playerLevelsDB[identifier] 
end)

lib.callback.register('stevo_levels:server:addPlayerXP', function(source, skill, amount)
    local xp, level, newLevel = addPlayerXP(source, skill, amount)

    return xp, level, newLevel
end)

exports('getPlayerLevels', function(source)
    local identifier = Bridge.Server.GetPlayerIdentifier(source)

    if not identifier then return {} end

    if not playerLevelsDB[identifier] then
        playerLevelsDB[identifier] = {}
        for id, skill in ipairs(config.levels) do
            playerLevelsDB[identifier][id] = {level = 1, xp = 0}
        end
    end

    updatePlayerLevelsDB(identifier, playerLevelsDB[identifier])

    return playerLevelsDB[identifier] 
end)

exports('addPlayerXP', function(source, skill, amount)
    local xp, level, newLevel = addPlayerXP(source, skill, amount)

    return {xp = xp, level = level, newLevel = newLevel}
end)


CreateThread(function()

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `stevo_levels` (
        `identifier` varchar(50) DEFAULT NULL,
        `data` longtext DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
    ]])

    local selectedPlayers = MySQL.query.await('SELECT * FROM `stevo_levels`')


    if selectedPlayers then
        for i = 1, #selectedPlayers do

            local storedPlayerLevels = json.decode(selectedPlayers[i].data)
            local playerLevels = {}

            for id, level in pairs(config.levels) do -- This process ensures the player has all the configured skills and also removes skills that no longer exist :)
                playerLevels[id] = storedPlayerLevels[id] or {level = 1, xp = 0}
            end

            playerLevelsDB[selectedPlayers[i].identifier] = playerLevels
            updatePlayerLevelsDB(selectedPlayers[i].identifier, playerLevels, true)
        end
    end

    databaseLoaded = true
end)







