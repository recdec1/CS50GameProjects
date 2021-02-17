

Class = require 'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- seed RNG
math.randomseed(os.time())

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- an object to contain our map data
map = Map()

-- performs initialization of all objects and data needed by program
function love.load()

    -- sets up a different, better-looking retro font as our default
    love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 8))
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    largeFont = love.graphics.newFont('fonts/font.ttf', 16)
    scoreFont = love.graphics.newFont('fonts/font.ttf', 32)


    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    love.window.setTitle('Gravity Guru')

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}

    gameState = 'menu'

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'menu' then
            gameState = 'play'
            love.keyboard.keysPressed[key] = true
        elseif gameState == 'done' then
            gameState = 'menu'
            love.keyboard.keysPressed[key] = true
        elseif gameState == 'win' then
            gameState = 'menu'
            love.keyboard.keysPressed[key] = true
        end
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

function love.update(dt)
    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')


    love.graphics.clear(108/255, 140/255, 255/255, 255/255)

    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))

    map:render()
    if gameState == 'menu' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Gravity Guru!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Controls: Spacebar - Invert Gravity', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Start', 0, 40, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then

    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('You Lost!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Restart!', 0, 25, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'win' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('You Won!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Restart!', 0, 25, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont (smallFont)
    -- end virtual resolution
    push:apply('end')
end
