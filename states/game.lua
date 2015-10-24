gameState = {}

function gameState.load()
    smallPlant()
    --generatePlant()
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

    camera.push()
    plant.draw()

    level.draw()
    camera.pop()

    -- Interface
    textWidgets.draw()
end

function gameState.keypressed(key)
    if key == "u" then plant.screamFace() end 
    if key == "i" then plant.sadFace() end 
    if key == "o" then plant.defaultFace() end 
    if key == "p" then plant.happyFace() end 
    if key == "up" then plant.headImageIndex = plant.headImageIndex + 1; lush.play("levelup.wav", {tags = {}}) end
    if key == "down" then plant.headImageIndex = plant.headImageIndex - 1 end
end 