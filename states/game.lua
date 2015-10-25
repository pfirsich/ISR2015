gameState = {time = 0}
marker = {}

function gameState.load()
    ants.clear()
    smallPlant()
    plant.appendToGraph()
    ants.testInit()
    plant.strikeRoots()
    background.load()
end

function gameState.onEnter()

end

function gameState.update()
    marker = {}
    plant.update(simulationDt)
    plant.updateGraph()
    ants.update()
    ants.testUpdate()
    -- Camera Movement
    camera.control(simulationDt, 1000)
    knobs.update(simulationDt)
    director(simulationDt)
end


function gameState.draw()
	-- Game World
    love.graphics.setColor(100,136,240)
    love.graphics.rectangle("fill", 0, 0, love.window.getWidth(), love.window.getHeight())
    love.graphics.setColor(255, 255, 255, 255)

    background.draw()
    camera.push()
    plant.draw()

    level.draw()

    -- roots
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(plant.rootCanvas, level.plantAttachmentPosition[1], level.plantAttachmentPosition[2] - 20, 0, 1, 1, plant.rootCanvas:getWidth()/2)
    love.graphics.push()
    love.graphics.origin()
    local knobList = {}

    if #plant.stem > 2 then 
        knobList[#knobList+1] = {
            textWidget = textWidgets.list["dance"], 
            clickCallback = function()
                plant.targetShake = 1.0
                plant.screamFace()
                lush.play("leaves.wav")
                lush.play("ability.wav")
                delay(function() 
                    plant.targetShake = 0.0
                    plant.defaultFace()
                end, 2.0)
            end
        }
    end 

    if #plant.stem > 3 then 
        knobList[#knobList+1] = {
            textWidget = textWidgets.list["strikeRoots"], 
            clickCallback = function()
                plant.strikeRoots()
                plant.happyFace()
                lush.play("ability.wav")
            end
        }
    end 

    local sx, sy = camera.worldToScreen(unpack(level.plantAttachmentPosition)) 
    if #knobList > 0 then knobs.draw(21, sx, sy, knobList) end
    love.graphics.pop()

    ants.draw()
    --moveGraph.debugDraw()
    for i = 1, #marker, 2 do 
        love.graphics.circle("fill", marker[i], marker[i+1], 20)
    end 
    camera.pop()

    -- Interface
    textWidgets.draw()
end

function gameState.keypressed(key)
    if key == "u" then plant.screamFace() end 
    if key == "i" then plant.sadFace() end 
    if key == "o" then plant.defaultFace() end 
    if key == "p" then plant.happyFace() end 
    if key == "up" then plant.headImageIndex = clamp(plant.headImageIndex + 1, 1,3); lush.play("levelup.wav", {tags = {}}) end
    if key == "down" then plant.headImageIndex = clamp(plant.headImageIndex - 1, 1,3) end
    if key == "n" then plant.strikeRoots() end
end 
