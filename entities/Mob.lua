Mob = Class:extend()


function Mob:new(spawn, goal, map, worldPos)
  self.dimensions = Vector( 32, 32 ) -- Default texture is 32x32
  -- self.passable = {6, 11} -- All mobs can walk on wood
  -- self.worldMap = worldMap
  self.worldPos = worldPos -- The position which the world starts rendering
  self.map = map
  self.spawn = spawn
  self.goal = goal
  self.passable = {6}

  self.movSpeed = 50 -- Default movementSpeed of 50

  -- Use placeholder image if none is defined
  self.image = love.graphics.newImage('images/placeholder.png')

  self:createPassableMap() -- Create the tfmap
  self.path = Luafinding.FindPath(self.spawn, self.goal, self.tfMap)

  if self.path then
    self.currPos = table.remove(self.path, 1) -- Get current position
    self.nextPos = table.remove(self.path, 1) -- Get next position
    self.moving = true
  else
    self.currPos = self.spawn
    self.nextPos = self.spawn
    self.moving = false
  end

  self.spawnPixelPos = -- Position on pixel coordinates
    Mob.posToPixel(self.currPos, self.dimensions, self.worldPos)
  self.startPixelPos = self.spawnPixelPos
  self.currPixelPos = self.spawnPixelPos -- First pos is same as spawn
  self.nextPixelPos =
    Mob.posToPixel(self.nextPos, self.dimensions, self.worldPos)

  self.distNextPos = Vector.dist(self.currPixelPos, self.nextPixelPos)

  self.direction = (self.nextPixelPos - self.currPixelPos) / self.distNextPos
end


-- Updates the position of the mob
function Mob:update(dt)
  -- If the entity should be moving
  if self.moving and self.path ~= nil then
    -- Take care of the movement
    self.currPixelPos = self.currPixelPos + self.direction *  self.movSpeed * dt
    -- Check if we have reached our next position
    if Vector.dist(self.startPixelPos, self.currPixelPos) > self.distNextPos then
      if #self.path > 0 then -- If there are still new tiles to visit
        -- If there are still moves to be made then calculate new path
        self:calculateNewPath()
      else
        -- Stop moving once we get to final tile
        self.moving = false
      end
    end
  end
end


-- Draw the mob, default is just a placeholder image and function should
-- be replaced in each mob
function Mob:draw()
  -- Draw the placeholder image
  love.graphics.draw(
    self.image, self.currPixelPos.x, self.currPixelPos.y, 0, SCALE, SCALE
  )
  -- Draw the path which the enemies will follow
  if self.path ~= nil and self.moving then
    for _, vec in ipairs(self.path) do
      local pos = Mob.posToPixel(vec, self.dimensions, self.worldPos)
      love.graphics.circle('fill', pos.x + self.dimensions.x / 2 * SCALE,
        pos.y + self.dimensions.y / 2 * SCALE, 3
      )
    end
  end
end


-- Calculate the new path from one tile to the next
-- current, next: Two vector coordinates on the map
-- Returns: an array of vector coordinates to visit as pixels
function Mob:calculateNewPath()
  self.currPos = self.nextPos
  self.nextPos = table.remove(self.path, 1)

  self.startPixelPos =
    Mob.posToPixel(self.currPos, self.dimensions, self.worldPos)

  if #self.path > 0 then
    self.nextPixelPos =
      Mob.posToPixel(self.nextPos, self.dimensions, self.worldPos)
    self.distNextPos = Vector.dist(self.currPixelPos, self.nextPixelPos)
    self.direction = (self.nextPixelPos - self.currPixelPos) / self.distNextPos
  end
end


-- Translates some Vector coordinate (1, 1) from the tile map
-- to a pixel coordinates for rendering to the screen.
-- Example: 
-- Pos = Vector(1,1)
-- tileW, tileH = 32
-- worldPos = Vector(200, 200)
-- Returns: Vector(300, 453)
function Mob.posToPixel(pos, dim, worldPos)
  return Vector(
    worldPos.x
    + ((pos.y * dim.x / 2) * SCALE)
    - ((pos.x * dim.x / 2) * SCALE)
    ,
    worldPos.y
    + ((pos.x * dim.y / 4) * SCALE)
    + ((pos.y * dim.y / 4) * SCALE)
  )
end


-- Create a passable map. This means a map that which enemies can walk on.
-- This is used for pathfinding.
-- A similar function is also used with mobs in the loading process.
-- Example:
-- worldMap = {{1, 1, 1,},{6, 6, 6,},{1, 1, 1,}}
-- passable = {6}
-- Return:
-- {{false, false, false}, {true, true, true}, {false, false, false}}
function Mob:createPassableMap()
  local tfMap = {}
  for i = 1, #self.map do
    tfMap[i] = {}
    for j = 1, #self.map[i] do
      local canWalk = false
      for _, v in ipairs(self.passable) do
        if v == self.map[i][j] then
          canWalk = true
        end
      end
      table.insert(tfMap[i], canWalk)
    end
  end
  self.tfMap = tfMap
end


-- Update the path of a mob, this is done when a tower is created or
-- when a tile is updated and there is a new true/false map to be considered.
function Mob:updatePath(newMap)

  -- If mob has not reached end
  if self.spawn ~= self.goal then
    self.map = newMap or self.map
    self:createPassableMap() -- Update the mobs true/false map

    self.path = nil
    -- Reset values before running the pathfinding algorithm
    self.currPos.g, self.currPos.h, self.currPos.f, self.currPos.previous =
      nil, nil, nil, nil
    local path = Luafinding.FindPath(self.currPos, self.goal, self.tfMap)

    if path then
      table.remove(path, 1)
      self.path = table.copy(path)
      self.moving = true

      if self.distNextPos == 0 then
        -- // TODO update
        -- self.currPos = table.remove(self.path, 1) -- Get current position
        self.nextPos = table.remove(self.path, 1) -- Get next position
        self.moving = true

        self.nextPixelPos =
          Mob.posToPixel(self.nextPos, self.dimensions, self.worldPos)
        self.distNextPos = Vector.dist(self.currPixelPos, self.nextPixelPos)
        self.direction =
          (self.nextPixelPos - self.currPixelPos) / self.distNextPos
      end
    end
  end
end



function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

