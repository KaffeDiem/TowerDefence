Timer = Class:extend()


-- Create a new timer as Timer(secs) and make sure to update it
-- with the update function provided.
-- Then you can test if TIMER:hasFinished() then ...
-- and choose to reset the timer or not afterwards.
function Timer:new(stayAliveFor)
  self.created = os.time()
  self.alive = 0
  self.stayAliveFor = stayAliveFor
  self.hasRunOut = false
end


function Timer:update()
  local now = os.time()

  self.alive = now - self.created

  if self.alive > self.stayAliveFor then
    self.hasRunOut = true
  end
end


function Timer:reset()
  self.created = os.time()
  self.hasRunOut = false
end


function Timer:hasFinished()
  return self.hasRunOut
end
