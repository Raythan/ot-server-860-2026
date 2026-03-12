--[[
	Ingame Shop - handles client extended opcode 201 (JSON).
	Client sends: { action = "init" | "history" | "buy", data = ... }
	Server responds with same opcode: { action = "categories" | "history" | "message", data = ..., status = { points = N } }
]]

local SHOP_OPCODE = 201
local shopJsonBuffer = {} -- per player id: accumulated JSON string for split packets

function onExtendedOpcode(player, opcode, buffer)
	if opcode ~= SHOP_OPCODE then return true end
	if not player or not player:isUsingOtClient() then return true end

	-- Client may send JSON in one packet or split with S (start), P (part), E (end)
	local status = buffer:sub(1, 1)
	local data = buffer
	local pid = player:getId()

	if status == "S" then
		data = buffer:sub(2)
		shopJsonBuffer[pid] = data
		return true
	elseif status == "P" then
		data = buffer:sub(2)
		if shopJsonBuffer[pid] then
			shopJsonBuffer[pid] = shopJsonBuffer[pid] .. data
		end
		return true
	elseif status == "E" then
		data = buffer:sub(2)
		if shopJsonBuffer[pid] then
			data = shopJsonBuffer[pid] .. data
			shopJsonBuffer[pid] = nil
		end
	else
		-- single packet, no prefix
	end

	local ok, jsonData = pcall(function() return json.decode(data) end)
	if not ok or not jsonData then return true end

	local action = jsonData.action
	local payload = jsonData.data or {}

	if action == "init" then
		local categories = getShopCategoriesWithOffers()
		local points = getAccountPremiumPoints(player:getAccountId())
		sendShopResponse(player, {
			action = "categories",
			data = categories,
			status = { points = points }
		})
	elseif action == "history" then
		local list = getShopHistory(player:getAccountId(), 50)
		sendShopResponse(player, {
			action = "history",
			data = list
		})
	elseif action == "buy" then
		local offerId = type(payload.id) == "number" and payload.id or (tonumber(payload.id))
		if not offerId then
			sendShopResponse(player, { action = "message", data = { title = "Shop Error", msg = "Invalid offer." } })
			return true
		end
		local success, msg = shopPurchaseItem(player, offerId)
		if success then
			sendShopResponse(player, {
				action = "message",
				data = { title = "Successful shop purchase", msg = msg }
			})
			sendShopResponse(player, {
				action = "categories",
				data = getShopCategoriesWithOffers(),
				status = { points = getAccountPremiumPoints(player:getAccountId()) }
			})
		else
			sendShopResponse(player, {
				action = "message",
				data = { title = "Shop Error", msg = msg or "Purchase failed." }
			})
		end
	end
	return true
end
