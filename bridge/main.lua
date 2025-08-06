local config = require('config')
QBCore, ESX = nil, nil
Bridge = {
  Client = {},
  Server = {}
}

if GetResourceState("qbx_core") == "started" then
  config.Framework = "Qbox"
elseif GetResourceState("qb-core") == "started" then
  QBCore = exports['qb-core']:GetCoreObject()
  config.Framework = "QBCore"
elseif GetResourceState("es_extended") == "started" then
  ESX = exports["es_extended"]:getSharedObject()
  config.Framework = "ESX"
else
  error("Your framework is not supported, we only support Qbox, QBCore and ESX!")
end