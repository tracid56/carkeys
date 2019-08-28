-- ESX
ESX               = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--For nb_menuperso
RegisterNetEvent('NB:OpenKeysMenu')
AddEventHandler('NB:OpenKeysMenu', function()
    OpenKeysMenu()
end)

function OpenKeysMenu()
    local playerId = PlayerId()
    ESX.TriggerServerCallback('skm_carkeys:getPlayersKeys', function(keys)
        local elements = {}

        for k,key in ipairs(keys) do
            table.insert(elements, {
                label     = 'Clé - '.. key.plate,
                plate     = key.plate
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeys', {
            title    = 'Clés',
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'CarKeyOptions', {
            title    = data.current.label,
            align    = 'top-left',
            elements = {{label = 'Donner', value = 'giveKey'}, {label = 'Donner un double', value = 'copyKey'}, {label = 'Jeter', value = 'deleteKey'}}
            }, function(data2, menu2)
                menu2.close()
                    if data2.current.value == 'giveKey' then
                        local reciever, distance = ESX.Game.GetClosestPlayer()
                        if player ~= -1 and distance <= 3.0 then
                            TriggerServerEvent('skm_carkeys:giveKey', data.current.plate, GetPlayerServerId(reciever))
                            ESX.ShowNotification('vous avez donné la clé du véhicule '..data.current.plate)
                        else
                            ESX.ShowNotification('Pas de joueurs à proximité')
                        end
                    elseif data2.current.value == 'copyKey' then
                        local reciever, distance = ESX.Game.GetClosestPlayer()
                        if player ~= -1 and distance <= 3.0 then
                            TriggerServerEvent('skm_carkeys:copyKey', data.current.plate, GetPlayerServerId(reciever))
                            ESX.ShowNotification('vous avez donné un double des clés du véhicule '..data.current.plate)
                        else
                            ESX.ShowNotification('Pas de joueurs à proximité')
                        end
                    elseif data2.current.value == 'deleteKey' then
                        TriggerServerEvent('skm_carkeys:deleteKey', data.current.plate)
                        ESX.ShowNotification('Vous avez jeté le clé du véhicule '.. data.current.plate) 
                    end
            end, function(data2, menu2)
                menu2.close()
            end)

        end, function(data, menu)
            menu.close()
        end)

    end)
end

Citizen.CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    while true do
        Wait(0)
        if(IsControlJustPressed(1, 75))then
            local plr = GetPlayerPed(-1)
            if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId(plr))) and GetVehicleDoorLockStatus(GetVehiclePedIsTryingToEnter(PlayerPedId(plr))) == 4 then
                ClearPedTasks(plr)
            end
        end

        -- Key : U
        if(IsControlJustPressed(1, 303)) then 
            
            local plr = GetPlayerPed(-1)
            local plrCoords = GetEntityCoords(plr, true)

            if(IsPedInAnyVehicle(plr, true))then
                local localVehId = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                local localVehPlate = string.lower(GetVehicleNumberPlateText(localVehId))

                    
                ESX.TriggerServerCallback('skm_carkeys:checkIfKeyExist', function(exists)
                    if exists then
                        ESX.TriggerServerCallback('skm_carkeys:checkIfPlayerHasKey', function(haskey)
                            if haskey then
                                local lockStatus = GetVehicleDoorLockStatus(localVehId)

                                if lockStatus == 1 then -- unlocked
                                    SetVehicleDoorsLocked(localVehId, 4)
                                    PlayVehicleDoorCloseSound(localVehId, 1)

                                    TriggerEvent('esx:showNotification', 'Véhicule ~r~vérrouillé')   
                                elseif lockStatus == 4 then -- locked
                                    SetVehicleDoorsLocked(localVehId, 1)
                                    PlayVehicleDoorOpenSound(localVehId, 0)

                                    TriggerEvent('esx:showNotification', 'Véhicule ~g~dévérrouillé') 
                                end
                            else
                                TriggerEvent('esx:showNotification', 'Vous n\'avez pas les clés de ce véhicule.') 
                            end
                        end, localVehPlate)
                    else
                        TriggerServerEvent('skm_carkeys:createKey', localVehPlate)
                        TriggerEvent('esx:showNotification', 'Vous avez pris les clés du véhicule '..localVehPlate)   
                    end
                end, localVehPlate)
            else
                local localVehId = GetClosestVehicle(plrCoords, 8.0, 0, 70)
                local localVehPlate = string.lower(GetVehicleNumberPlateText(localVehId))

                ESX.TriggerServerCallback('skm_carkeys:checkIfPlayerHasKey', function(haskey)
                    if haskey then
                        local lockStatus = GetVehicleDoorLockStatus(localVehId)

                        if lockStatus == 1 then -- unlocked
                            SetVehicleDoorsLocked(localVehId, 4)
                            PlayVehicleDoorCloseSound(localVehId, 1)
                            TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)

                            TriggerEvent('esx:showNotification', 'Véhicule ~r~vérrouillé')  
                        elseif lockStatus == 4 then -- locked
                            SetVehicleDoorsLocked(localVehId, 1)
                            PlayVehicleDoorOpenSound(localVehId, 0)
                            TaskPlayAnim(GetPlayerPed(-1), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)

                            TriggerEvent('esx:showNotification', 'Véhicule ~g~dévérrouillé') 
                        end
                    else
                        TriggerEvent('esx:showNotification', 'Vous n\'avez pas les clés de ce véhicule.') 
                    end
                end, localVehPlate)
            end

            Citizen.Wait(1000)
        end
    end
end)