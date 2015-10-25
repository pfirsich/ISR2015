abilityIcons = {
	branch = love.graphics.newImage("images/abilityIcons/BranchIcon.png"),
	bud = love.graphics.newImage("images/abilityIcons/FlowerIcon.png"),
	leaf = love.graphics.newImage("images/abilityIcons/LeafIcon.png"),
	root = love.graphics.newImage("images/abilityIcons/RootIcon.png"),
	shake = love.graphics.newImage("images/abilityIcons/ShakeIcon.png"),
	thorns = love.graphics.newImage("images/abilityIcons/ThornsIcon.png"),
}

do
	local haloImage = love.graphics.newImage("images/effectglow.png")

	knobs = {
		mouse = {x = 0, y = 0, leftclick = 0},
		list = {},
		dt = 0,
		radPresets = {2.0, 1.0, 0.92, 0.83, 0.75},
		timePresets = {1.0, 0.2, 0.15, 0.12, 0.1},
		used = {}
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
		if currentState == gameState then 
			knobs.assureExistence(id)
			knobs.prepareElements(content)

			-- check if unused elements
			local used = true
			for i = 1, #content do 
				local key = content[i].textWidget.caption
				if knobs.used[key] == nil then 
					used = false 
					break
				end 
			end 

			local minRad, delRad = 15, 15*(#content > 1 and 2.2 or 1)

			-- check mouse interaction
			local self = knobs.list[id]
			if knobs.mouseInSphere(x, y, knobs.list[id].hovered and minRad + delRad or minRad) then
				if not self.hovered then lush.play("hover.wav") end
				self.hovered = true
			else
				self.hovered = false
			end
			-- update size
			if self.hovered then
				if self.zoomedIn < 1 then self.zoomedIn = clamp(self.zoomedIn + simulationDt*3.0, 0, 1) end
			else
				if self.zoomedIn > 0 then self.zoomedIn = clamp(self.zoomedIn - simulationDt*3.0, 0, 1) end
			end
		
			-- Draw surrounding circle
			local p = 0.5 - 0.5*math.cos(math.pi*(0.5 - 0.5*math.cos(math.pi*self.zoomedIn)))
			local size = minRad + p * delRad
			love.graphics.setColor(255, 255, 0, 255)
			if not used then 
				local scale = size / (haloImage:getWidth()/2 - 50)
				love.graphics.draw(haloImage, x, y,  currentState.time, scale, scale, haloImage:getWidth()/2, haloImage:getHeight()/2)
				love.graphics.draw(haloImage, x, y, -currentState.time, scale, scale, haloImage:getWidth()/2, haloImage:getHeight()/2)
			end 
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.circle("line", x, y, size, 32)
			-- Circles inside
			if p > 0 then
				local rad = knobs.radPresets[#content]*size/2
				local dis = size - rad
				local sizeScale = (knobs.radPresets[#content]*size/2)/128
				local timeOff = -knobs.time*knobs.timePresets[#content]*0.0 + 0.1*math.sin(knobs.time*0.8)
				love.graphics.setColor(255,255,255,255*p)
				for i = 1,#content do
					local key = content[i].textWidget.caption
					local used = knobs.used[key] ~= nil 

					local baseAngle = i*2*math.pi/#content + math.pi
					local angle = baseAngle + timeOff
					local cx = x + dis*math.sin(angle)
					local cy = y + dis*math.cos(angle)
					local alpha = 255*p*(0.5 + 0.5*content[i].highlight)
					love.graphics.setColor(255,255,255,alpha)

					-- Draw actual object
					if not used then 
						local scale = rad*0.9 / (haloImage:getWidth()/2 - 50)
						love.graphics.draw(haloImage, cx, cy,  currentState.time, scale, scale, haloImage:getWidth()/2, haloImage:getHeight()/2)
						love.graphics.draw(haloImage, cx, cy, -currentState.time, scale, scale, haloImage:getWidth()/2, haloImage:getHeight()/2)
					end
					if content[i].image then
						love.graphics.draw(content[i].image, cx, cy, 0.0, sizeScale*0.9, sizeScale*0.9, content[i].image:getWidth()/2, content[i].image:getHeight()/2)
					else
						love.graphics.circle("line", cx, cy, rad*0.9, 32)
					end

					-- Hovering and interaction
					if knobs.mouseInSphere(cx, cy, rad) then
						if p >= 1 then
							content[i].highlight = clamp(content[i].highlight + simulationDt*3.5, 0, 1)
							if content[i].textWidget then 
								textWidgets.show(content[i].textWidget, x + dis*math.sin(baseAngle), y + dis*math.cos(baseAngle)-150) 
							end
						end
						if knobs.mouse.leftclick == 2 and content[i].clickCallback then 
							local valid = true
							for j, k in ipairs({"h2o", "glucose", "minerals"}) do 
								if resources[k] - content[i].textWidget.cost[j] < 0 then 
									valid = false 
									break 
								end 
							end 
							if valid then 
								for j, k in ipairs({"h2o", "glucose", "minerals"}) do 
									resources[k] = resources[k] - content[i].textWidget.cost[j]
								end 
								knobs.used[key] = true
								content[i].clickCallback()
							else 
								lush.play("no.wav")
							end
						 end
						if knobs.mouse.leftclick == 2 then knobs.mouse.leftclick = 1 end -- hax
					else
						content[i].highlight = clamp(content[i].highlight - simulationDt*1.6, 0, 1)
					end
				end
			end
			love.graphics.setColor(255,255,255,255)
		end
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