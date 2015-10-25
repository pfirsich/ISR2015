
function drawMouth(mouthOpen, mouthScale, blink, lookX, lookY)
    local mouthHeight = 30
    local mouthWidth = 40
    local eyeOffset = 60
    local eyeSpacing = 30
    local eyeRadius = 12
    local mouthDisplacement = 1.0
    local pupilRadiusFactor = 0.7
    local glareRadiusFactor = 0.2
    blink = 1.0 - blink
    
    local mouthFunc = function(x) return math.pow(1 - x*x, 0.4) end
    local points = {}
    local samples = 20
    for i = 1, samples do 
        points[#points+1] = -mouthWidth/2 + mouthWidth * (i-1) / (samples-1)
        points[#points+1] = mouthFunc((i-1) / (samples-1) * 2.0 - 1.0) * mouthScale * mouthHeight - (mouthScale / 2.0 + 0.5) * mouthHeight * mouthDisplacement
    end 
    local backwardsPoints = {}
    for i = samples - 1, 2, -1 do 
        backwardsPoints[#backwardsPoints+1] = -mouthWidth/2 + mouthWidth * (i-1) / (samples-1) 
        backwardsPoints[#backwardsPoints+1] = mouthFunc((i-1) / (samples-1) * 2.0 - 1.0) * mouthScale * mouthHeight * (1.0 - mouthOpen)- (mouthScale / 2.0 + 0.5) * mouthHeight * mouthDisplacement
    end 
    love.graphics.setColor(0, 0, 0)

    --local tris = love.math.triangulate(points)

    love.graphics.setLineWidth(3)
    love.graphics.line(points) 
    love.graphics.line(backwardsPoints)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(255, 255, 255, 255)
    local stretch = 1.2 * blink
    drawEllipse( -eyeSpacing, -eyeOffset, eyeRadius, 1.0, stretch)
    drawEllipse(  eyeSpacing, -eyeOffset, eyeRadius, 1.0, stretch)
    love.graphics.setColor(0, 0, 0, 255)
    drawEllipse( -eyeSpacing, -eyeOffset, eyeRadius, 1.0, stretch, "line")
    drawEllipse(  eyeSpacing, -eyeOffset, eyeRadius, 1.0, stretch, "line")
  
    local mouseRelXL, mouseRelYL = lookX + eyeSpacing, lookY + eyeOffset
    lookAngleL = math.atan2(mouseRelYL, mouseRelXL)
    local mouseRelXR, mouseRelYR = lookX - eyeSpacing, lookY + eyeOffset
    lookAngleR = math.atan2(mouseRelYR, mouseRelXR)
    local xL, yL = math.cos(lookAngleL) * (1.0 - pupilRadiusFactor) * eyeRadius, math.sin(lookAngleL) * (1.0 - pupilRadiusFactor) * eyeRadius
    local xR, yR = math.cos(lookAngleR) * (1.0 - pupilRadiusFactor) * eyeRadius, math.sin(lookAngleR) * (1.0 - pupilRadiusFactor) * eyeRadius
    drawEllipse( -eyeSpacing + xL, -eyeOffset + yL, eyeRadius * pupilRadiusFactor, 1.0, blink)
    drawEllipse(  eyeSpacing + xR, -eyeOffset + yR, eyeRadius * pupilRadiusFactor, 1.0, blink)
    love.graphics.setColor(255, 255, 255, 255)
    local r = eyeRadius * glareRadiusFactor
    drawEllipse(-eyeSpacing + xL - r, -eyeOffset + yL - r, r, 1.0, blink)
    drawEllipse( eyeSpacing + xR - r, -eyeOffset + yR - r, r, 1.0, blink)
end

function drawEllipse(x, y, r, sx, sy, mode)
    sx, sy = sx or 1.0, sy or 1.0
    mode = mode or "fill"
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(sx, sy)
    love.graphics.circle(mode, 0, 0, r, 24)
    love.graphics.pop()
end 