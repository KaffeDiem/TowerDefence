Dragon = Class:extend()


function Dragon:new(source, target, worldX, worldY, worldMap, passable)

  self.tileWidth = 32
  self.tileHeight = 32
  self.worldX = worldX
  self.worldY = worldY

  self.map = {}
  for i = 1, #worldMap do
    self.map[i] = {}
    for j = 1, #worldMap[i] do

      local foundPassable = false
      for _, v in ipairs(passable) do
        if v == worldMap[i][j] then
          foundPassable = true
        end
      end
      table.insert(self.map[i], foundPassable)
    end
  end
  -- self.map = {
  --   {true, true, true},
  --   {false, false, true},
  --   {true, true, true},
  --   {true, false, false},
  --   {true, true, true},
  -- }

  self.image = love.graphics.newImage('images/placeholder.png')
  self.start = source
  self.goal = target

  self.path = Luafinding.FindPath(self.start, self.goal, self.map)
  assert(self.path ~= nil, "Enemy could not find valid path")
  self.currPos = table.remove(self.path, 1)
  self.nextPos = table.remove(self.path, 1)

  self.startPixelPos = Vector(
    worldX + -- Starting point
    (self.currPos.y * ((self.tileWidth / 2) * SCALE)) - -- The width on rows
    (self.currPos.x * ((self.tileWidth / 2) * SCALE)), -- The width on cols
    worldY +
    (self.currPos.x * ((self.tileHeight / 4) * SCALE)) + -- The height on rows
    (self.currPos.y * ((self.tileHeight / 4) * SCALE)) -- The width on cols
  )
  self.currPixelPos = Vector(
    worldX + -- Starting point
    (self.currPos.y * ((self.tileWidth / 2) * SCALE)) - -- The width on rows
    (self.currPos.x * ((self.tileWidth / 2) * SCALE)), -- The width on cols
    worldY +
    (self.currPos.x * ((self.tileHeight / 4) * SCALE)) + -- The height on rows
    (self.currPos.y * ((self.tileHeight / 4) * SCALE)) -- The width on cols
  )
  self.nextPixelPos = Vector(
    worldX +
    (self.nextPos.y * ((self.tileWidth / 2) * SCALE)) -
    (self.nextPos.x * ((self.tileWidth / 2) * SCALE)),
    worldY +
    (self.nextPos.x * ((self.tileHeight / 4) * SCALE)) +
    (self.nextPos.y * ((self.tileHeight / 4) * SCALE))
  )
  self.distance = Dist(self.currPixelPos, self.nextPixelPos)
  self.direction = (self.nextPixelPos - self.currPixelPos) / self.distance
  -- self.distance = 0
  -- self.direction = Vector()
  self.moving = true

  -- For debugging
  self:printPath()
end


function Dragon:update(dt)
  -- If the entity should be moving
  if self.moving then
    -- Take care of the movement
    self.currPixelPos = self.currPixelPos + self.direction * dt * 100
    if Dist(self.startPixelPos, self.currPixelPos) > self.distance then
      if #self.path > 0 then
        self:calculateNewPath()
      else
        self.moving = false
      end
    end
  end
end


function Dragon:calculateNewPath()
  self.currPos = self.nextPos
  self.nextPos = table.remove(self.path, 1)

  self.startPixelPos = Vector(
    self.worldX + -- Starting point
    (self.currPos.y * ((self.tileWidth / 2) * SCALE)) - -- The width on rows
    (self.currPos.x * ((self.tileWidth / 2) * SCALE)), -- The width on cols
    self.worldY +
    (self.currPos.x * ((self.tileHeight / 4) * SCALE)) + -- The height on rows
    (self.currPos.y * ((self.tileHeight / 4) * SCALE)) -- The width on cols
  )

  self.currPixelPos = Vector(
    self.worldX + -- Starting point
    (self.currPos.y * ((self.tileWidth / 2) * SCALE)) - -- The width on rows
    (self.currPos.x * ((self.tileWidth / 2) * SCALE)), -- The width on cols
    self.worldY +
    (self.currPos.x * ((self.tileHeight / 4) * SCALE)) + -- The height on rows
    (self.currPos.y * ((self.tileHeight / 4) * SCALE)) -- The width on cols
  )

  if #self.path < 1 then
  else
    self.nextPixelPos = Vector(
      self.worldX +
      (self.nextPos.y * ((self.tileWidth / 2) * SCALE)) -
      (self.nextPos.x * ((self.tileWidth / 2) * SCALE)),
      self.worldY +
      (self.nextPos.x * ((self.tileHeight / 4) * SCALE)) +
      (self.nextPos.y * ((self.tileHeight / 4) * SCALE))
    )
    self.distance = Dist(self.currPixelPos, self.nextPixelPos)
    self.direction = (self.nextPixelPos - self.currPixelPos) / self.distance
  end
end


function Dist(start, goal)
  return math.sqrt((goal.x - start.x)^2 + (goal.y - start.y)^2)
end


function Dragon:draw()

  -- Draw the placeholder image
  love.graphics.draw(
    self.image, self.currPixelPos.x, self.currPixelPos.y, 0, SCALE, SCALE
  )

end




function Dragon:printPath()
  io.write("__Remaing path__\n")
  print("Current and next position:")
  print(self.currPos, self.nextPos)
  print("Remaning:")
  for _, vec in ipairs(self.path) do
    print(vec)
  end
  print("________________")
end