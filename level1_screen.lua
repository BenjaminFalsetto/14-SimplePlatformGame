-----------------------------------------------------------------------------------------
--
-- level1_screen.lua
-- Created by: Ms Raffin
-- Date: Nov. 22nd, 2014
-- Description: This is the level 1 screen of the game.
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- INITIALIZATIONS
-----------------------------------------------------------------------------------------

-- Use Composer Libraries
local composer = require( "composer" )
local widget = require( "widget" )

-- load physics
local physics = require("physics")

-----------------------------------------------------------------------------------------

-- Naming Scene
sceneName = "level1_screen"

-----------------------------------------------------------------------------------------

-- Creating Scene Object
local scene = composer.newScene( sceneName )

-----------------------------------------------------------------------------------------
-- LOCAL VARIABLES
-----------------------------------------------------------------------------------------

-- The local variables for this scene
local bkg_image

local platform1
local platform2
local platform3
local platform4

local spikes1
local spikes2
local spikes3

local spikes1platform
local spikes2platform
local spikes3platform

local torchesAndSign
local door
local door2
local character

local heart1
local heart2
local numLives = 2

local rArrow 
local uArrow
local lArrow

local motionx = 0
local SPEED = 5
local LINEAR_VELOCITY = -100
local GRAVITY = 7

local leftW 
local rightW
local topW
local floor

local YouLose
local YouWin

local ball2
local ball3
local theBall

local questionsAnswered = 0

local popSound = audio.loadSound( "Sounds/Pop.mp3")
local popSoundChannel

local youWinSound = audio.loadSound("Sounds/Cheer.m4a")
local youWinSoundChannel

-----------------------------------------------------------------------------------------
-- LOCAL SCENE FUNCTIONS
-----------------------------------------------------------------------------------------

-- When left arrow is touched, move character left
local function left (touch)
        motionx = -SPEED
        character.xScale = -1

end
 
 
-- When right arrow is touched, move character right
local function right (touch)
    --if (character ~= nil) then
        motionx = SPEED
        character.xScale = 1
    --end
end

-- When up arrow is touched, add vertical so it can jump
local function up (touch)
    if (character ~= nil) then
        character:setLinearVelocity( 0, LINEAR_VELOCITY )
    end
end

-- Move character horizontally
local function movePlayer (event)
    --if (character ~= nil) then
        character.x = character.x + motionx
    --end
end
 
-- Stop character movement when no arrow is pushed
local function stop (event)
    if (event.phase =="ended") then
        motionx = 0
    end
end


local function AddArrowEventListeners()
    rArrow:addEventListener("touch", right)
    uArrow:addEventListener("touch", up)
    lArrow:addEventListener("touch", left)
end

local function RemoveArrowEventListeners()
    rArrow:removeEventListener("touch", right)
    uArrow:removeEventListener("touch", up)
    lArrow:removeEventListener("touch", left)
end

local function AddRuntimeListeners()
    Runtime:addEventListener("enterFrame", movePlayer)
    Runtime:addEventListener("touch", stop )
end

local function RemoveRuntimeListeners()
    Runtime:removeEventListener("enterFrame", movePlayer)
    Runtime:removeEventListener("touch", stop )
end


local function ReplaceCharacter()
    character = display.newImageRect("Images/KickyKatRight.png", 100, 150)
    character.x = display.contentWidth * 0.5 / 8
    character.y = display.contentHeight  * 0.1 / 3
    character.width = 75
    character.height = 100
    character.myName = "KickyKat"

    -- intialize horizontal movement of character
    motionx = 0

    -- add physics body
    physics.addBody( character, "dynamic", { density=0, friction=0.5, bounce=0, rotation=0 } )

    -- prevent character from being able to tip over
    character.isFixedRotation = true

    -- add back arrow listeners
    AddArrowEventListeners()

    -- add back runtime listeners
    AddRuntimeListeners()
end

local function MakeSoccerBallsVisible()
    ball2.isVisible = true
    ball3.isVisible = true
end

local function MakeHeartsVisible()
    heart1.isVisible = true
    heart2.isVisible = true
end

local function YouLoseTransition()
    composer.gotoScene( "you_lose" )
end

local function Level2Transition( )
    composer.gotoScene( "you_win" )
    audio.stop ( mmMusicChannel)

    --play you win audio
    youWinSoundChannel = audio.play(youWinSound)
end

