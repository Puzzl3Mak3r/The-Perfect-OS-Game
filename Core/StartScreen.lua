----------------------------------------------------------------------------------
-- StartScreen
----------------------------------------------------------------------------------

-- Important variables
local cx = display.contentCenterX
local cy = display.contentCenterY
local count = 0



----------------------------------------------------------------------------------
-- Keybinds
----------------------------------------------------------------------------------

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
Runtime:addEventListener( "key", onKeyEvent )



----------------------------------------------------------------------------------
-- Objects
----------------------------------------------------------------------------------

-- Text
local introText1 = display.newText("Welcome to", cx, cy - 70, native.systemFont, 20)
local introText2 = display.newText("The Perfect OS", cx, cy, native.systemFont, 70)
local introText3 = display.newText("Press ENTER to start", cx, cy + 100, native.systemFont, 20)
local textGroup = display.newGroup()
textGroup.x, textGroup.y = 0, 0
textGroup:insert(introText1)
textGroup:insert(introText2)
textGroup:insert(introText3)

-- Menu Stuff
local function touchHandler()
    if pressedKeys["enter"] then

        -- Move the text offscreen
        transition.to (textGroup, {xScale = 3, transition = easing.linear, time = 900})
        transition.to (textGroup, {yScale = 3, transition = easing.linear, time = 900})
        transition.to (textGroup, {alpha = 0, transition = easing.linear, time = 900})
        transition.to (textGroup, {x = 2*-cx, transition = easing.linear, time = 900})
        transition.to (textGroup, {y = 2*-cy, transition = easing.linear, time = 900})

        -- Little delay
        timer.performWithDelay( 950, function()
            -- Delete objects
            textGroup:removeSelf()

            -- Write to file
            local file = io.open( system.pathForFile( "temp.csv", system.DocumentsDirectory ), "w" )
            if file then
                file:write("New,GameWorld")
                io.close( file )
                print( "File write successful" )
            else
                print( "File write failed" )
            end
        end)
    end
end

Runtime:addEventListener("key", touchHandler)



----------------------------------------------------------------------------------
-- Function calling
----------------------------------------------------------------------------------

local SS = {}

function SS.Start()
end

return SS