-- Importing modules
Class = require "modules.classic"

-- Import A* algorithm
require "modules/luafinding/vector"
require "modules/luafinding/heap"
require "modules/luafinding/luafinding"
require "modules/timer"

-- Import other entities
require "Map"
require "entities/Mob"
require "entities/Tower"
require "entities/Dragon"
require "entities/Skeleton"

-- Keep images pixelated as the are scaled in size
love.graphics.setDefaultFilter('nearest')


function love.load()

  love.graphics.setBackgroundColor(0.2, 0.2, 0.2, 1)

  lvl1 = {
    {6, 6, 6, 6, 6, 6},
    {6, 6, 6, 6, 6, 6},
    {6, 1, 6, 1, 6, 6},
    {6, 6, 6, 6, 6, 6},
    {6, 1, 6, 1, 6, 6},
    {6, 6, 6, 6, 6, 6},
    {6, 6, 6, 6, 6, 6},
    {6, 6, 6, 6, 6, 6},
    {6, 1, 1, 1, 6, 6},
    {6, 1, 1, 1, 6, 6},
    {6, 1, 1, 1, 6, 6},
    {6, 6, 6, 6, 6, 6},
  }


  lvl1_height = {
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0},
  }

  keyboardOnly = true
  debug = true
  SCALE = 2

  local spawn   = Vector(1, 1)
  local goal    = Vector(12, 6)

  local randommap = Map.createRandomMap()

  MAP = Map(randommap[1], randommap[2], randommap[3], randommap[4])

  if debug then
    print("__Visit http://127.0.0.1:8000 for debugging__")
  end
end



function love.update(dt)
  MAP:update(dt)

  -- Print debugging info to a browser
  if debug then
    require("lovebird").update()
  end
end


function love.draw()
  love.graphics.setFont(
    love.graphics.newFont("fonts/fira.ttf", 10)
  )

  love.graphics.print(
    "FPS: " .. love.timer.getFPS(), 10, 10
  )
  local tileSelected = "None"

  if MAP.tileSelected  then
    tileSelected = MAP.tileSelected[1] .. " x " .. MAP.tileSelected[2]
  end
  love.graphics.print(
    "TILE: " .. tileSelected,
    10, 25
  )
  love.graphics.print(
    "MODE: " .. MAP.tileSelectionMode,
    10, 40
  )

  MAP:draw()
end


function love.keypressed(key)

  if key == 'a' then
    MAP:addMob()
  end

  if key == 't' then
    MAP:addTower()
  end

  if key == 'space' then
    if MAP.tileSelectionMode == 'changetile' then
      MAP.tileSelectionMode = 'tower'
    else MAP.tileSelectionMode = 'changetile'
    end
  end

  if key == 'r' then
    love.load()
  end
end
