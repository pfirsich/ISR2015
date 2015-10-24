

do

	ants = {
		list = {},
		speed = 1.7,
		gravity = 800,
		eatDuration = 5.0,
	}


	function ants.load()
		ants.image = love.graphics.newImage("images/ant.png")
		ants.list = {}
	end

	function ants.testInit()
		ants.spawn()
	end

	function ants.testUpdate()
		if love.math.random() < 0.002 then ants.spawn() end
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
				ant.prevx = ant.x
				ant.prevy = ant.y
				-- Movement on Graph
				local change = moveGraph.proceed(ant, ant.eating and 0.0 or ant.speed, ant.goingHome)
				ant.vx = (ant.x - ant.prevx)/simulationDt
				ant.vy = (ant.y - ant.prevy)/simulationDt
				if not ant.eating then
					ant.angle = 0.5*math.pi - math.atan2(ant.vx, ant.vy)
					-- Moved outside?
					if ant.toPoint == level.leftEntryPoint or ant.toPoint == level.rightEntryPoint then
						ants.deleteAnt(ant)
					else
						if ant.fromPoint.tp == "leaf" and not ant.goingHome then
							ant.eating = true
							ant.eatingTimeRemaining = ants.eatDuration
							ant.inertia = 0.7
						end
					end
				else
					-- Eating update
					ant.eatingTimeRemaining = ant.eatingTimeRemaining - simulationDt
					if ant.eatingTimeRemaining <= 0.0 then
						ant.eating = false
						ant.goingHome = true
						ant.inertia = 0.97
					end
					-- Affect leaf
					-- ...
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