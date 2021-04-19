
-- A simple helper function to get the distance between two points
function Map:distPoints(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


function Map:addTower(towerType, mapPlaceHolder)
  local newTowerPos = Vector(self.tileSelected[1], self.tileSelected[2])

  -- Check if tower has already been placed at set location
  local towerPlacedAlready = false
  for _, tower in ipairs(self.towers) do
    if tower.pos == newTowerPos then
      towerPlacedAlready = true
    end
  end

  -- If no towers have been placed at that location yet, then add a tower
  if not towerPlacedAlready then
    local towerType = towerType or -- TowerType is what kind of tower should go
      Tower(newTowerPos, self.map, self.pos)

    table.insert(self.towers, towerType)
    self.map[newTowerPos.x][newTowerPos.y] = mapPlaceHolder
  end
end


-- Take a table of tables as input with mobs, see waves.lua file for more info
-- Could be eg. the 'easy' table.
function Map:generateMobs(t)
  math.randomseed(os.time())

  for i = 1, WAVEAMOUNT do
    local randWave = math.random(#t)
    local wave = t[randWave] -- The random wave which is to be added.

    for j = 1, #wave do -- Run trough the tables of t
      table.insert(self.waves, wave[j])
    end
    table.insert(self.waves, -1)
  end
end


-- Type is an integer, 0 means no mob and 1 is the default mob
function Map:addMob(type)
  if type == 1 then
    local Mob = Mob(self.mobSpawn, self.mobGoal, self.map, self.pos)
    table.insert(self.mobs, Mob)
  end
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
        local towerPos = Vector(self.tileSelected[1], self.tileSelected[2])
        local currentTile = self.map[towerPos.x][towerPos.y]
        local placeholder = 29 
        self.map[towerPos.x][towerPos.y] = placeholder
        if Map.checkValidPlacement(self) then
          self:addTower(nil, placeholder)
          self:updateMobPaths()
        else
          MAP:sendNotification(1, "Cannot block mobs paths")
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


-- Create a random map of size rows, cols
function Map.createRandomMap(rows, cols, walkable)
  math.randomseed(os.time())
  ::retry::

  local map = {}
  local height = {}

  local rows = rows or math.random(20, 30)
  local cols = cols or math.random(7, 15)

  -- //TODO make sure that the spawn is at a real tile
  local spawn = Vector(1,    math.random(rows))
  local goal  = Vector(rows, math.random(cols))

  local walkable = walkable or {6, 16}

  -- These are all the different levels
  local levels = {
    {1, 6, 6, 6, 6, 6, 14, 0, 0}, -- Sand, wood and empty space
    {16, 16, 16, 16, 4, 0}, -- Lava, stone and empty space
    {6, 6, 6, 6, 6, 6, 6, 31, 32, 33, 34, 0}, -- Woods
    {1, 2, 15, 15, 15, 15, 0} -- Ice and snow
  }

  local randomLevel = math.random(#levels)
  local variance = levels[randomLevel]

  for i = 1, rows do
    table.insert(map, {})
    table.insert(height, {})
    -- This is the loop in which tile are decided
    for j = 1, cols do

      table.insert(map[i], variance[math.random(#variance)])


      table.insert(height[i], 0)

    end
  end

  -- Create the true/false map
  local tf = {}
  for i = 1, #map do
    tf[i] = {}
    for j = 1, #map[i] do
      local canWalk = false
      for _, v in ipairs(walkable) do
        if v == map[i][j] then
          canWalk = true
        end
      end
      table.insert(tf[i], canWalk)
    end
  end

  if Luafinding.FindPath(spawn, goal, tf) == nil then
    goto retry
  end

  return {map, height, spawn, goal}

end


function Map:sendNotification(time, message)
  table.insert(self.notifications, Notification(time, message))
end