-- Importing modules
Class = require "modules.classic"
suit = require "modules.suit"

-- Import A* algorithm
require "modules.luafinding.vector"
require "modules.luafinding.heap"
require "modules.luafinding.luafinding"
require "modules.timer"

-- Import other entities
require "Map"
require "entities.Mob"
require "entities.Tower"
require "entities.Dragon"
require "entities.Skeleton"
require "entities.Bullet"
require "entities.Main_menu"
require "entities.Game_over"
require "entities.Game_won"
require "entities.waves"
require "entities.Notification"

-- Keep images pixelated as they are scaled in size
love.graphics.setDefaultFilter('nearest')


function love.load()
  ----------------------------------------
  -- SOME CONFIGURATION WHICH IS GLOBAL --
  ----------------------------------------
  keyboardOnly = true
  debug = true -- Runs a debugging server as well and renders different things
  SCALE = 2 -- 32x32 is scaled up to 64x64
  MOBILE = false
  GAMESTATE = "menu"
  WALKABLE = {6, 11, 14, 15, 16, 17, 18, 19}
  WAVEAMOUNT = 4 -- Amount of waves per level
  DIFFICULTY = "easy"

  -- Detect if the user is a mobile or a desktop user
  if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    MOBILE = true
  end
  -- Some mobile configuration which hides the status bar
  if MOBILE then love.window.setFullscreen(true) end
  -- Debugging with lovebird if debug is enabled.
  if debug then
    print("__Visit http://127.0.0.1:8000 for debugging__")
  end

  -- Setting the global background color
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1, 1)
  iflash_small = love.graphics.newFont("fonts/iflash.ttf", 10, "none")
  iflash_big = love.graphics.newFont("fonts/iflash.ttf", 18, "none")
  love.graphics.setFont(iflash_big)


  ---------------------------------------------
  -- SETTING UP INITAL MAPS AND SCREENS    ----
  ---------------------------------------------
  PLAYERSCORE = 0
  PLAYERHEALTH = 5

  MENU = Main_menu()
  GAMEOVER = Game_over()
  GAMEWON = Game_won()

  -- Generate a random map, spawn point and so on
  local randommap = Map.createRandomMap(nil, nil, WALKABLE)
  -- Creation of the map object
  MAP = Map(randommap[1], randommap[2], randommap[3], randommap[4])
  if DIFFICULTY == "easy" then
    MAP:generateMobs(WAVES.easy)
  end

end



function love.update(dt)
  if GAMESTATE == 'menu' then
    MENU:update(dt)
  elseif GAMESTATE == 'running' then
    MAP:update(dt) -- Update the map object
  elseif GAMESTATE == 'gameover' then
    GAMEOVER:update(dt)
  elseif GAMESTATE == 'gamewon' then
    GAMEWON:update(dt)
  end

  -- Update lovebird if debugging is enabled.
  if debug then
    require("lovebird").update()
  end
end


function love.draw()
  -------------------------------------
  -- DRAWING OF ACTUAL GAME ENTITIES --
  -------------------------------------
  if GAMESTATE == 'menu' then
    MENU:draw()
    -- MAP:draw()
  elseif GAMESTATE == 'gameover' then
    GAMEOVER:draw()
  elseif GAMESTATE == 'gamewon' then
    GAMEWON:draw()
  elseif GAMESTATE == 'running' then
    MENU:draw()
    MAP:draw()
    -----------------------------------------------------------
    --DEBUGGING INFORMATION PRINTED OUT ON TOP OF THE SCREEN --
    -- ONLY WHEN MAP IS RUNNING                              --
    -----------------------------------------------------------
    if debug then
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
    end

  else love.graphics.print("If you see this the gamestate is invalid")
  end
end


function love.keypressed(key)
  if GAMESTATE == "running" then
    if key == 'm' and debug then
      MAP:sendNotification(3, "test")
    end
    if key == 'a' and debug then
      MAP:addMob(1)
    end
    if key == 'escape' then
      GAMESTATE = "menu"
    end
  end

  if debug then
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
end


function love.touchmoved( id, x, y, dx, dy, pressure )
  if MOBILE and GAMESTATE == "running" then
    MAP:touchControls(dx, dy)
  end
end
