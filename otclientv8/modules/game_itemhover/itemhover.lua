-- Item hover: ao parar o mouse em cima de um item (slot de equipamento ou container),
-- abre um tooltip com os detalhes do Look. Opacidade configurável em Opções (0%% a 100%%).
-- Look manual (Shift+clique) continua igual: Server Log + texto verde na tela.

local HOVER_DELAY_MS = 500
local LOOK_TIMEOUT_MS = 2000

-- Cores no estilo do esboço: borda externa azul escura, borda interna azul/roxo, fundo semi-transparente
local BORDER_OUTER_COLOR = '#1e3a5f'
local BORDER_INNER_COLOR = '#3d5a80'
local BACKGROUND_COLOR = '#2a2a4acc'  -- azul/roxo com alpha
local TITLE_COLOR = '#ffffff'
local CONTENT_COLOR = '#e0e0ff'

local popupPanel       -- painel raiz (opacidade aplicada aqui)
local borderPanel      -- borda dupla (outer + inner)
local innerPanel       -- fundo do conteúdo
local titleLabel
local contentLabel
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

-- Extrai título (primeira linha) e corpo do texto do Look.
local function splitTitleAndContent(text)
  if not text or text:len() == 0 then return '', '' end
  local firstLine = text:match('^([^\r\n]+)') or text
  local rest = text:match('^[^\r\n]+\r?\n(.+)$') or ''
  return firstLine, rest
end

local function showPopup(text)
  if not popupPanel or not titleLabel or not contentLabel or not text or text:len() == 0 then return end
  local title, content = splitTitleAndContent(text)
  titleLabel:setText(title)
  titleLabel:setWidth(360)
  titleLabel:setHeight(0)
  titleLabel:resizeToText()
  contentLabel:setText(content)
  contentLabel:setWidth(360)
  contentLabel:setHeight(0)
  contentLabel:resizeToText()
  local tw, th = titleLabel:getWidth(), titleLabel:getHeight()
  local cw, ch = contentLabel:getWidth(), contentLabel:getHeight()
  local padH, padV = 14, 10
  local innerW = math.max(tw, cw) + padH
  local innerH = th + (ch > 0 and (4 + ch) or 0) + padV
  innerW = math.min(innerW, 400)
  innerH = math.min(innerH, 320)
  titleLabel:setPosition(10, 8)
  contentLabel:setPosition(10, th + 12)
  innerPanel:setWidth(innerW)
  innerPanel:setHeight(innerH)
  borderPanel:setWidth(innerW + 4)
  borderPanel:setHeight(innerH + 4)
  borderPanel:setPosition(2, 2)
  popupPanel:setWidth(innerW + 8)
  popupPanel:setHeight(innerH + 8)
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

  -- Painel raiz: opacidade 0–100% aplicada aqui
  popupPanel = g_ui.createWidget('Panel', rootWidget)
  popupPanel:setId('itemHoverPopup')
  popupPanel:setBackgroundColor('#00000000')
  popupPanel:setVisible(false)
  popupPanel:setPhantom(true)
  popupPanel:setFocusable(false)

  -- Borda externa (azul escuro), efeito de “moldura”
  borderPanel = g_ui.createWidget('Panel', popupPanel)
  borderPanel:setId('itemHoverBorder')
  borderPanel:setBackgroundColor(BORDER_OUTER_COLOR)
  borderPanel:setBorderWidth(2)
  borderPanel:setBorderColor(BORDER_INNER_COLOR)

  -- Área interna: fundo azul/roxo semi-transparente
  innerPanel = g_ui.createWidget('Panel', borderPanel)
  innerPanel:setId('itemHoverInner')
  innerPanel:setBackgroundColor(BACKGROUND_COLOR)
  innerPanel:setPosition(2, 2)

  -- Título do tooltip (primeira linha do Look)
  titleLabel = g_ui.createWidget('UILabel', innerPanel)
  titleLabel:setId('itemHoverTitle')
  titleLabel:setTextAlign(AlignLeft)
  titleLabel:setTextWrap(true)
  titleLabel:setFont('verdana-11')
  titleLabel:setColor(TITLE_COLOR)

  -- Conteúdo (restante do texto)
  contentLabel = g_ui.createWidget('UILabel', innerPanel)
  contentLabel:setId('itemHoverContent')
  contentLabel:setTextAlign(AlignLeft)
  contentLabel:setTextWrap(true)
  contentLabel:setFont('verdana-11')
  contentLabel:setColor(CONTENT_COLOR)
end

function terminate()
  cancelHover()
  unregisterMessageMode(MessageModes.Look, onLook)
  if popupPanel then
    popupPanel:destroy()
    popupPanel = nil
  end
  borderPanel = nil
  innerPanel = nil
  titleLabel = nil
  contentLabel = nil
end
