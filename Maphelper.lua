
-- A simple helper function to get the distance between two points
function Map:distPoints(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


function Map:addTower(towerType)
  local towerPos = Vector(self.tileSelected[1], self.tileSelected[2])
  local towerType = towerType or
    Tower(towerPos, self.map, self.pos)
  table.insert(self.towers, towerType)
  self.map[towerPos.x][towerPos.y] = 16
end


function Map:addMob(mobtype)
  local mobType = mobType or
    Mob(self.mobSpawn, self.mobGoal, self.map, self.pos)
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


-- Create a walkable TF map for pathfinding
function Map:createwalkableMap()
  local tfMap = {}
  for i = 1, #self.map do
    tfMap[i] = {}
    for j = 1, #self.map[i] do
      local canWalk = false
      for _, v in ipairs(self.walkable) do
        if v == self.map[i][j] then
          canWalk = true
        end
      end
      table.insert(tfMap[i], canWalk)
    end
  end
  self.tfMap = tfMap
end


function Map.checkValidPlacement(mapObj)
  mapObj:createwalkableMap()
  local path = Luafinding.FindPath(mapObj.mobSpawn, mapObj.mobGoal, mapObj.tfMap)

  if path then return true end
  return false
end


-- Update mobs paths
function Map:updateMobPaths()
  for _, m in ipairs(self.mobs) do
  m:updatePath(self.map)
  end
end


function Map:changeTiles()
  if self.tileSelected ~= nil then -- Raise and lower tiles if it is not nil
    local timeNow = love.timer.getTime()
    if timeNow > self.timerTileChanged + self.timerTileChangedLast then

      -- CHANGE TILE FEATURE --

      if self.tileSelectionMode == 'changetile' then
        local i, j = self.tileSelected[1], self.tileSelected[2]

        if love.mouse.isDown(1) then
          self.map[i][j] = self.map[i][j] + 1
          if self.map[i][j] > 40 then self.map[i][j] = 1 end
          self:updateMobPaths() -- Update paths if tile is changed
          self.timerTileChangedLast = timeNow

        else if love.mouse.isDown(2) then
          self.map[i][j] = self.map[i][j] - 1
          if self.map[i][j] < 1 then self.map[i][j] = 40 end
          self:updateMobPaths() -- Update paths if tile is changed
          self.timerTileChangedLast = timeNow
        end
      end
      end

      -- ADD TOWERS FEATURE --

      if self.tileSelectionMode == 'tower' and love.mouse.isDown(1) then
        print('Tower placement')
        local towerPos = Vector(self.tileSelected[1], self.tileSelected[2])
        local currentTile = self.map[towerPos.x][towerPos.y]
        self.map[towerPos.x][towerPos.y] = 16
        if Map.checkValidPlacement(self) then
          self:addTower()
          self:updateMobPaths()
        else
          self.map[towerPos.x][towerPos.y] = currentTile
        end
        self.timerTileChangedLast = timeNow
      end
    end
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

