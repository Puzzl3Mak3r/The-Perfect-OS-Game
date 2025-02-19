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
local playing = true
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

-- local scene = require(sceneOptions[math.random(#sceneOptions)])
-- local scene = require(sceneOptions[2])
-- scene.Start()



-- ----------------------------------------------------------------------------------
-- -- Player
-- ----------------------------------------------------------------------------------

-- Player setup
local player = display.newRect( cx, screenY - 100, 70, 70 )
physics.addBody(player, "dynamic", { bounce = 0 })
player.isFixedRotation = true

-- Ground (for testing)
local floor = display.newRect(cx, screenY - 30, 2000, 60)
physics.addBody(floor, "static", { bounce = 0 })

-- Movement variables
local speed = 200
local jumpForce = -300
local canJump = false



-- ----------------------------------------------------------------------------------
-- -- Platformer
-- ----------------------------------------------------------------------------------

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

