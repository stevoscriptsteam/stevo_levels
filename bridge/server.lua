local config = require('config')


---@param src integer
function Bridge.Server.GetPlayer(src)
  if config.Framework == "QBCore" then
    return QBCore.Functions.GetPlayer(src)
  elseif config.Framework == "Qbox" then
    return exports.qbx_core:GetPlayer(src)
  elseif config.Framework == "ESX" then
    return ESX.GetPlayerFromId(src)
  end
end

---@param src integer
function Bridge.Server.GetPlayerIdentifier(src)
  local player = Bridge.Server.GetPlayer(src)
  if not player then return false end

  if config.Framework == "QBCore" or config.Framework == "Qbox" then
    return player.PlayerData.citizenid
  elseif config.Framework == "ESX" then
    return player.getIdentifier()
  end
end



