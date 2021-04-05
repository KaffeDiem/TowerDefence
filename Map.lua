Map = Class:extend()
require "Maphelper"

function Map:new(map, mapheight, mobSpawn, mobGoal)
  assert(#map == #mapheight,
    "Creating a new map: Map and MapHeight table should be same dimension"
  )

  self.quads = {}
  self.tilesheet = love.graphics.newImage("images/tilesheet.png")
  self.tileWidth = 32 -- Pixels wide
  self.tileHeight = 32-- Pixels tall
  self.imageWidth = self.tilesheet:getWidth()
  self.imageHeight = self.tilesheet:getHeight()
  self.imageSelector = love.graphics.newImage("images/tileselector.png")

  SCALE = 2

  local x = love.graphics.getWidth() / 2 - (self.tileWidth / 2) * SCALE
  local y = love.graphics.getHeight() * 0.2
  self.pos = Vector(x, y) -- The position which the map is being drawn from

  -- Initialization of the mouse and translation layer
  self.tx = 0
  self.ty = 0
  self.sx = 1
  self.sy = 1
  self.screenMovementSpeed = 300 -- movement speed when navigating game

  self.map = map -- the map table
  self.mapheight = mapheight -- the height table

  self.tilesHovered = {} -- Table containing all tiles hovered (inside hitbox)
  self.tileSelected = nil -- if tile is selected then {i, j, pixel x, pixel h}
  self.tileSelectionMode = 'changetile' -- Change height or tile

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
end


function Map:update(dt)
  self.tilesHovered = {} -- Reset the tilesHovered table every frame

  self:translation(dt) -- Movement and translation layer of the map
  -- Mouse coords as in game coords (translated mouse x, y)
  self.tmx, self.tmy = self.mx - self.tx, self.my - self.ty

  self:changeTiles() -- Change height and type of tiles

  if self.mobs ~= nil then -- If the table is not empty then update the mobs
    for _, mob in ipairs(self.mobs) do
      mob:update(dt)
    end
  end

  if self.towers ~= nil then
    for _, tower in ipairs(self.towers) do
      tower:update(dt)
    end
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
end
