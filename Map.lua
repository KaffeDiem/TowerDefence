Map = Class:extend()


-- (tilesheetpath: string) Path to the tilesheet
-- (map: table) An NxN table containing numbers representing 
-- images in the tilesheet
-- (mapheight: table) An NxN table containing numbers representing
-- the relative height of images
-- (tilew and tileH: integers) The width and height of the tiles
function Map:new(tilesheetpath, map, mapheight, tileW, tileH)
  assert(#map == #mapheight,
    "Creating a new map: Map and MapHeight table should be same dimension"
  )

  self.tiles = {}
  self.tilesheet = love.graphics.newImage(tilesheetpath)
  self.tileWidth = tileW -- Pixels wide
  self.tileHeight = tileH -- Pixels tall
  self.imageWidth = self.tilesheet:getWidth()
  self.imageHeight = self.tilesheet:getHeight()
  self.imageSelector = love.graphics.newImage("images/tile_selector.png")

  SCALE = 2

  self.x = love.graphics.getWidth() / 2 - (self.tileWidth / 2) * SCALE
  self.y = love.graphics.getHeight() * 0.2
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

  self.timerTileHeight = 0.2 -- Increase height every 0.2 sec
  self.timerTileHeightLast = love.timer.getTime()

  -- Add quads to a table
  for j = 0, self.imageHeight - 1, self.tileHeight do
    for i = 0, self.imageWidth - 1, self.tileWidth do
      table.insert(
        self.tiles, love.graphics.newQuad(
          i, j, self.tileWidth, self.tileHeight,
          self.imageWidth, self.imageHeight
      ))
    end
  end

  -- ALL THINGS RELATED TO ENEMIES --
  self.enemySpawn = Vector(1, 1)
  self.enemyGoal = Vector(1, 3)
  self.enemies = {}

  table.insert(self.enemies, Dragon(self.enemySpawn, self.enemyGoal))
end


function Map:update(dt)

  self:mapMovement(dt) -- Movement and translation layer of the map
  -- Mouse coords as in game coords (translated mouse x, y)
  self.tmx, self.tmy = self.mx - self.tx, self.my - self.ty

  self:getTileSelected() -- Get selected tile when mouse is hovering
  self:changeTiles() -- Change height and type of tiles

  for _, v in ipairs(self.enemies) do
    v:update(self.x, self.y, dt)
  end
end


