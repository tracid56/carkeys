ESX               = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

----
function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

RegisterServerEvent('skm_carkeys:createKey')
AddEventHandler('skm_carkeys:createKey', function(plate)
	local identifier = getIdentifiant(GetPlayerIdentifiers(source))
	MySQL.Sync.execute("INSERT INTO `vehicle_keys`(`identifier`, `plate`) VALUES (@identifier,@plate)", { 
        ['@identifier'] = identifier,
        ['@plate'] = plate
    })
end)

RegisterServerEvent('skm_carkeys:giveKey')
AddEventHandler('skm_carkeys:giveKey', function(plate, reciever)
    local identifier = getIdentifiant(GetPlayerIdentifiers(source))
    local reciever = ESX.GetPlayerFromId(reciever)
    MySQL.Sync.execute("UPDATE `vehicle_keys` SET `identifier`=@recieverid WHERE identifier = @identifier AND plate = @plate", { 
        ['@recieverid'] = reciever.identifier,
        ['@identifier'] = identifier,
        ['@plate'] = plate
    })
end)

RegisterServerEvent('skm_carkeys:copyKey')
AddEventHandler('skm_carkeys:copyKey', function(plate, reciever)
    local reciever = ESX.GetPlayerFromId(reciever)
    MySQL.Sync.execute("INSERT INTO `vehicle_keys`(`identifier`, `plate`) VALUES (@recieverid,@plate)", { 
        ['@recieverid'] = reciever.identifier,
        ['@plate'] = plate
    })
end)

RegisterServerEvent('skm_carkeys:deleteKey')
AddEventHandler('skm_carkeys:deleteKey', function(plate)
    local identifier = getIdentifiant(GetPlayerIdentifiers(source))
    MySQL.Sync.execute("DELETE FROM `vehicle_keys` WHERE identifier = @identifier AND plate = @plate", { 
        ['@identifier'] = identifier,
        ['@plate'] = plate
    })
end)

ESX.RegisterServerCallback('skm_carkeys:checkIfPlayerHasKey', function(source, cb, plate)
	local identifier = getIdentifiant(GetPlayerIdentifiers(source))
	MySQL.Async.fetchAll('SELECT plate FROM vehicle_keys WHERE identifier = @identifier AND plate = @plate', {
		['@identifier'] = identifier,
        ['@plate'] = plate
	}, function(result)
		if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
	end)
end)

ESX.RegisterServerCallback('skm_carkeys:checkIfKeyExist', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT * FROM vehicle_keys WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('skm_carkeys:getPlayersKeys', function(source, cb, plate)
    local identifier = getIdentifiant(GetPlayerIdentifiers(source))
    MySQL.Async.fetchAll('SELECT plate FROM vehicle_keys WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(keys)
        if keys ~= nil then
            cb(keys)
        else
            cb(nil)
        end
    end)
end)