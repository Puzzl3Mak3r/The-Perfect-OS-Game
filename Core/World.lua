----------------------------------------------------------------------------------
-- World
----------------------------------------------------------------------------------

-- Important
local cx = display.contentCenterX
local cy = display.contentCenterY
local pressedKeys = {}
local camera = display.newGroup(); camera.x, camera.y = 0, 0-- Center the camera on the player
local playing = true
local glitchiness = 0
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
    main_Right = 1470,
    right_Left = 175,
    right_Right= 1265,
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
    right_Left = -335,
    right_Right = -335,
    right_Down = -140,
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
    left_DownLeft = -140,
    left_DownRight = -140,
    left_UpRight = -210
}
-- Connections
local doorConnections1 = {
    "main", -- (1st entry)
    "right",
    "right",
    "rightdown",
    "rightdown",
    "rightdown",
    "middle2",
    "middle2",
    "middle1",
    "leftdown",
    "leftdown",
    "left"
}
local doorPrefixes1 = {
    "_Right", -- (1st entry)
    "_Right",
    "_Down",
    "_UpLeft",
    "_DownLeft",
    "_DownRight",
    "_UpLeft",
    "_DownLeft",
    "_DownLeft",
    "_UpRight",
    "_UpLeft",
    "_UpRight"
}
local doorConnections2 = {
    "right", -- (1st entry)
    "rightright",
    "rightdown",
    "middle2",
    "middle2",
    "rightdowndown",
    "middle1",
    "middle1",
    "leftdown",
    "left",
    "left",
    "main" -- (last entry)
}
local doorPrefixes2 = {
    "_Left", -- (1st entry)
    "",
    "_Up",
    "_UpRight",
    "_DownRight",
    "_Left",
    "_UpRight",
    "_DownRight",
    "_DownRight",
    "_DownRight",
    "_DownLeft",
    "_Left" -- (last entry)
}
-- Colours
local roomColours = {
    main = "blue",
    right = "pink",
    middle1 = "purple",
    middle2 = "orange",
    left = "green",
    leftdown = "biege",
    rightright = "red",
    rightdowndown = "grey",
    rightdown = "yellow"
}



----------------------------------------------------------------------------------
-- Player
----------------------------------------------------------------------------------

-- Player setup
local player = display.newRect( spawnPointX.main, spawnPointY.main, 60, 60 )
physics.addBody(player, "dynamic", { bounce = 0 })
player.isFixedRotation = true
camera:insert(player)

-- Movement variables
local speed = 500
local jumpForce = -690
local canJump = false



----------------------------------------------------------------------------------
-- Music
----------------------------------------------------------------------------------

local music = audio.loadStream( "Music/main.mp3" )
local musicMiniGame = audio.loadStream( "Music/playing.mp3" )
local musicBossFight = audio.loadStream( "Music/bossfight.mp3" )
local function playMusic(option)
    if option == "start" then
        audio.play(music, { channel=1, loops=-1 })
    elseif option == "pause" then
        -- Pause music and start musicMiniGame on a DIFFERENT channel
        audio.pause(1)
        audio.play(musicMiniGame, { channel=2, loops=-1 }) -- Using channel 2
    elseif option == "resume" then
        -- Resume main music and stop mini-game music
        audio.resume(1)
        audio.stop(2)  -- Stop channel 2
    elseif option == "stop" then
        audio.stop(1)
        audio.stop(2)  -- Stop both tracks just in case
    end
end

local function changeTrack(option)
    music = audio.loadStream( "Music/"..option..".mp3" )
    audio.play( music, { channel=1, loops=-1 } )
end

playMusic("start")



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
        scene = nil
        -- player:setLinearVelocity(cachePVX, cachePVY)
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
    "Tasks.typeIt",
    "Tasks.sliderCalibrate",
    "Tasks.memorySequence"
}

