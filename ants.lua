

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
	end

	function ants.testInit()
		--ants.spawn()
	end

	function ants.testUpdate()
		--if love.math.random() < 0.002 then ants.spawn() end
	end


	function ants.clear()

	end


	function ants.spawn()
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
					leaf.health = leaf.health - simulationDt / 13.0 -- 2.5 * 5
					-- Flower is shocked
					plant.screamFace()
					-- Affect leaf
					local leafGone = leaf.health < 0.0
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
					ant.y = gh
					ant.onGraph = true
					ant.fromPoint, ant.toPoint, ant.p = level.getGroundNode(ant.x)
					ant.vy = 0.0
					if ant.x > 0 then
						ant.mirror = true
					else
						ant.mirror = false
					end
				end
			end
		end

	function ants.draw()
		for i = 1,#ants.list do
			ants.drawAnt(ants.list[i])
		end
	end

		function ants.drawAnt(ant)
			local scx = ant.mirror and -0.3 or 0.3
			love.graphics.draw(ants.image, ant.x, ant.y, ant.angle + (ant.mirror and 0 or math.pi), scx, 0.3, ants.image:getWidth()/2, ants.image:getHeight())
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
			end
		end
	end


end