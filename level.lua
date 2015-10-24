
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
            list[2*i] = list[2*i] + scaley*0.02*off
        end
    end

    return list
end