-- Get identifiers
function getIdentifiers(target)
    local identifiers = {
        license = 'Not found',
        xbl = 'Not found',
        live = 'Not found',
        discord = 'Not found',
        license2 = 'Not found',
        ip = 'Not found',
        fivem = 'Not found',
        steam = 'Not found'
    }

    local function match(total, identifier)
        local match = string.match(total, identifier)
        return match
    end

    local function cut(total, identifier)
        local cut = string.gsub(total, identifier, '')
        return cut
    end

    for k, v in ipairs(GetPlayerIdentifiers(target)) do
        if match(v, 'license') and not match(v, 'license2:') then
            identifiers.license = cut(v, 'license:')
        elseif match(v, 'xbl') then
            identifiers.xbl = cut(v, 'xbl:')
        elseif match(v, 'live') then
            identifiers.live = cut(v, 'live:')
        elseif match(v, 'discord') then
            identifiers.discord = cut(v, 'discord:')
        elseif match(v, 'license2') then
            identifiers.license2 = cut(v, 'license2:')
        elseif match(v, 'ip') then
            identifiers.ip = cut(v, 'ip:')
        elseif match(v, 'fivem') then
            identifiers.fivem = cut(v, 'fivem:')
        elseif match(v, 'steam') then
            identifiers.steam = cut(v, 'steam:')
        end
    end
    return identifiers
end

-- Discord function
function sendDiscord(webhook, title, message, image, color)
    if title == nil then title = "pe-adminmenu" end
    if color == nil then color = 123456 end
    if image == nil then image = "" end
    if webhook == nil then webhook = Config.defaultWebhook end
    local embeds = {
        {
            ["title"] = title,
            ["thumbnail"] = {
                ["url"] = Config.discordThumbnail, 
            },
            ["image"] ={
                ["url"] = image,
            },
            ["color"] = color,
            ["description"]  = message,
            ["footer"] = {
                ["text"] = "Project-Entity",
                ["icon_url"] = Config.discordIcon,
           },
        }
    }
    
    if message == nil or message == '' then return false end
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ username = name, embeds = embeds, avatar_url = Config.discordAvatar}), { ['Content-Type'] = 'application/json' })
end