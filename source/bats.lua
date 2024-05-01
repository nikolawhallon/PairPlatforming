import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local gmtry <const> = playdate.geometry

local imagetable = gfx.imagetable.new("images/bat/bat")
assert(imagetable)

local batSpawnInterval = 2134

bats = {}

class('Bat').extends(AnimatedSprite)

function Bat:init(position)
	Bat.super.init(self, imagetable)

	self:addState("idle", 1, 4, { tickStep = 3 })
	self:playAnimation()
	self:moveTo(position:unpack())
	self:setCollideRect(16, 10, 12, 10)
	self:setTag(TAGS.bat)
	self:setZIndex(2)
	self:add()
	
	self.velocity = gmtry.vector2D.new(-1, 0)
end

local function batTimerCallback()
	local bat = Bat(gmtry.vector2D.new(400 + 32, math.random(0, 240)))

	if bats[1] == nil then
		bats[1] = bat
	else
		table.insert(bats, bat)
	end
end

function initBats()
	for index = #bats, 1, -1 do
		table.remove(bats, index)
	end
	
	batTimer = playdate.timer.new(batSpawnInterval, batTimerCallback)
	batTimer.repeats = true
end

function removeBats()
	for index = #bats, 1, -1 do
		table.remove(bats, index)
	end
end

function removeBatTimers()
	if batTimer ~= nil then
		batTimer:remove()
		batTimer = nil
	end
end

function updateBats()
	for index = #bats, 1, -1 do
		bats[index]:moveBy(bats[index].velocity:unpack())
		
		if bats[index].velocity.x <= 0 then
			bats[index].globalFlip = gfx.kImageFlippedX
		else
			bats[index].globalFlip = gfx.kImageUnflipped
		end
		
		local x, _ = bats[index]:getPosition()
		if x < 0 - 32 then
			bats[index]:remove()
			table.remove(bats, index)
		end
	end
end

-- TODO extract this for all such objects?
function batIndex(bat) 
	for index, other in pairs(bats) do
		if bat == other then
			return index
		end
	end
	
	return -1
end
