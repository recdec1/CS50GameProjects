
require 'Util'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = -1


-- bush tiles
BUSH_LEFT = 2
BUSH_RIGHT = 3

-- mushroom tiles
MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

-- Pole tiles
POLE_TOP = 8
POLE_MIDDLE = 12
POLE_BOTTOM = 16
FLAG = 13

-- jump block
JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

-- constructor for our map object
function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.sprites = generateQuads(self.spritesheet, 16, 16)
    self.music = love.audio.newSource('sounds/music.wav', 'static')

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 200
    self.mapHeight = 28
    self.tiles = {}

    -- applies positive Y influence on anything affected
    self.gravity = 3

    -- associate player with map
    self.player = Player(self)

    -- camera offsets
    self.camX = 0
    self.camY = -3

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)

            if y == 1 then
                for x = 1, 400 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            for y = self.mapHeight / 2, self.mapHeight / 2 + 3 do
                for x = 1, 400 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end


            if x == 31 or x == 43 or x == 55 or x == 119 or x == 131 then
                --make pyramid
                for i = 1, 5 do
                    tileLevel = self.mapHeight / 2 - i
                    self:setTile(x, tileLevel, TILE_BRICK)

                    for y = self.mapHeight / 2 - i, self.mapHeight do
                        self:setTile(x, y, TILE_BRICK)
                    end
                    x = x + 1
                end
            end
            if x == 36 or x == 48 or x == 112 or x == 124 or x == 136 then
                for i = 1, 4 do
                    tileLevel = self.mapHeight / 2 - 5 + i
                    self:setTile(x, tileLevel, TILE_BRICK)

                    for y = self.mapHeight / 2 - 5 + i, self.mapHeight / 2 + 3 do
                        self:setTile(x, y, TILE_BRICK)
                    end
                    x = x + 1
                end
            end
            if x == 37 or x == 49 or x == 25 or x == 113 or x == 125 then
                for i = 1, 5 do
                    tileLevel = 1 + i
                    self:setTile(x, tileLevel, TILE_BRICK)

                    for y = 1, tileLevel do
                        self:setTile(x, y, TILE_BRICK)
                    end
                    x = x + 1
                end
            end
            if x == 42 or x == 54 or x == 30 or x == 118 or x == 130 then
                for i = 1, 4 do
                    tileLevel = 1 + 5 - i
                    self:setTile(x, tileLevel, TILE_BRICK)

                    for y = 1, tileLevel do
                        self:setTile(x, y, TILE_BRICK)
                    end
                    x = x + 1
                end
            end
            if x == 60 then
                for y = 8, self.mapHeight / 2 + 3 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end

            for x = 64, 69 do
                if y == self.mapHeight / 4 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end

            for x = 71, 76 do
                if y == 4 or y == 10 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            for x = 78, 88 do
                if y == self.mapHeight / 4 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 80 or x == 86 then
                for y = self.mapHeight / 4 - 2, self.mapHeight / 4 + 2 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 83 or x == 89 or x == 66 then
                for y = self.mapHeight / 2 - 3, self.mapHeight / 2 do
                    self:setTile(x, y, TILE_BRICK)
                end
                for y = 0, 3 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 91 then
                if y == 4 or y == 6 or y == 7 or y == 11 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 92 then
                if y == 8 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 93 then
                if y == 3 or y == 4 or y == 9 or y == 13 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 94 then
                if y == 6 or y == 12 or y == 13 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 95 then
                if y == 9 or y == 13 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 96 then
                if y == 4 or y == 8 or y == 7 or y == 10 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 97 then
                if y == 7 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 98 then
                if y == 2 or y == 3 or y == 7 or y == 8 or y == 9 or y == 10 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 99 then
                if y == 6 or y == 13 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 100 then
                if y == 4 or y == 5 or y == 6 or y == 11 or y == 12 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 101 then
                if y == 4 or y == 6 or y == 7 or y == 12 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 102 then
                if y == 4 or y == 8 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 103 then
                if y == 7 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 104 then
                for y = 1, 4 do
                    self:setTile(x, y, TILE_BRICK)
                end
                for y = 10, 13 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            for x = 105, 108 do
                if y == 7 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 106 then
                if y == 4 or y == 10 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 107 then
                if y == 1 or y == 6 or y == 13 or y == 12 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 108 then
                if y == 4 or y == 6 or y == 8 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 109 then
                if y == 7 or y == 13 then
                    self:setTile(x, y, TILE_BRICK)
                end
            end
            if x == 111 then
                for y = 1, 5 do
                    self:setTile(x, y, TILE_BRICK)
                end
                for y = 10, 13 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end

            if y == 4 then
                for x = 138, 142 do
                    self:setTile(x, y, TILE_BRICK)
                end
                for x = 152, 156 do
                    self:setTile(x, y, TILE_BRICK)
                end
                for x = 166, 170 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end

            if y == 10 then
                for x = 145, 149 do
                    self:setTile(x, y, TILE_BRICK)
                end
                for x = 159, 163 do
                    self:setTile(x, y, TILE_BRICK)
                end
                for x = 173, 177 do
                    self:setTile(x, y, TILE_BRICK)
                end
            end

            if y == 1 then
                for x = 138, 141 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 145, 147 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 154, 156 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 160, 164 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 170, 177 do
                    self:setTile(x, y, TILE_EMPTY)
                end
            end
            for y = self.mapHeight / 2, self.mapHeight / 2 + 3 do
                for x = 140, 143 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 147, 148 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 151, 153 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 156, 159 do
                    self:setTile(x, y, TILE_EMPTY)
                end
                for x = 165, 170 do
                    self:setTile(x, y, TILE_EMPTY)
                end
            end

                --draw flag post
            if x == self.mapWidth - 1 then
                tileLevel = self.mapHeight / 2 - 5
                self:setTile(x, tileLevel, POLE_TOP)
                self:setTile(x + 1, tileLevel, FLAG)
                self:setTile(x, tileLevel + 1, POLE_MIDDLE)
                self:setTile(x, tileLevel + 2, POLE_MIDDLE)
                self:setTile(x, tileLevel + 3, POLE_MIDDLE)
                self:setTile(x, tileLevel + 4, POLE_BOTTOM)
                for y = self.mapHeight / 2, self.mapHeight do
                    self:setTile(x, y, TILE_BRICK)
                end
                --draw normal tiles
            else
                tileLevel = self.mapHeight / 2

                for y = self.mapHeight / 2, self.mapHeight / 2 + 3 do
                    self:setTile(x, y, TILE_BRICK)
                end
                x = x + 1
            end
        end
    end

    -- begin generating the terrain using vertical scan lines
    local x = 1
    while x < 80 and x > 60 do

        -- 10% chance to not generate anything, creating a gap
        if math.random(10) == 1 then

            -- creates column of tiles going to bottom of map

            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_EMPTY)
            end

            if y == 1 then
                self:setTile(x + 5, y, TILE_EMPTY)
            end


            -- next vertical scan line
            x = x + 1
        else
            -- increment X so we skip two scanlines, creating a 2-tile gap
            x = x + 2
        end
    end

    self.music:setLooping(true)
    self.music:play()
end

-- return whether a given tile is collidable
function Map:collides(tile)
    local collidables = {
        TILE_BRICK
    }

    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:update(dt)
    self.player:update(dt)

    if gameState == 'play' then
        self.camX = math.max(0, math.min(self.camX + (WALKING_SPEED - 16) * dt,
            math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x + self.player.width + 1)))
    else
        self.camX = 0
        self.camY = -3
    end
end


function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end


function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end


function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.sprites[tile],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end

    self.player:render()
end
