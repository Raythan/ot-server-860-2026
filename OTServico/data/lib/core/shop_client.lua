--[[
	Shop client (ingame) - loads categories/offers from DB and handles purchases.
	Uses accounts.premium_points as currency.
	Tables: z_shop_category, z_shop_offer, z_shop_history_item (for history).
]]

local SHOP_OPCODE = 201

-- Get account premium points (coins) from DB
function getAccountPremiumPoints(accountId)
	local resultId = db.storeQuery("SELECT `premium_points` FROM `accounts` WHERE `id` = " .. (accountId or 0))
	if not resultId then return 0 end
	local points = result.getNumber(resultId, "premium_points")
	result.free(resultId)
	return points or 0
end

-- Set account premium points
function setAccountPremiumPoints(accountId, points)
	if not accountId or points < 0 then return false end
	db.query("UPDATE `accounts` SET `premium_points` = " .. math.floor(points) .. " WHERE `id` = " .. accountId)
	return true
end

-- Add premium points to account
function addAccountPremiumPoints(accountId, amount)
	local current = getAccountPremiumPoints(accountId)
	return setAccountPremiumPoints(accountId, current + amount)
end

-- Remove premium points (returns true if had enough)
function removeAccountPremiumPoints(accountId, amount)
	local current = getAccountPremiumPoints(accountId)
	if current < amount then return false end
	return setAccountPremiumPoints(accountId, current - amount)
end

-- Load categories and offers from DB for ingame shop (hide = 0)
function getShopCategoriesWithOffers()
	local categories = {}
	local catResult = db.storeQuery("SELECT `id`, `name`, `desc`, `button` FROM `z_shop_category` WHERE `hide` = 0 ORDER BY `id`")
	if not catResult then return categories end

	repeat
		local catId = result.getNumber(catResult, "id")
		local catName = result.getString(catResult, "name")
		local catDesc = result.getString(catResult, "desc")
		local button = result.getString(catResult, "button")

		local offers = {}
		local offerResult = db.storeQuery("SELECT `id`, `coins`, `itemid`, `count`, `offer_name`, `offer_description`, `offer_type`, `default_image` FROM `z_shop_offer` WHERE `category` = " .. catId .. " AND `hide` = 0 ORDER BY `id`")
		if offerResult then
			repeat
				local offerId = result.getNumber(offerResult, "id")
				local coins = result.getNumber(offerResult, "coins")
				local itemid = result.getNumber(offerResult, "itemid")
				local count = math.max(1, result.getNumber(offerResult, "count"))
				local name = result.getString(offerResult, "offer_name")
				local desc = result.getString(offerResult, "offer_description") or ""
				local offerType = result.getString(offerResult, "offer_type") or "items"
				local defaultImage = result.getString(offerResult, "default_image") or ""

				local offerEntry = {
					id = offerId,
					type = "item",
					title = name,
					cost = coins,
					description = desc,
					image = defaultImage
				}
				if itemid and itemid > 0 then
					offerEntry.item = itemid
					offerEntry.count = count
				end
				-- If offer_type is outfits/mounts we could set type = "outfit" and outfit data; for simplicity we keep as item or image
				if (not itemid or itemid == 0) and defaultImage ~= "" then
					offerEntry.type = "image"
				end
				table.insert(offers, offerEntry)
			until not result.next(offerResult)
			result.free(offerResult)
		end

		local catEntry = {
			type = "image",
			name = catName,
			image = button ~= "" and button or "",
			offers = offers
		}
		table.insert(categories, catEntry)
	until not result.next(catResult)
	result.free(catResult)
	return categories
end

-- Get offer by id (for purchase validation)
function getShopOffer(offerId)
	local resultId = db.storeQuery("SELECT `id`, `category`, `coins`, `itemid`, `count`, `offer_name`, `offer_description`, `offer_type`, `hide` FROM `z_shop_offer` WHERE `id` = " .. (offerId or 0))
	if not resultId then return nil end
	local offer = {
		id = result.getNumber(resultId, "id"),
		category = result.getNumber(resultId, "category"),
		coins = result.getNumber(resultId, "coins"),
		itemid = result.getNumber(resultId, "itemid"),
		count = math.max(1, result.getNumber(resultId, "count")),
		offer_name = result.getString(resultId, "offer_name"),
		offer_description = result.getString(resultId, "offer_description"),
		offer_type = result.getString(resultId, "offer_type"),
		hide = result.getNumber(resultId, "hide")
	}
	result.free(resultId)
	if offer.hide ~= 0 then return nil end
	return offer
