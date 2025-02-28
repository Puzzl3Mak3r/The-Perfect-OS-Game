----------------------------------------------------------------------------------
-- Sort Items
----------------------------------------------------------------------------------

-- Important
local cx = display.contentCenterX
local cy = display.contentCenterY
local mouseX, mouseY = 0,0
local playing = true
local finished = false
local howToText = display.newText("Click and drag the items to", cx, 300, native.systemFont, 50)
local howToText2 = display.newText("snap them into the pink squares", cx, 370, native.systemFont, 50)

local randomItemsNumber = math.random(3, 5)
local items = {}
local snaps = {}
local itemsPlacement3 = {cx - 420, cx, cx + 420}
local itemsPlacement4 = {cx - 420, cx - 140, cx + 140, cx + 420}
local itemsPlacement5 = {cx - 420, cx - 210, cx, cx + 210, cx + 420}



local function START()
    playing = true
    howToText.isVisible = true
    howToText2.isVisible = true
    randomItemsNumber = math.random(3, 5)

    ----------------------------------------------------------------------------------
    -- Objects
    ----------------------------------------------------------------------------------

    -- Create the items and place them
    for i = 1, randomItemsNumber do
        snaps[i] = display.newRect(cx, cy, 140, 140); snaps[i].fill = {1, 0, 1}
        if randomItemsNumber == 3 then
            snaps[i].x, snaps[i].y = itemsPlacement3[i], cy
        end
        if randomItemsNumber == 4 then
            snaps[i].x, snaps[i].y = itemsPlacement4[i], cy
        end
        if randomItemsNumber == 5 then
            snaps[i].x, snaps[i].y = itemsPlacement5[i], cy
        end
    end
    for i = 1, randomItemsNumber do
        items[i] = display.newRect(cx, cy, 100, 100)
        items[i].draggable = true
        items[i].x, items[i].y = math.random(50, 1870), math.random(50, 1030)
    end

    -- Make the items draggable
    for i = 1, randomItemsNumber do
        items[i]:addEventListener("touch", function(event)
            if items[i].draggable and playing then
                if event.phase == "began" then
                    event.target.isFocus = true
                    event.target.xScale, event.target.yScale = 1.2, 1.2
                elseif event.phase == "ended" or event.phase == "cancelled" then
                    event.target.isFocus = false
                    event.target.xScale, event.target.yScale = 1, 1
                end
            end
        end)
    end

    -- Snap items to snaps
    Runtime:addEventListener("enterFrame", function()
        for i = 1, randomItemsNumber do
            if playing and items[i].isFocus and items[i].draggable then
                items[i].x, items[i].y = mouseX, mouseY
            end
        end
    end)

    -- Snap items to snaps
    Runtime:addEventListener("enterFrame", function()
        for i = 1, randomItemsNumber do
            if playing and items[i].isFocus then
                if math.abs(items[i].x - snaps[i].x) < 100 and math.abs(items[i].y - snaps[i].y) < 100 then
                    items[i].x, items[i].y = snaps[i].x, snaps[i].y
                    items[i].draggable = false
                end
            end
        end
    end)



    ----------------------------------------------------------------------------------
    -- Detect when finished
    ----------------------------------------------------------------------------------

    local function detectFinished()
        finished = true  -- Assume finished, then check for mistakes
        for i = 1, randomItemsNumber do
            if not (items[i].x == snaps[i].x and items[i].y == snaps[i].y) then
                finished = false  -- If any item is not in place, it's not finished
                break
            end
        end
        if finished then
            Runtime:removeEventListener("enterFrame", detectFinished)
        end
    end

    Runtime:addEventListener("enterFrame", detectFinished)



    ----------------------------------------------------------------------------------
    -- Mouse
    ----------------------------------------------------------------------------------

    -- Called when a mouse event has been received.
    local function onMouseEvent( event )
        -- Print the mouse cursor's current position to the log.
        mouseX, mouseY = event.x, event.y
    end

    -- Add the mouse event listener.
    Runtime:addEventListener( "mouse", onMouseEvent )
end



----------------------------------------------------------------------------------
-- Function calling
----------------------------------------------------------------------------------

local SortItems = {}

function SortItems.Start()
    print ("Starting SortItems")
    START()
end

function SortItems.Yield()
    -- Stop playing
    playing = false
    howToText.isVisible = false
    howToText2.isVisible = false

    -- Remove Listeners
    Runtime:removeEventListener("enterFrame")
    Runtime:removeEventListener("mouse")

    -- Remove Objects
    for i = 1, randomItemsNumber do items[i]:removeSelf(); items[i] = nil end
    for i = 1, randomItemsNumber do snaps[i]:removeSelf(); snaps[i] = nil end

    -- Write to file
    local file = io.open( system.pathForFile( "lock.csv", system.DocumentsDirectory ), "w" )
    if file then
        file:write("unlocked")
        file:flush()
        -- io.close(file)
        print( "File write successful" )
    else
        print( "File write failed on line 140" )
    end
end

Runtime:addEventListener("enterFrame", function()
    if finished then
        finished = false
        timer.performWithDelay( 100, SortItems.Yield() )
    end
end)

return SortItems