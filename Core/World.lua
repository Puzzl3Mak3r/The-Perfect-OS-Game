----------------------------------------------------------------------------------
-- World
----------------------------------------------------------------------------------

-- Important
local cx = display.contentCenterX
local cy = display.contentCenterY
local pressedKeys = {}
local camera = display.newGroup(); camera.x, camera.y = 0, 0-- Center the camera on the player
local playing = true
local glitchiness = 15
local blocksize = 71
local selectedRoom = "main"
local selectedDoor = ""
local selectedSpawn = selectedRoom..selectedDoor
local minigameBackground = display.newImageRect("Images/window.png", 1134, 756); minigameBackground.x, minigameBackground.y = cx, cy; minigameBackground.alpha = 0
-- physics.setDrawMode( "hybrid" )



----------------------------------------------------------------------------------
-- Spawn points
----------------------------------------------------------------------------------

-- mapName_spawnOfMap
local spawnPointX = {
    main = 750,
    main_Left = 140,
    main_Right = 1420,
    right_Left = 140,
    right_Right= 1270,
    right_Down = 780,
    rightdown_Up = 300,
    rightdown_UpLeft = 140,
    rightdown_DownLeft = 140,
    rightdown_DownRight = 570,
    rightdowndown_Left = 140,
    rightright = 140,
    middle1_UpRight = 785,
    middle1_DownLeft = 140,
    middle1_DownRight = 780,
    middle2_DownLeft = 140,
    middle2_UpRight = 785,
    middle2_UpLeft = 140,
    middle2_DownRight = 785,
    leftdown_UpLeft = 225,
    leftdown_UpRight = 1585,
    leftdown_DownRight = 1635,
    left_DownLeft = 565,
    left_DownRight = 1705,
    left_UpRight = 2205,
}
local spawnPointY = {
    main = -192,
    main_Left = -142,
    main_Right = -142,
    right_Left = -330,
    right_Right = -330,
    right_Down = -70,
    rightdown_Up = -1410,
    rightdown_UpLeft = -990,
    rightdown_DownLeft = -550,
    rightdown_DownRight = -110,
    rightdowndown_Left = -1730,
    rightright = -140,
    middle1_UpRight = -980,
    middle1_DownLeft = -180,
    middle1_DownRight = -130,
    middle2_DownLeft = -120,
    middle2_UpRight = -700,
    middle2_UpLeft = -990,
    middle2_DownRight = -230,
    leftdown_UpLeft = -990,
    leftdown_UpRight = -990,
    leftdown_DownRight = -90,
    left_DownLeft = -70,
    left_DownRight = -70,
    left_UpRight = -210
}



----------------------------------------------------------------------------------
-- Player
----------------------------------------------------------------------------------

-- Player setup
local player = display.newRect( spawnPointX.main, spawnPointY.main, 60, 60 )
physics.addBody(player, "dynamic", { bounce = 0 })
player.isFixedRotation = true
camera:insert(player)

-- player.fill.effect = "filter.custom.crt"

-- -- Ground (for testing)
-- local floor = display.newRect(cx, screenY - 30, 2000, 60)
-- physics.addBody(floor, "static", { bounce = 0 })

-- Movement variables
local speed = 400
local jumpForce = -690
local canJump = false



-----------------------------------------------------------------------------------
-- Freeze Game
-----------------------------------------------------------------------------------

-- Freeze
local cachePVX, cachePVY = player:getLinearVelocity()
local function freezeGame(option)
    if option == "freeze" then
        cachePVX, cachePVY = player:getLinearVelocity()
        player:setLinearVelocity( 0, 0 )
        physics.setGravity( 0, 0 )
        playing = false
    elseif option == "unfreeze" then
        player:setLinearVelocity(cachePVX, cachePVY)
        physics.setGravity( 0, 60 )
        playing = true
    end
end



----------------------------------------------------------------------------------
-- MiniGames
----------------------------------------------------------------------------------

-- List of minigames
local sceneOptions = {
    "Tasks.sortItems",
    "Tasks.fallingCookies",
    "Tasks.fileFinder",
    "Tasks.typeIt",
    "Tasks.binaryMatch",
    "Tasks.sliderCalibrate",
    "Tasks.pixelRepair",
    "Tasks.memorySequence"
}

