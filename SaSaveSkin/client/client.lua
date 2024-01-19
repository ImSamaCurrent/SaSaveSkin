ESX = exports['es_extended']:getSharedObject()

----------------------------------------------
IniKvp = "SaSaveSkin:" -- ⛔ - Don't edit - ⛔
----------------------------------------------

local filterArray = {Config.Lang.Menu_Load_Skin, Config.Lang.Menu_Delete_Skin};
local filter = 1;
local lastSkin = 0;
local AllSkin = {};

function GetFindKvp()
    AllSkin = {}
    local kvpHandle = StartFindKvp(IniKvp)
    local key = nil

    repeat
        key = FindKvp(kvpHandle)

        if key then
            --print(key, GetResourceKvpString(key))
            table.insert(AllSkin,{Kvp = key,Name = string.sub(key, 12), Skin = GetResourceKvpString(key)})
        end

    until not key

    EndFindKvp(kvpHandle)
end


function createPed(model, locationx, locationy, locationz)
    local hash = model
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Citizen.Wait(1)
    end
    return CreatePed(26, hash, locationx, locationy, locationz, 0, false, false)
end



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



RegisterNetEvent('SaSaveSkin:Open')
AddEventHandler('SaSaveSkin:Open', function()
    GetFindKvp()
    OpenMenuSkin()
end)

local MenuSkin = false

RMenu.Add('SaSaveSkin', 'main', RageUI.CreateMenu(Config.Lang.Menu_Header_Title, Config.Lang.Menu_Header_Desc))
RMenu:Get('SaSaveSkin', 'main'):SetRectangleBanner(0,0,0)
RMenu:Get('SaSaveSkin', 'main').Closed = function() 
    MenuSkin = false
    DeleteEntity(clonedPed)
    lastSkin = 0
end 

function OpenMenuSkin()
    if MenuSkin then
        MenuSkin = false
    else
        MenuSkin = true
        RageUI.Visible(RMenu:Get('SaSaveSkin', 'main'), true)
        Citizen.CreateThread(function()
            while MenuSkin do
                Wait(1)

                RageUI.IsVisible(RMenu:Get('SaSaveSkin', 'main'), true, true, true, function()


                    RageUI.Button(Config.Lang.Menu_Save_New_Skin, nil, { RightLabel = Config.Lang.Menu_RightLabel }, true, function(Hovered, Active, Selected)
                        if Selected then
                            local NameSkin = lib.inputDialog(Config.Lang.Menu_New_Skin, {Config.Lang.Menu_Name_Skin})
                            if not NameSkin then return end
                            if NameSkin[1] == nil or NameSkin[1] == "" or NameSkin[1] == " " then
                                Config.Notification(Config.Lang.Notif_Nill_Name_Skin)
                            else
                                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(appearance)
                                    SetResourceKvp(IniKvp..NameSkin[1], json.encode(appearance))
                                    Wait(100)
                                    GetFindKvp()
                                    --RageUI.CloseAll()
                                end)
                            end
                        end
                        if Active and DoesEntityExist(clonedPed) then
                            DeleteEntity(clonedPed)
                            lastSkin = 0
                        end
                    end)

                    RageUI.Separator('Liste des skins')

                    for k, v in pairs(AllSkin) do

                        RageUI.List(v.Name, filterArray, filter, v.Kvp, {}, true, function(h, a, s, i)
                            filter = i
                            if s then
                                if i == 1 then
                                    exports['fivem-appearance']:setPlayerAppearance(json.decode(v.Skin))
                                elseif i == 2 then
                                    local SelectKey = lib.inputDialog(Config.Lang.Menu_Name_Delete_Skin, {
                                      {type = 'select', label = 'Type', options = {{value = "no", label = Config.Lang.Menu_No},{value = "yes", label = Config.Lang.Menu_Yes},}, required = true}
                                    })
                                    if not SelectKey then return end
                                    if SelectKey[1] == "no" then

                                    elseif SelectKey[1] == "yes" then
                                        DeleteResourceKvp(v.Kvp)
                                        Wait(100)
                                        GetFindKvp()
                                        --RageUI.CloseAll()
                                    end
                                end
                            end
                            if a then
                                TriggerEvent('SaSaveSkin:PVStart', k, json.decode(v.Skin))
                            end
                        end)

                    end

                end, function() 
                end)
            end
        end)
    end
end



function createPed(model, locationx, locationy, locationz)
    local hash = model
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Citizen.Wait(1)
    end
    return CreatePed(26, hash, locationx, locationy, locationz, 0, false, false)
end

RegisterNetEvent('SaSaveSkin:PVStart')
AddEventHandler('SaSaveSkin:PVStart', function(SkinIndex, Skin)
    if lastSkin == SkinIndex then
        return
    else
        lastSkin = SkinIndex
    end

    DeleteEntity(clonedPed)

    if Skin.sex == 1 then
        clonedPed = createPed("mp_f_freemode_01", nil, nil, nil)
    else
        clonedPed = createPed("mp_m_freemode_01", nil, nil, nil)
    end

    local screenX = GetDisabledControlNormal(0, 239)
    local screenY = GetDisabledControlNormal(0, 240)

    exports['fivem-appearance']:setPedAppearance(clonedPed, Skin)
    
    SetEntityCollision(clonedPed, false, true)
    SetEntityInvincible(clonedPed, true)
    NetworkSetEntityInvisibleToNetwork(clonedPed, true)
    SetEntityCanBeDamaged(clonedPed, false)
    SetBlockingOfNonTemporaryEvents(clonedPed, true)

    local screenX = GetDisabledControlNormal(0, 239)
    local screenY = GetDisabledControlNormal(0, 240)

    local positionBuffer = {}
    local bufferSize = 7

    while DoesEntityExist(clonedPed) do 
        local world, normal = GetWorldCoordFromScreenCoord(0.37135417461395, 0.4787036895752)
        local depth = 5.5
        local target = world + normal * depth
        local camRot = GetGameplayCamRot(2)

        table.insert(positionBuffer, target)
        if #positionBuffer > bufferSize then
            table.remove(positionBuffer, 1)
        end

        local averagedTarget = vector3(0, 0, 0)
        for _, position in ipairs(positionBuffer) do
            averagedTarget = averagedTarget + position
        end
        averagedTarget = averagedTarget / #positionBuffer

        SetEntityCoords(clonedPed, averagedTarget.x, averagedTarget.y, averagedTarget.z, false, false, false, true)
        SetEntityHeading(clonedPed, camRot.z + 180.0)
        SetEntityRotation(clonedPed, camRot.x*(-1), 0, camRot.z + 180.0, false, false)

        Citizen.Wait(0)
    end
end)
