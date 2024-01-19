
ESX = exports['es_extended']:getSharedObject()

admins = {
    'license:88134ec7ca7575ffdd64be6bfb1dd94581bc56db',
    'license:274b6a1992286eedd0b5277662d57887300cfb93',
    'license:0ad91cae300dd74524176c616fd6df5c9783f133'
}


function isAllowedToChange(player)
    local allowed = false
    for i,id in ipairs(admins) do
        for x,pid in ipairs(GetPlayerIdentifiers(player)) do
            if debugprint then print('admin id: ' .. id .. '\nplayer id:' .. pid) end
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
    end
    return allowed
end

RegisterCommand('SaveSkinMenu', function(source, args)
    if isAllowedToChange(source) then
        TriggerClientEvent('SaSaveSkin:Open', source)
    end
end)