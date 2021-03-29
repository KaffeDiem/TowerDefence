
local map = {
  {1, 3, 1},
  {1, 3, 1},
  {1, 3, 1},
}

local startCoord = {
  x = 3, y = 2
}

local endCoord = {
  x = 1, y = 2
}


function printMap(map)
  for i = 1, #map do
    for j = 1, #map[i] do
      io.write(map[i][j])
      io.write('\t')
    end
    io.write('\n')
  end
end


function tableHasKey(table,key)
  return table[key] ~= nil
end


function findPath(map, startCoord, endCoord)

  local posToCheck = {
    {-1, 0}, -- Check up
    {1, 0}, -- Check down 
    {0, 1}, -- Check right 
    {0, -1}, -- Check left
  }

  local unvisited = map
  for i = 1, #unvisited do
    for j = 1, #unvisited[i] do
      if i == startCoord.x and j == startCoord.y then -- If position is start
        unvisited[i][j] = 0
      else
        unvisited[i][j] = -1 -- -1 for not visited
      end
    end
  end

  printMap(unvisited)

  local currNode = startCoord
  local neighbors = {}

  for ii = 1, #neighbors do
    for i = 1, #posToCheck do
      if tableHasKey(
        unvisited,
        currNode.x + posToCheck[i][1]
      ) then
        if unvisited[currNode.x + posToCheck[i][1]][currNode.y + posToCheck[i][2]] == -1 then
          unvisited[currNode.x + posToCheck[i][1]][currNode.y + posToCheck[i][2]] = 1
        else
        unvisited[currNode.x + posToCheck[i][1]][currNode.y + posToCheck[i][2]] =
          unvisited[currNode.x + posToCheck[i][1]][currNode.y + posToCheck[i][2]] + 1
        
        end
        print("table had key")
      else print("table did not have key")
      end
    end
  end




  return unvisited
end


local path = findPath(map, startCoord, endCoord)

printMap(path)