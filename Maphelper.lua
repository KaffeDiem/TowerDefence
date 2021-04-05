
-- A simple helper function to get the distance between two points
function Map:distPoints(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


function Map:addMob(mobtype)
  local mobType = mobType or Mob(self.mobSpawn, self.mobGoal, self.map, self.pos)
  table.insert(self.mobs, mobType)
end


-- Handles movement of the map such that you can 'move around'
function Map:translation(dt)
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


-- Handles chaning the height or type of tiles (mostly just for fun) //FIXME
function Map:changeTiles()
  if self.tileSelected ~= nil then -- Raise and lower tiles if it is not nil
    local timeNow = love.timer.getTime()
    -- CHANGE TILES
    if timeNow > self.timerTileChanged + self.timerTileChangedLast
    and self.tileSelectionMode == 'changetile' then

      local i, j = self.tileSelected[1], self.tileSelected[2]

      -- Increase tile quad if left is pressed and decrease if right is pressed
      if love.mouse.isDown(1) then
        self.map[i][j] = self.map[i][j] + 1


        if self.map[i][j] > 40 then self.map[i][j] = 1 end

        -- Update mobs paths
        for _, m in ipairs(self.mobs) do
          m:updatePath(self.map)
        end

        self.timerTileChangedLast = timeNow
      else if love.mouse.isDown(2) then
        self.map[i][j] = self.map[i][j] - 1

        if self.map[i][j] < 1 then self.map[i][j] = 40 end

        -- Update mobs paths
        for _, m in ipairs(self.mobs) do
          m:updatePath(self.map)
        end

        self.timerTileChangedLast = timeNow
      end
    end
  end
    -- RAISE AND LOWER TILES
    -- if love.mouse.isDown(1) and -- If mouse is pressed raise the selected tile
    -- love.timer.getTime() >
    -- self.timerTileHeight + self.timerTileHeightLast and
    -- self.tileSelectionMode == 'height' then
    --   self.mapheight[self.tileSelected[1]][self.tileSelected[2]] =
    --     self.mapheight[self.tileSelected[1]][self.tileSelected[2]] + 1
    --   self.timerTileHeightLast = love.timer.getTime()

    -- elseif love.mouse.isDown(2) and -- If m2 is pressed lower the selected tile
    -- love.timer.getTime() > 
    -- self.timerTileHeight + self.timerTileHeightLast and 
    -- self.tileSelectionMode == 'height' then
    --   self.mapheight[self.tileSelected[1]][self.tileSelected[2]] =
    --     self.mapheight[self.tileSelected[1]][self.tileSelected[2]] - 1
    --   self.timerTileHeightLast = love.timer.getTime()
    -- end

    -- PLACE TOWERS
    -- if love.mouse.isDown(1) and
    -- love.timer.getTime() >
    -- self.timerTileHeight + self.timerTileHeightLast and
    -- self.tileSelectionMode == 'tower' then

    --   table.insert(self.towers, Tower(Vector(self.tileSelected[1], self.tileSelected[2]), self.map, Vector(self.x, self.y)))
    --   self.timerTileHeightLast = love.timer.getTime()

    --   local tfMap = Map.createPassableMap(self.map, self.passable)
    --   for _, e in ipairs(self.enemies) do
    --     e:updatePath(tfMap, self.mobGoal)
    --   end
    -- end
  end
end


-- Get the currently selected tile
function Map:getTileSelected()
  if #self.tilesHovered < 1 then -- If no tiles are hovered then none selected
    self.tileSelected = nil
  end

  local minDist = nil
  for i = 1, #self.tilesHovered do

    local distTileCursor = self:distPoints(
      self.tmx, self.tmy,
      self.tilesHovered[i][3] + (self.tileWidth*SCALE/2),
      self.tilesHovered[i][4] + (self.tileHeight*SCALE/2)
    )

    if minDist == nil then -- Set first tile to current one
      minDist = distTileCursor
      self.tileSelected = self.tilesHovered[i]
    elseif distTileCursor < minDist then
      minDist = distTileCursor
      self.tileSelected = self.tilesHovered[i] -- This tile is closer to cursor
    end
  end
end

