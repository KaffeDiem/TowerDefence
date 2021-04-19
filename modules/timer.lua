local lovebird = require "lovebird"
Timer = Class:extend()

-- Create a new timer as Timer(secs) and make sure to update it
-- with the update function provided.
-- Then you can test if TIMER:hasFinished() then ...
-- and choose to reset the timer or not afterwards.
function Timer:new(stayAliveFor)
  self.created = love.timer.getTime()
  self.alive = 0
  self.stayAliveFor = stayAliveFor
  self.hasRunOut = false
end


function Timer:update()
  local now = love.timer.getTime()

  self.alive = now - self.created

  if self.alive > self.stayAliveFor then
    self.hasRunOut = true
  end
end


function Timer:reset()
  self.created = love.timer.getTime()
  self.hasRunOut = false
end


function Timer:hasFinished()
  return self.hasRunOut
end
