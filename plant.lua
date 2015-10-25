plant = {}
plant.stem = {}
plant.branches = {}
plant.stemTexture = love.graphics.newImage("images/stem.png")
plant.leafImage = love.graphics.newImage("images/leaf.png")
plant.stalkMesh = love.graphics.newMesh(50, plant.stemTexture, "triangles")
plant.headImages = {love.graphics.newImage("images/FlowerBud.png"), love.graphics.newImage("images/FlowerOne.png"), love.graphics.newImage("images/FlowerTwo.png")}
plant.headImageIndex = 1
plant.shakeAmp = 0

plant.mouthOpen = 0.0
plant.targetMouthOpen = 0.0
plant.mouthScale = 1.0 
plant.targetMouthScale = 1.0
plant.blink = 0.0
plant.nextBlink = 0
plant.targetBlink = 0.0

function plant.happyFace()
    plant.targetMouthOpen = 1.0
    plant.targetMouthScale = 1.0
end 

function plant.defaultFace()
    plant.targetMouthOpen = 0.0
    plant.targetMouthScale = 1.0
end 

function plant.sadFace()
    plant.targetMouthOpen = 0.0
    plant.targetMouthScale = -1.0
end 

function plant.screamFace()
    plant.targetMouthOpen = 1.0
    plant.targetMouthScale = -1.0
end 

function smallPlant()
    local totalAngle = 0
    local angleRange = 0.05 * 2 * math.pi
    for i = 1, 2 do 
        local angle = randf(-angleRange - totalAngle, angleRange - totalAngle)
        table.insert(plant.stem, {angle = angle, angleOrigin = angle, length = randf(100, 120), branchPosition = 0.0, velocity = 0})
        totalAngle = totalAngle + angle
    end 
    plant.stem[1].angle = 0.75 * 2 * math.pi
    plant.stem[1].angleOrigin = plant.stem[1].angle

    for i = 1, #plant.stem do 
        plant.branches[i] = {}
    end 
end 

function generatePlant()
    local stemSegments = 7
    local totalAngle = 0
    local angleRange = 0.05 * 2 * math.pi
    for i = 1, stemSegments do 
        local angle = randf(-angleRange - totalAngle, angleRange - totalAngle)
    	table.insert(plant.stem, {angle = angle, angleOrigin = angle, length = randf(100, 120), branchPosition = 0.0, velocity = 0})
        totalAngle = totalAngle + angle
    end 
    plant.stem[1].angle = 0.75 * 2 * math.pi + plant.stem[1].angle
    plant.stem[1].angleOrigin = plant.stem[1].angle

    angleRange = 0.035 * 2 * math.pi
    plant.branches[1] = {}
    --plant.branches[stemSegments-1] = {}
    plant.branches[stemSegments] = {}
    for i = 2, stemSegments - 1 do 
        local branch = {}
        totalAngle = 0
        for j = 1, 3 - math.floor(2.0 * i / stemSegments) do
            local leaf = nil 
            if love.math.random() < 0.5 then 
                leaf = {}
                local leafAngleRange = 0.05 * 2 * math.pi
                leaf.angle = randf(-leafAngleRange, leafAngleRange) + 0.1 * 2 * math.pi * (i % 2 == 0 and 1 or -1)
                leaf.flip = i % 2 == 1
                leaf.angleOrigin = leaf.angle
                leaf.scale = randf(0.2, 0.25)
                leaf.velocity = 0
            end 
            local angle = (j % 2 == 0 and 1 or -1) * math.pi * 2 * (0.1 - 0.025 * j) + randf(-angleRange, angleRange)
            branch[j] = {angle = angle, angleOrigin = angle, length = randf(100, 120), velocity = 0, leaf = leaf}
            totalAngle = totalAngle + angle
        end 
        branch[1].angle = 0.18 * (i % 2 == 0 and 1 or -1) * 2 * math.pi
        branch[1].angleOrigin = branch[1].angle
        plant.branches[i] = branch
    end 
end

function getThickness(startThickness, endThickness, t)
    return startThickness + (endThickness - startThickness) * math.pow(t, 0.7)
end 

