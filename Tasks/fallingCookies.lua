----------------------------------------------------------------------------------
-- Falling Cookies
----------------------------------------------------------------------------------

-- Important
local cx = display.contentCenterX
local cy = display.contentCenterY
local screenX = display.contentWidth
local screenY = display.contentHeight
local mouseX, mouseY = 0,0
local playing = true

local moveRight, moveLeft, moveForward = false, false, false
local cookiesToCollect = math.random( 5, 10 )


local function START()
    playing = true
    ----------------------------------------------------------------------------------
    -- Player && Environment
    ----------------------------------------------------------------------------------

    local player = display.newRect( cx, screenY - 100, 70, 70)
    physics.addBody( player )
    player.isFixedRotation = true
    player.name = "player"

    local floor = display.newRect( cx, screenY - 30, 2000, 60 )
    physics.addBody( floor, "static", { density=1.0, friction=0, bounce=-1} )
    floor.name = "floor"

    physics.setGravity(0, 20)

    local textDisplay = display.newText( "Cookies to collect: " .. cookiesToCollect, 0, 0, "Arial", 30 )

    -- 2 walls
    local wall1 = display.newRect( 0, 0, 50, screenY )
    physics.addBody( wall1, "static", { density=1.0, friction=0, bounce=0} )
    wall1.name = "wall"
    local wall2 = display.newRect( screenX, 0, 50, screenY )
    physics.addBody( wall2, "static", { density=1.0, friction=0, bounce=0} )
    wall2.name = "wall"



    ----------------------------------------------------------------------------------
    -- Cookies
    ----------------------------------------------------------------------------------

    -- Create cookies
    local cookies = {}
    local i = 0 -- cookie counter
    local randomDelay = math.random( 30,50 ) * 100
    local function createCookie()
        cookies[i] = display.newRect(cx, 0, 50, 50)
        cookies[i].fill = {1, 0, 0}
        cookies[i].name = "cookie"
        physics.addBody( cookies[i], "dynamic" )
        cookies[i].isFixedRotation = true
        cookies[i].x, cookies[i].y = math.random(300, screenX-300), -100
        i = i + 1
    end

    local cookieTimer
    cookieTimer = timer.performWithDelay(randomDelay, function()
        createCookie()
        randomDelay = math.random(30, 50) * 100
    end, 0)
    
    -- Delete cookie when collected
    local function cookieCollision(event)
        if event.other.name == "cookie" then
            event.other:removeSelf()
            if event.target.name == "player" then
                cookiesToCollect = cookiesToCollect - 1
                textDisplay.text = "Cookies to collect: " .. cookiesToCollect
                local gravX = physics.getGravity(1)
                local gravY = physics.getGravity(2)
                physics.setGravity( gravX, gravY + 20 )
            end
        end
    end
    player:addEventListener( "collision", cookieCollision )
    floor:addEventListener( "collision", cookieCollision )




    ----------------------------------------------------------------------------------
    -- Keys
    ----------------------------------------------------------------------------------

    -- Keybinds
    local pressedKeys = {}
    local function onKeyEvent(event)
        if event.phase == "down" then
            pressedKeys[event.keyName] = true
        elseif event.phase == "up" then
            pressedKeys[event.keyName] = false
        else
            pressedKeys[event.keyName] = false
        end
    end
    local function keyRunner()
        -- Move Left and Right
        moveLeft, moveRight = false, false
        if pressedKeys["d"] then
            moveRight = true
        end if pressedKeys["a"] then
            moveLeft = true
        end if pressedKeys["right"] then
            moveRight = true
        end if pressedKeys["left"] then
            moveLeft = true
        end
        if moveRight and moveLeft then
            moveRight, moveLeft = false, false
        end

        if moveRight then
            player.x = player.x + 7
        end if moveLeft then
            player.x = player.x - 7
        end
    end
    Runtime:addEventListener( "key", onKeyEvent )
    Runtime:addEventListener( "enterFrame", keyRunner )
end



----------------------------------------------------------------------------------
-- Function calling
----------------------------------------------------------------------------------

local FallingCookies = {}

function FallingCookies.Start()
    print ("Starting FallingCookies")
    START()
end

function FallingCookies.Yield()
    -- Stop playing
    playing = false
end

return FallingCookies