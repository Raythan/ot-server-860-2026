-- Item hover: ao parar o mouse em cima de um item (slot ou container), abre um
-- balão com os mesmos detalhes do Look. Ao tirar o foco do item, o popup fecha.
-- Look manual (Shift+clique) continua igual: Server Log + texto verde na tela.

local HOVER_DELAY_MS = 500
local LOOK_TIMEOUT_MS = 2000

local popupPanel
local popupLabel
local hoverTimer
local currentItemWidget
local waitingForLookFromHover = false
local lookWaitDeadline = 0

local function hidePopup()
  if not popupPanel then return end
  disconnect(rootWidget, { onMouseMove = movePopup })
  popupPanel:hide()
end

local function movePopup()
  if not popupPanel or not popupPanel:isVisible() then return end
  local pos = g_window.getMousePosition()
  local sz = popupPanel:getSize()
  local win = g_window.getSize()
  pos.x = pos.x + 14
  pos.y = pos.y + 14
  if pos.x + sz.width > win.width - 10 then pos.x = pos.x - sz.width - 20 end
  if pos.y + sz.height > win.height - 10 then pos.y = pos.y - sz.height - 20 end
  popupPanel:setPosition(pos)
end

local function showPopup(text)
  if not popupPanel or not popupLabel or not text or text:len() == 0 then return end
  popupLabel:setText(text)
  popupLabel:setWidth(380)
  popupLabel:setHeight(0)
  popupLabel:resizeToText()
  local lw = popupLabel:getWidth()
  local lh = popupLabel:getHeight()
  local w = math.min(lw + 14, 400)
  local h = math.min(lh + 10, 300)
  popupPanel:setWidth(w)
  popupPanel:setHeight(h)
  popupLabel:setPosition(7, 5)
  if modules.client_options then
    local pct = modules.client_options.getOption('itemHoverPopupOpacity')
    if pct == nil then pct = 90 end
    popupPanel:setOpacity(math.max(0, math.min(100, pct)) / 100)
  else
    popupPanel:setOpacity(0.9)
  end
  popupPanel:show()
  popupPanel:raise()
  movePopup()
  connect(rootWidget, { onMouseMove = movePopup })
end

function applyItemPopupOpacity()
  if popupPanel and popupPanel:isVisible() and modules.client_options then
    local pct = modules.client_options.getOption('itemHoverPopupOpacity')
    if pct == nil then pct = 90 end
    popupPanel:setOpacity(math.max(0, math.min(100, pct)) / 100)
  end
end

-- Callback do servidor: mensagem Look. Só consumimos se foi nosso hover que pediu.
local function onLook(messageMode, text)
  if messageMode ~= MessageModes.Look then return false end
  if not waitingForLookFromHover then return false end
  if g_clock.millis() > lookWaitDeadline then
    waitingForLookFromHover = false
    return false
  end
  waitingForLookFromHover = false
  if currentItemWidget then
    showPopup(text)
  end
  return true
end

local function cancelHover()
  if hoverTimer then
    removeEvent(hoverTimer)
    hoverTimer = nil
  end
  currentItemWidget = nil
  waitingForLookFromHover = false
  lookWaitDeadline = 0
  hidePopup()
end

local function doHoverLook()
  hoverTimer = nil
  if not currentItemWidget then return end
  local item = currentItemWidget:getItem()
  if not item or not item:isItem() then return end
  if not g_game.isOnline() then return end
  waitingForLookFromHover = true
  lookWaitDeadline = g_clock.millis() + LOOK_TIMEOUT_MS
  g_game.look(item)
  -- Fallback: se o servidor demorar, mostrar tooltip do item se existir
  scheduleEvent(function()
    if not waitingForLookFromHover or not currentItemWidget then return end
    local fallbackItem = currentItemWidget:getItem()
    if not fallbackItem or not fallbackItem:isItem() then return end
    local tip = fallbackItem:getTooltip()
    if tip and tip:len() > 0 then
      waitingForLookFromHover = false
      lookWaitDeadline = 0
      showPopup(tip)
    end
  end, 300)
end

function onItemHoverChange(widget, hovered)
  if hovered then
    if not widget or widget:getClassName() ~= 'UIItem' then return end
    if widget:isVirtual() then return end
    local item = widget:getItem()
    if not item or not item:isItem() then return end
    if g_mouse.isPressed() then return end
    currentItemWidget = widget
    if hoverTimer then removeEvent(hoverTimer) end
    hoverTimer = scheduleEvent(doHoverLook, HOVER_DELAY_MS)
  else
    if widget == currentItemWidget then
      cancelHover()
    end
  end
end

function init()
  registerMessageMode(MessageModes.Look, onLook, true)

  popupPanel = g_ui.createWidget('Panel', rootWidget)
  popupPanel:setId('itemHoverPopup')
  popupPanel:setBackgroundColor('#1a1a1a')
  popupPanel:setVisible(false)
  popupPanel:setPhantom(true)
  popupPanel:setFocusable(false)

  popupLabel = g_ui.createWidget('UILabel', popupPanel)
  popupLabel:setId('itemHoverPopupLabel')
  popupLabel:setTextAlign(AlignLeft)
  popupLabel:setTextWrap(true)
  popupLabel:setFont('verdana-11')
  popupLabel:setColor('#b0ffb0')
  popupLabel:setMargin(7, 5)
  popupLabel:setWidth(380)
  popupLabel:setHeight(0)
end

function terminate()
  cancelHover()
  unregisterMessageMode(MessageModes.Look, onLook)
  if popupPanel then
    popupPanel:destroy()
    popupPanel = nil
    popupLabel = nil
  end
end