local function onCollision( self, event )
    -- for testing purposes
    --print( event.target )        --the first object in the collision
    --print( event.other )         --the second object in the collision
    --print( event.selfElement )   --the element (number) of the first object which was hit in the collision
    --print( event.otherElement )  --the element (number) of the second object which was hit in the collision
    --print( event.target.myName .. ": collision began with " .. event.other.myName )

    if ( event.phase == "began" ) then

        --Pop sound
        popSoundChannel = audio.play(popSound)

        if  (event.target.myName == "spikes1") or 
            (event.target.myName == "spikes2") or
            (event.target.myName == "spikes3") then

            -- add sound effect here

            -- remove runtime listeners that move the character
            RemoveArrowEventListeners()
            RemoveRuntimeListeners()

            -- remove the character from the display
            display.remove(character)

            -- decrease number of lives
            numLives = numLives - 1

            if (numLives == 1) then
                -- update hearts
                heart1.isVisible = true
                heart2.isVisible = false
                timer.performWithDelay(200, ReplaceCharacter) 

            elseif (numLives == 0) then
                -- update hearts
                heart1.isVisible = false
                heart2.isVisible = false
                timer.performWithDelay(200, YouLoseTransition)
            end
        end

        if  (event.target.myName == "ball2") or
            (event.target.myName == "ball3") then

            -- get the ball that the user hit
            theBall = event.target

            -- stop the character from moving
            motionx = 0

            -- make the character invisible
            character.isVisible = false

            -- show overlay with math question
            composer.showOverlay( "level1_question", { isModal = true, effect = "fade", time = 100})

            -- Increment questions answered
            questionsAnswered = questionsAnswered + 1
        end

        if (event.target.myName == "door2") then
            --check to see if the user has answered 5 questions
            if questionsAnswered == 5 then
                Level2Transition( )
            end
        end        

    end
end


local function AddCollisionListeners()
    print ("***Called AddCollisionListeners")
    -- if character collides with ball, onCollision will be called
    spikes1.collision = onCollision
    spikes1:addEventListener( "collision" )
    spikes2.collision = onCollision
    spikes2:addEventListener( "collision" )
    spikes3.collision = onCollision
    spikes3:addEventListener( "collision" )

    -- if character collides with ball, onCollision will be called    
    ball2.collision = onCollision
    ball2:addEventListener( "collision" )
    ball3.collision = onCollision
    ball3:addEventListener( "collision" )

    door2.collision = onCollision
    door2:addEventListener( "collision" )
end

local function RemoveCollisionListeners()
    print ("***Called RemoveCollisionListeners")
    spikes1:removeEventListener( "collision" )
    spikes2:removeEventListener( "collision" )
    spikes3:removeEventListener( "collision" )

    ball2:removeEventListener( "collision" )
    ball3:removeEventListener( "collision" )

    door2:removeEventListener( "collision")

end

local function AddPhysicsBodies()
    

    --add to the physics engine
    physics.addBody( platform1, "static", { density=1.0, friction=0.3, bounce=0.2 } )
    physics.addBody( platform2, "static", { density=1.0, friction=0.3, bounce=0.2 } )
    physics.addBody( platform3, "static", { density=1.0, friction=0.3, bounce=0.2 } )
    physics.addBody( platform4, "static", { density=1.0, friction=0.3, bounce=0.2 } )

    physics.addBody( spikes1, "static", { density=1.0, friction=0.3, bounce=0.2 } )
    physics.addBody( spikes2, "static", { density=1.0, friction=0.3, bounce=0.2 } )
    physics.addBody( spikes3, "static", { density=1.0, friction=0.3, bounce=0.2 } )    

    physics.addBody( spikes1platform, "static", { density=1.0, friction=0.3, bounce=0.2 } )
    physics.addBody( spikes2platform, "static", { density=1.0, friction=0.3, bounce=0.2 } )
    physics.addBody( spikes3platform, "static", { density=1.0, friction=0.3, bounce=0.2 } )

    physics.addBody(leftW, "static", {density=1, friction=0.3, bounce=0.2} )
    physics.addBody(rightW, "static", {density=1, friction=0.3, bounce=0.2} )
    physics.addBody(topW, "static", {density=1, friction=0.3, bounce=0.2} )
    physics.addBody(floor, "static", {density=1, friction=0.3, bounce=0.2} )

    physics.addBody(ball2, "static",  {density=0, friction=0, bounce=0} )
    physics.addBody(ball3, "static",  {density=0, friction=0, bounce=0} )

    physics.addBody(door2, "static", {density=1, friction=0.3, bounce=0.2})

end

local function RemovePhysicsBodies()
    physics.removeBody(platform1)
    physics.removeBody(platform2)
    physics.removeBody(platform3)
    physics.removeBody(platform4)

    physics.removeBody(spikes1)
    physics.removeBody(spikes2)
    physics.removeBody(spikes3)

    physics.removeBody(spikes1platform)
    physics.removeBody(spikes2platform)
    physics.removeBody(spikes3platform)

    physics.removeBody(leftW)
    physics.removeBody(rightW)
    physics.removeBody(topW)
    physics.removeBody(floor)
 
