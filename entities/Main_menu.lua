Main_menu = Class:extend()
local lg = love.graphics -- Shorthand for love.graphics


function Main_menu:new()
  self.background = lg.newImage("images/background.png")
end

function Main_menu:update(dt)
  lg.setFont(iflash_big)
  local buttonSize = 100 * SCALE

  suit.layout:reset(lg:getWidth()/2 - buttonSize / 2, lg:getHeight()*0.2,
    10 * SCALE, 10 * SCALE
  )

  -- Put a button on the screen. If hit, show a message
  local start = suit.Button("Start", suit.layout:row(buttonSize, 30))

  -- Buttons only shown on desktop
  if not MOBILE then
    local quit = suit.Button("Exit", suit.layout:row(buttonSize, 30))

    if quit.hit then
      love.event.quit('quit')
    end
  end

  if start.hit then
    GAMESTATE = "running"
  end
end


function Main_menu:draw()
  lg.draw(self.background, 0, 0, 0,
    lg:getWidth() / self.background:getWidth(),
    lg:getHeight() / self.background:getHeight()
  )

  suit:draw()
  lg.setFont(iflash_small)
  if GAMESTATE == "menu" then
    love.graphics.print("© Kasper Munch 2021", lg:getWidth()*0.02, lg:getHeight()*0.95)
  end
end
