
do

	moveGraph = {
		nodes = {}
	}


	function moveGraph.load()
		moveGraph.clear()
	end


	function moveGraph.append(x, y, parent, priority)
		local dis = 0
		if parent then
			local dx = x - parent.x
			local dy = y - parent.y
			dis = math.sqrt(dx*dx + dy*dy)
		end
		local node = {
			x = x,
			y = y,
			neighbours = parent and {{parent, dis}} or {},
			priority = priority or 1,
			inversePriority = priority and 1.0/priority or 1,
		}
		if parent then table.insert(parent.neighbours, {node,dis}) end
		table.insert(moveGraph.nodes, node)
		return node
	end

	function moveGraph.clear()
		moveGraph.nodes = {}
	end

	function moveGraph.getNextPoint(currentPoint, oldPoint, leavingPlant)
		local targets = {}
		local costSum = 0
		for i = 1,#currentPoint.neighbours do
			local point = currentPoint.neighbours[i][1] 
			if point ~= oldPoint then 
				table.insert(targets, point) 
				costSum = costSum + (leavingPlant and point.inversePriority or point.priority)
			end
		end
		-- Target Points Found?
		if targets[1] then
			-- Target Points found
			if targets[2] then
				-- Multiple target points, select random one according to each point's priority
				local r = love.math.random(costSum)-0.001
				local newPoint = targets[#targets]
				for i = 1,#targets-1 do
					local pri = (leavingPlant and targets[i].inversePriority or targets[i].priority)
					if r < pri then newPoint = i; break end
					r = r - pri
				end
			else
				-- Single target point
				return targets[1]
			end
		else
			-- No target point, go back
			return oldPoint
		end
	end


	function moveGraph.proceed(fromPoint, toPoint, p, speed, leavingPlant)
		leavingPlant = leavingPlant or false
		-- Move forward with speed
		local dx = toPoint.x - fromPoint.x
		local dy = toPoint.y - fromPoint.y
		local dis = math.sqrt(dx*dx + dy*dy)
		p = p + speed/dis
		-- Progressed to other node
		if p >= 1.0 then
			local oldPoint = fromPoint
			fromPoint = toPoint
			toPoint = moveGraph.getNextPoint(fromPoint, oldPoint)
			p = p - 1
			-- respace progress according to distance
			local dx, dy = toPoint.x - fromPoint.x, toPoint.y - fromPoint.y
			local newdis = math.sqrt(dx*dx + dy*dy)
			p = p * dis / newdis
		end
		-- Return relevant information, caller should apply these values to respective object
		return fromPoint, toPoint, p
	end


end