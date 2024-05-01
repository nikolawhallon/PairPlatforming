import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "pulp-audio"

-- from https://github.com/Whitebrim/AnimatedSprite
import "AnimatedSprite"

-- pseudo-enum for game state
MENU = 0
GAME = 1

STATE = MENU

import "game"
import "menu"

local gfx <const> = playdate.graphics
local gmtry <const> = playdate.geometry
gfx.setBackgroundColor(gfx.kColorBlack)

pulp.audio.init()

-- the global font that everyone should use
font = gfx.font.new("fonts/Quickboot-7-Medium")
assert(font)

-- the tilemap (image) for some reason needed to be initialized here?
local tilesetImagetable = gfx.imagetable.new("images/solluco-tileset")
assert(tilesetImagetable)

function initTilemap()
	local tilemap = gfx.tilemap.new()
	tilemap:setImageTable(tilesetImagetable)
	
	local tiledMap = import "solluco.lua"
	local width = tiledMap.layers[1].width
	local height = tiledMap.layers[1].height
	local mapData = tiledMap.layers[1].data
	tilemap:setSize(width, height)
	for i = 1, width do
		for j = 1, height do
			local tileId = mapData[i + (j - 1) * width]
	
			tilemap:setTileAtPosition(i, j, tileId)
		end
	end
	
	return tilemap
end

tilemap = initTilemap()

function playdate.update()
	pulp.audio.update()
	
	if STATE == MENU then
		local state_change = updateMenu()
		if state_change ~= nil and state_change == GAME then
			initGame()
			STATE = GAME
		end
	elseif STATE == GAME then
		updateGame()
	end
end
