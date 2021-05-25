Config = {}

Config.setLang = 'en' -- Select the language the mnu is going to be on (en, es, fr). 
-- Command Options
Config.commandName = 'adm' -- The command you are going to use to open the menu.
Config.commandDescription = 'Open the admin menu' -- The description of the command you are going to use to open the menu.
Config.commandKey = 'INSERT' -- Menu opening key: You can find keys at https://docs.fivem.net/docs/game-references/controls/.

-- Menu options
Config.alignMenu = 'right' -- Menu position options: (top-left, top, top-right, right, bottom-right, bottom, bottom-left)

-- Admin permission options
Config.steamPerms = false -- Original perms from pe-adminmenu V1
Config.badgerPerms = false -- Discord perms
Config.acePerms = false -- Server.cfg (add_group_identifier)
Config.esxPerms = false -- ESX perms (/setgroup admin)
Config.debugPerms = true -- Testing perms (no perms required)

-- Notification Options
Config.tNotify = false
Config.esxNotify = false
Config.debugNotify = true

-- Configurable options
Config.noClipSpeed = 1.0 -- Higher the speed, the more ms it will consume
Config.drawButtons = true -- True will lead to more ms

-- Weapon Config
Config.allWeapons = {
    {
        label = "Hola", 
        value = "test"
    },
    {
        label = "Hola1", 
        value = "test1"
    }
}