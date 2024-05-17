fx_version 'cerulean'
games { 'gta5' }

author 'qwezert'
description 'QWZ Hunting script'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'locales/*.json'
}

lua54 'yes'