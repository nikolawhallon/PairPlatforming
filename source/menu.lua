import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local gmtry <const> = playdate.geometry
gfx.setBackgroundColor(gfx.kColorBlack)

function updateMenu()
	gfx.clear()
	gfx.setLineWidth(1)
	gfx.setColor(playdate.graphics.kColorXOR)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

	if playdate.buttonIsPressed( playdate.kButtonA ) and playdate.buttonIsPressed( playdate.kButtonB ) then		
		return GAME
	end

	gfx.drawTextAligned("Pair Platforming", 200, 120 - 16 - 4, kTextAlignment.center)
	gfx.drawTextAligned("Press A+B To Start", 200, 120 + 4, kTextAlignment.center)
		
	playdate.timer.updateTimers()
end