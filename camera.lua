
do

	camera = {
		outerFrame = {-1000, -1000, 1000, 1000}, --outer coordinates the camera view may never pass
		centerFrame = {0,0,0,0}, --coordinates the camera center may never pass
		dampedMovementWidth = 150, --pixels on outer frame that limit camera movement
		freeMoveBounds = {0,0,0,0}, --bounds in which camera center(!) can move freely, outside it's slowed down when moving to the outside
		scale = 1.0,
		position = {0,0},
		viewSize = {0,0},
		currentFrame = {0,0,0,0},
		velocity = {0,0},
		dt = 1,
	}

	function camera.load()
		camera.setScale(1.0)
		--camera.move(0,0)
	end

	function camera.setBounds(x1,y1,x2,y2)
		camera.outerFrame[1] = x1
		camera.outerFrame[2] = y1
		camera.outerFrame[3] = x2 or -x1
		camera.outerFrame[4] = y2
		camera.setScale()
	end

	function camera.setScale(scale)
		camera.scale = scale or camera.scale
		camera.viewSize = {love.window.getWidth()/camera.scale, love.window.getHeight()/camera.scale}
		camera.centerFrame[1] = camera.outerFrame[1] + camera.viewSize[1]/2
		camera.centerFrame[2] = camera.outerFrame[2] + camera.viewSize[2]/2
		camera.centerFrame[3] = camera.outerFrame[3] - camera.viewSize[1]/2
		camera.centerFrame[4] = camera.outerFrame[4] - camera.viewSize[2]/2
		camera.freeMoveBounds[1] = camera.centerFrame[1] + camera.dampedMovementWidth
		camera.freeMoveBounds[2] = camera.centerFrame[2] + camera.dampedMovementWidth
		camera.freeMoveBounds[3] = camera.centerFrame[3] - camera.dampedMovementWidth
		camera.freeMoveBounds[4] = camera.centerFrame[4] - camera.dampedMovementWidth
		camera.updateCurrentFrame()
	end

	function camera.move(dx, dy)
		local smoothing = 0.96
		local inversed = 1.0-smoothing
		camera.velocity[1] = smoothing*camera.velocity[1] + inversed*dx
		camera.velocity[2] = smoothing*camera.velocity[2] + inversed*dy
		camera.moveBy(camera.velocity[1], camera.velocity[2])
	end

	function camera.moveBy(dx, dy)
		dx = -camera.dt*dx
		dy = -camera.dt*dy
		-- Movement damped?true
		if camera.position[1] >= camera.freeMoveBounds[1] and camera.position[1] <= camera.freeMoveBounds[3] then
			if camera.position[2] >= camera.freeMoveBounds[2] and camera.position[2] <= camera.freeMoveBounds[4] then
				-- Free Movement
				camera.position[1] = camera.position[1] + dx
				camera.position[2] = camera.position[2] + dy
				camera.updateCurrentFrame()
				return
			end
		end
		-- Damped
		local freenessx = 1.0
		local freenessy = 1.0
		if camera.position[1] < camera.freeMoveBounds[1] then
			if dx < 0 then freenessx = freenessx * (camera.currentFrame[1] - camera.outerFrame[1])/camera.dampedMovementWidth end
		end
		if camera.position[1] > camera.freeMoveBounds[3] then
			if dx > 0 then freenessx = freenessx * (camera.outerFrame[3] - camera.currentFrame[3])/camera.dampedMovementWidth end
		end
		if camera.position[2] < camera.freeMoveBounds[2] then
			if dy < 0 then freenessy = freenessy * (camera.currentFrame[2] - camera.outerFrame[2])/camera.dampedMovementWidth end
		end
		if camera.position[2] > camera.freeMoveBounds[4] then 
			if dy > 0 then freenessy = freenessy * (camera.outerFrame[4] - camera.currentFrame[4])/camera.dampedMovementWidth end
		end
		camera.position[1] = camera.position[1] + freenessx*dx
		camera.position[2] = camera.position[2] + freenessy*dy
		camera.updateCurrentFrame()
	end

	function camera.updateCurrentFrame()
		-- Limit Coordinates
		camera.position[1] = clamp(camera.position[1], camera.centerFrame[1], camera.centerFrame[3])
		camera.position[2] = clamp(camera.position[2], camera.centerFrame[2], camera.centerFrame[4])
		-- Get Frame
		camera.currentFrame[1] = camera.position[1] - camera.viewSize[1]/2
		camera.currentFrame[2] = camera.position[2] - camera.viewSize[2]/2
		camera.currentFrame[3] = camera.currentFrame[1] + camera.viewSize[1]
		camera.currentFrame[4] = camera.currentFrame[2] + camera.viewSize[2]
	end


	function clamp(v, min, max) return (v < min) and min or ((v > max) and max or v) end


    function camera.control(dt, speed)
        camera.dt = dt
        speed = speed or 1000
        local mx,my = love.mouse.getPosition()
        local left = love.keyboard.isDown("left") or mx < 30
        local right = love.keyboard.isDown("right") or mx > love.window.getWidth()-30
        local up = love.keyboard.isDown("up") or my < 30
        local down = love.keyboard.isDown("down") or my > love.window.getHeight()-30 
        local rl = (right and 1 or 0) - (left and 1 or 0)
        local ud = (down  and 1 or 0) - (up   and 1 or 0)
        camera.move(rl*speed, ud*speed)
    end

end