

do

	ants = {
		list = {},
		speed = 1.0,
		gravity = 800,
		eatDuration = 5.0,
	}


	function ants.load()
		ants.image = love.graphics.newImage("images/ant.png")
		ants.list = {}
		ants.walkImages = {}
		for i = 1,24 do
			ants.walkImages[i] = love.graphics.newImage("images/ant/walk/Ant_" .. (i-1) .. ".png")
		end
		ants.eatImages = {}
		for i = 1,24 do
			ants.eatImages[i] = love.graphics.newImage("images/ant/eat/Ant_" .. (i-1) .. ".png")
		end
	end

	function ants.testInit()
		--ants.spawn()
	end

	function ants.testUpdate()
		--if love.math.random() < 0.002 then ants.spawn() end
	end


	function ants.clear()

	end


	function ants.spawn(delaySeconds, count)
		count = count or 1
		if count <= 0 then return end
		if delaySeconds then
			if #plant.stem < 4 then return end
			delay(function() ants.spawn(); ants.spawn(delaySeconds, count-1) end, delaySeconds)
			return
		end
		local rightSide = (love.math.random() > 0.5)
		local ant
		if not rightSide then
			ant = ants.create(level.leftEntryPoint)
			ant.mirror = true
		else
			ant = ants.create(level.rightEntryPoint)
		end
		return ant
	end

	function ants.create(graphNode)
		local ant = {
			onGraph = true,
			eating = false,
			goingHome = false,
			fromPoint = graphNode,
			toPoint = graphNode.neighbours[1][1],
			p = 0.0,
			x = graphNode.x,
			y = graphNode.y,
			angle = 0,
			mirror = false,
			speed = ants.speed * (0.7 + 0.3*love.math.random()),
			vx = 0.0,
			vy = 0.0,
			inertia = 0.97,
			damageIndicator = 0.0,
			life = 1.0,
			alpha = 1.0, -- used to fadeOut when killing
		}
		table.insert(ants.list, ant)
		return ant
	end


	function ants.update()
		-- loop backwards because ants may get removed during update
		for i = #ants.list,1,-1 do
			ants.updateAnt(ants.list[i])
		end
		-- Shake?
		if plant.shakeAmp > 0 then
			ants.shakeOff()
		end
	end

		function ants.updateAnt(ant)
			-- Alive?
			if ant.life > 0.0 then
				-- Move forward
				if ant.onGraph then
					-- Movement on Graph
					ant.prevx = ant.x
					ant.prevy = ant.y
						local speed = (ant.eating and 0.0 or ant.speed) * (love.keyboard.isDown("lshift") and 6 or 1)
					local change = moveGraph.proceed(ant, speed, ant.goingHome)
					-- fix ants going below ground
					if ant.toPoint.tp == "ground" and ant.fromPoint.tp == "ground" and simulationDt > 0 then
						if ant.vx >  0.1 then ant.mirror = true end
						if ant.vx < -0.1 then ant.mirror = false end
					else
						if ant.fromPoint.tp == "leaf" then plant.sadFace() end
					end
					-- Apply force to leaves and branches
					if ant.toPoint.tp == "plant" and ant.toPoint.branchIndex then
						if ant.toPoint.branchIndex >= 1 and ant.toPoint.branchIndex < #plant.branches[ant.toPoint.stemIndex] then
	        				applyForce(plant.branches[ant.toPoint.stemIndex], ant.toPoint.branchIndex+1,  0.0, 0.01,  1.0, simulationDt)
						end
					end
					if ant.toPoint.tp == "leaf" and ant.toPoint.branchIndex then 
						if ant.toPoint.branchIndex >= 2 then 
							applyForce(plant.branches[ant.toPoint.stemIndex], ant.toPoint.branchIndex,  0.0, 0.01,  1.0, simulationDt)
						end 
					end 
					-- Damaged by Thorns?
					if ant.fromPoint.stemIndex and not ant.fromPoint.branchIndex and ant.toPoint.stemIndex and not ant.toPoint.branchIndex then
						-- ant on stem 
						local index = ((ant.vy < 0) and ant.fromPoint.stemIndex or ant.toPoint.stemIndex)
						if plant.stem[index] and plant.stem[index].thorns then
							-- damage ant
							--if ant.life >= 1.0 then lush.play("enemy_hit.wav") end
							local killed = ants.damage(ant, simulationDt*0.3)
							if killed then return end
						end
					end
					-- TODO leaf noch!
					-- eating vs movement
					if not ant.eating then
						ant.vx = (ant.x - ant.prevx)/simulationDt
						ant.vy = (ant.y - ant.prevy)/simulationDt
						-- Compute interpolated new angle
						local target_angle = 0.5*math.pi - math.atan2(ant.vx, ant.vy)
						local angle_dif = (target_angle - ant.angle)/(2*math.pi)
						angle_dif = (angle_dif - math.floor(angle_dif))*(2*math.pi)
						if angle_dif > math.pi then angle_dif = angle_dif - 2*math.pi end
						ant.angle = 0.92*ant.angle + 0.08*(ant.angle + angle_dif)
						-- Moved outside?
						if ant.toPoint == level.leftEntryPoint or ant.toPoint == level.rightEntryPoint then
							ants.deleteAnt(ant)
						else
							-- Start Eating when walking on a leaf
							if ant.fromPoint.tp == "leaf" and not ant.goingHome then
								ant.eating = true
								ant.eatingTimeRemaining = ants.eatDuration
								ant.inertia = 0.92
								lush.play("eating.wav")
							end
						end
					else
						local leaf = plant.branches[ant.fromPoint.stemIndex][ant.fromPoint.branchIndex].leaf
						if leaf then
							leaf.health = leaf.health - simulationDt / 13.0 -- 2.5 * 5
							-- Flower is shocked
							plant.screamFace()
							-- Affect leaf
							local leafGone = leaf.health < 0.0
							-- Fall down
							if leafGone then
								ant.onGraph = false
								ant.eating = false
								ant.goingHome = true
							end
						end
						-- Eating update
						ant.eatingTimeRemaining = ant.eatingTimeRemaining - simulationDt
						if ant.eatingTimeRemaining <= ants.eatDuration/2 and ant.eatingTimeRemaining + simulationDt >= ants.eatDuration/2 then 
							lush.play("eating.wav")
						end

						if ant.eatingTimeRemaining <= 0.0 or leafGone then
							ant.eating = false
							ant.goingHome = true
							ant.inertia = 0.97
						end
					end
				else
					-- Fall Gravity
					ant.vy = ant.vy + ants.gravity*simulationDt
					-- Movement
					ant.x = ant.x + ant.vx*simulationDt
					ant.y = ant.y + ant.vy*simulationDt
					-- Check Ground
					local gh = level.getGroundHeight(ant.x)
					if ant.y > gh then
						local killed = ants.damage(ant, ant.vy*0.0005)
						if not killed then
							ant.y = gh
							ant.onGraph = true
							ant.fromPoint, ant.toPoint, ant.p = level.getGroundNode(ant.x)
							-- randomly inverse
							local inverse = false
							if love.math.random() > 0.6 then
								ant.fromPoint, ant.toPoint = ant.toPoint, ant.fromPoint
								ant.p = 1.0 - ant.p
								inverse = true
							end
							ant.vy = 0.0
							if ant.x > 0 ~= inverse then
								ant.mirror = true
							else
								ant.mirror = false
							end
						end
					end
				end
				-- Damage Indicator
				if ant.damageIndicator > 0.0 then
					ant.damageIndicator = ant.damageIndicator - simulationDt*2.5
					if ant.damageIndicator < 0.0 then ant.damageIndicator = 0.0 end
				end
			else
				-- Ant is dead
				-- Fall Gravity
				ant.vy = ant.vy + ants.gravity*simulationDt
				-- Movement
				ant.x = ant.x + ant.vx*simulationDt
				ant.y = ant.y + ant.vy*simulationDt
				local gh = level.getGroundHeight(ant.x) - 40
				if ant.y >= gh then
					ant.vy = 0.1
					ant.vx = 0.8*ant.vx
					ant.alpha = ant.alpha - simulationDt*0.2
					if ant.alpha <= 0.0 then ants.deleteAnt(ant) end
				end
			end
		end


	function ants.damage(ant, dmg)
		ant.life = ant.life - dmg
		if ant.damageIndicator <= 0.0 then ant.damageIndicator = 1.0; lush.play("enemy_hit.wav") end
		if ant.life <= 0 then
			-- this kills the ant
			ants.kill(ant)
			return 1
		end
		return false
	end

	function ants.kill(ant)
		ant.life = 0.0
		ant.onGraph = false
		ant.damageIndicator = 0.0
		if resources then resources.minerals = resources.minerals + 10 end
	end

	function ants.draw()
		for i = 1,#ants.list do
			ants.drawAnt(ants.list[i])
		end
		love.graphics.setColor(255,255,255,255)
	end

		function ants.drawAnt(ant)
			local sc = 0.8
			local scx = ant.mirror and -sc or sc
			local c = 255-200*ant.damageIndicator
			love.graphics.setColor(255, c, c, c*ant.alpha)
			-- figure out which image to use
			local img
			if ant.eating then
				img = ants.eatImages[1 + (math.floor(currentState.time*40) % 24)]
			else
				if ant.onGraph then
					img = ants.walkImages[1 + (math.floor(currentState.time*40) % 24)]
				else
					-- Falling
					img = ants.walkImages[1]
				end
			end
			love.graphics.draw(img, ant.x, ant.y, ant.angle + (ant.mirror and 0 or math.pi), scx, sc, img:getWidth()/2, img:getHeight()*0.7)
		end


	function ants.deleteAnt(ant)
		-- find in array and remove
		for i = 1,#ants.list do
			if ants.list[i] == ant then
				table.remove(ants.list, i)
				return true
			end
		end
		return false
	end


	function ants.shakeOff()
		for i = 1,#ants.list do
			-- check whether ant is on tree
			if ants.list[i].onGraph and ants.list[i].fromPoint.id > level.rightEntryPoint.id then
				-- shake it off
				ants.list[i].onGraph = false
				ants.list[i].eating = false
			end
		end
	end


end