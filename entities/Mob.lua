Mob = Class:extend()


function Mob:new(spawn, target, worldMap, worldPos)
  self.dimensions = Vector( 32, 32) -- Default texture is 32x32
  self.passable = {6, 11} -- All mobs can walk on wood
  self.worldMap = worldMap
  self.worldPos = worldPos -- The position which the world starts rendering
  self.movSpeed = 50 -- Default movementSpeed of 50
  self.moving = true

  -- Use placeholder image if none is defined
  self.image = love.graphics.newImage('images/placeholder.png')

  -- The path which the mob is going to take as a list
  self.path = Mob.createPassableMap(self.worldMap, self.passable)
  self.path = Luafinding.FindPath(spawn, target, self.path)
  -- Check that the path is valid
  assert(self.path ~= nil, "Enemy could not find valid path")
  self.currPos = table.remove(self.path, 1) -- Get current position
  self.nextPos = table.remove(self.path, 1) -- Get next position

  self.spawnPixelPos = -- Position on pixel coordinates
    Mob.posToPixel(self.currPos, self.dimensions, self.worldPos)
  self.startPixelPos = self.spawnPixelPos
  self.currPixelPos = self.spawnPixelPos -- First pos is same as spawn
  self.nextPixelPos =
    Mob.posToPixel(self.nextPos, self.dimensions, self.worldPos)

  self.distNextPos = vectorDist(self.currPixelPos, self.nextPixelPos)
  self.direction = (self.nextPixelPos - self.currPixelPos) / self.distNextPos
end


-- Updates the position of the mob
function Mob:update(dt)
  -- If the entity should be moving
  if self.moving then
    -- Take care of the movement
    self.currPixelPos = self.currPixelPos + self.direction *  self.movSpeed * dt
    -- Check if we have reached our next position
    if vectorDist(self.startPixelPos, self.currPixelPos) > self.distNextPos then
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
  for _, vec in ipairs(self.path) do
    local pos = Mob.posToPixel(vec, self.dimensions, self.worldPos)
    love.graphics.circle('fill', pos.x + self.dimensions.x / 2 * SCALE,
      pos.y + self.dimensions.y / 2 * SCALE, 3
    )
  end
end


-- Calculates the new path a mob is supposed to go if it has reached its
-- goal but there are still new tiles to visit
-- current, next: Two vector coordinates on the map
-- Returns: an array of vector coordinates to visit as pixels
function Mob:calculateNewPath(current, next)
  self.currPos = self.nextPos
  self.nextPos = table.remove(self.path, 1)

  self.startPixelPos =
    Mob.posToPixel(self.currPos, self.dimensions, self.worldPos)

  if #self.path > 0 then
    self.nextPixelPos =
      Mob.posToPixel(self.nextPos, self.dimensions, self.worldPos)
    self.distNextPos = vectorDist(self.currPixelPos, self.nextPixelPos)
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


-- Takes a MxN size map and a list of objects which are passable as arguments
-- Is supposed to be used with pathfinding algorithm
-- Example:
-- worldMap = {{1, 1, 1,},{6, 6, 6,},{1, 1, 1,}}
-- passable = {6}
-- Return:
-- {{false, false, false}, {true, true, true}, {false, false, false}}
function Mob.createPassableMap(worldMap, passable)
  local passMap = {}
  for i = 1, #worldMap do
    passMap[i] = {}
    for j = 1, #worldMap[i] do
      local canWalk = false
      for _, v in ipairs(passable) do
        if v == worldMap[i][j] then
          canWalk = true
        end
      end
      table.insert(passMap[i], canWalk)
    end
  end
  return passMap
end