function drawStalk(points, startThickness, endThickness)
    -- smooth
    for pass = 1, 0 do 
        for i = 1 + 2, #points - 2, 2 do 
            local meanX = (points[i+0] + points[i+0-2] + points[i+0+2]) / 3.0
            local meanY = (points[i+1] + points[i+1-2] + points[i+1+2]) / 3.0
            points[i+0], points[i+1] = meanX, meanY
        end 
    end 

    local getNormal = function(i)
        local tangentX, tangentY = 0, 0
        if i >= 3 then 
            local localTangentX, localTangentY = points[i+0] - points[i-2+0], points[i+1] - points[i-2+1]
            local len = math.sqrt(localTangentX*localTangentX + localTangentY*localTangentY)
            tangentX, tangentY = tangentX + localTangentX/len, tangentY + localTangentY/len
        end 

        if i <= #points - 3 then 
            local localTangentX, localTangentY = points[i+2+0] - points[i+0], points[i+2+1] - points[i+1]
            local len = math.sqrt(localTangentX*localTangentX + localTangentY*localTangentY)
            tangentX, tangentY = tangentX + localTangentX/len, tangentY + localTangentY/len
        end 

        local len = math.sqrt(tangentX*tangentX + tangentY*tangentY)
        return -tangentY/len, tangentX/len -- do i have to divide by two for a proper mean here? it would not be normalized.
    end

    local vertices = {}
    for i = 1, #points - 2, 2 do 
        local normalX, normalY = getNormal(i)
        local nextNormalX, nextNormalY = getNormal(i+2)
        local thickness = getThickness(startThickness, endThickness, (i-1) / (#points - 1))
        local nextThickness = getThickness(startThickness, endThickness, (i+2-1) / (#points - 1))

        normalX, normalY = normalX * thickness/2, normalY * thickness/2
        nextNormalX, nextNormalY = nextNormalX * nextThickness/2, nextNormalY * nextThickness/2
        vertices[#vertices+1] = {points[i+0] - normalX, points[i+1] - normalY, 0, 1}
        vertices[#vertices+1] = {points[i+0] + normalX, points[i+1] + normalY, 1, 1}
        vertices[#vertices+1] = {points[i+2] + nextNormalX, points[i+3] + nextNormalY, 1, 0}

        vertices[#vertices+1] = {points[i+0] - normalX, points[i+1] - normalY, 0, 1}
        vertices[#vertices+1] = {points[i+2] + nextNormalX, points[i+3] + nextNormalY, 1, 0}
        vertices[#vertices+1] = {points[i+2] - nextNormalX, points[i+3] - nextNormalY, 0, 0}
    end 

    plant.stalkMesh:setVertices(vertices)
    love.graphics.draw(plant.stalkMesh)
end  

function plant.update(dt)
    -- animations
    for i = 1, #plant.stem do 
        bounceInto(plant.stem[i], "targetLength", "length")

        for j = 1, #plant.branches[i] do 
            bounceInto(plant.branches[i][j], "targetLength", "length")

            local leaf = plant.branches[i][j].leaf 
            if leaf then bounceInto(leaf, "targetScale", "scale") end 
        end 
    end 

	-- update positions
    local totalAngle = 0
    local cursorX, cursorY = unpack(level.plantAttachmentPosition)
    local danceAmpAngle = love.timer.getTime() / 60.0 * 170 * 2*math.pi -- 170 bpm
    plant.danceAmplitude = math.cos(danceAmpAngle) * (0 + plant.shakeAmp)

    local maxShakeAmp = 12.0
    if love.keyboard.isDown(" ") then 
        if plant.shakeAmp < 0.01 then 
            lush.play("leaves.wav")
            plant.screamFace()
        end 

        plant.shakeAmp = plant.shakeAmp + dt*maxShakeAmp*5.0
        if plant.shakeAmp > maxShakeAmp then plant.shakeAmp = maxShakeAmp end
    else 
        if plant.shakeAmp > 0.0 then 
            plant.shakeAmp = plant.shakeAmp - dt*maxShakeAmp
            if plant.shakeAmp < 0.0 then 
                plant.shakeAmp = 0.0 
                plant.defaultFace()
            end
        end
    end 

    for i = 1, #plant.stem do 
        local danceAngle = (i-1) / (#plant.stem-1) * 2 * math.pi
        local nextDanceAngle = (i-1+1) / (#plant.stem-1) * 2 * math.pi
        local danceOffset = math.sin(danceAngle) * plant.danceAmplitude
        local nextDanceOffset = math.sin(nextDanceAngle) * plant.danceAmplitude
        danceOffset = danceOffset < 0 and -math.pow(-danceOffset, 0.7) or math.pow(danceOffset, 0.7)
        nextDanceOffset = nextDanceOffset < 0 and -math.pow(-nextDanceOffset, 0.7) or math.pow(nextDanceOffset, 0.7)

        local nextTotalAngle = totalAngle + plant.stem[i].angle
        local nextX, nextY = math.cos(nextTotalAngle) * plant.stem[i].length + cursorX, math.sin(nextTotalAngle) * plant.stem[i].length + cursorY

        plant.stem[i]._x, plant.stem[i]._y = cursorX + danceOffset, cursorY
        plant.stem[i]._nextX, plant.stem[i]._nextY = nextX + nextDanceOffset, nextY
        plant.stem[i]._totalAngle = nextTotalAngle

        local branchCursorX, branchCursorY = lerp(cursorX, nextX, plant.stem[i].branchPosition), lerp(cursorY, nextY, plant.stem[i].branchPosition)
        local totalBranchAngle = nextTotalAngle + math.atan(math.cos(danceAngle)) * plant.danceAmplitude * 0.01
        for j = 1, #plant.branches[i] do 
            local nextBranchAngle = totalBranchAngle + plant.branches[i][j].angle 
            local nextBranchX, nextBranchY = math.cos(nextBranchAngle) * plant.branches[i][j].length + branchCursorX, math.sin(nextBranchAngle) * plant.branches[i][j].length + branchCursorY
            
            plant.branches[i][j]._x, plant.branches[i][j]._y = branchCursorX + danceOffset, branchCursorY
            plant.branches[i][j]._nextX, plant.branches[i][j]._nextY = nextBranchX + danceOffset, nextBranchY
            plant.branches[i][j]._totalAngle = nextBranchAngle

            branchCursorX, branchCursorY = nextBranchX, nextBranchY
            totalBranchAngle = nextBranchAngle

            if plant.branches[i][j].leaf then 
                local angle = plant.branches[i][j]._totalAngle
                plant.branches[i][j].leaf._x = math.cos(angle) * plant.branches[i][j].length + plant.branches[i][j]._x
                plant.branches[i][j].leaf._y = math.sin(angle) * plant.branches[i][j].length + plant.branches[i][j]._y
            end 
        end 

        cursorX, cursorY = nextX, nextY
        totalAngle = nextTotalAngle
    end

    -- apply wind
    local surge = love.math.noise(love.timer.getTime() * 0.1)
    surge = surge * surge * surge; surge = surge * surge;
    local windAmp = (love.math.noise(love.timer.getTime()) + love.math.noise(love.timer.getTime() * 1.235335) + surge*5.0) * 0.00015
    local windX, windY = -windAmp, 0

    for i = 2, #plant.stem do 
        applyForce(plant.stem, i, windX, windY, 1.0, dt)

        for j = 2, #plant.branches[i] do 
            applyForce(plant.branches[i], j, windX, windY, 0.1, dt)

            local leaf = plant.branches[i][j].leaf
            if leaf then 
                local inertia = 0.5
                local angle = plant.branches[i][j]._totalAngle + leaf.angle
                local relX, relY = math.cos(angle) * plant.leafImage:getWidth() * leaf.scale, math.sin(angle) * plant.leafImage:getWidth() * leaf.scale
                --local relX, relY = leaf._x - plant.branches[i][j]._nextX, leaf._y - plant.branches[i][j]._nextY
                leaf.velocity = leaf.velocity + (relX * windY - relY * windX) * dt / inertia
            end 
        end
    end 

    -- reset force, friction and integration
    for i = 1, #plant.stem do 
        plant.stem[i].velocity = plant.stem[i].velocity + (plant.stem[i].angleOrigin - plant.stem[i].angle) * dt * 10.0
        plant.stem[i].velocity = plant.stem[i].velocity - plant.stem[i].velocity * dt * 1.0
        plant.stem[i].angle = plant.stem[i].angle + plant.stem[i].velocity * dt

        for j = 1, #plant.branches[i] do 
            plant.branches[i][j].velocity = plant.branches[i][j].velocity + (plant.branches[i][j].angleOrigin - plant.branches[i][j].angle) * dt * 10.0 --5
            plant.branches[i][j].velocity = plant.branches[i][j].velocity - plant.branches[i][j].velocity * dt * 0.1
            plant.branches[i][j].angle = plant.branches[i][j].angle + plant.branches[i][j].velocity * dt

            local leaf = plant.branches[i][j].leaf
            if leaf then 
                leaf.velocity = leaf.velocity + (leaf.angleOrigin - leaf.angle) * dt * 10.0 --5
                leaf.velocity = leaf.velocity - leaf.velocity * dt * 0.1
                leaf.angle = leaf.angle + leaf.velocity * dt
            end 
        end
    end 

    -- face 
    if currentState.time > plant.nextBlink then 
        plant.targetBlink = 1.0 - plant.targetBlink
        if plant.targetBlink < 0.5 then 
            plant.nextBlink = currentState.time + 2.0 + love.math.random() * 3.0
        else 
            plant.nextBlink = currentState.time + 0.1
        end
    end 
    
    plant.blink = plant.blink + (plant.targetBlink - plant.blink) * dt * 20.0
    plant.mouthOpen = plant.mouthOpen + (plant.targetMouthOpen - plant.mouthOpen) * dt * 10.0
    plant.mouthScale = plant.mouthScale + (plant.targetMouthScale - plant.mouthScale) * dt * 10.0
end

function bounceInto(object, targetKey, key)
    if object.creationTime and object.creationTime + 2.0 > currentState.time then 
        local t = (currentState.time - object.creationTime) * 22.0
        object[key] = object[targetKey] * (1.0 - math.cos(t)*math.pow(t+1, -1.5))
    else 
        if object[targetKey] then object[key] = object[targetKey] end
    end 
end

function sampleLine(table, samples, interp, lastInTable)
    for n = 1, samples do 
        local t = (n-1) / (samples - (lastInTable and 1 or 0))
        local x, y = interp(t)
        table[#table+1] = x
        table[#table+1] = y
    end 
end

function interpStalk(segments, i, smoothness)
    return function(t)
        local velFromX, velFromY = nil, nil
        if i == 1 then 
            velFromX, velFromY = 0, 0
        else 
            velFromX = segments[i]._nextX - segments[i-1]._x
            velFromY = segments[i]._nextY - segments[i-1]._y
        end
        local len = math.sqrt(velFromX*velFromX + velFromY*velFromY) + 0.1
        velFromX, velFromY = velFromX / len * smoothness, velFromY / len * smoothness

        local velToX, velToY = nil, nil 
        if i == #segments then 
            velToX, velToY = 0, 0
            -- velToX = segments[i]._nextX - segments[i]._x
            -- velToY = segments[i]._nextY - segments[i]._y
        else 
            velToX = segments[i+1]._nextX - segments[i+1-1]._x
            velToY = segments[i+1]._nextY - segments[i+1-1]._y
        end 
        len = math.sqrt(velToX*velToX + velToY*velToY) + 0.1
        velToX, velToY = velToX / len * smoothness, velToY / len * smoothness

        --love.graphics.setColor(255, 255, 0)
        --love.graphics.line(segments[i]._x, segments[i]._y, segments[i]._x + velFromX, segments[i]._y + velFromY)
        --love.graphics.line(segments[i]._nextX, segments[i]._nextY, segments[i]._nextX - velToX, segments[i]._nextY - velToY)

        return bezier(segments[i]._x, segments[i]._nextX, segments[i]._x + velFromX, segments[i]._nextX - velToX, t), 
               bezier(segments[i]._y, segments[i]._nextY, segments[i]._y + velFromY, segments[i]._nextY - velToY, t) 
    end
end

function plant.draw()
    love.graphics.push()
    love.graphics.translate(0, 0)
    love.graphics.scale(1.0)
    love.graphics.setColor(0, 255, 0)
    local start = love.timer.getTime()

    local stemPoints = {}
    for i = 1, #plant.stem do 
        local stemSamples = 10
        local stemSmoothness = 30
        sampleLine(stemPoints, stemSamples, interpStalk(plant.stem, i, stemSmoothness), i == #plant.stem)

        local branchPoints = {}
        for j = 1, #plant.branches[i] do 
            local branchSamples = 8
            local branchSmoothness = 20
            sampleLine(branchPoints, branchSamples, interpStalk(plant.branches[i], j, branchSmoothness), j == #plant.branches[i])
        end 
        if #branchPoints > 0 then drawStalk(branchPoints, 25, 5) end

        for j = 1, #plant.branches[i] do 
            --love.graphics.circle("fill", plant.branches[i][j]._x, plant.branches[i][j]._y, 20, 12)
        end 

        for j = #plant.branches[i], 1, -1 do 
            local leaf = plant.branches[i][j].leaf
            if leaf then 
                local scale = plant.branches[i][j].leaf.scale
                love.graphics.draw(plant.leafImage, leaf._x, leaf._y, leaf.angle + plant.branches[i][j]._totalAngle, 
                                   scale, scale * (leaf.flip and -1 or 1), 25, 128)
            end 
        end 
    end

    drawStalk(stemPoints, 50, 10)
    love.graphics.setColor(255, 0, 0)
    for i = 1, #stemPoints, 2 do 
        --love.graphics.circle("line", stemPoints[i], stemPoints[i+1], 5, 12)
    end 
    love.graphics.setColor(0, 0, 255)
    for i = 1, #plant.stem do 
        --love.graphics.circle("fill", plant.stem[i]._x, plant.stem[i]._y, 8, 12)
    end 

    --print("taken: ", 1000.0 * (love.timer.getTime() - start))
    local headAngle = plant.danceAmplitude * 0.01
    love.graphics.setColor(255, 255, 255)
    local flowerHeadScale = lerp(0.3, 0.5, (#plant.stem - 3) / 7)
    local img = plant.headImages[plant.headImageIndex]
    love.graphics.draw(img, stemPoints[#stemPoints-1], stemPoints[#stemPoints], headAngle, 
                       flowerHeadScale, flowerHeadScale, 512, 768)

    local faceOffset = {0, 0,    -92*flowerHeadScale, -300*flowerHeadScale,   0, -67*flowerHeadScale}
    local scale = {0.0,   2.0*flowerHeadScale,   3.0*flowerHeadScale}

    love.graphics.push()
    local mouthX, mouthY = stemPoints[#stemPoints-1], stemPoints[#stemPoints]
    love.graphics.translate(mouthX, mouthY)
    love.graphics.rotate(headAngle)
    love.graphics.translate(faceOffset[plant.headImageIndex*2-1+0], faceOffset[plant.headImageIndex*2-1+1])
    love.graphics.scale(scale[plant.headImageIndex], scale[plant.headImageIndex])
    mouthX, mouthY = camera.worldToScreen(mouthX, mouthY)
    local relX, relY = love.mouse.getX() - mouthX, love.mouse.getY() - mouthY
    local dist = math.sqrt(relX*relX + relY*relY)
    local lastCloseFace = plant.closeToFace
    plant.closeToFace = dist < 200
    if plant.closeToFace and not lastCloseFace then 
        plant.happyFace()
    end 
    if not plant.closeToFace and lastCloseFace then 
        plant.defaultFace()
    end 
    if not plant.closeToFace then 
        relX, relY = 0, 1
    end 
    drawMouth(plant.mouthOpen, plant.mouthScale, plant.blink, relX, relY)
    love.graphics.pop()

    love.graphics.pop()

    love.graphics.push()
    love.graphics.origin()
    if plant.headImageIndex == 1 then 
        local sx, sy = camera.worldToScreen(stemPoints[#stemPoints-1], stemPoints[#stemPoints]) 
        knobs.draw(20, sx, sy, {
            {textWidget = textWidgets.list["openBud"], clickCallback = function()
                plant.headImageIndex = plant.headImageIndex + 1
                lush.play("levelup.wav")
            end}
        })
    else 
        for i = 2, #plant.stem do 
            if #plant.branches[i] == 0 then
                local sx, sy = camera.worldToScreen(plant.stem[i]._x, plant.stem[i]._y) 
                knobs.draw(100*i, sx, sy, {
                    {textWidget = textWidgets.list["createBranch"], clickCallback = function()
                        local branchSeg = {}
                        branchSeg.angle = 0.18 * (i % 2 == 0 and 1 or -1) * 2 * math.pi
                        branchSeg.angleOrigin = branchSeg.angle
                        branchSeg.targetLength = randf(100, 120)
                        branchSeg.creationTime = currentState.time
                        branchSeg.velocity = 0
                        plant.branches[i] = {branchSeg}
                        plant.branches[i].count = 1
                        plant.happyFace()
                        plant.update(simulationDt)
                        lush.play("ability.wav")
                    end}
                })
            else 
                for j = 1, #plant.branches[i] do 
                    if plant.branches[i][j].leaf == nil then 
                        local sx, sy = camera.worldToScreen(plant.branches[i][j]._nextX, plant.branches[i][j]._nextY) 
                        knobs.draw(100*i + j, sx, sy, {
                            {textWidget = textWidgets.list["createLeaf"], clickCallback = function()
                                leaf = {}
                                local leafAngleRange = 0.05 * 2 * math.pi
                                leaf.angle = randf(-leafAngleRange, leafAngleRange) + 0.1 * 2 * math.pi * (i % 2 == 0 and 1 or -1)
                                leaf.flip = i % 2 == 1
                                leaf.angleOrigin = leaf.angle
                                leaf.targetScale = randf(0.2, 0.25)
                                leaf.velocity = 0
                                leaf.creationTime = currentState.time
                                plant.branches[i][j].leaf = leaf
                                plant.happyFace()
                                plant.update(simulationDt)
                                lush.play("ability.wav")
                            end}
                        })
                    else -- level up + drop leaves
                        -- local sx, sy = camera.worldToScreen(plant.branches[i][j]._nextX, plant.branches[i][j]._nextY) 
                        -- knobs.draw(100*i + j, sx, sy, {
                        --     {textWidget = textWidgets.list["dropLeaf"], clickCallback = function()
                        --         plant.branches[i][j].leaf.wither = true
                        --     end}
                        -- })
                    end 
                end 
            end 
        end
    end
    love.graphics.pop()
end

function applyForce(elements, index, forceX, forceY, inertia, dt)
    local relX, relY = elements[index]._x - elements[index-1]._x, elements[index]._y - elements[index-1]._y
    elements[index-1].velocity = elements[index-1].velocity + (relX * forceY - relY * forceX) * dt / inertia
end


function plant.appendToGraph()
    plant.update(0)
    -- Stem
    local prev = level.plantAttachmentNode
    for i = 2, #plant.stem do
        prev = moveGraph.append(0,0, prev, 100, "plant")
        -- Branches
        plant.stem[i].graphNode = prev
        local bprev = prev
        for j = 1, #plant.branches[i] do
            bprev = moveGraph.append(0,0, bprev, 200, "plant")
            plant.branches[i][j].graphNode = bprev
            if plant.branches[i][j].leaf then
                plant.branches[i][j].leaf.graphNode = moveGraph.append(plant.branches[i][j]._x, plant.branches[i][j]._y+50, bprev, 500, "leaf")
            end
        end
    end
    plant.updateGraph()
end

function plant.updateGraph()
    -- Stem
    for i = 2, #plant.stem do
        if not plant.stem[i].graphNode then plant.stem[i].graphNode = moveGraph.append(0,0, plant.stem[i-1].graphNode, 100, "plant") end
        plant.stem[i].graphNode.x = level.plantAttachmentPosition[1] + plant.stem[i]._x + 25
        plant.stem[i].graphNode.y = level.plantAttachmentPosition[2] + plant.stem[i]._y - 210
        -- Branches
        for j = 1, #plant.branches[i] do
            local branch = plant.branches[i][j]
            if not branch.graphNode then branch.graphNode = moveGraph.append(0,0, (j == 1 and plant.stem[i].graphNode or plant.branches[i][j-1].graphNode), 200, "plant") end
            branch.graphNode.x = level.plantAttachmentPosition[1] + branch._nextX + 25
            branch.graphNode.y = level.plantAttachmentPosition[2] + branch._nextY - 200
            if branch.leaf then
                if not branch.leaf.graphNode then branch.leaf.graphNode = moveGraph.append(0,0, branch.graphNode, 500, "leaf") end
                local angle = branch.leaf.angle + branch._totalAngle + (branch.leaf.flip and -0.1 or 0.1)
                branch.leaf.graphNode.x = level.plantAttachmentPosition[1] + branch._nextX + 25 + 90*math.cos(angle)
                branch.leaf.graphNode.y = level.plantAttachmentPosition[2] + branch._nextY - 200 + 90*math.sin(angle)
            end
        end
    end
end