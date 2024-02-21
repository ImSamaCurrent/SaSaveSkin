
ESX = exports['es_extended']:getSharedObject()

admins = {
    'license:XXX',
    'license:XXX',
    'license:XXX'
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
