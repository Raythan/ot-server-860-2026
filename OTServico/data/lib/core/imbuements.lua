MESSAGEDIALOG_IMBUEMENT_ERROR = 1
MESSAGEDIALOG_IMBUEMENT_ROLL_FAILED = 2
MESSAGEDIALOG_IMBUING_STATION_NOT_FOUND = 3
MESSAGEDIALOG_CLEARING_CHARM_SUCCESS = 10
MESSAGEDIALOG_CLEARING_CHARM_ERROR = 11

-- Custom attribute keys for imbuement slots (slot 0 -> IMBUEMENT_SLOT+0, etc.)
IMBUEMENT_SLOT = 1

-- tables
Imbuements_Weapons = {
	["armor"] = {21692, 2500, 2656, 2464, 2487, 2494, 2492, 2503, 12607, 2505, 32419, 2466, 23538, 10296, 2476, 3968, 2472, 7463, 8888, 23537, 2486, 15406, 8891, 18404}, -- ok
	["shield"] = {34068, 2537, 2518, 15491, 2535, 2519, 25414, 2520, 15411, 2516, 32422, 32421, 30885, 2522, 2533, 21707, 2514, 10289, 2536, 6433, 6391, 7460, 2524, 15413, 2539, 25382, 21697, 3974, 10297, 12644, 10294, 2509, 2542, 2528, 2534, 2531, 15453}, -- ok
	["boots"] = {34062, 24742, 2195, 2644, 9931, 3982, 11117, 15410, 11118, 12646, 7457, 7892, 2646, 11240, 2643, 7893, 7891, 23540, 24637, 2641, 5462, 18406, 2642, 2645, 7886, 25412, 21708, 11303, 35229, 36452}, --ok
	["helmet"] = {34065, 2499, 2139, 3972, 2458, 2491, 2497, 2493, 2502, 12645, 32415, 7458, 2471, 10299, 20132, 10298, 2662, 10291, 2498, 24848, 5741, 25410, 2475, 11302, 35232, 36412}, --ok
	["helmetmage"] = {10016, 2323, 11368, 8820, 10570, 9778, 32414, 30882, 36417}, -- ok
	["bow"] = {34055, 25946, 30690, 8855, 7438, 32418, 15643, 21696, 10295, 18454, 25522, 8857, 22417, 22418, 8854, 36416}, -- ok
	["crossbow"] = {25950, 8850, 2455, 30691, 8849, 25523, 8851, 8852, 8853, 16111, 21690, 22420, 22421, 35228}, -- ok
	["backpack"] = {1988, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2365, 3940, 3960, 5801, 5926, 5949, 7342, 9774, 10518, 10519, 10521, 10522, 11119, 11241, 11243, 11244, 11263, 15645, 15646, 16007, 18393, 18394, 21475, 22696, 23666, 23816, 24740, 26181, 27061, 27063, 35056, 33318},
	["wand"] = {29005, 2191, 8920, 8921, 8922}, --ok
	["rod"] = {8910, 8911, 24839}, --ok
	["axe"] = {30686, 2429, 3962, 7412, 30687, 18451, 8926, 2414, 11305, 7419, 2435, 7453, 2415, 2427, 7380, 8924, 7389, 15492, 7435, 2430, 7455, 7456, 2443, 25383, 7434, 6553, 8925, 2431, 2447, 22405, 22408, 22406, 22409, 2454, 15451, 11323}, --ok
	["club"] = {7414, 7426, 2453, 7429, 2423, 7415, 2445, 15647, 7431, 7430, 23543, 30689, 2444, 2452, 20093, 7424, 30688, 25418, 18452, 8928, 7421, 7392, 15414, 7410, 7437, 7451, 2424, 2436, 7423, 12648, 7452, 8929, 22414, 22411, 22415, 22412, 2421, 2391}, --ok
	["sword"] = {7404, 7403, 7406, 12649, 30684, 7416, 2407, 2413, 7385, 7382, 2451, 7402, 8930, 2438, 32423, 2393, 7407, 7405, 2400, 7384, 7418, 7383, 7417, 18465, 30685, 2383, 2376, 7391, 6528, 8931, 12613, 11309, 22399, 22403, 22400, 22402, 7408, 11307, 35233}, --ok
	["spellbooks"] = {25411, 2175, 8900, 8901, 22423, 22424, 29004, 34069, 34058, 34064}, -- ok
	["special_strike"] = {32417, 32416, 30693, 30692, 32523, 32522, 34063}, --ok
	["special_wand"] = {35234},
	["special_rod"] = {35235},
	["elemental_swords"] = {30886, 34059, 34060, 36449},
	["elemental_axes"] = {32424, 35231},
	["elemental_clubs"] = {32425, 34057, 35230, 36415},
	-- Note: if an armor has native protection, it can't be imbue with this protection
	["armor_energy"] = {30883},
	["armor_only_energy"] = {34061},
	["armor_ice"] = {36414},
	["armor_earth"] = {34056, 36413},
	["armor_death"] = {15407, 36418}
}