local scene
-- Entering minigame
local function enterMiniGame()
    -- Make background visible
    minigameBackground.alpha = 1
    minigameBackground:toFront()

    -- Load minigame
    -- local scene = require(sceneOptions[math.random(#sceneOptions)])
    scene = require(sceneOptions[1])
    scene.Start()
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

    -- Create blocks, doors and bugs
    for i = 1, #map do
        for j = 1, #map[i] do
            if map[i][j] == "3" then
                -- Solid block
                local block = display.newImageRect("Images/blockShades/"..roomColours[selectedRoom]..".png", blocksize, blocksize)
                block.x, block.y = blocksize * (j - 1), - blocksize * (i - 1)
                -- display.newImageRect(  filename, width, height )
                -- local block = display.newRect(blocksize * (j - 1), - blocksize * (i - 1), blocksize, blocksize)
                -- block.fill = {1, 0, 1}
                block.type = "worldBlock"
                block.isFixedRotation = true
                physics.addBody(block, "static", { bounce = 0 })
                camera:insert(block)
            end
            if map[i][j] == "0" then
                local block = display.newRect(blocksize * (j - 1), - blocksize * (i - 1), blocksize, blocksize)
                block.fill = {0, 0, 1}
                block.type = "enemy"
                block.typeEnemy = "idle"
                physics.addBody(block, "static", { bounce = 0 })
                block.isFixedRotation = true
                camera:insert(block)
            end
            if map[i][j] == "1" then
                local block = display.newRect(blocksize * (j - 1), - blocksize * (i - 1), blocksize, blocksize)
                block.fill = {0, 1, 1}
                block.type = "enemy"
                block.typeEnemy = "shoot"
                physics.addBody(block, "static", { bounce = 0 })
                block.isFixedRotation = true
                camera:insert(block)
            end
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
    timer.performWithDelay( 20, function()
        -- Set player spawn point
        player.x = spawnPointX[selectedSpawn]
        player.y = spawnPointY[selectedSpawn]
    end )

    parallaxBG = display.newImageRect("Images/backgrounds/"..roomColours[selectedRoom]..".png", 30 * blocksize, 30 * blocksize)
    parallaxBG.x, parallaxBG.y = cx, cy
end

local function deleteMap()
    for i = camera.numChildren, 1, -1 do
        local obj = camera[i]
        if obj.type == "worldBlock" or obj.type == "doorBlock" or obj.type == "doorGlow" or obj.type == "enemy" then
            display.remove(obj)
            obj = nil
        end
    end
end

createMap("Map/"..selectedRoom..".csv")



-----------------------------------------------------------------------------------
-- Wait to unfreeze
-----------------------------------------------------------------------------------

local function waitToUnfreeze()
    local unfreezeFile = io.open(system.pathForFile("lock.csv", system.DocumentsDirectory), "r")
    if unfreezeFile then
        timer.cancel("unfreezer")

        local unfreezeText = unfreezeFile:read("*a")  -- Read the content
        io.close(unfreezeFile)  -- Close after reading
        print("unfreezeText:", unfreezeText)

        if unfreezeText and unfreezeText:match("unlocked") then
            freezeGame("unfreeze")
            playMusic("resume")
            minigameBackground.alpha = 0
        end
    else
        print("Error: Could not open lock.csv! File may not exist or is locked.")
    end
end



-----------------------------------------------------------------------------------
-- Enemies
-----------------------------------------------------------------------------------

-- Delete enemy
function deleteEnemy( enemy )
    -- Delete Bug
    display.remove(enemy)
    enemy = nil
    print ("Enemy deleted")
    -- Freeze
    timer.performWithDelay( 1000, function()
        freezeGame("freeze")
    end )
    -- Other music track
    playMusic("pause")
    -- Wait to unfreeze
    timer.performWithDelay( 3000, function()
        timer.performWithDelay( 300, function() waitToUnfreeze() end, 0, "unfreezer" )
    end )
end

-- Enemy Detect touch
local function detectTouch(event)
    if event.phase == "began" then
        if event.other.type == "enemy" then
            playing = false
            enterMiniGame()
            timer.performWithDelay( 1, function() deleteEnemy(event.other) end )
            -- write in file
            local file = io.open( system.pathForFile( "lock.csv", system.DocumentsDirectory ), "w" )
            if file then
                file:write("lock")
                file:flush()
                -- io.close(file)
                print( "File write successful" )
            else
                print( "File write failed on line 506" )
            end
        end
    end
end

player:addEventListener( "collision", detectTouch )


-----------------------------------------------------------------------------------
-- Door Selection
-----------------------------------------------------------------------------------

local function selectDoor()
    if playing then
        -- Door from room
        if selectedRoom == "main" then
            if player.x > 600 then
                selectedDoor = "_Right"
            else
                selectedDoor = "_Left"
            end
        end
        if selectedRoom == "right" then
            if player.x < 200 then
                selectedDoor = "_Left"
            else
                if player.y < -250 then
                    selectedDoor = "_Right"
                else
                    selectedDoor = "_Down"
                end
            end
        end
        if selectedRoom == "rightright" then
            selectedDoor = ""
        end
        if selectedRoom == "rightdowndown" then
            selectedDoor = "_Left"
        end
        if selectedRoom == "rightdown" then
            if player.y < -1400 then
                selectedDoor = "_Up"
            end if player.y > -1000 then
                selectedDoor = "_UpLeft"
            end if player.y > -800 then
                selectedDoor = "_DownLeft"
            end if player.y > -300 then
                selectedDoor = "_DownRight"
            end
        end
        if selectedRoom == "middle2" then
            if player.y < -900 then
                selectedDoor = "_UpLeft"
            elseif player.y < -420 then
                selectedDoor = "_UpRight"
            elseif player.x > 400 then
                selectedDoor = "_DownRight"
            else
                selectedDoor = "_DownLeft"
            end
        end
        if selectedRoom == "middle1" then
            if player.y < -900 then
                selectedDoor = "_UpRight"
            elseif player.x < 600 then
                selectedDoor = "_DownLeft"
            else
                selectedDoor = "_DownRight"
            end
        end
        if selectedRoom == "leftdown" then
            if player.y > -600 then
                selectedDoor = "_DownRight"
            elseif player.x > 600 then
                selectedDoor = "_UpRight"
            else
                selectedDoor = "_UpLeft"
            end
        end
        if selectedRoom == "left" then
            if player.x > 2000 then
                selectedDoor = "_UpRight"
            else
                if player.x > 1000 then
                    selectedDoor = "_DownRight"
                else
                    selectedDoor = "_DownLeft"
                end
            end
        end
    end
end

Runtime:addEventListener("enterFrame", selectDoor)



-----------------------------------------------------------------------------------
-- Connect Doors
-----------------------------------------------------------------------------------

-- Reset world with a little delay
local function reset()
    -- Reset Map
    createMap("Map/"..selectedRoom..".csv")
    -- print("Room: "..selectedRoom.." Door: "..selectedDoor)
end


local function onDoorCollision(event)
    if event.phase == "began" then
        if event.other.type == "doorBlock" then
            for i = 1, #doorConnections1 do
                -- Find match
                if selectedRoom == doorConnections1[i] and selectedDoor == doorPrefixes1[i] then
                    -- Change room
                    selectedRoom = doorConnections2[i]
                    selectedDoor = doorPrefixes2[i]
                    selectedSpawn = selectedRoom..selectedDoor
                    player:setLinearVelocity( 0, 0 )
                    deleteMap()
                    timer.performWithDelay( 400, function() reset() end )
                    break
                end
                if selectedRoom == doorConnections2[i] and selectedDoor == doorPrefixes2[i] then
                    -- Change room
                    selectedRoom = doorConnections1[i]
                    selectedDoor = doorPrefixes1[i]
                    selectedSpawn = selectedRoom..selectedDoor
                    player:setLinearVelocity( 0, 0 )
                    deleteMap()
                    timer.performWithDelay( 400, function() reset() end )
                    break
                end
            end
        end
    end
end

player:addEventListener("collision", onDoorCollision)



-----------------------------------------------------------------------------------
-- Virtual Camera
-----------------------------------------------------------------------------------

-- Move Camera
local diffX = 0
local diffY = 0
local function moveCamera()
    if playing then
        -- Center the camera on the player
        diffX = cx - player.x
        diffY = cy - player.y

        camera.x = diffX
        camera.y = diffY
    end
end

Runtime:addEventListener("enterFrame", moveCamera)
function moveBackground()
    -- Send to back
    -- parallaxBG:toBack()
    parallaxBG.x, parallaxBG.y = diffX, diffY
    parallaxBG.x, parallaxBG.y = 10000, 10000
end
Runtime:addEventListener("enterFrame", moveBackground)


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




-----------------------------------------------------------------------------------
-- Toggle Map
-----------------------------------------------------------------------------------

-- Map
local mapToggle = display.newImageRect("Images/map.png", 1950 *.7, 1420 *.7)
local locationIndicator = display.newImageRect("Images/LocationIndicator.png", 127, 75)
mapToggle.x, mapToggle.y = cx, cy
locationIndicator.x, locationIndicator.y = cx, cy
mapToggle.alpha = 0
locationIndicator.alpha = 0
local function toggleMap()
    if playing then
        if pressedKeys["leftShift"] or pressedKeys["rightShift"] then
            mapToggle.alpha = 0.8
            locationIndicator.alpha = 1

            -- Change Indicator Pos
            if selectedRoom == "main" then
                locationIndicator.x, locationIndicator.y = 970, 310
            elseif selectedRoom == "right" then
                locationIndicator.x, locationIndicator.y = 1235, 335
            elseif selectedRoom == "left" then
                locationIndicator.x, locationIndicator.y = 610, 350
            elseif selectedRoom == "middle1" then
                locationIndicator.x, locationIndicator.y = 900, 545
            elseif selectedRoom == "middle2" then
                locationIndicator.x, locationIndicator.y = 1080, 545
            elseif selectedRoom == "leftdown" then
                locationIndicator.x, locationIndicator.y = 650, 530
            elseif selectedRoom == "rightdown" then
                locationIndicator.x, locationIndicator.y = 1235, 570
            elseif selectedRoom == "rightdowndown" then
                locationIndicator.x, locationIndicator.y = 1410, 800
            elseif selectedRoom == "rightright" then
                locationIndicator.x, locationIndicator.y = 1437, 244
            end
        else
            mapToggle.alpha = 0
            locationIndicator.alpha = 0
        end
    end
end

Runtime:addEventListener("key", toggleMap)



----------------------------------------------------------------------------------
-- Glitchiness (Ramps up)
----------------------------------------------------------------------------------

local function glitch()
    if playing then
        local glitchChance = 100 - glitchiness
        if math.random( 1, glitchChance ) == 1 then
            -- Glitch with delay
            freezeGame("freeze")
            print ("Glitch")

            timer.performWithDelay( 700, function() freezeGame("unfreeze") end )
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

