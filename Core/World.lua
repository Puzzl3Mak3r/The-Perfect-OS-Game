----------------------------------------------------------------------------------
-- World
----------------------------------------------------------------------------------

-- Important
local cx = display.contentCenterX
local cy = display.contentCenterY
local screenX = display.contentWidth
local screenY = display.contentHeight
local mouseX, mouseY = 0,0
local pressedKeys = {}
local camera = display.newGroup(); camera.x, camera.y = 0, 0-- Center the camera on the player
local offsetX, offsetY = 0, 0
local playing = true
local blocksize = 71
local selectedRoom = "leftdown"
local selectedSpawn = "leftdown_UpLeft"



----------------------------------------------------------------------------------
-- Spawn points
----------------------------------------------------------------------------------

-- mapName_spawnOfMap
local spawnPointX = {
    main = 750,
    main_Left = 70,
    main_Right = 1490,
    right_Left = 140,
    right_Right= 1270,
    right_Up = 675,
    rightdown_Down = 400,
    rightdown_DownLeft = 150,
    rightdown_Left = 140,
    rightdown_Right = 570,
    rightdowndown_Left = 140,
    middle1_Right = 785,
    middle1_Left = 140,
    middle1_Up = 785,
    middle1_DownLeft = 140,
    middle1_DownRight = 780,
    middle2_DownLeft = 140,
    middle2_UpRight = 785,
    middle2_UpLeft = 140,
    middle2_DownRight = 785,
    leftdown_UpLeft = 225,
}
local spawnPointY = {
    main = -70,
    main_Left = -70,
    main_Right = -70,
    right_Left = -630,
    right_Right = -630,
    right_Up = -890,
    rightdown_Down = -80,
    rightdown_DownLeft = -480,
    rightdown_Left = -890,
    rightdown_Right = -1360,
    rightdowndown_Left = -1730,
    middle1_Right = -140,
    middle1_Left = -230,
    middle1_Up = -980,
    middle1_DownLeft = -180,
    middle1_DownRight = -130,
    middle2_DownLeft = -120,
    middle2_UpRight = -700,
    middle2_UpLeft = -990,
    middle2_DownRight = -230,
    leftdown_UpLeft = -1080
}



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
    local scene = require(sceneOptions[math.random(#sceneOptions)])
    local scene = require(sceneOptions[2])
    scene.Start()
end



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



----------------------------------------------------------------------------------
-- Environment
----------------------------------------------------------------------------------

-- Change Gravity
physics.setGravity( 0, 60 )

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
    -- print("Result: "..result)
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

-- Make map from import
local map = ""
local function createMap(mapSelected)
    mapData = io.open( system.pathForFile( mapSelected, system.ResourceDirectory ), "r" )
    if mapData then
        map = parse_csv_to_array(mapData:read("*a"))
    end
    io.close( mapData )
    print ("Map created")

    for i = 1, #map do
        for j = 1, #map[i] do
            if map[i][j] == "3" then
                local block = display.newRect(blocksize * (j - 1), - blocksize * (i - 1), blocksize, blocksize)
                block.fill = {1, 0, 1}
                block.type = "worldBlock"
                block.isFixedRotation = true
                physics.addBody(block, "static", { bounce = 0 })
                camera:insert(block)
            end
            if map[i][j] == "0" then
                local block = display.newRect(blocksize * (j - 1), - blocksize * (i - 1), blocksize, blocksize)
                block.fill = {0, 0, 1}
                block.type = "doorBlock"
                block.isFixedRotation = true
                physics.addBody(block, "static", { bounce = 0 })
                camera:insert(block)
            end
        end
    end
end

-- Adjust Spawn
player.x = spawnPointX[selectedSpawn]
player.y = spawnPointY[selectedSpawn]
createMap("Map/"..selectedRoom..".csv")
physics.setDrawMode( "hybrid" )



-----------------------------------------------------------------------------------
-- Virtual Camera
-----------------------------------------------------------------------------------

-- Move camera
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
-- Function calling
----------------------------------------------------------------------------------

local World = {}

function World.Start()
end

return World