local equipitems = {
	["lich shroud"] = {"armor", "armor_energy", "armor_only_energy", "armor_ice", "armor_earth", "spellbooks", "shield"},
	["reap"] = {"axe", "club", "sword"},
	["vampirism"] = {"axe", "club", "sword", "wand", "rod", "special_strike", "bow", "crossbow", "armor", "armor_energy", "armor_only_energy", "armor_ice", "armor_earth", "armor_death", "elemental_swords", "elemental_axes", "elemental_clubs", "special_wand"},
	["cloud fabric"] = {"armor", "armor_earth", "armor_death", "spellbooks", "shield"},
	["electrify"] = {"axe", "club", "sword"},
	["swiftness"] = {"boots"},
	["snake skin"] = {"armor", "armor_energy", "armor_only_energy", "armor_ice", "armor_death", "spellbooks", "shield"},
	["venom"] = {"axe", "club", "sword"},
	["slash"] = {"sword", "helmet", "elemental_swords"},
	["chop"] = {"axe", "helmet", "elemental_axes"},
	["bash"] = {"club", "helmet", "elemental_clubs"},
	["hide dragon"] = {"armor", "armor_energy", "armor_only_energy", "armor_ice", "armor_death", "spellbooks", "shield"},
	["scorch"] = {"axe", "club", "sword"},
	["void"] = {"axe", "club", "sword", "wand", "rod", "special_strike", "bow", "crossbow", "helmet","helmetmage", "elemental_swords", "elemental_axes", "elemental_clubs", "special_wand", "special_rod"}, -- Mana
	["quara scale"] = {"armor", "armor_only_energy", "armor_earth", "armor_death", "spellbooks", "shield"},
	["frost"] = {"axe", "club", "sword"},
	["blockade"] = {"shield", "helmet", "spellbooks", "shield"},
	["demon presence"] = {"armor", "armor_energy", "armor_only_energy", "armor_ice", "armor_earth", "armor_death", "spellbooks", "shield"},
	["precision"] = {"bow", "crossbow", "helmet"},
	["strike"] = {"axe", "club", "sword", "bow", "crossbow", "special_strike", "elemental_swords", "elemental_axes", "elemental_clubs", "special_rod"},
	["epiphany"] = {"wand", "rod", "helmetmage", "special_strike", "special_wand", "special_rod"},
	["featherweight"] = {"backpack"},
}

local enablingStorages = {
	["lich shroud"] = Storage.ForgottenKnowledge.LadyTenebrisKilled,
	["reap"] = Storage.ForgottenKnowledge.LadyTenebrisKilled,
	["vampirism"] = Storage.ForgottenKnowledge.LadyTenebrisKilled,
	["cloud fabric"] = Storage.ForgottenKnowledge.LloydKilled,
	["electrify"] = Storage.ForgottenKnowledge.LloydKilled,
	["swiftness"] = Storage.ForgottenKnowledge.LloydKilled,
	["snake skin"] = Storage.ForgottenKnowledge.ThornKnightKilled,
	["venom"] = Storage.ForgottenKnowledge.ThornKnightKilled,
	["slash"] = Storage.ForgottenKnowledge.ThornKnightKilled,
	["chop"] = Storage.ForgottenKnowledge.ThornKnightKilled,
	["bash"] = Storage.ForgottenKnowledge.ThornKnightKilled,
	["hide dragon"] = Storage.ForgottenKnowledge.DragonkingKilled,
	["scorch"] = Storage.ForgottenKnowledge.DragonkingKilled,
	["void"] = Storage.ForgottenKnowledge.DragonkingKilled,
	["quara scale"] = Storage.ForgottenKnowledge.HorrorKilled,
	["frost"] = Storage.ForgottenKnowledge.HorrorKilled,
	["blockade"] = Storage.ForgottenKnowledge.HorrorKilled,
	["demon presence"] = Storage.ForgottenKnowledge.TimeGuardianKilled,
	["precision"] = Storage.ForgottenKnowledge.TimeGuardianKilled,
	["strike"] = Storage.ForgottenKnowledge.LastLoreKilled,
	["epiphany"] = Storage.ForgottenKnowledge.LastLoreKilled,
	["featherweight"] = -1,
}

