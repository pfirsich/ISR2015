
require "borderedFannedPolygons_simple"

do

    level = {}

    local levelWidth = 3500
    local levelHeightFactor = 750
    local groundSegments = 120
    groundHeight = 700
    local textureScale = 1.5
    local groundVariance = 30
    local textureOffsetX, textureOffsetY = 0, 0
    local groundFanOffset, groundFanHeight = -50, 250
    local groundFanTextureScale = 1.0
    local grassFanOffset, grassFanHeight = 0, 40
    local grassFanTextureScale = 5.0
    local grassProb = 0.0


    function level.load()
        groundFanImage = love.graphics.newImage("images/fan.png")
        groundFanImage:setWrap("repeat", "clamp")
        grassFanImage = love.graphics.newImage("images/fan.png")
        grassFanImage:setWrap("repeat", "clamp")
        groundTexture = love.graphics.newImage("images/ground2.png")
        groundTexture:setWrap("repeat", "repeat")
    end

    function level.draw()
        love.graphics.draw(groundMesh, 0, 0)
        love.graphics.draw(groundFanMesh, 0, 0)
        love.graphics.draw(grassFanMesh, 0, 0)
    end

    function level.generate()

        local w = levelWidth
        local groundSurfacePoints = generateSurface(groundSegments, -w/2, w/2, 0, levelHeightFactor, math.floor(groundSegments/4))

        groundSurfacePoints[#groundSurfacePoints+1] = w/2
        groundSurfacePoints[#groundSurfacePoints+1] = 1000
        groundSurfacePoints[#groundSurfacePoints+1] = -w/2
        groundSurfacePoints[#groundSurfacePoints+1] = 1000

        local tris = love.math.triangulate(groundSurfacePoints)


        local vertices = {}
        for tri = 1, #tris do 
            for i = 1, 6, 2 do 
                vertices[#vertices+1] = {tris[tri][i+0], tris[tri][i+1], 
                                         tris[tri][i+0] / love.window.getWidth() * textureScale + textureOffsetX,
                                         tris[tri][i+1] / love.window.getHeight() * textureScale + textureOffsetY}
            end 
        end 

        groundMesh = love.graphics.newMesh(vertices, groundTexture, "triangles")
        
        local groundFanVertices = buildFanGeometry(groundSurfacePoints, groundFanOffset, groundFanHeight)
        for i = 1, #groundFanVertices do groundFanVertices[i][3] = groundFanVertices[i][3] / groundFanImage:getWidth() * groundFanTextureScale + 0.1 end
        groundFanMesh = love.graphics.newMesh(groundFanVertices, groundFanImage, "triangles")

        local edgeMask = {}
        for i = 1, groundSegments do edgeMask[i] = love.math.random() > grassProb end
        local grassFanVertices = buildFanGeometry(groundSurfacePoints, grassFanOffset, grassFanHeight, edgeMask)
        for i = 1, #grassFanVertices do grassFanVertices[i][3] = grassFanVertices[i][3] / grassFanImage:getWidth() * grassFanTextureScale end
        grassFanMesh = love.graphics.newMesh(grassFanVertices, grassFanImage, "triangles")


        -- Move Graph for Ants and stuff
        moveGraph.clear()
        local prev = moveGraph.append(groundSurfacePoints[1], groundSurfacePoints[2], nil, 1, "ground")
        level.leftEntryPoint = prev
        level.plantAttachmentPoint = math.floor(groundSegments/2+0.5)
        for i = 2,groundSegments,2 do
            prev = moveGraph.append(groundSurfacePoints[2*i-1], groundSurfacePoints[2*i], prev, 1, "ground")
            if i == level.plantAttachmentPoint then level.plantAttachmentNode = prev end
        end
        level.rightEntryPoint = prev
        level.plantAttachmentPosition = {groundSurfacePoints[2*level.plantAttachmentPoint-1], 
            groundSurfacePoints[2*level.plantAttachmentPoint]}

        camera.setBounds(-w/2,-1000,w/2,1200)

    end


    function generateSurface(nodes, x1, x2, y, scaley, plantHoleSegments)
        -- Base Line (half pipe-ish)
        local list = {}
        local w = x2-x1
        for i = 1,nodes do
            local p = (i-1)/(nodes-1)
            list[2*i-1] = x1 + p*w
            local off = math.sqrt(p - p*p) - 0.3
            list[2*i] = (off > 0) and y+scaley*off or y
        end

        -- Simplex Noise
        local coordScale = 0.08 
        for layer = 1,3 do
            local heightScale = scaley*0.12*math.pow(0.4,layer)
            for i = 1,nodes do
                list[2*i] = list[2*i] + heightScale * love.math.noise(coordScale*i)
            end 
            coordScale = 2*coordScale
        end


        -- Plant Spot in middle
        local nodemid = math.floor(nodes/2)
        local nodeleft = math.ceil(nodemid - plantHoleSegments/2)
        local noderight = nodeleft + plantHoleSegments
        -- Averaging
        for blur = 1,30 do
            for i = nodeleft,noderight do
                list[2*i] = 0.334*list[2*i] + 0.333*(list[2*i+2] + list[2*i-2]) 
            end
        end
        -- Bend
        for i = nodeleft,noderight do
            local dif = (i-nodemid)/plantHoleSegments
            local off = math.pow(2.0, -16*dif*dif) - 0.1
            if off > 0 then
                list[2*i] = list[2*i] - scaley*0.11*off
            end
        end

        return list
    end


    level.store = {}

    function level.getGroundHeight(x)
        if x < level.leftEntryPoint.x then
            -- Left Frame
            level.store.fromNode = level.leftEntryPoint.neighbours[1][1]
            level.store.toNode = level.leftEntryPoint
            level.store.p = 1.0
            return level.leftEntryPoint.y
        elseif x > level.rightEntryPoint.x then
            -- Right Frame
            level.store.fromNode = level.rightEntryPoint.neighbours[1][1] 
            level.store.toNode = level.rightEntryPoint
            level.store.p = 1.0
            return level.rightEntryPoint.y
        else
            -- Anywhere else
            local node = level.leftEntryPoint.neighbours[1][1]
            while node ~= level.rightEntryPoint do
                -- Check
                if node.x >= x then
                    -- Get exact coordinates and return
                    if x < 0 then
                        -- Walk to the right
                        level.store.fromNode = node
                        level.store.toNode = node.neighbours[1][1]
                        level.store.p = (x - level.store.toNode.x)/(node.x - level.store.toNode.x)
                        return node.y
                    else
                        -- Walk to the left
                        level.store.fromNode = node.neighbours[1][1]
                        level.store.toNode = node
                        level.store.p = (x - level.store.fromNode.x)/(node.x - level.store.fromNode.x)
                        return node.y
                    end
                end
                -- Proceed
                node = node.neighbours[2][1]
            end
            -- Something went wrong, return something
            level.store.fromNode = level.rightEntryPoint.neighbours[1][1] 
            level.store.toNode = level.rightEntryPoint
            level.store.p = 1.0
            return level.leftEntryPoint.y
        end
    end

    function level.getGroundNode(x)
        return level.store.fromNode, level.store.toNode, level.store.p
    end


end