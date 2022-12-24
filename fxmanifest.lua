fx_version 'cerulean'
game 'gta5'

author 'TRClassic#0001, Mycroft, Benzo, Gojan#1450'
description 'LumberJack Job For QB-Core, Converted to ESX, Updated for ox_inventory/ox_lib/esx-legacy'
version '2.1.0'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    '@es_extended/imports.lua'
}

lua54 'yes'

dependencies {
    'ox_lib',
}