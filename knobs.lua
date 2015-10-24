

do

	knobs = {
		mouse = {x = 0, y = 0, leftclick = 0},
		list = {},
		dt = 0,
		radPresets = {2.0, 1.0, 0.92, 0.83, 0.75},
		timePresets = {1.0, 0.2, 0.15, 0.12, 0.1},
	}

	function knobs.load()

	end

	function knobs.update(dt)
		knobs.dt = dt
		knobs.time = love.timer.getTime()
		knobs.mouse.x, knobs.mouse.y = love.mouse.getPosition()
		knobs.mouse.leftclick = knobs.stateChange(knobs.mouse.leftclick, love.mouse.isDown("l"))
	end


	function knobs.draw(id, x, y, content)
		knobs.assureExistence(id)
		knobs.prepareElements(content)
		-- check mouse interaction
		local self = knobs.list[id]
		if knobs.mouseInSphere(x, y, knobs.list[id].hovered and 60 or 32) then
			self.hovered = true
		else
			self.hovered = false
		end
		-- update size
		if self.hovered then
			if self.zoomedIn < 1 then self.zoomedIn = clamp(self.zoomedIn + knobs.dt*3.0, 0, 1) end
		else
			if self.zoomedIn > 0 then self.zoomedIn = clamp(self.zoomedIn - knobs.dt*3.0, 0, 1) end
		end
		-- Draw basic circle
		local p = 0.5 - 0.5*math.cos(math.pi*(0.5 - 0.5*math.cos(math.pi*self.zoomedIn)))
		local size = 22 + 38*p
		love.graphics.circle("line", x, y, size)
		-- Circles inside
		if p > 0 then
			local rad = knobs.radPresets[#content]*size/2
			local dis = size - rad
			local sizeScale = (knobs.radPresets[#content]*size/2)/32
			local timeOff = -knobs.time*knobs.timePresets[#content]
			love.graphics.setColor(255,255,255,255*p)
			for i = 1,#content do
				local angle = i*2*math.pi/#content + timeOff*0.1
				local cx = x + dis*math.sin(angle)
				local cy = y + dis*math.cos(angle)
				local alpha = 255*p*(0.5 + 0.5*content[i].highlight)
				love.graphics.setColor(255,255,255,alpha)
				-- Draw actual object
				if content[i].image then
					love.graphics.draw(content[i].image, cx, cy, 0.0, sizeScale, sizeScale, 0.5*content[i].image:getWidth(), 0.5*content[i].image:getHeight())
				else
					love.graphics.circle("line", cx, cy, rad*0.9)
				end
				-- Hovering and interaction
				if knobs.mouseInSphere(cx, cy, rad) then
					if p >= 1 then
						content[i].highlight = clamp(content[i].highlight + knobs.dt*3.5, 0, 1)
						if content[i].textWidget then textWidgets.show(content[i].textWidget) end
					end
					if knobs.mouse.leftclick == 2 and content[i].clickCallback then content[i].clickCallback() end
				else
					content[i].highlight = clamp(content[i].highlight - knobs.dt*1.6, 0, 1)
				end
			end
		end
		love.graphics.setColor(255,255,255,255)
	end

	function knobs.assureExistence(id)
		while #knobs.list < id do
			table.insert(knobs.list, {hovered = false, zoomedIn = 0})
		end
	end

	function knobs.prepareElements(list)
		for i = 1,#list do
			local e = list[i]
			if not e.highlight then e.highlight = 0.0 end
		end
	end

	function knobs.mouseInSphere(x,y,r)
		local dx = knobs.mouse.x - x
		local dy = knobs.mouse.y - y
		return dx*dx + dy*dy <= r*r
	end


	function knobs.stateChange(old, current)
		return current and (old > 0 and 1 or 2) or (old > 0 and -1 or 0)
	end

end