function Player.canImbueItem(self, imbuement, item)
	local item_type = ""
	for tp, items in pairs(Imbuements_Weapons) do
		if isInArray(items, item:getId()) then
			item_type = tp
			break
		end
	end
	local imb_type = ""
	for ibt, imb_n in pairs(enablingStorages) do
		if string.find(ibt, imbuement:getName():lower()) then
			imb_type = ibt
			break
		end
	end
	if imb_type == "" then
		print(">> [Imbuement::canImbueItem] Error on search imbuement '".. imbuement:getName() .. "'")
		return false
	end

	local equip = equipitems[imb_type]
	if not equip then
		print(">> [Imbuement::canImbueItem] Error on search Weapons imbuement '" .. imbuement:getName() .. "'")
		return false
	end

	local imbuable = false
	for i, p in pairs(equip) do
		if p:lower() == item_type then
			imbuable = true
			break
		end
	end
	if not imbuable then
		return false
	end
	local stg = enablingStorages[imb_type]
	if not stg then
		print(">> [Imbuement::canImbueItem] Error on search Storage imbuement '" .. imbuement:getName() .. "'")
		return false
	end

	if imbuement:getBase().id == 3 and not self:getGroup():getAccess() and stg > -1 and self:getStorageValue(stg) < 1 then
		return false
	end

	return true
end

-- Player functions
function Player.sendImbuementResult(self, errorType, message)
	local msg = NetworkMessage()
	msg:addByte(0xED)
	msg:addByte(errorType or 0x01)
	msg:addString(message)
	msg:sendToPlayer(self)
	msg:delete()
	return
end

function Player.closeImbuementWindow(self)
	local msg = NetworkMessage()
	msg:addByte(0xEC)
	msg:sendToPlayer(self)
	msg:delete()
end

-- Returns number of imbuement slots (0-3) for an item by id. Use when ItemType:getImbuingSlots() is not available.
function getImbuingSlotsForItem(itemId)
	for _, list in pairs(Imbuements_Weapons) do
		if isInArray(list, itemId) then
			return 3
		end
	end
	return 0
end

-- Safe slot count: tries engine ItemType:getImbuingSlots(), then getImbuingSlotsForItem. Pass item id (number).
function getItemImbuingSlots(itemId)
	local ok, n = pcall(function()
		local it = ItemType(itemId)
		return it and it.getImbuingSlots and it:getImbuingSlots() or nil
	end)
	if ok and n and n > 0 then
		return math.min(3, n)
	end
	return getImbuingSlotsForItem(itemId)
end

