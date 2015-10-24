
do

	moveGraph = {
		nodes = {}
	}


	function moveGraph.load()
		moveGraph.clear()
	end


	function moveGraph.append(x, y, parent, priority, tp)
		local dis = 0
		if parent then
			local dx = x - parent.x
			local dy = y - parent.y
			dis = math.sqrt(dx*dx + dy*dy)
		end
		local node = {
			id = #moveGraph.nodes+1,
			tp = tp,
			x = x+0,
			y = y+0,
			neighbours = (parent and {{parent, dis}} or {}),
			priority = priority or 1,
			inversePriority = priority and 1.0/priority or 1,
		}
		print("Adding node at " .. x .. "," .. y .. " with id " .. node.id .. " for parent " .. (parent and parent.id or "nil"))
		print("Now has " .. #node.neighbours .. " neighbours")
		if parent then
			table.insert(parent.neighbours, {node,dis}) 
			print("Added as neighbour of node " .. parent.id)
		end
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
					if r < pri then newPoint = targets[i]; break end
					r = r - pri
				end
				return newPoint
			else
				-- Single target point
				return targets[1]
			end
		else
			-- No target point, go back
			return oldPoint
		end
	end


	function moveGraph.proceed(object, speed, leavingPlant)
		leavingPlant = leavingPlant or false
		-- Move forward with speed
		local dx = object.toPoint.x - object.fromPoint.x
		local dy = object.toPoint.y - object.fromPoint.y
		local dis = math.sqrt(dx*dx + dy*dy)
		object.p = object.p + speed/dis
		-- Progressed to other node
		if object.p >= 1.0 then
			local oldPoint = object.fromPoint
			object.fromPoint = object.toPoint
			object.toPoint = moveGraph.getNextPoint(object.fromPoint, oldPoint, leavingPlant)
			object.p = object.p - 1
			-- respace progress according to distance
			local dx, dy = object.toPoint.x - object.fromPoint.x, object.toPoint.y - object.fromPoint.y
			local newdis = math.sqrt(dx*dx + dy*dy)
			object.p = object.p * dis / newdis
		end
		-- Apply position
		local p1 = 1.0 - object.p
		local nx = object.p * object.toPoint.x + p1 * object.fromPoint.x
		local ny = object.p * object.toPoint.y + p1 * object.fromPoint.y
		local f = object.inertia or 0.97
		object.x = f*object.x + (1-f)*nx
		object.y = f*object.y + (1-f)*ny
	end



	function moveGraph.debugDraw()
		love.graphics.setColor(255,255,255,255)
		for i = 1,#moveGraph.nodes do
			local node = moveGraph.nodes[i]
			love.graphics.circle("line", node.x, node.y, 10)
			for j = 1,#node.neighbours do
				local nb = node.neighbours[j][1]
				if node.id > nb.id then
					love.graphics.line(node.x, node.y, nb.x, nb.y)
				end
			end
		end
	end

end