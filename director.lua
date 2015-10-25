nextAntSpawn = math.huge

function director(dt)
    local full = true
    for i = 2, #plant.stem do 
    	if #plant.branches[i] == 0 then full = false; break end
        for j = 1, #plant.branches[i] do 
        	if plant.branches[i][j].leaf == nil then 
        		full = false 
        		break
        	end 
        end 
    end 

    if full and #plant.stem < 10 then 
    	local angleRange = 0.05 * 2 * math.pi
    	local totalAngle = plant.stem[#plant.stem]._totalAngle - 0.75 * 2 * math.pi
        local angle = randf(-angleRange - totalAngle, angleRange - totalAngle)
    	plant.stem[#plant.stem+1] = {angle = angle, angleOrigin = angle, targetLength = randf(100, 120), length = 0, 
    								 branchPosition = 0.0, creationTime = currentState.time, velocity = 0}
    	plant.branches[#plant.branches+1] = {}

    	for i = 1, #plant.branches do 
    		if #plant.branches[i] > 0 then 
    			plant.branches[i].count = (plant.branches[i].count or 0) + 0.7
    			if math.floor(plant.branches[i].count) > #plant.branches[i] and #plant.branches[i] < 4 then 
    				local j = #plant.branches[i]+1
    				local angleRange = 0.035 * 2 * math.pi
    				local angle = (j % 2 == 0 and 1 or -1) * math.pi * 2 * (0.1 - 0.025 * j) + randf(-angleRange, angleRange)
           			plant.branches[i][j] = {angle = angle, angleOrigin = angle, targetLength = randf(100, 120), length = 0, 
           									creationTime = currentState.time, velocity = 0}
    			end 
    		end 
    	end 

    	if #plant.stem == 10 then 
    		plant.headImageIndex = plant.headImageIndex + 1
    		plant.happyFace()
            lush.play("levelup.wav")
    	end 

    	if #plant.stem == 3 then 
    		nextAntSpawn = 2.0 + currentState.time
    	end 

    	plant.update(dt)
    end 

    if #plant.stem >= 4 then 
    	local interval = 20.0
    	if nextAntSpawn < currentState.time then 
    		nextAntSpawn = currentState.time + lerp(20.0, 4.0, (#plant.stem - 3)/7) + love.math.random()
    		ants.spawn()
    		lush.play("enemy_entry.wav") 
    	end 
    end 
end 