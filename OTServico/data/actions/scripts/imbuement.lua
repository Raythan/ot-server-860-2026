-- Imbuing Shrine: use the shrine to open the imbuement window (only in Protection Zone).
-- Same effect as saying !imbue - opens panel for the first imbuable item.
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player:getTile() or not player:getTile():hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You can only use the imbuing shrine in a protection zone.")
		return true
	end
	local function findImbuable(it)
		if not it then return nil end
		if getImbuingSlotsForItem(it:getId()) > 0 then return it end
		if it:isContainer() then
			for i = 0, it:getCapacity() - 1 do
				local sub = it:getItem(i)
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
	player:sendTextMessage(MESSAGE_STATUS_SMALL, "You have no imbuable items. Carry or equip an item that can be imbued.")
	return true
end
