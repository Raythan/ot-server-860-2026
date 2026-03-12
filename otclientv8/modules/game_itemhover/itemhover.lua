-- Item hover: ao parar o mouse em cima de um item (slot de equipamento ou container),
-- abre um tooltip com os detalhes do Look. Opacidade configurável em Opções (0%% a 100%%).
-- Look manual (Shift+clique) continua igual: Server Log + texto verde na tela.

local HOVER_DELAY_MS = 500
local LOOK_TIMEOUT_MS = 2000

-- Cores no estilo do esboço: borda externa azul escura, borda interna azul/roxo, fundo semi-transparente
local BORDER_OUTER_COLOR = '#1e3a5f'
local BORDER_INNER_COLOR = '#3d5a80'
local BACKGROUND_COLOR = '#2a2a4acc'  -- azul/roxo com alpha
local TEXT_COLOR = '#e0e0ff'

local popupPanel       -- painel raiz (opacidade aplicada aqui)
local borderPanel      -- borda dupla (outer + inner)
local innerPanel       -- fundo do conteúdo
local contentLabel     -- único label com todo o texto (evita sobreposição e perda de quebras de linha)
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

-- Normaliza quebras de linha (servidor pode enviar \r\n ou \r) e retorna o texto limpo.
local function normalizeLookText(text)
  if not text or text:len() == 0 then return '' end
  return text:gsub('\r\n', '\n'):gsub('\r', '\n')
end

-- Largura fixa do texto para quebra de linha consistente; padding ao redor do texto
local TOOLTIP_TEXT_WIDTH = 340
local TOOLTIP_PAD_H = 16
local TOOLTIP_PAD_V = 12
-- Altura inicial alta para o motor calcular corretamente a quebra de linha
local TOOLTIP_INIT_HEIGHT = 1200
-- Altura aproximada por linha (fallback se getTextSize retornar valor incorreto)
local APPROX_LINE_HEIGHT = 16

local function showPopup(text)
  if not popupPanel or not contentLabel or not text or text:len() == 0 then return end

  local normalized = normalizeLookText(text)

  -- Um único label: preserva todas as quebras de linha do servidor e evita erro de split
  contentLabel:setWidth(TOOLTIP_TEXT_WIDTH)
  contentLabel:setHeight(TOOLTIP_INIT_HEIGHT)
  contentLabel:setText(normalized)

  local textSize = contentLabel:getTextSize()
  local contentH = math.max(1, textSize.height or 1)
  -- Fallback: o motor pode retornar altura incorreta com setTextWrap; estimar por linhas explícitas e por quebra por largura
  local lineCount = 1
  for _ in normalized:gmatch('\n') do lineCount = lineCount + 1 end
  local charsPerLine = math.max(1, math.floor(TOOLTIP_TEXT_WIDTH / 7))  -- aprox. 7px por caractere verdana-11
  local wrappedLines = math.ceil(#normalized / charsPerLine)
  local estimatedLines = math.max(lineCount, wrappedLines)
  local minHeight = estimatedLines * APPROX_LINE_HEIGHT
  if contentH < minHeight then
    contentH = minHeight
  end

  contentLabel:setHeight(contentH)

  -- Tamanho do painel = conteúdo + padding (caixa se ajusta dinamicamente ao texto)
  local innerW = TOOLTIP_TEXT_WIDTH + (TOOLTIP_PAD_H * 2)
  local innerH = (TOOLTIP_PAD_V * 2) + contentH

  contentLabel:setPosition(topoint(TOOLTIP_PAD_H .. ' ' .. TOOLTIP_PAD_V))

  innerPanel:setWidth(innerW)
  innerPanel:setHeight(innerH)
  borderPanel:setWidth(innerW + 4)
  borderPanel:setHeight(innerH + 4)
  borderPanel:setPosition(topoint('2 2'))
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
  innerPanel:setPosition(topoint('2 2'))
  innerPanel:setClipping(true)

  -- Único label com todo o texto: quebra de linha correta, sem sobreposição, padding ao redor
  contentLabel = g_ui.createWidget('UILabel', innerPanel)
  contentLabel:setId('itemHoverContent')
  contentLabel:setTextAlign(AlignLeft)
  contentLabel:setTextWrap(true)
  contentLabel:setTextAutoResize(false)
  contentLabel:setFont('verdana-11')
  contentLabel:setColor(TEXT_COLOR)
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
  contentLabel = nil
end
