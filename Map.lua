Map = Class:extend()
require "Maphelper"

function Map:new(map, mapheight, mobSpawn, mobGoal)
  assert(#map == #mapheight,
    "Creating a new map: Map and MapHeight table should be same dimension"
  )

  self.tilesheet = love.graphics.newImage("images/tilesheet.png")
  self.quads = {}
  self.tileWidth = 32 -- Pixels wide
  self.tileHeight = 32-- Pixels tall
  self.imageWidth = self.tilesheet:getWidth()
  self.imageHeight = self.tilesheet:getHeight()
  self.imageSelector = love.graphics.newImage("images/tileselector.png")
  self.background = love.graphics.newImage("images/background.png")
  self.walkable = WALKABLE

  local x = love.graphics.getWidth() / 2 - (self.tileWidth / 2) * SCALE
  local y = love.graphics.getHeight() * 0.2
  self.pos = Vector(x, y) -- The position which the map is being drawn from

  -- Initialization of the mouse and translation layer
  self.tmx = 0
  self.tmy = 0
  self.tx = 0
  self.ty = 0
  self.sx = 1
  self.sy = 1
  self.screenMovementSpeed = 300 -- movement speed when navigating game

  self.map = map -- the map table
  self.mapheight = mapheight -- the height table

  self.tilesHovered = {} -- Table containing all tiles hovered (inside hitbox)
  self.tileSelected = nil -- if tile is selected then {i, j, pixel x, pixel h}
  self.tileSelectionMode = 'tower' -- Change height or tile

  self.timerTileChanged = 0.2 -- Increase height every 0.2 sec
  self.timerTileChangedLast = love.timer.getTime()

  -- Load tiles from tilesheet to self.quads
  for j = 0, self.imageHeight - 1, self.tileHeight do
    for i = 0, self.imageWidth - 1, self.tileWidth do
      table.insert(
        self.quads,
        love.graphics.newQuad(
          i, j, self.tileWidth, self.tileHeight,
          self.imageWidth, self.imageHeight
      ))
    end
  end

  -- ALL THINGS RELATED TO ENEMIES AND TOWERS --
  self.mobSpawn = mobSpawn
  self.mobGoal = mobGoal


  self.towers = {}
  self.mobs = {}

  self.playerHealth = 5
  self.playerGold = 10
  self.playerScore = 0

  -- ALL THINGS RELATED TO LOADING THE PRINCESS -- 👸
  self.princessTimer = Timer(0.5)
  self.princessCounter = 1
  self.princessQuads = {}
  self.princessSheet = love.graphics.newImage("images/princess.png")
  self.princessPos = Tower.posToPixel(
    self.mobGoal, Vector(32, 32), self.pos
  )
  -- Load princess images
  for i = 0, self.princessSheet:getWidth() - 1, 32 do
    table.insert(
      self.princessQuads,
      love.graphics.newQuad(
        i, 0, self.tileWidth, self.tileHeight,
        self.princessSheet:getWidth(), self.princessSheet:getHeight()
    ))
  end

  -- Loading the hearth images
  self.hearthQuads = {}
  self.hearthImage = love.graphics.newImage("images/hearths.png")
  for i = 0, self.hearthImage:getWidth() - 1, 64 do
    table.insert(
      self.hearthQuads,
      love.graphics.newQuad(
      i, 0, 64, 64, self.hearthImage:getWidth(), self.hearthImage:getHeight()  
      )
    )
  end

  -- Loading the gold images
  self.goldQuads = {}
  self.goldImage = love.graphics.newImage("images/gold.png")
  self.goldCounter = 1
  self.goldTimer = Timer(0.1)
  for i = 0, 160-1, 16 do
    table.insert(
      self.goldQuads,
      love.graphics.newQuad(
      i, 0, 16, 16, self.goldImage:getWidth(), self.goldImage:getHeight()
      )
    )
  end
  print(#self.goldQuads)

  self.waves = {}
  self.mobTimer = Timer(1)
  self.currMob = -1
end


function Map:update(dt)
  self.mobTimer:update() -- Add mobs if the timer has run out
  self.goldTimer:update()

  -- Wavesystem implementation
  if self.mobTimer:hasFinished() then
    if self.waves then
      if self.currMob == -1 then
        if #self.mobs < 1 then
          self.currMob = table.remove(self.waves)
        end
      else
        self:addMob(self.currMob)
        self.currMob = table.remove(self.waves)
        self.playerScore = self.playerScore + 1
        self.mobTimer:reset()
      end
    end
    if #self.waves < 1 and #self.mobs < 1 then
      GAMESTATE = "gamewon"
    end
  end

  PLAYERSCORE = self.playerScore

  if self.goldTimer:hasFinished() then
    self.goldCounter = self.goldCounter + 1
    if self.goldCounter > #self.goldQuads then
      self.goldCounter = 1
    end
    self.goldTimer:reset()
  end

  self.tilesHovered = {} -- Reset the tilesHovered table every frame

  self:translation(dt) -- Movement and translation layer of the map
  -- Mouse coords as in game coords (translated mouse x, y)
  self.tmx, self.tmy = self.mx - self.tx, self.my - self.ty

  self:changeTiles() -- Change height and type of tiles

  if self.mobs ~= nil then -- If the table is not empty then update the mobs
    for k, mob in ipairs(self.mobs) do
      mob:update(dt)

      -- Remove the mob if it has died
      if mob.hasDied then
        table.remove(self.mobs, k)
      end

      if mob.hasReachedEnd then -- If a mob reached the end
        table.remove(self.mobs, k)
        if self.playerHealth > 0 then
          self.playerHealth = self.playerHealth - 1
        end
      end

    end
  end

  if self.towers ~= nil then
    for _, tower in ipairs(self.towers) do
      tower:update(dt)
    end
  end

  -- Check if towers should shoot for mobs
  for _, tower in ipairs(self.towers) do
    for _, mob in ipairs(self.mobs) do
      if Vector.dist(tower.posPixel, mob.currPixelPos) < tower.range * SCALE then
        tower:shoot(mob)
      end
    end
  end

  self.princessTimer:update()
  if self.princessTimer:hasFinished() then
    if self.princessCounter > #self.princessQuads -1 then
      self.princessCounter = 1
    else self.princessCounter = self.princessCounter + 1
    end
    self.princessTimer:reset()
  end

  if self.playerHealth < 1 then
    GAMESTATE = "gameover"
  end
end


function Map:draw()
	love.graphics.translate(self.tx, self.ty)
  love.graphics.scale(self.sx, self.sy)

  -- Drawing the map as isometric tiles
  for i = 1, #self.map do -- Loop trough rows
    for j = 1, #self.map[i] do -- Loop through cols in the rows
      if self.map[i][j] ~= 0 then -- If there is a tile to draw

        local x =
          self.pos.x + -- Starting point
          (j * ((self.tileWidth / 2) * SCALE)) - -- The width on rows
          (i * ((self.tileWidth / 2) * SCALE)) -- The width on cols
        local y =
          self.pos.y +
          (i * ((self.tileHeight / 4) * SCALE)) + -- The height on rows
          (j * ((self.tileHeight / 4) * SCALE)) -- The width on cols
        -- Take the height map into account
        local y = y - self.mapheight[i][j] * 16
        -- Draw the tiles
        love.graphics.draw(self.tilesheet, self.quads[self.map[i][j]],
          x, y,
          0,
          SCALE,
          SCALE
        )

        if self.tmx > x and -- Hitbox between mouse and tile
        self.tmx < x + self.tileWidth * SCALE and
        self.tmy > y + self.tileHeight / 2 and
        self.tmy < y + self.tileHeight * SCALE then
          -- Add the tile to tiles hovered, if mouse is on top of it
          table.insert(self.tilesHovered, {i, j, x, y})
        end

      end
    end
  end

  -- Draw the tile selector if one is selected
  if self.tileSelected ~= nil then
    love.graphics.draw(self.imageSelector,
      self.tileSelected[3], self.tileSelected[4],
      0, SCALE, SCALE)
  end

  -- Update mobs and towers
  if self.mobs ~= nil then
    for _, mob in ipairs(self.mobs) do
      mob:draw()
    end
  end

  if self.towers ~= nil then
    for _, tower in ipairs(self.towers) do
      tower:draw()
    end
  end

  self:getTileSelected() -- Get selected tile when mouse is hovering

  -- Draw the princess
  love.graphics.draw(self.princessSheet, self.princessQuads[self.princessCounter],
    self.princessPos.x, self.princessPos.y - 10 * SCALE, 0, SCALE, SCALE
  )
  -- Draw the hearths representing hp
  love.graphics.draw(self.hearthImage, self.hearthQuads[6-self.playerHealth],
    self.princessPos.x - 18 * SCALE,
    self.princessPos.y - 25 * SCALE, 0, SCALE, SCALE
  )

	love.graphics.translate(-self.tx, -self.ty)
  -- Draw a rectangle below the coin and amount
  -- love.graphics.rectangle("fill",
  --   love.graphics:getWidth()*0.9, love.graphics:getHeight()*0.05,
  --   love.graphics:getWidth()*0.95 - love.graphics:getWidth()*0.90, 20
  -- )
  -- Draw the gold coin
  love.graphics.setFont(iflash_big)
  love.graphics.draw(self.goldImage, self.goldQuads[self.goldCounter],
    love.graphics:getWidth()*0.9, love.graphics:getHeight()*0.05, 0, SCALE, SCALE
  )
  love.graphics.print(self.playerGold,
    love.graphics:getWidth()*0.95, love.graphics:getHeight()*0.06)
end


function Map:touchControls(dx, dy)
  self.tx = self.tx + dx
  self.ty = self.ty + dy
end