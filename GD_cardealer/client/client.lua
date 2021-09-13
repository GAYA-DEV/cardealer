ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local societycardealermoney = nil

cardealer             = {}
cardealer.DrawDistance = 100
cardealer.Size         = {x = 1.0, y = 1.0, z = 1.0}
cardealer.Color        = {r = 255, g = 255, b = 255}
cardealer.Type         = 20

h4ci_conc = {
	catevehi = {},
	listecatevehi = {},
}

local derniervoituresorti = {}
local sortirvoitureacheter = {}
--blips

Citizen.CreateThread(function()

        local cardealermap = AddBlipForCoord(-803.11, -223.96, 37.22)
        SetBlipSprite(cardealermap, 326)
        SetBlipColour(cardealermap, 18)
        SetBlipScale(cardealermap, 0.90)
        SetBlipAsShortRange(cardealermap, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Concessionnaire | Voiture")
        EndTextCommandSetBlipName(cardealermap)

end)

--fin blips

--travail cardealer

local markerjob = {
        {x = -781.87, y = -211.38, z = 37.15}, --point vente
}  

Citizen.CreateThread(function()
    
    while true do
        Citizen.Wait(0)
        local coords, letSleep = GetEntityCoords(PlayerPedId()), true

        for k in pairs(markerjob) do
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' then 
            if (cardealer.Type ~= -1 and GetDistanceBetweenCoords(coords, markerjob[k].x, markerjob[k].y, markerjob[k].z, true) < cardealer.DrawDistance) then
                DrawMarker(cardealer.Type, markerjob[k].x, markerjob[k].y, markerjob[k].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, cardealer.Size.x, cardealer.Size.y, cardealer.Size.z, cardealer.Color.r, cardealer.Color.g, cardealer.Color.b, 100, false, true, 2, false, false, false, false)
                letSleep = false
            end
        end
        end

        if letSleep then
            Citizen.Wait(500)
        end
    
end
end)

--point vente
local cardealerpointvente = false
RMenu.Add('cardealervente', 'main', RageUI.CreateMenu("Menu cardealer", "Pour vendre des véhicules"))
RMenu.Add('cardealervente', 'listevehicule', RageUI.CreateSubMenu(RMenu:Get('cardealervente', 'main'), "Catalogue", "Pour acheter un véhicule"))
RMenu.Add('cardealervente', 'categorievehicule', RageUI.CreateSubMenu(RMenu:Get('cardealervente', 'listevehicule'), "Véhicules", "Pour acheter un véhicule"))
RMenu.Add('cardealervente', 'achatvehicule', RageUI.CreateSubMenu(RMenu:Get('cardealervente', 'categorievehicule'), "Véhicules", "Pour acheter un véhicule"))
RMenu.Add('cardealervente', 'annonces', RageUI.CreateSubMenu(RMenu:Get('cardealervente', 'main'), "Annonces", "Annonces de la ville"))
RMenu:Get('cardealervente', 'main').Closed = function()
    cardealerpointvente = false
end
RMenu:Get('cardealervente', 'categorievehicule').Closed = function()
    supprimervehiculecardealer()
end

function ouvrirpointventeconc()
    if not cardealerpointvente then
        cardealerpointvente = true
        RageUI.Visible(RMenu:Get('cardealervente', 'main'), true)
    while cardealerpointvente do

        RageUI.IsVisible(RMenu:Get('cardealervente', 'main'), true, true, true, function()
           
            RageUI.ButtonWithStyle("Catalogue véhicules", nil, {RightLabel = "→→→"},true, function()
           end, RMenu:Get('cardealervente', 'listevehicule'))
           
           RageUI.ButtonWithStyle("Facture", nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestPlayer == -1 or closestDistance > 3.0 then
                        ESX.ShowNotification('Personne autour')
                    else
                    	local amount = KeyboardInput('Veuillez saisir le montant de la facture', '', 4)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_cardealer', 'cardealer', amount)
                    end
                end
            end)

            RageUI.ButtonWithStyle("Annonces", nil, {RightLabel = "→→→"},true, function()
            end, RMenu:Get('cardealervente', 'annonces'))
    
            end, function()
            end)

        RageUI.IsVisible(RMenu:Get('cardealervente', 'listevehicule'), true, true, true, function()
        	for i = 1, #h4ci_conc.catevehi, 1 do
            RageUI.ButtonWithStyle("Catégorie - "..h4ci_conc.catevehi[i].label, nil, {RightLabel = "→→→"},true, function(Hovered, Active, Selected)
            if (Selected) then
            		nomcategorie = h4ci_conc.catevehi[i].label
                    categorievehi = h4ci_conc.catevehi[i].name
                    ESX.TriggerServerCallback('h4ci_cardealer:recupererlistevehicule', function(listevehi)
                            h4ci_conc.listecatevehi = listevehi
                    end, categorievehi)
                end
            end, RMenu:Get('cardealervente', 'categorievehicule'))
        	end
            end, function()
            end)

        RageUI.IsVisible(RMenu:Get('cardealervente', 'categorievehicule'), true, true, true, function()
        	RageUI.ButtonWithStyle("↓ Catégorie : "..nomcategorie.." ↓", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
            if (Selected) then   
            end
            end)

        	for i2 = 1, #h4ci_conc.listecatevehi, 1 do
            RageUI.ButtonWithStyle(h4ci_conc.listecatevehi[i2].name, "Pour acheter ce véhicule", {RightLabel = h4ci_conc.listecatevehi[i2].price.."$"},true, function(Hovered, Active, Selected)
            if (Selected) then
            		nomvoiture = h4ci_conc.listecatevehi[i2].name
            		prixvoiture = h4ci_conc.listecatevehi[i2].price
            		modelevoiture = h4ci_conc.listecatevehi[i2].model
            		supprimervehiculecardealer()
					chargementvoiture(modelevoiture)

					ESX.Game.SpawnLocalVehicle(modelevoiture, {x = -797.68, y = -811.10, z = 36.64}, 210.53, function (vehicle)
					table.insert(derniervoituresorti, vehicle)
					FreezeEntityPosition(vehicle, true)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
					SetModelAsNoLongerNeeded(modelevoiture)
					end)
                end
            end, RMenu:Get('cardealervente', 'achatvehicule'))

        	end
            end, function()
            end)

        RageUI.IsVisible(RMenu:Get('cardealervente', 'achatvehicule'), true, true, true, function()
        	RageUI.ButtonWithStyle("Nom du modèle : "..nomvoiture, nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
            if (Selected) then   
            end
            end)
            RageUI.ButtonWithStyle("Prix du véhicule : "..prixvoiture.."$", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
            if (Selected) then   
            end
            end)
            RageUI.ButtonWithStyle("Vendre au client", "Attribue le véhicule au client le plus proche (paiement avec argent entreprise)", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            if (Selected) then   
            	ESX.TriggerServerCallback('h4ci_cardealer:verifsouscardealer', function(suffisantsous)
                if suffisantsous then

				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if closestPlayer == -1 or closestDistance > 3.0 then
				ESX.ShowNotification('Personne autour')
				else
				supprimervehiculecardealer()
				chargementvoiture(modelevoiture)

				ESX.Game.SpawnVehicle(modelevoiture, {x = -775.33, y = -232.22, z = 36.64}, 208.61, function (vehicle)
				table.insert(sortirvoitureacheter, vehicle)
				FreezeEntityPosition(vehicle, true)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetModelAsNoLongerNeeded(modelevoiture)
				local plaque     = GeneratePlate()
                local vehicleProps = ESX.Game.GetVehicleProperties(sortirvoitureacheter[#sortirvoitureacheter])
                vehicleProps.plate = plaque
                SetVehicleNumberPlateText(sortirvoitureacheter[#sortirvoitureacheter], plaque)
                FreezeEntityPosition(sortirvoitureacheter[#sortirvoitureacheter], false)

				TriggerServerEvent('h4ci_cardealer:vendrevoiturejoueur', GetPlayerServerId(closestPlayer), vehicleProps, prixvoiture)
				ESX.ShowNotification('Le véhicule '..nomvoiture..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(closestPlayer))
                TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
				end)
				end
                else
                    ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                end

            end, prixvoiture)
                end
            end)

            RageUI.ButtonWithStyle("Acheter le véhicule", "Attribue le véhicule à vous même ( argent de societé )", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                    ESX.TriggerServerCallback('h4ci_cardealer:verifsouscardealer', function(suffisantsous)
                    if suffisantsous then
                    supprimervehiculecardealer()
                    chargementvoiture(modelevoiture)
                    ESX.Game.SpawnVehicle(modelevoiture, {x = -775.33, y = -232.22, z = 36.64}, 208.61, function (vehicle)
                    table.insert(sortirvoitureacheter, vehicle)
                    FreezeEntityPosition(vehicle, true)
                    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                    SetModelAsNoLongerNeeded(modelevoiture)
                    local plaque     = GeneratePlate()
                    local vehicleProps = ESX.Game.GetVehicleProperties(sortirvoitureacheter[#sortirvoitureacheter])
                    vehicleProps.plate = plaque
                    SetVehicleNumberPlateText(sortirvoitureacheter[#sortirvoitureacheter], plaque)
                    FreezeEntityPosition(sortirvoitureacheter[#sortirvoitureacheter], false)

                    TriggerServerEvent('shop:vehicule', vehicleProps, prixvoiture)
                    ESX.ShowNotification('Le véhicule '..nomvoiture..' avec la plaque '..vehicleProps.plate..' a été vendu à '..GetPlayerName(closestPlayer))
                    TriggerServerEvent('esx_vehiclelock:registerkey', vehicleProps.plate, GetPlayerServerId(closestPlayer))
                    end)

                    else
                        ESX.ShowNotification('La société n\'as pas assez d\'argent pour ce véhicule!')
                    end
    
                end, prixvoiture)
                    end
                end)

            end, function()
            end)

            RageUI.IsVisible(RMenu:Get('cardealervente', 'annonces'), true, true, true, function()
                
                RageUI.ButtonWithStyle("Ouvert", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent('Open:Ads')
                    end
                end)

                RageUI.ButtonWithStyle("Fermer", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent('Close:Ads')
                    end
                end)

                RageUI.ButtonWithStyle("Personnalisé", nil, {RightLabel = nil}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local msg = KeyboardInput("Message", "", 100)
                        ExecuteCommand("acon" ..msg)
                    end
                end)

                end, function()
                end)

            Citizen.Wait(0)
        end
    else
        cardealerpointvente = false
    end
end

Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
                local plycrdjob = GetEntityCoords(GetPlayerPed(-1), false)
                local jobdist = Vdist(plycrdjob.x, plycrdjob.y, plycrdjob.z, -781.87, -211.38, 37.15)
            if jobdist <= 1.0 then
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' then  
                    ESX.ShowHelpNotification("Appuyez sur [~b~E~w~] pour accéder au menu cardealer")
                    if IsControlJustPressed(1,51) then
                    	ESX.TriggerServerCallback('h4ci_cardealer:recuperercategorievehicule', function(catevehi)
                            h4ci_conc.catevehi = catevehi
                        end)
                        cardealerpointvente = false
                        ouvrirpointventeconc()
                    end   
                end
               end 
        end
end)

function supprimervehiculecardealer()
	while #derniervoituresorti > 0 do
		local vehicle = derniervoituresorti[1]

		ESX.Game.DeleteVehicle(vehicle)
		table.remove(derniervoituresorti, 1)
	end
end

function chargementvoiture(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyString('STRING')
		AddTextComponentSubstringPlayerName('shop_awaiting_model')
		EndTextCommandBusyString(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
			DisableAllControlActions(0)
		end

		RemoveLoadingPrompt()
	end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)


    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end

Citizen.CreateThread(function()
    local hash = GetHashKey("cs_barry")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Citizen.Wait(20)
    end
    ped = CreatePed("PED_TYPE_CIVMALE", "cs_barry", -780.66, -224.86, 36.15, 85.96, false, true) --Emplacement du PEDS
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
end)

------------
Citizen.Trace('^0======================================================================^7 \n')
Citizen.Trace('^0[^4Author^0] ^7:^0 ^5"GAYA Devellopement^7 \n')
Citizen.Trace('^0[^7Version^0] ^7:^0 ^01.0^7 \n')
Citizen.Trace('^0[^1Support^0] ^7https://discord.gg/uaYK2AN \n')
Citizen.Trace('^0======================================================================^7 \n')