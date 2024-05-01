import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local gmtry <const> = playdate.geometry

class('Player').extends(AnimatedSprite)

function Player:init(position, type)
	local imagetable = nil
	if type == "cross" then
		imagetable = gfx.imagetable.new("images/cross/cross")
	end
	if type == "cranky" then
		imagetable = gfx.imagetable.new("images/cranky/cranky")
	end
	assert(imagetable)

	Player.super.init(self, imagetable)

	self:addState("idle", 1, 6, { tickStep = 3 })
	self:addState("move", 7, 10, { tickStep = 3 })
	self:playAnimation()
	self:moveTo(position)
	self:setCollideRect(0, 0, self:getSize())
	self:setTag(TAGS.player)
	-- we want to handle collisions with enemies ourselves,
	-- but we want moveWithCollisions to handle collisions with wallSprites
	self.collisionResponse = function(self, other)
		if other:getTag() == TAGS.bat or other:getTag() == TAGS.blob then
			return gfx.sprite.kCollisionTypeOverlap
		end
		return gfx.sprite.kCollisionTypeSlide
	end
	self:add()
	
	self.type = type
	self.speed = 96
	self.jump = 6
	self.health = 3
	self.score = 0
	self.weight = 10
	self.velocity = gmtry.vector2D.new(0, 0)
	self.on_floor = false
end

function Player:update()
	if self.health <= 0 then
		self:setVisible(false)
		self:setCollisionsEnabled(false)
		return
	end	
	
	local seconds = 1.0 / playdate.getFPS()
	local crankChange, crankAcceleratedChange = playdate.getCrankChange()
	local crank_position = playdate.getCrankPosition()

	-- moving
	self.velocity.y += self.weight * seconds
	
	if self.type == "cross" then
		if playdate.buttonIsPressed( playdate.kButtonLeft ) then
			self.velocity.x = -self.speed * seconds
		elseif playdate.buttonIsPressed( playdate.kButtonRight ) then
			self.velocity.x = self.speed * seconds
		else
			self.velocity.x = 0.0
		end
		
		-- the commented out part is behavior I want to think more about
		if playdate.buttonJustPressed( playdate.kButtonB ) and self.on_floor then
			self.velocity.y = -self.jump
		--elseif playdate.buttonJustReleased( playdate.kButtonB ) and self.velocity.y < 0.0 then
		--	self.velocity.y = 0.0
		end
	end

	-- TODO balance out a way to do this analog
	if self.type == "cranky" then
		local tolerance = 10
		if crankChange > tolerance then
			self.velocity.x = self.speed * seconds
		elseif crankChange < -tolerance then
			self.velocity.x = -self.speed * seconds
		else
			self.velocity.x = 0.0
		end

		-- the commented out part is behavior I want to think more about
		if playdate.buttonJustPressed( playdate.kButtonA ) and self.on_floor then
			self.velocity.y = -self.jump
		--elseif playdate.buttonJustReleased( playdate.kButtonA ) and self.velocity.y < 0.0 then
		--	self.velocity.y = 0.0
		end
	end
	
	local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(self.x + self.velocity.x, self.y + self.velocity.y)
	
	-- set this to false here, because we are going to check if this is true by looking at collisions
	self.on_floor = false
	for i = 1, numberOfCollisions do
		local collision = collisions[i]
	
		assert(collision.sprite == self)
		assert(collision.sprite:getTag() == TAGS.player)
		assert(collision.sprite:getTag() == self:getTag())
	
		if collision.other:getTag() == TAGS.bat then
			if collision.normal.y == -1 then
				self.velocity.y = -self.jump
				
				local b = batIndex(collision.other)
				assert(b ~= -1)
				
				bats[b]:remove()
				table.remove(bats, b)

			end
		else
			-- this ought to be a wallSprite
			if collision.normal.y == -1 then
				self.on_floor = true
				self.velocity.y = 0.0
			elseif collision.normal.y == 1 then
				self.velocity.y = 0.0
			end
		end
	end

	if self.velocity.x > 0 then
		self.globalFlip = gfx.kImageUnflipped
	elseif self.velocity.x < 0 then
		self.globalFlip = gfx.kImageFlippedX
	end

	if self.velocity.x ~= 0 then
		self:changeState("move")
	else
		self:changeState("idle")
	end

	-- wrap the around the screen
	local x, y = self:getPosition()
	local depth = 7
	if x < 0 - depth then
		self:moveTo(400 + depth, y)
	end
	if x > 400 + depth then
		self:moveTo(0 - depth, y)
	end
	
	-- NB we have overridden AnimatedSprite:update so we need to manually call this here
	self:updateAnimation()
end
