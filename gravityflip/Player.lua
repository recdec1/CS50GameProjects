--[[
    Represents our player in the game, with its own sprite.
]]

Player = Class{}

WALKING_SPEED = 140
local JUMP_VELOCITY = 400

function Player:init(map)

    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 20

    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10

    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage('graphics/roofchar.png')

    -- sound effects
    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static')
    }

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'walking'

    -- determines sprite flipping
    self.direction = 'right'
    self.orientation = 'down'

    -- x and y velocity
    self.dx = WALKING_SPEED
    self.dy = 0


    -- position on top of map tiles initialised, not set.
    self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height - 1
    self.x = map.tileWidth * 10

    -- initialize all player animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(128, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(160, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(176, 0, 16, 20, self.texture:getDimensions()),
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(32, 0, 16, 20, self.texture:getDimensions())
            },
        }),
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['walking']
    self.currentFrame = self.animation:getCurrentFrame()

    -- behavior map we can call based on player state
    self.behaviors = {

        ['walking'] = function(dt)

            if gameState == 'play' then
                if love.keyboard.wasPressed('space') then
                    self:flipGravity()
                    self.state = 'jumping'
                    self.animation = self.animations['jumping']
                    self.sounds['jump']:play()
                    if self.orientation == 'up' then
                        self.orientation = 'down'
                    elseif self.orientation == 'down' then
                        self.orientation = 'up'
                    end
                end
                    self.direction = 'right'
                    self.dx = WALKING_SPEED
                    if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                        self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

                        -- if so, reset velocity and position and change state
                        self.dy = 0
                        self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
                        -- check if there is a tile above us
                    elseif self.map:collides(self.map:tileAt(self.x, self.y)) or
                        self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y)) then

                        -- if so, reset velocity and position and change state
                        self.dy = 0
                        self.y = (self.map:tileAt(self.x, self.y).y) * self.map.tileHeight
                    end
                else
                    self.dx = WALKING_SPEED
                    self.dy = 0
                    self.state = 'walking'
                    self.animation = self.animations['walking']
                    self.orientation = self.orientation
                end

                -- check for collisions moving left and right
                self:checkRightCollision()
                self:checkLeftCollision()

                -- jump state if nothing is above or below.
                if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                    not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) and not self.map:collides(self.map:tileAt(self.x, self.y - 1)) and
                        not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y - 1)) then

                    -- if so, reset velocity and position and change state
                    self.state = 'jumping'
                    self.animation = self.animations['jumping']

                end

        end,
        ['jumping'] = function(dt)

            if self.dy ~= 0 then
                    self.direction = 'right'
                    self.dx = WALKING_SPEED
                    self.state = 'jumping'
                    self.animation = self.animations['walking']
                    self.orientation = self.orientation

            end

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

                -- if so, reset velocity and position and change state
                self.dy = 0
                self.state = 'walking'
                self.animation = self.animations['walking']
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
                -- check if there is a tile above us
            elseif self.map:collides(self.map:tileAt(self.x, self.y)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y)) then

                -- if so, reset velocity and position and change state
                self.dy = 0
                self.state = 'walking'
                self.animation = self.animations['walking']
                self.y = (self.map:tileAt(self.x, self.y).y) * self.map.tileHeight

                --self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end
            self.dy = self.dy + self.map.gravity
            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
            self:losing()
            self:winning()
        end
    }
end

function Player:update(dt)
    if gameState == 'play' then
        self.behaviors[self.state](dt)
        self.animation:update(dt)
        self.currentFrame = self.animation:getCurrentFrame()
        self.x = self.x + self.dx * dt

        -- jumping and block hitting logic
        self:calculateJumps()

        -- apply velocity
        self.y = self.y + self.dy * dt
    end
end

function Player:calculateJumps()

        -- if we have negative y velocity (jumping), check if we collide

        -- with any blocks above us
    if self.dy < 0 and self.orientation == 'up' then
        if self.map:collides(self.map:tileAt(self.x, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y)) then
            -- reset y velocity
            self.dy = 0
            self.state = 'walking'
                -- change block to different block
            local playCoin = false
            local playHit = false
            if self.map:tileAt(self.x, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                playCoin = true
            else
                playHit = true
            end
            if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                playCoin = true
            else
                playHit = true
            end
            if playCoin then
                self.sounds['coin']:play()
            elseif playHit then
                self.sounds['hit']:play()
            end
        end
        -- bottom collision
    elseif self.dy > 0 and self.orientation == 'down' then
        if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
            self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
            -- reset dy
            self.dy = 0
            self.state = 'walking'
        end
    end
end


-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y + 1)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then

            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y + 1)) or
            self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then

            -- if so, reset velocity and position and change state
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
end


function Player:render()
    local scaleX
    local scaleY

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end
    if self.orientation == 'down' then
        scaleY = 1
    elseif self.orientation == 'up' then
        scaleY = -1
    end

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, scaleX, scaleY, self.xOffset, self.yOffset)
end

function Player:flipGravity()
    if self.orientation == 'up' and self.dy == 0 then
        self.dy = 400
        self.map.gravity = 3
    elseif self.orientation == 'down' and self.dy == 0 then
        self.dy = -400
        self.map.gravity = -3
    end
end

function Player:reset()
    self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height - 1
    self.x = map.tileWidth * 10
    self.dx = 0
    self.dy = 0
end

function Player:losing()
    if self.x + self.width < map.camX or self.y > map.mapHeightPixels / 2 or self.y + self.height < 0 then
        gameState = 'done'
        self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height - 1
        self.x = map.tileWidth * 10
        self.dx = 0
        map.camX = 0
        map.camY = -3
        self.orientation = 'down'
        self.dy = 0
        self.map.gravity = 3

    end
end

function Player:winning()
    if self.x > map.mapWidthPixels then
        gameState = 'win'
        self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height - 1
        self.x = map.tileWidth * 10
        self.dx = 0
        self.orientation = 'down'
        self.dy = 0
        self.map.gravity = 3
        map.camX = 0
        map.camY = -3
    end
end