end

-----------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS
-----------------------------------------------------------------------------------------

function ResumeGame()

    -- make character visible again
    character.isVisible = true
    
    if (questionsAnswered > 0) then
        if (theBall ~= nil) and (theBall.isBodyActive == true) then
                physics.removeBody(theBall)
                theBall.isVisible = false
        end
    end

end

-----------------------------------------------------------------------------------------
-- GLOBAL SCENE FUNCTIONS
-----------------------------------------------------------------------------------------

-- The function called when the screen doesn't exist
function scene:create( event )

    -- Creating a group that associates objects with the scene
    local sceneGroup = self.view

    -----------------------------------------------------------------------------------------

    -- Insert the background image
    bkg_image = display.newImageRect("Images/Level-1BKG.png", display.contentWidth, display.contentHeight)
    bkg_image.x = display.contentWidth / 2 
    bkg_image.y = display.contentHeight / 2

    -- Insert background image into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( bkg_image )    

    
    -- Insert the platforms
    platform1 = display.newImageRect("Images/Level-1Platform1.png", 250, 50)
    platform1.x = display.contentWidth * 1 / 8
    platform1.y = display.contentHeight * 1.6 / 4
        
    sceneGroup:insert( platform1 )

    platform2 = display.newImageRect("Images/Level-1Platform1.png", 150, 50)
    platform2.x = display.contentWidth /2.1
    platform2.y = display.contentHeight * 1.2 / 4
        
    sceneGroup:insert( platform2 )

    platform3 = display.newImageRect("Images/Level-1Platform1.png", 180, 50)
    platform3.x = display.contentWidth *3 / 5
    platform3.y = display.contentHeight * 3.5 / 5
        
    sceneGroup:insert( platform3 )

    platform4 = display.newImageRect("Images/Level-1Platform1.png", 180, 50)
    platform4.x = display.contentWidth *4.7 / 5
    platform4.y = display.contentHeight * 1.3 / 5
        
    sceneGroup:insert( platform4 )

    spikes1 = display.newImageRect("Images/Level-1Spikes1.png", 250, 50)
    spikes1.x = display.contentWidth * 3 / 8
    spikes1.y = display.contentHeight * 2.5 / 5
    spikes1.myName = "spikes1"
        
    sceneGroup:insert( spikes1)

    spikes1platform = display.newImageRect("Images/Level-1Platform1.png", 250, 50)
    spikes1platform.x = display.contentWidth * 3 / 8
    spikes1platform.y = display.contentHeight * 2.8 / 5
        
    sceneGroup:insert( spikes1platform)

    spikes2 = display.newImageRect("Images/Level-1Spikes2.png", 150, 50)
    spikes2.x = display.contentWidth * 6 / 8
    spikes2.y = display.contentHeight * 2.5 / 5
    spikes2.myName = "spikes2"
        
    sceneGroup:insert( spikes2)

    spikes2platform = display.newImageRect("Images/Level-1Platform1.png", 150, 50)
    spikes2platform.x = display.contentWidth * 6 / 8
    spikes2platform.y = display.contentHeight * 2.2 / 5
        
    sceneGroup:insert( spikes2platform)

    spikes3 = display.newImageRect("Images/Level-1Spikes3.png", 50, 150)
    spikes3.x = display.contentWidth * 5.5 / 8
    spikes3.y = display.contentHeight * 0.4 / 5
    spikes3.myName = "spikes3"
        
    sceneGroup:insert( spikes3)

    spikes3platform = display.newImageRect("Images/Level-1Platform2.png", 50, 150)
    spikes3platform.x = display.contentWidth * 5.8 / 8
    spikes3platform.y = display.contentHeight * 0.4 / 5
        
    sceneGroup:insert( spikes3platform)

    -- Insert the torchesAndSign Objects
    torchesAndSign = display.newImageRect("Images/Level-1Random.png", display.contentWidth, display.contentHeight)
    torchesAndSign.x = display.contentCenterX
    torchesAndSign.y = display.contentCenterY + 10

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( torchesAndSign )

    -- Insert the Door
    door = display.newImageRect("Images/Level-1Door.png", display.contentWidth, display.contentHeight)
    door.x = display.contentCenterX
    door.y = display.contentCenterY

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( door )

    -- door 2
    door2 = display.newRect(155, 650, 200, 200)
    door2.isVisible = false
    door2.myName = "door2"

    -- Insert the Hearts
    heart1 = display.newImageRect("Images/heart.png", 80, 80)
    heart1.x = 50
    heart1.y = 50
    heart1.isVisible = true

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( heart1 )

    heart2 = display.newImageRect("Images/heart.png", 80, 80)
    heart2.x = 130
    heart2.y = 50
    heart2.isVisible = true

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( heart2 )

    --Insert the right arrow
    rArrow = display.newImageRect("Images/RightArrowUnpressed.png", 100, 50)
    rArrow.x = display.contentWidth * 9.2 / 10
    rArrow.y = display.contentHeight * 9.5 / 10
   
    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( rArrow)

    --Insert the left arrow
    uArrow = display.newImageRect("Images/UpArrowUnpressed.png", 50, 100)
    uArrow.x = display.contentWidth * 8.2 / 10
    uArrow.y = display.contentHeight * 8.5 / 10

    -- Insert objects into the scene group in order to ONLY be associated with this scene 
    sceneGroup:insert( uArrow)

    -- Insert the left arrow
    lArrow = display.newImageRect("Images/LeftArrowUnpressed.png", 100, 50)
    lArrow.x = display.contentWidth * 7.2 / 10
    lArrow.y = display.contentHeight * 9.5 / 10

    sceneGroup:insert( lArrow)

    --WALLS--
    leftW = display.newLine( 0, 0, 0, display.contentHeight)
    leftW.isVisible = true

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( leftW )

    rightW = display.newLine( 0, 0, 0, display.contentHeight)
    rightW.x = display.contentCenterX * 2
    rightW.isVisible = true

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( rightW )

    topW = display.newLine( 0, 0, display.contentWidth, 0)
    topW.isVisible = true

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( topW )


    floor = display.newImageRect("Images/Level-1Floor.png", 1024, 100)
    floor.x = display.contentCenterX
    floor.y = display.contentHeight * 1.05
    

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( floor )

    -- You Lose screen
    YouLose = display.newImageRect ("Images/YouLose.png", display.contentWidth, display.contentHeight)
    YouLose.isVisible = false
    YouLose.x = display.contentWidth / 2 
    YouLose.y = display.contentHeight / 2

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( YouLose )

    -- You Win screen
    YouWin = display.newImageRect ("Images/YouWin.png", display.contentWidth, display.contentHeight)
    YouWin.isVisible = false
    YouWin.x = display.contentWidth / 2 
    YouWin.y = display.contentHeight / 2

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( YouWin )

    --ball2
    ball2 = display.newImageRect ("Images/SoccerBall.png", 70, 70)
    ball2.x = 610
    ball2.y = 480
    ball2.myName = "ball2"

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( ball2 )


    --ball3
    ball3 = display.newImageRect ("Images/SoccerBall.png", 70, 70)
    ball3.x = 490
    ball3.y = 170
    ball3.myName = "ball3"

    -- Insert objects into the scene group in order to ONLY be associated with this scene
    sceneGroup:insert( ball3 )

