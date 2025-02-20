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
local blocksize = 60



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
local player = display.newRect( cx, cy, 60, 60 )
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
            -- print (map[i][j])
            if map[i][j] ~= "3" then
                local block = display.newRect(cx + blocksize * (j - 1), screenY - blocksize * (i - 1), blocksize, blocksize)
                block.fill = {1, 0, 1}
                block.isFixedRotation = true
                physics.addBody(block, "static", { bounce = 0 })
                camera:insert(block)
            end
        end
    end
end

createMap("Map/main.csv")
physics.setDrawMode( "hybrid" )



-----------------------------------------------------------------------------------
-- Virtual Camera
-----------------------------------------------------------------------------------

-- Move camera
local function moveCamera()
    -- Center the camera on the player
    camera.x = cx - player.x
    camera.y = cy - player.y
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

