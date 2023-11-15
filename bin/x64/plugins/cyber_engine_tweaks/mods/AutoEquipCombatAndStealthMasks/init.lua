State = require("modules/state")
Util = require("modules/util")


local state = State.new()




local function equipItems()
	state.wasEquipped = true
	state:update()
	Util.unequipItems(state.lastItems)
	Util.equipItems(state.items, state.wasTransmog)
end


local function unequipItems()
	local outfitSystem = Util.getOutfitSystem()

	Util.unequipItems(state.items)
	Util.equipItems(state.lastItems, state.wasTransmog)

	if state.lastOutfit then
		outfitSystem:LoadOutfit(state.lastOutfit)
	elseif not state.wasTransmog then
		outfitSystem:Deactivate()
	end

	state:reset()
end


local function onStateChanged(active)
	if active then
		if not state.wasEquipped and not Util.isInVehicle() then
			equipItems()
		end
	elseif state.wasEquipped then
		unequipItems()
	end
end




registerForEvent("onInit", function ()
	state.items = Util.getItems()

	ObserveAfter("EquipmentSystemPlayerData", "OnRestored", function ()
		state:update()
	end)

	ObserveAfter("PlayerPuppet", "OnCombatStateChanged", function ()
		state.wasInCombat = Util.isInCombat()
		onStateChanged(state.wasInCombat or state.wasWeaponDrawn or state.wasInHostileZone)
	end)

	ObserveAfter("TargetHitIndicatorGameController", "OnWeaponChanged", function ()
		state.wasWeaponDrawn = Util.isWeaponDrawn()
		onStateChanged(state.wasInCombat or state.wasWeaponDrawn or state.wasInHostileZone)
	end)

	ObserveAfter("PlayerPuppet", "OnZoneFactChanged", function ()
		state.wasInHostileZone = Util.isInHostileZone()
		onStateChanged(state.wasInCombat or state.wasWeaponDrawn or state.wasInHostileZone)
	end)
end)
