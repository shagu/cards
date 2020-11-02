-- set default game size
GWIDTH, GHEIGHT = 3840, 2160
local drag = {}

local cards = {
  [1] = { -- Land: Swamp Island
    type = "Land", cost = 0, phase = true, name = "Mountain Isle",
    picture = "1.png", artist = "Albert Bierstadt", bgpic = "bg.png",
    function(player, target)
      player.mana = player.mana + 1
    end
  },

  [2] = { -- Spell: Shock!
    type = "Spell", cost = 3, phase = nil, name = "Shock",
    picture = "2.png", artist = "Unknown", bgpic = "bg.png",
    text = "Deals 2 Damage to an enemy player or creature.",
    function(player, target)
      target.life = target.life - 2
    end
  },
}

local pool = {}
local deck = {}
local uuid = 0
local desk = {}
local function addCardToDesk(id, x, y)
  local newCard = { x = x or 100, y = y or 100, width = 240, height = 400, size = 1, id = id or 1, uuid = uuid }
  table.insert(desk, newCard)
  uuid = uuid + 1
end

local function drawCard(id, x, y, size)
  local size = size or 1
  local card = cards[id]

  -- load fonts
  ttf_title  = love.graphics.newFont(18*size)
  ttf_type   = love.graphics.newFont(16*size)
  ttf_artist = love.graphics.newFont(10*size)

  if not card.graphicbg then
    card.graphicbg = love.graphics.newImage("img/" .. (card.bgpic or "bg.png"))
  end

  if not card.graphic and card.picture then
    card.graphic = love.graphics.newImage("img/" .. card.picture)
  end

  if not card.shadow then
    card.shadow = love.graphics.newImage("img/shadow.png")
  end

  if not card.areaicon and card.type == "Land" then
    card.areaicon = love.graphics.newImage("img/tap.png")
  end

  if card.shadow then
    love.graphics.setColor(1,1,1,1)
    local xscale = 360*size/card.shadow:getWidth()
    local yscale = 580*size/card.shadow:getHeight()
    love.graphics.draw(card.shadow, x-60, y-80, 0,xscale, yscale)
  end

  if card.graphicbg then
    love.graphics.setColor(1,1,1,1)
    local xscale = 240*size/card.graphicbg:getWidth()
    local yscale = 400*size/card.graphicbg:getHeight()
    love.graphics.draw(card.graphicbg, x, y, 0,xscale, yscale)
  end

  if card.graphic then
    local xscale = 220*size/card.graphic:getWidth()
    local yscale = 160*size/card.graphic:getHeight()
    love.graphics.draw(card.graphic,x+10*size,y+40*size,0,xscale, yscale)
  end

  -- set line width to real pixel size
  love.graphics.setLineWidth(1*scale)

  -- title
  love.graphics.setColor(0,0,0,.3)
  love.graphics.rectangle("fill", x + 5*size, y + 5*size, 230*size, 30*size)
  love.graphics.setColor(1,1,1,.1)
  love.graphics.rectangle("line", x + 5*size, y + 5*size, 230*size, 30*size)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setFont(ttf_title)
  love.graphics.print(card.name, x + 12*size, y + 10*size)

  -- type
  love.graphics.setColor(0,0,0,.3)
  love.graphics.rectangle("fill", x + 5*size, y + 205*size, 230*size, 25*size)
  love.graphics.setColor(1,1,1,.1)
  love.graphics.rectangle("line", x + 5*size, y + 205*size, 230*size, 25*size)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setFont(ttf_type)
  love.graphics.print(card.type, x + 12*size, y + 208*size)

  -- area
  love.graphics.setColor(0,0,0,.2)
  love.graphics.rectangle("fill", x + 10*size, y + 235*size, 220*size, 135*size)
  love.graphics.setColor(1,1,1,.1)
  love.graphics.rectangle("line", x + 10*size, y + 235*size, 220*size, 135*size)
  love.graphics.setColor(1,1,1,.8)
  love.graphics.setFont(ttf_artist)

  -- area icon
  if card.areaicon then
    love.graphics.setColor(1,1,1,.2)
    local xscale = 80*size/card.areaicon:getWidth()
    local yscale = 80*size/card.areaicon:getHeight()
    love.graphics.draw(card.areaicon,x+80*size,y+260*size,0,xscale, yscale)
  end

  -- artist
  if card.artist then
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Artist: " .. card.artist, x + 10*size, y + 380*size)
  end
end

function love.load()
  -- set default window size
  love.window.setMode(GWIDTH, GHEIGHT, {resizable = true})

  -- draw desk
  quad = love.graphics.newQuad(0,0,GWIDTH,GHEIGHT,256,256)
	background = love.graphics.newImage("img/desk.png")
	background:setWrap("repeat","repeat")

  -- give 20 cards of all available
  for id, data in pairs(cards) do
    pool[id] = 20
  end

  -- put all cards in pool into deck
  for id, count in pairs(pool) do
    for i=1, count do
      table.insert(deck, id)
    end
  end

  -- add dummy cards
  addCardToDesk(1, 100, 100)
  addCardToDesk(1, 400, 100)
  addCardToDesk(2, 100, 600)
end

function love.update()
  -- update card dragging
  if drag.offx and drag.offy and drag.uuid then
    for k, v in pairs(desk) do
      if v.uuid == drag.uuid then
        local x, y = (love.mouse.getX()-xtranslate)/scale, (love.mouse.getY()-ytranslate)/scale
        v.x = x + drag.offx
        v.y = y + drag.offy
        break
      end
    end
  end
end

function love.mousepressed(x, y, button)
  local x, y = (x-xtranslate)/scale, (y-ytranslate)/scale

  local active, offx, offy = nil, 0, 0
  for order, card in pairs(desk) do
    if x > card.x and x < card.x + card.width and
       y > card.y and y < card.y + card.height
    then
      active = card.uuid
      offx = card.x - x
      offy = card.y - y
    end
  end

  if active then
    local olddesk = desk

    drag.uuid = active
    drag.offx = offx
    drag.offy = offy

    -- rearrange desk z-layers
    desk = {}

    -- add all old cards in same order
    for id, card in pairs(olddesk) do
      if card.uuid ~= drag.uuid then
        table.insert(desk, card)
      end
    end

    -- place current drag at the top
    for id, card in pairs(olddesk) do
      if card.uuid == drag.uuid then
        table.insert(desk, card)
      end
    end
  end
end

function love.mousereleased(x, y, button)
  drag.uuid = nil
end

function love.draw()
  do -- scale/transform window
    winw, winh = love.graphics.getWidth(), love.graphics.getHeight()
    gratio, wratio = GWIDTH/GHEIGHT, winw/winh
    scale = gratio < wratio and winh/GHEIGHT or winw/GWIDTH
    xtranslate = gratio < wratio and winw/2 - scale*GWIDTH/2 or 0
    ytranslate = gratio > wratio and winh/2 - scale*GHEIGHT/2 or 0
    love.graphics.translate(xtranslate, ytranslate)
    love.graphics.scale(scale, scale)
  end

  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(background,quad,0,0)

  -- draw all regular cards
  for order, card in pairs(desk) do
    drawCard(card.id, card.x, card.y, card.size)
  end
end
