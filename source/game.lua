import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local gmtry <const> = playdate.geometry
gfx.setBackgroundColor(gfx.kColorBlack)

local gameOver = false

tilemapSprite = nil

TAGS = {
	player = 1,
	bat = 2,
	blob = 3
}

import "player"
players = {}

function initGame()
	gfx.sprite.removeAll()

	gameOver = false
	
	tilemapSprite = gfx.sprite.new()
	tilemapSprite:setTilemap(tilemap)
	tilemapSprite:moveTo(200, 120)
	tilemapSprite:setZIndex(1)
	tilemapSprite:add()
	gfx.sprite.addWallSprites(tilemap, {0})
	
	players[1] = Player(gmtry.point.new(100, 120), "cross")
	players[2] = Player(gmtry.point.new(300, 120), "cranky")
end

function updateGame()
	if gameOver then
		if playdate.buttonIsPressed( playdate.kButtonA ) and playdate.buttonIsPressed( playdate.kButtonB ) then		
			initGame()
		end
		
		gfx.drawTextAligned("Game Over", 200, 120 - 16 - 4, kTextAlignment.center)
		gfx.drawTextAligned("Press A+B To Retry", 200, 120 + 4, kTextAlignment.center)
				
		return
	end
	
	-- render	
	gfx.clear()
	gfx.sprite.update()
	
	playdate.timer.updateTimers()
end
