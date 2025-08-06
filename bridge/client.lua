local config = require('config')
Bridge.Client.PlayerData = {}

if (GetResourceState("qbx_core") == "started") then

  RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
  AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    local PlayerData = exports.qbx_core:GetPlayerData()

    Bridge.Client.PlayerData.job = PlayerData.job.name
    Bridge.Client.PlayerData.gang = PlayerData.gang.name

  end)

  RegisterNetEvent("QBCore:Client:OnJobUpdate")
  AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
    Bridge.Client.PlayerData.job = job.name

  end)

  RegisterNetEvent("QBCore:Client:OnGangUpdate")
  AddEventHandler("QBCore:Client:OnGangUpdate", function(gang)
  
    Bridge.Client.PlayerData.gang = gang.name

  end)

  AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local PlayerData = exports.qbx_core:GetPlayerData()

  
    Bridge.Client.PlayerData.job = PlayerData.job.name
    Bridge.Client.PlayerData.gang = PlayerData.gang.name

  end)

  function Bridge.Client.GetFrameworkCallsign()
    local PlayerData = exports.qbx_core:GetPlayerData()
    return PlayerData.metadata.callsign
  end
end

if (GetResourceState("qb-core") == "started") and not (GetResourceState("qbx_core") == "started") then
  RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
  AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
  
    Bridge.Client.PlayerData.job = PlayerData.job.name
    Bridge.Client.PlayerData.gang = PlayerData.gang.name

  end)
  
  RegisterNetEvent("QBCore:Client:OnJobUpdate")
  AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
  
    Bridge.Client.PlayerData.job = job.name

  end)

  RegisterNetEvent("QBCore:Client:OnGangUpdate")
  AddEventHandler("QBCore:Client:OnGangUpdate", function(gang)
  
    Bridge.Client.PlayerData.gang = gang.name

  end)

  AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local PlayerData = QBCore.Functions.GetPlayerData()
  
    Bridge.Client.PlayerData.job = PlayerData.job.name
    Bridge.Client.PlayerData.gang = PlayerData.gang.name

  end)

  function Bridge.Client.GetFrameworkCallsign()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return PlayerData.metadata.callsign
  end
end

if (GetResourceState("es_extended") == "started") then
  RegisterNetEvent("esx:playerLoaded")
  AddEventHandler("esx:playerLoaded", function(xPlayer)
    local PlayerData = xPlayer
    
    Bridge.Client.PlayerData.job = PlayerData.job.name
    Bridge.Client.PlayerData.gang = PlayerData.job.name

    LoadDumpsterDiving()
  end)
  
  RegisterNetEvent("esx:setJob")
  AddEventHandler("esx:setJob", function(job)
    
    Bridge.Client.PlayerData.job = job.name
    Bridge.Client.PlayerData.gang = job.name
  end)  


  AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    local PlayerData = ESX.PlayerData

    Bridge.Client.PlayerData.job = PlayerData.job.name
    Bridge.Client.PlayerData.gang = PlayerData.job.name
    
  end)

  function Bridge.Client.GetFrameworkCallsign()
    return ''
  end
end


---@param title string
---@param msg string
---@param type? "success" | "warning" | "error" | "info"
---@param time? number
function Bridge.Client.Notify(title, msg, type, time)
  title = title or 'Claiming'
  type = type or "success"
  time = time or 5000

  if (config.notify == "auto" and GetResourceState("okokNotify") == "started") or config.notify == "okokNotify" then
    exports["okokNotify"]:Alert(title, msg, time, type)
  elseif (config.notify == "auto" and GetResourceState("ps-ui") == "started") or config.notify == "ps-ui" then
    exports["ps-ui"]:Notify(msg, type, time)
  elseif (config.notify == "auto" and GetResourceState("ox_lib") == "started") or config.notify == "ox_lib" then
    exports["ox_lib"]:notify({
      title = title,
      description = msg,
      type = type
    })
  elseif (config.notify == "auto" and GetResourceState("wasabi_notify") == "started") or config.notify == "wasabi_notify" then
    exports.wasabi_notify:notify(title, msg, time, type)
  else
    if config.Framework == "QBCore" then
      return QBCore.Functions.Notify(msg, type, time)
    elseif config.Framework == "Qbox" then
      exports.qbx_core:Notify(msg, type, time)
    elseif config.Framework == "ESX" then
      return ESX.ShowNotification(msg, type)
    end
  end
end