-- Entering minigame
local function enterMiniGame()
    -- Make background visible
    minigameBackground.alpha = 1
    minigameBackground:toFront()

    -- Load minigame
    -- local scene = require(sceneOptions[math.random(#sceneOptions)])
    local scene = require(sceneOptions[2])
    scene.Start()

    local function waitForYeild()
        if scene.yeild == true then
            scene.Yield()
            scene = nil
            freezeGame("unfreeze")
            Runtime:removeEventListener("enterFrame", waitForYeild)
        end
    end
    Runtime:addEventListener("enterFrame", waitForYeild)
end

-- timer.performWithDelay( 5000, function() freezeGame("freeze"); enterMiniGame() end )



-- --------------------------------------------------------------------------------
-- CSV compiler
-- --------------------------------------------------------------------------------

-- Convert commas to ¤
local function replace_commas_with_forex(text)
    local result = ""
    local in_string = false
    for i = 1, #text do
        local char = text:sub(i, i)
        if char == '"' then
            in_string = not in_string
        elseif char == ',' and in_string then
            char = '¤'
        end
        result = result .. char
    end
    return result
end

-- Parse the CSV
local function parse_csv_to_array(oldCsv)
    -- The 2D array
    local csv = replace_commas_with_forex(oldCsv)
    local array = {}
    for line in csv:gmatch("[^\r\n]+") do
        -- The 1D array inside the 2D array
        local row = {}
        for cell in line:gmatch("[^,]+") do
            table.insert(row, cell)
        end
        table.insert(array, row)
    end
    return array
end



----------------------------------------------------------------------------------
-- Environment / Map
----------------------------------------------------------------------------------

-- Change Gravity
physics.setGravity( 0, 60 )

-- Make map from import
local map = ""
local function createMap(mapSelected)
    local mapData = io.open( system.pathForFile( mapSelected, system.ResourceDirectory ), "r" )
    if mapData then
        map = parse_csv_to_array(mapData:read("*a"))
    end
    io.close( mapData )
    print ("Map created")

    -- Create blocks, doors and bugs
    for i = 1, #map do
        for j = 1, #map[i] do
            if map[i][j] == "3" then
                -- Solid block
                local block = display.newImageRect("Images/blockSolid.png", blocksize, blocksize)
                block.x, block.y = blocksize * (j - 1), - blocksize * (i - 1)
                -- display.newImageRect(  filename, width, height )
                -- local block = display.newRect(blocksize * (j - 1), - blocksize * (i - 1), blocksize, blocksize)
                -- block.fill = {1, 0, 1}
                block.type = "worldBlock"
                block.isFixedRotation = true
                physics.addBody(block, "static", { bounce = 0 })
                camera:insert(block)
            end
            -- if map[i][j] == "0" then
            --     local block = display.newRect(blocksize * (j - 1), - blocksize * (i - 1), blocksize, blocksize)
            --     block.fill = {0, 0, 1}
            --     block.type = "doorBlock"
            --     block.isFixedRotation = true
            --     physics.addBody(block, "static", { bounce = 0 })
            --     camera:insert(block)
            -- end
            if map[i][j] == "L" or map[i][j] == "R" or map[i][j] == "U" or map[i][j] == "D" then
                -- Door
                local block = display.newImageRect("Images/blockDoor.png", blocksize/16, blocksize)
                block.x, block.y = blocksize * (j - 1), - blocksize * (i - 1)
                block.type = "doorBlock"
                block.isFixedRotation = true
                physics.addBody(block, "static", { bounce = 0 })
                camera:insert(block)

                -- Glow
                local blockGlow = display.newImageRect("Images/blockDoorGlow.png", blocksize/2, blocksize)
                blockGlow.x, blockGlow.y = blocksize * (j - 1), - blocksize * (i - 1)
                blockGlow.type = "doorGlow"
                camera:insert(blockGlow)

                -- Rotate
                if map[i][j] == "L" then
                    block.rotation = 0
                    block.x = block.x - blocksize/2 + blocksize/32
                    blockGlow.rotation = 0
                    blockGlow.x = blockGlow.x - blocksize/4
                end
                if map[i][j] == "R" then
                    block.rotation = 180
                    block.x = block.x + blocksize/2 - blocksize/32
                    blockGlow.rotation = 180
                    blockGlow.x = blockGlow.x + blocksize/4
                end
                if map[i][j] == "D" then
                    block.rotation = 270
                    block.y = block.y + blocksize/2 - blocksize/32
                    blockGlow.rotation = 270
                    blockGlow.y = blockGlow.y + blocksize/4
                end
                if map[i][j] == "U" then
                    block.rotation = 90
                    block.y = block.y - blocksize/2 + blocksize/32
                    blockGlow.rotation = 90
                    blockGlow.y = blockGlow.y - blocksize/4
                end
            end
        end
    end

    -- Set player spawn point
    player.x = spawnPointX[selectedSpawn]
    player.y = spawnPointY[selectedSpawn]
end

local function deleteMap()
    for i = camera.numChildren, 1, -1 do
        local obj = camera[i]
        if obj.type == "worldBlock" or obj.type == "doorBlock" or obj.type == "doorGlow" then
            display.remove(obj)
            obj = nil
        end
    end
end

createMap("Map/"..selectedRoom..".csv")


-----------------------------------------------------------------------------------
-- Connect Doors
-----------------------------------------------------------------------------------

-- Get door connections file
local doorConnectionFile = io.open( system.pathForFile( "Map/doorConnections.csv", system.ResourceDirectory ), "r" )
if doorConnectionFile then
    doorConnections = parse_csv_to_array(doorConnectionFile:read("*a"))
end
io.close( doorConnectionFile )

for i = 1, #doorConnections do
    for j = 1, #doorConnections[i] do 
        print(doorConnections[i][j],i,j)
    end
end

-- Search Door connection
for i = 1, #doorConnections do
    for j = 1, #doorConnections[i] do
    end
end






-----------------------------------------------------------------------------------
-- Virtual Camera
-----------------------------------------------------------------------------------

-- Move Camera
local diffX = 0
local diffY = 0
local function moveCamera()
    -- Center the camera on the player
    diffX = cx - player.x
    diffY = cy - player.y

    camera.x = diffX
    camera.y = diffY
end

Runtime:addEventListener("enterFrame", moveCamera)



----------------------------------------------------------------------------------
-- Platformer
----------------------------------------------------------------------------------

-- Movement logic
local function keyRunner()
    if playing then 
        local vx, vy = player:getLinearVelocity()

        -- Horizontal movement
        if pressedKeys["right"] or pressedKeys["d"] then
            player:setLinearVelocity(speed, vy)
        elseif pressedKeys["left"] or pressedKeys["a"] then
            player:setLinearVelocity(-speed, vy)
        else
            player:setLinearVelocity(0, vy)
        end

        -- Jumping (only when allowed)
        if (pressedKeys["space"] or pressedKeys["up"] or pressedKeys["w"]) and canJump then
            player:setLinearVelocity(vx, jumpForce)
            canJump = false
        end
    end
end

-- Detect collision (reset jump when on ground)
local function onCollision(event)
    if event.phase == "began" then
        canJump = true
    end
end
player:addEventListener("collision", onCollision)

-- Key event handler
local function onKeyEvent(event)
    if event.phase == "down" then
        pressedKeys[event.keyName] = true
    elseif event.phase == "up" then
        pressedKeys[event.keyName] = false
    end
end

-- Event listeners
Runtime:addEventListener("enterFrame", keyRunner)
Runtime:addEventListener("key", onKeyEvent)



----------------------------------------------------------------------------------
-- Glitchiness (Ramps up)
----------------------------------------------------------------------------------

local function glitch()
    if playing then
        local glitchChance = 21 - glitchiness
        if math.random( 1, glitchChance ) == 1 then
            -- if math.random( 1, 2 ) == 1 then
            --     -- Glitch with delay
            --     deleteMap()
            --     timer.performWithDelay( 700, function() createMap("Map/"..selectedRoom..".csv") end )
            -- else
                -- Glitch without delay
                deleteMap()
                createMap("Map/"..selectedRoom..".csv")
            -- end
        end
    end
end

timer.performWithDelay(1000, function() glitch() end, 0)



----------------------------------------------------------------------------------
-- Function calling
----------------------------------------------------------------------------------

local World = {}

function World.Start()
end

return World

