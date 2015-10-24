
do

	moveGraph = {
		nodes = {}
	}


	function moveGraph.load()
		moveGraph.clear()
	end


	function moveGraph.append(x, y, parent)
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
		}
		if parent then table.insert(parent.neighbours, {node,dis}) end
		table.insert(moveGraph.nodes, node)
		return node
	end

	function moveGraph.clear()
		moveGraph.nodes = {}
	end



end