gameState = {}

function gameState.load()
    print("YISSSSS")
    testKnobs = {}
    for i = 1,7 do
    	testKnobs[i] = {textWidget = textWidgets.list[i]}
	end
end

function gameState.update()
    --print(gameState.time)
end


function gameState.draw()
    love.graphics.setColor(100,136,240)
    love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.push()
    love.graphics.scale(camera.scale)
    love.graphics.translate(camera.position[1] + love.window.getWidth()/2/camera.scale, 
    						camera.position[2] + love.window.getHeight()/2/camera.scale)
    love.graphics.setColor(255,255,255,255)
    -- Level Geometry
    level.draw()
    -- Plants
    love.graphics.setColor(40,180,21)
    love.graphics.rectangle("fill",-25,-600,50,1000)
    love.graphics.rectangle("fill",-225,90,40,300)
    love.graphics.setColor(255,255,255,255)
    love.graphics.pop()
    -- Interface
    knobs.draw(1, 200, 400, {testKnobs[1], testKnobs[4], testKnobs[6]})
    textWidgets.draw()
end