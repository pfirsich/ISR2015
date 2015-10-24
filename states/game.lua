gameState = {}

function gameState.load()
    testKnobs = {}
    for i = 1,7 do
    	testKnobs[i] = {textWidget = textWidgets.list[i]}
	end
    generatePlant()
end

function gameState.update()
    plant.update(simulationDt)
    -- Camera Movement
    camera.control(simulationDt, 1000)
    knobs.update(simulationDt)
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

    plant.draw()

    level.draw()

    love.graphics.pop()

    -- Interface
    knobs.draw(1, 200, 400, {testKnobs[1], testKnobs[4], testKnobs[6]})
    textWidgets.draw()
end