end

-- Record purchase in history and deliver item (or queue). Returns true on success.
function shopPurchaseItem(player, offerId)
	local offer = getShopOffer(offerId)
	if not offer then return false, "Offer not found." end

	local accountId = player:getAccountId()
	local points = getAccountPremiumPoints(accountId)
	if points < offer.coins then return false, "You do not have enough premium points." end

	-- Only item-type offers are delivered here; outfits/premium etc. can be extended later
	if offer.itemid and offer.itemid > 0 then
		local item = Game.createItem(offer.itemid, offer.count)
		if not item then return false, "Could not create item." end
		local ret = player:addItemEx(item, true)
		if ret ~= RETURNVALUE_NOERROR then
			return false, "Please make sure you have free capacity and space in your backpack."
		end
	end

	-- Deduct points
	if not removeAccountPremiumPoints(accountId, offer.coins) then
		return false, "Could not deduct points."
	end

	-- Record in history (reuse z_shop_history_item: to_name, to_account, from_nick, from_account, price, offer_id, trans_state, trans_start, trans_real)
	db.asyncQuery("INSERT INTO `z_shop_history_item` (`to_name`, `to_account`, `from_nick`, `from_account`, `price`, `offer_id`, `trans_state`, `trans_start`, `trans_real`) VALUES (" ..
		db.escapeString(player:getName()) .. ", " .. accountId .. ", " .. db.escapeString("Ingame Shop") .. ", 0, " .. offer.coins .. ", " .. offer.id .. ", 'realized', " .. os.time() .. ", " .. os.time() .. ")")

	return true, "You have purchased " .. offer.offer_name .. "."
end

-- Get transaction history for client (last N purchases for this account)
function getShopHistory(accountId, limit)
	limit = math.min(tonumber(limit) or 50, 100)
	local list = {}
	local resultId = db.storeQuery("SELECT h.`offer_id`, h.`price`, h.`trans_real`, o.`offer_name`, o.`offer_description`, o.`default_image` FROM `z_shop_history_item` h LEFT JOIN `z_shop_offer` o ON o.`id` = h.`offer_id` WHERE h.`to_account` = " .. accountId .. " AND h.`trans_state` = 'realized' ORDER BY h.`trans_real` DESC LIMIT " .. limit)
	if not resultId then return list end
	repeat
		local offerId = result.getNumber(resultId, "offer_id")
		local price = result.getNumber(resultId, "price")
		local name = result.getString(resultId, "offer_name") or "Unknown"
		local desc = result.getString(resultId, "offer_description") or ""
		local img = result.getString(resultId, "default_image") or ""
		table.insert(list, {
			id = offerId,
			type = "image",
			image = img,
			cost = price,
			title = name,
			description = desc
		})
	until not result.next(resultId)
	result.free(resultId)
	return list
end

-- Send JSON to client via extended opcode, chunking with S/P/E when needed.
function sendShopResponse(player, payload)
	if not player then return end
	-- Check method exists without calling it (player:sendExtendedOpcode in condition can cause errors with userdata)
	if type(player.sendExtendedOpcode) ~= "function" then return end
	local jsonStr = json.encode(payload)
	local maxPacketSize = 65000

	if #jsonStr <= maxPacketSize then
		player:sendExtendedOpcode(SHOP_OPCODE, jsonStr)
		return
	end

	local chunks = {}
	for i = 1, #jsonStr, maxPacketSize do
		table.insert(chunks, jsonStr:sub(i, i + maxPacketSize - 1))
	end

	player:sendExtendedOpcode(SHOP_OPCODE, "S" .. chunks[1])
	for i = 2, #chunks - 1 do
		player:sendExtendedOpcode(SHOP_OPCODE, "P" .. chunks[i])
	end
	player:sendExtendedOpcode(SHOP_OPCODE, "E" .. chunks[#chunks])
end
