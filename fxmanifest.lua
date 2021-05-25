fx_version 'cerulean'

game { 'gta5' }

lua54 'yes'

description 'A re-worked admin menu that has fixes and new features compared to the original one'

version '2.0.0'

client_scripts {
    'config/config_cl.lua',
    'lib/i18n.lua',
    'locales/*.lua',
    'client/functions_cl.lua',
    'client/events_cl.lua',
    'client/menu_cl.lua'
}

server_scripts {
    'config/config_sv.lua',
    'lib/i18n.lua',
    'locales/*.lua',
    'server/*.lua'
}