function Map:draw()
	love.graphics.translate(self.tx, self.ty)
  love.graphics.scale(self.sx, self.sy)

  -- Drawing the map as isometric tiles
  self.tilesHovered = {} -- Reset the tilesHovered table every frame
  for i = 1, #self.map do -- Loop trough rows
    for j = 1, #self.map[i] do -- Loop through cols in the rows
      if self.map[i][j] ~= 0 then -- If there is a tile to draw

        local x =
          self.x + -- Starting point
          (j * ((self.tileWidth / 2) * SCALE)) - -- The width on rows
          (i * ((self.tileWidth / 2) * SCALE)) -- The width on cols
        local y =
          self.y +
          (i * ((self.tileHeight / 4) * SCALE)) + -- The height on rows
          (j * ((self.tileHeight / 4) * SCALE)) -- The width on cols
        -- Take the height map into account
        local y = y - self.mapheight[i][j] * 8
        -- Draw the tiles
        love.graphics.draw(self.tilesheet, self.tiles[self.map[i][j]],
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

  for _, enemy in ipairs(self.enemies) do
    enemy:draw()
  end

end

-- A simple helper function to get the distance between two points
function Map:getDistanceBetweenPoints(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


-- Handles movement of the map such that you can 'move around'
function Map:mapMovement(dt)
  self.mx, self.my = love.mouse.getPosition()
  if (self.my < love.graphics.getHeight() * 0.1 and not keyboardOnly) or
  love.keyboard.isDown('up') then
    self.ty = self.ty + (self.screenMovementSpeed * dt)
  end
  if (self.my > love.graphics.getHeight() * 0.9 and not keyboardOnly) or
  love.keyboard.isDown('down') then
    self.ty = self.ty - (self.screenMovementSpeed * dt)
  end
  if (self.mx < love.graphics.getWidth() * 0.1 and not keyboardOnly) or
  love.keyboard.isDown('left') then
    self.tx = self.tx + (self.screenMovementSpeed * dt)
  end
  if (self.mx > love.graphics.getWidth() * 0.9 and not keyboardOnly) or
  love.keyboard.isDown('right') then
    self.tx = self.tx - (self.screenMovementSpeed * dt)
  end
  -- TODO: make sure that the mouse position gets scaled as well
  if love.keyboard.isDown('-') then
    self.sx = self.sx - (0.1 * dt)
    self.sy = self.sy - (0.1 * dt)
  end
  if love.keyboard.isDown('+') then
    self.sx = self.sx + (0.1 * dt)
    self.sy = self.sy + (0.1 * dt)
  end
end


-- Handles chaning the height or type of tiles (mostly just for fun)
function Map:changeTiles()
  if self.tileSelected ~= nil then -- Raise and lower tiles if it is not nil
    if love.mouse.isDown(1) and -- If mouse is pressed raise the selected tile
    love.timer.getTime() >
    self.timerTileHeight + self.timerTileHeightLast and
    self.tileSelectionMode == 'height' then
      self.mapheight[self.tileSelected[1]][self.tileSelected[2]] =
        self.mapheight[self.tileSelected[1]][self.tileSelected[2]] + 1
      self.timerTileHeightLast = love.timer.getTime()

    elseif love.mouse.isDown(2) and -- If m2 is pressed lower the selected tile
    love.timer.getTime() > 
    self.timerTileHeight + self.timerTileHeightLast and 
    self.tileSelectionMode == 'height' then
      self.mapheight[self.tileSelected[1]][self.tileSelected[2]] =
        self.mapheight[self.tileSelected[1]][self.tileSelected[2]] - 1
      self.timerTileHeightLast = love.timer.getTime()
    end

    if love.mouse.isDown(1) and
    love.timer.getTime() >
    self.timerTileHeight + self.timerTileHeightLast and
    self.tileSelectionMode == 'changetile' then
      if self.map[self.tileSelected[1]][self.tileSelected[2]] < 40 then
        self.map[self.tileSelected[1]][self.tileSelected[2]] =
          self.map[self.tileSelected[1]][self.tileSelected[2]] + 1
      else
        self.map[self.tileSelected[1]][self.tileSelected[2]] =
          1
      end
      self.timerTileHeightLast = love.timer.getTime()
    end

    if love.mouse.isDown(2) and
    love.timer.getTime() >
    self.timerTileHeight + self.timerTileHeightLast and
    self.tileSelectionMode == 'changetile' then
      if self.map[self.tileSelected[1]][self.tileSelected[2]] < 2 then
        self.map[self.tileSelected[1]][self.tileSelected[2]] = 40
      else
        self.map[self.tileSelected[1]][self.tileSelected[2]] =
          self.map[self.tileSelected[1]][self.tileSelected[2]] - 1
      end
      self.timerTileHeightLast = love.timer.getTime()
    end
  end
end


-- Get the currently hovered tile
function Map:getTileSelected()
  if #self.tilesHovered < 1 then -- If no tiles are hovered then none selected
    self.tileSelected = nil
  end

  local minDistanceFromTileToCursor = nil
  for i = 1, #self.tilesHovered do
    local distanceToTileFromCursor = self:getDistanceBetweenPoints(
      self.tmx, self.tmy,
      self.tilesHovered[i][3] + (self.tileWidth*SCALE/2),
      self.tilesHovered[i][4] + (self.tileHeight*SCALE/2)
    )

    if minDistanceFromTileToCursor == nil then -- Set first tile to current one
      minDistanceFromTileToCursor = distanceToTileFromCursor
      self.tileSelected = self.tilesHovered[i]
    elseif distanceToTileFromCursor < minDistanceFromTileToCursor then
      minDistanceFromTileToCursor = distanceToTileFromCursor
      self.tileSelected = self.tilesHovered[i] -- This tile is closer to cursor
    end
  end
end