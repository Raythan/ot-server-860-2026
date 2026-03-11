local messageModeCallbacks = {}

function g_game.onTextMessage(messageMode, message)
  local callbacks = messageModeCallbacks[messageMode]
  if not callbacks or #callbacks == 0 then
    perror(string.format('Unhandled onTextMessage message mode %i: %s', messageMode, message))
    return
  end

  for _, callback in pairs(callbacks) do
    if callback(messageMode, message) then
      return
    end
  end
end

function registerMessageMode(messageMode, callback, first)
  if not messageModeCallbacks[messageMode] then
    messageModeCallbacks[messageMode] = {}
  end

  if first then
    table.insert(messageModeCallbacks[messageMode], 1, callback)
  else
    table.insert(messageModeCallbacks[messageMode], callback)
  end
  return true
end

function unregisterMessageMode(messageMode, callback)
  if not messageModeCallbacks[messageMode] then
    return false
  end

  return table.removevalue(messageModeCallbacks[messageMode], callback)
end
