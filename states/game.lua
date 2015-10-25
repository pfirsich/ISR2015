gameState = {time = 0}
marker = {}

function gameState.load()
    background.load()
    hudValueFont = love.graphics.newFont(30)
end

function gameState.onEnter()
    plant.stem = {}
    plant.branches = {}
    love.mouse.setPosition(love.window.getWidth()/2, love.window.getHeight()/2)
    camera.position = {0, 0}

    ants.clear()
    smallPlant()
    plant.appendToGraph()
    ants.testInit()
    plant.strikeRoots()

    plant.headImageIndex = 1
    plant.rootCanvas:clear(0, 0, 0, 0)
    plant.rootLevel = 0
end

function gameState.update()
    marker = {}
    plant.update(simulationDt)
    plant.updateGraph()
    ants.update()
    ants.testUpdate()
    -- Camera Movement
    camera.control(simulationDt, 1000)
    director(simulationDt)

    local leaves = 0
    for i = 1, #plant.stem do 
        for j = 1, #plant.branches[i] do 
            if plant.branches[i][j].leaf then leaves = leaves + 1 end
        end 
    end 

    if resources.glucose - simulationDt * plant.rootLevel > 0 then 
        resources.glucose = resources.glucose - simulationDt * plant.rootLevel
        resources.h2o = resources.h2o + simulationDt * 5.2 * plant.rootLevel
    end

    if resources.h2o - simulationDt * leaves > 0 then 
        resources.glucose = resources.glucose + simulationDt * 2.2 * leaves
        resources.h2o = resources.h2o - simulationDt * leaves
    end

    if music:tell("seconds") > 150.336 then 
        music:seek(14.780 + music:tell("seconds") - 150.336, "seconds")
    end
end


resources = {
    h2o = 250,
    glucose = 250,
    minerals = 100
}

function drawGame()
    knobs.update(simulationDt) -- sorry but this solves the problem
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

    if #plant.stem > 3 then 
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
            end,
            image = abilityIcons.shake,
        }
    end 

    if #plant.stem > 2 then 
        knobList[#knobList+1] = {
            textWidget = textWidgets.list["strikeRoots"], 
            clickCallback = function()
                plant.strikeRoots()
                plant.happyFace()
                increaseCost("strikeRoots")
                lush.play("ability.wav")
            end,
            image = abilityIcons.root,
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


function gameState.draw()
    drawGame()

    -- love.graphics.setLineWidth(2)
    -- love.graphics.setColor(255, 255, 255, 255)
    -- love.graphics.rectangle("line", 1, 1, love.window.getWidth(), 25)
    -- love.graphics.setColor(0, 0, 0, 255)
    -- love.graphics.rectangle("fill", 1, 1, love.window.getWidth(), 25)

    local oldFont = love.graphics.getFont()
    love.graphics.setColor(255, 255, 255, 255)
    for i, kind in ipairs({"h2o", "glucose", "minerals"}) do 
        love.graphics.setFont(oldFont)
        love.graphics.setColor(255, 255, 255, 255)
        local x = (i-1) * love.window.getWidth() / 3 + 10
        local iconOffset = love.graphics.getFont():getWidth(resourceInfo[kind].name)
        love.graphics.print(resourceInfo[kind].name, x, 5)
        love.graphics.draw(resourceInfo[kind].icon, x + iconOffset, 5)

        love.graphics.setFont(hudValueFont)
        local iconSizeX, iconSizeY = resourceInfo[kind].icon:getDimensions()
        local height = love.graphics.getFont():getHeight()

        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.print(tostring(math.floor(resources[kind])), x + iconOffset + iconSizeX + 10 + 2, iconSizeY / 2 - height / 2 + 2)
        
        love.graphics.setColor(resourceInfo[kind].color)
        love.graphics.print(tostring(math.floor(resources[kind])), x + iconOffset + iconSizeX + 10, iconSizeY / 2 - height / 2)
    end 
    love.graphics.setFont(oldFont)
end



function gameState.keypressed(key)
    if key == "," then
        for key,value in pairs(resources) do
            resources[key] = resources[key] + 100
        end
    end
end