end --function scene:create( event )

-----------------------------------------------------------------------------------------

-- The function called when the scene is issued to appear on screen
function scene:show( event )

    -- Creating a group that associates objects with the scene
    local sceneGroup = self.view
    local phase = event.phase

    -----------------------------------------------------------------------------------------

    if ( phase == "will" ) then

        -- Called when the scene is still off screen (but is about to come on screen).
    -----------------------------------------------------------------------------------------
        -- start physics
        physics.start()

        -- set gravity
        physics.setGravity( 0, GRAVITY )

    elseif ( phase == "did" ) then

        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.

        numLives = 2
        questionsAnswered = 0

        -- make all soccer balls visible
        MakeSoccerBallsVisible()

        -- make all lives visible
        MakeHeartsVisible()

        -- add physics bodies to each object
        AddPhysicsBodies()

        -- add collision listeners to objects
        AddCollisionListeners()

        -- add arrow event listeners for buttons
        --AddArrowEventListeners()

        -- create the character, add physics bodies and runtime listeners
        ReplaceCharacter()

    end

end --function scene:show( event )

-----------------------------------------------------------------------------------------

-- The function called when the scene is issued to leave the screen
function scene:hide( event )

    -- Creating a group that associates objects with the scene
    local sceneGroup = self.view
    local phase = event.phase

    -----------------------------------------------------------------------------------------

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.

    -----------------------------------------------------------------------------------------

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        RemoveCollisionListeners()
        RemovePhysicsBodies()

        physics.stop()
        RemoveArrowEventListeners()
        RemoveRuntimeListeners()
        display.remove(character)
    end

end --function scene:hide( event )

-----------------------------------------------------------------------------------------

-- The function called when the scene is issued to be destroyed
function scene:destroy( event )

    -- Creating a group that associates objects with the scene
    local sceneGroup = self.view

    -----------------------------------------------------------------------------------------

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.

end -- function scene:destroy( event )

-----------------------------------------------------------------------------------------
-- EVENT LISTENERS
-----------------------------------------------------------------------------------------

-- Adding Event Listeners
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene