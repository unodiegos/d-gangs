local QBCore = exports['qb-core']:GetCoreObject()
local isLoggedIn = false
local PlayerGang = {}
local currentAction = "none"


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerGang = QBCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate')
AddEventHandler('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerGang = GangInfo
    isLoggedIn = true
end)


function GangMenu()
    exports['qb-menu']:openMenu({
        {
            header = "Gang Garage",
            icon = "fab fa-whmcs",
            isMenuHeader = true
        },
        {
            header = "Vehicle ",
            txt = "  ",
            icon = "fas fa-car",
            params = {
                event = "d-gangs:client:VehicleList"
            }
        },
        {
            header = "Insert Vehicle",
            txt = "  ",
            icon = "fas fa-arrow-right-to-bracket",
            params = {
                event = "d-gangs:client:VehicleDelet"
            }
        },
        {
            header = "Close",
            txt = "",
            icon = "fas fa-circle-right",
            params = {
            event = "qb-menu:closeMenu"
            }
        },
        })
    end
    
RegisterNetEvent("d-gangs:client:VehicleList", function()
    local VehicleList = {
    {
        header = "Vehicles",
        icon = "fab fa-whmcs",
        isMenuHeader = true
    },
    }
    for k, v in pairs(Config.Gangs[PlayerGang.name]["vehicles"]) do
        table.insert(VehicleList, {
        header = v,
        icon = "fas fa-circle",
        params = {
            event = "d-gangs:client:SpawnListVehicle",
            args = k
            }
        })
    end
        table.insert(VehicleList, {
        header = "Close",
        txt = "",
        icon = "fas fa-circle-xmark",
        params = {
            event = "qb-menu:closeMenu",
            }
        })
        exports['qb-menu']:openMenu(VehicleList)
end)

CreateThread(function()
    while true do
        Wait(0)
        if isLoggedIn and PlayerGang.name ~= "none" then
            v = Config.stash[PlayerGang.name]
            ped = PlayerPedId()
            pos = GetEntityCoords(ped)

            stashdist = #(pos - vector3(v.x, v.y, v.z))
            if stashdist < 10.0 then
                DrawMarker(2, v.x, v.y, v.z - 0.2 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                if stashdist < 1.5 then
                    exports['qb-core']:DrawText('<b style=color:rgb(255,0,0);>[E]</b> - STASH','left')
                    currentAction = "stash"
                elseif stashdist < 2.0 then
                    currentAction = "none"
                    exports['qb-core']:HideText()
                end
            else
                Wait(1000)
            end
        else
            Wait(2500)
        end
    end
end)


CreateThread(function()
    while true do
        Wait(0)
            if isLoggedIn and PlayerGang.name ~= "none" then
            v = Config.Gangs[PlayerGang.name]["VehicleSpawner"]
                ped = PlayerPedId()
                pos = GetEntityCoords(ped)
                vehdist = #(pos - vector3(v.x, v.y, v.z))
                if vehdist < 20.0 then
                    DrawMarker(2, v.x, v.y, v.z - 0.2 , 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if vehdist < 1.5 then
                        exports['qb-core']:DrawText('<b style=color:rgb(255,0,0);>[E]</b> - Garage','left')
                        if IsControlJustPressed(0, 38) then                                         
                        GangMenu()
                    end
                else
                    exports['qb-core']:HideText()
                end
            end
        end
    end
end)


RegisterNetEvent("d-gangs:client:VehicleDelet", function()
    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
end)


RegisterNetEvent("d-gangs:client:SpawnListVehicle", function(model)
    local coords = {
        x = Config.Gangs[PlayerGang.name]["VehicleSpawner"].x,
        y = Config.Gangs[PlayerGang.name]["VehicleSpawner"].y,
        z = Config.Gangs[PlayerGang.name]["VehicleSpawner"].z,
        w = Config.Gangs[PlayerGang.name]["VehicleSpawner"].w,
    }
    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetVehicleNumberPlateText(veh, Config.Gangs[PlayerGang.name]["PLATE"])
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleColours(veh, Config.Gangs[PlayerGang.name]["colors"][1], Config.Gangs[PlayerGang.name]["colors"][2])
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
        SetVehicleDirtLevel(veh, 0.0)
    end, coords, true)
end)

RegisterKeyMapping("+openganggarage", "Interaction for gang script", "keyboard", "e")

RegisterCommand("+openganggarage", function()
    if currentAction == "stash" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", PlayerGang.name.."stash", {
            maxweight = 4000000,
            slots = 500,
        })
        TriggerEvent("inventory:client:SetCurrentStash", PlayerGang.name.."stash")
    end
end, false)
