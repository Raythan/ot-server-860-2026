-- Opens the imbuement window. Only works in Protection Zone.
-- Usage: !imbue [itemId]
-- Without itemId: opens panel for the first imbuable item found (equipment then backpack).
-- With itemId: opens panel for that item if the player has it and it is imbuable.
function onSay(player, words, param)
	if not player:getTile() or not player:getTile():hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can only open the imbuement window in a protection zone.")
		return false
	end

	local itemId = tonumber(param)
	if itemId then
		-- Find item by id in player (inventory/equipment)
		local item = nil
		for _, slot in pairs({CONST_SLOT_HEAD, CONST_SLOT_NECKLACE, CONST_SLOT_BACKPACK, CONST_SLOT_ARMOR, CONST_SLOT_RIGHT, CONST_SLOT_LEFT, CONST_SLOT_LEGS, CONST_SLOT_FEET, CONST_SLOT_RING, CONST_SLOT_AMMO}) do
			local it = player:getSlotItem(slot)
			if it and it:getId() == itemId then
				item = it
				break
			end
			if it and it:isContainer() then
				for i = 0, it:getCapacity() - 1 do
					local sub = it:getItem(i)
					if sub and sub:getId() == itemId then
						item = sub
						break
					end
					if sub and sub:isContainer() then
						for j = 0, sub:getCapacity() - 1 do
							local sub2 = sub:getItem(j)
							if sub2 and sub2:getId() == itemId then
								item = sub2
								break
							end
						end
					end
					if item then break end
				end
			end
			if item then break end
		end
		if not item then
			player:sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have that item.")
			return false
		end
		return player:openImbuementPanelForItem(item)
	end

	-- Find first imbuable item: equipment first, then backpack
	local function findImbuable(item)
		if not item then return nil end
		if getImbuingSlotsForItem(item:getId()) > 0 then
			return item
		end
		if item:isContainer() then
			for i = 0, item:getCapacity() - 1 do
				local sub = item:getItem(i)
				local found = findImbuable(sub)
				if found then return found end
			end
		end
		return nil
	end

	for _, slot in pairs({CONST_SLOT_HEAD, CONST_SLOT_NECKLACE, CONST_SLOT_ARMOR, CONST_SLOT_RIGHT, CONST_SLOT_LEFT, CONST_SLOT_LEGS, CONST_SLOT_FEET, CONST_SLOT_RING, CONST_SLOT_AMMO}) do
		local it = player:getSlotItem(slot)
		if it and getImbuingSlotsForItem(it:getId()) > 0 then
			return player:openImbuementPanelForItem(it)
		end
	end
	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
	local found = findImbuable(backpack)
	if found then
		return player:openImbuementPanelForItem(found)
	end
	player:sendTextMessage(MESSAGE_STATUS_SMALL, "You have no imbuable items. Equip or carry weapons, armor, boots, helmet, shield, backpack, etc. that can be imbued.")
	return false
end