-- Sends the imbuement panel (open window) to the player for the given item.
-- Item must be in player's inventory/equipment and imbuable. Call only in Protection Zone.
function Player.sendImbuementPanel(self, item)
	if not item or not item:getId() then return false end
	local itemId = item:getId()
	local slots = getItemImbuingSlots(itemId)
	if slots == 0 then return false end

	local activeSlots = {}
	for slot = 0, slots - 1 do
		local duration = item:getImbuementDuration(slot)
		local imbue = item:getImbuement(slot)
		if duration and duration > 0 and imbue then
			local base = imbue:getBase()
			activeSlots[slot] = {
				name = imbue:getName() .. (base.subgroup or ""),
				group = imbue:getCategory() and imbue:getCategory().name or "",
				description = imbue:getDescription() or "",
				duration = duration,
				clearCost = base.removecost or 15000
			}
		end
	end

	local imbuementsList = {}
	for id = 1, 255 do
		local imb = Imbuement(id)
		if imb and self:canBeAppliedImbuement(imb, item) then
			local base = imb:getBase()
			local sources = {}
			for _, pid in pairs(imb:getItems()) do
				table.insert(sources, {
					item = ItemType(pid.itemid),
					description = ItemType(pid.itemid):getName() .. " x" .. pid.count,
					count = pid.count
				})
			end
			table.insert(imbuementsList, {
				id = id,
				name = imb:getName() .. (base.subgroup or ""),
				group = imb:getCategory() and imb:getCategory().name or "Elemental Damage",
				cost = base.price or 5000,
				protectionCost = base.protection or 10000,
				successRate = base.percent or 100,
				description = imb:getDescription() or "",
				sources = sources
			})
		end
	end

	local needItems = {}
	local inv = self:getSlotItem(CONST_SLOT_BACKPACK)
	if inv and inv:isContainer() then
		for slot = 0, inv:getCapacity() - 1 do
			local thing = inv:getItem(slot)
			if thing then
				if thing:isContainer() then
					for s2 = 0, thing:getCapacity() - 1 do
						local sub = thing:getItem(s2)
						if sub then table.insert(needItems, sub) end
					end
				else
					table.insert(needItems, thing)
				end
			end
		end
	end
	for _, slot in pairs({CONST_SLOT_HEAD, CONST_SLOT_NECKLACE, CONST_SLOT_BACKPACK, CONST_SLOT_ARMOR, CONST_SLOT_RIGHT, CONST_SLOT_LEFT, CONST_SLOT_LEGS, CONST_SLOT_FEET, CONST_SLOT_RING, CONST_SLOT_AMMO}) do
		local it = self:getSlotItem(slot)
		if it then table.insert(needItems, it) end
	end

	local msg = NetworkMessage()
	msg:addByte(0xEB)
	msg:addU16(itemId)
	msg:addByte(slots)
	for slot = 0, slots - 1 do
		local a = activeSlots[slot]
		if a then
			local imb = item:getImbuement(slot)
			msg:addU16(imb and imb:getId() or 0)
			msg:addU32(a.duration or 0)
			msg:addU32(a.clearCost or 15000)
		else
			msg:addU16(0)
			msg:addU32(0)
			msg:addU32(0)
		end
	end
	msg:addU16(#imbuementsList)
	for _, imb in ipairs(imbuementsList) do
		msg:addU16(imb.id)
		msg:addString(imb.name)
		msg:addString(imb.group)
		msg:addU32(imb.cost)
		msg:addU32(imb.protectionCost)
		msg:addByte(imb.successRate)
		msg:addString(imb.description or "")
		msg:addByte(#imb.sources)
		for _, src in ipairs(imb.sources) do
			msg:addU16(src.item and src.item:getId() or 0)
			msg:addU16(src.count or 0)
		end
	end
	msg:addByte(#needItems)
	for _, needItem in ipairs(needItems) do
		msg:addU16(needItem:getId())
		msg:addByte(needItem:getCount())
	end
	msg:sendToPlayer(self)
	msg:delete()
	return true
end

-- Items functions
function Item.getImbuementDuration(self, slot)
	local info = 0
	local binfo = tonumber(self:getCustomAttribute(IMBUEMENT_SLOT + slot))
	if binfo then
		info = bit.rshift(binfo, 8)
	end

	return info
end

function Item.getImbuement(self, slot)
	local binfo = tonumber(self:getCustomAttribute(IMBUEMENT_SLOT + slot))
	if not binfo then
		return false
	end
	local id = bit.band(binfo, 0xFF)
	if id == 0 then
		return false
	end
	return Imbuement(id)
end

function Item.addImbuement(self, slot, id)
	local imbuement = Imbuement(id)
	if not imbuement then return false end
	local duration = imbuement:getBase().duration

	local imbue = bit.bor(bit.lshift(duration, 8), id)
	self:setCustomAttribute(IMBUEMENT_SLOT + slot, imbue)
	return true
end

function Item.cleanImbuement(self, slot)
	self:setCustomAttribute(IMBUEMENT_SLOT + slot, 0)
	return true
end
