fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'StevoScripts'
description 'Simple Levelling system'
version '1.0.0'


shared_scripts {
  'config.lua',
  '@ox_lib/init.lua',
  'bridge/main.lua',
}


client_scripts {
  'bridge/client.lua',
  'bridge/editable_client.lua',
  'resource/client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'bridge/server.lua',
  'bridge/editable_server.lua',
  'resource/server.lua'
}

files {
  'locales/*.json'
}

dependencies {
  'ox_lib',
  'oxmysql',
}
