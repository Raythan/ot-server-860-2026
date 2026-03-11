-- Item hover popup: shows the same description as Shift+click (Look) when hovering items in inventory/containers.
-- Opacity is configurable in Options > Interface.

local hoverDelayMs = 550
local pendingHoverLook = false
local hoverSchedule = nil
local currentHoverWidget = nil
local popupPanel = nil
local popupLabel = nil

local function getPopupOpacity()
  local pct = 90
  if modules.client_options then
    pct = modules.client_options.getOption('itemHoverPopupOpacity')
    if pct == nil then pct = 90 end
  end
  return math.max(0, math.min(100, pct)) / 100
end

local function movePopup()
  if not popupPanel or not popupPanel:isVisible() then return end
  local pos = g_window.getMousePosition()
  local windowSize = g_window.getSize()
  local size = popupPanel:getSize()
  pos.x = pos.x + 12
  pos.y = pos.y + 12
  if windowSize.width - (pos.x + size.width) < 10 then
    pos.x = pos.x - size.width - 16
  end
  if windowSize.height - (pos.y + size.height) < 10 then
    pos.y = pos.y - size.height - 16
  end
  popupPanel:setPosition(pos)
end

function showItemPopup(text)
  if not popupPanel or not popupLabel then return end
  if not text or text:len() == 0 then return end
  popupLabel:setText(text)
  popupLabel:setWidth(380)
  popupLabel:setHeight(0)
  popupLabel:resizeToText()
  local lw = popupLabel:getWidth()
  local lh = popupLabel:getHeight()
  local w = math.min(lw + 14, 400)
  local h = math.min(lh + 10, 300)
  popupPanel:setSize(w, h)
  popupLabel:setPosition(7, 5)
  popupPanel:setOpacity(getPopupOpacity())
  popupPanel:show()
  popupPanel:raise()
  movePopup()
  connect(rootWidget, { onMouseMove = movePopup })
end

function hideItemPopup()
  if not popupPanel then return end
  disconnect(rootWidget, { onMouseMove = movePopup })
  popupPanel:hide()
end

function applyItemPopupOpacity()
  if popupPanel and popupPanel:isVisible() then
    popupPanel:setOpacity(getPopupOpacity())
  end
end

local function onLookMessage(mode, text)
  if mode ~= MessageModes.Look then return end
  if not pendingHoverLook then return end
  pendingHoverLook = false
  showItemPopup(text)
end

local function doHoverLook()
  hoverSchedule = nil
  if not currentHoverWidget then return end
  local item = currentHoverWidget:getItem()
  if not item or not item:isItem() then return end
  if not g_game.isOnline() then return end
  pendingHoverLook = true
  g_game.look(item)
end

local function cancelHover()
  if hoverSchedule then
    removeEvent(hoverSchedule)
    hoverSchedule = nil
  end
  currentHoverWidget = nil
  if pendingHoverLook then
    pendingHoverLook = false
  end
  hideItemPopup()
end

local function onWidgetHoverChange(widget, hovered)
  if hovered then
    if widget:getClassName() ~= 'UIItem' then return end
    if widget:isVirtual() then return end
    local item = widget:getItem()
    if not item or not item:isItem() then return end
    if g_mouse.isPressed() then return end
    currentHoverWidget = widget
    if hoverSchedule then removeEvent(hoverSchedule) end
    hoverSchedule = scheduleEvent(doHoverLook, hoverDelayMs)
  else
    if widget == currentHoverWidget then
      cancelHover()
    end
  end
end

function init()
  registerMessageMode(MessageModes.Look, onLookMessage)
  connect(UIWidget, { onHoverChange = onWidgetHoverChange })

  popupPanel = g_ui.createWidget('Panel', rootWidget)
  popupPanel:setId('itemHoverPopup')
  popupPanel:setBackgroundColor('#111111')
  popupPanel:setVisible(false)
  popupPanel:setPhantom(true)
  popupPanel:setFocusable(false)

  popupLabel = g_ui.createWidget('UILabel', popupPanel)
  popupLabel:setId('itemHoverPopupLabel')
  popupLabel:setTextAlign(AlignLeft)
  popupLabel:setTextWrap(true)
  popupLabel:setFont('verdana-11')
  popupLabel:setColor('#00ff00')
  popupLabel:setMargin(7, 5)
  popupLabel:setWidth(380)
  popupLabel:setHeight(0)
end

function terminate()
  cancelHover()
  unregisterMessageMode(MessageModes.Look, onLookMessage)
  disconnect(UIWidget, { onHoverChange = onWidgetHoverChange })
  if popupPanel then
    popupPanel:destroy()
    popupPanel = nil
    popupLabel = nil
  end
end
