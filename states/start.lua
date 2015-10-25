startState = {time = 0}

function startState.load()
	shoe = love.graphics.newImage("images/boot.png")
	titel = love.graphics.newImage("images/Titel.png")
	bigFont = love.graphics.newFont(32)
	smallFont = love.graphics.newFont(18)
	shoePos, shoeVel = -6000, 0
end

function startState.onEnter()
	generatePlant()

	plant.headImageIndex = 3
    plant.rootCanvas:clear(0, 0, 0, 0)
    for i = 1, 6 do plant.strikeRoots() end
    plant.happyFace()
end

shoeScale = 2.3

function startState.update()
	camera.move(0, -120)
	plant.update(simulationDt)
	--camera.control(simulationDt, 1000)
	if music:tell("seconds") > 9.674 then 
	    music:seek(3.993 + music:tell("seconds") - 9.674, "seconds")
	end              

	if shoeFall and not paused then 
		shoeVel = shoeVel + 10000 * simulationDt
		shoePos = shoePos + shoeVel * simulationDt
	end                                              
	if shoePos > -shoe:getHeight() * shoeScale + 200 and not paused then 
		paused = true
		shoePos = -shoe:getHeight() * shoeScale + 200 
		music:pause()
		delay(function() enterState(gameState) end, 3.0)
	end                                                     
end

function startState.keypressed(key)
    if not played then 
        played = true
        lush.play("shoe.wav")
        delay(function() shoeFall = true end, 2.0)
    end
end

function startState.draw()
	drawGame()
	camera.push()
	love.graphics.draw(shoe, -650*shoeScale, shoePos, 0, shoeScale, shoeScale)
	camera.pop()

	local curFont = love.graphics.getFont()
	love.graphics.setFont(bigFont)
	if not shoeFall then 
		love.graphics.draw(titel, love.window.getWidth()/2 - titel:getWidth()/2, love.window.getHeight()/2 - titel:getHeight()/2)
		local t = "This game was developed as part of Indie Speed Run 2015 (www.indiespeedrun.com)"
		shadowText(t, love.window.getWidth()/2 - bigFont:getWidth(t)/2, 5)
		local start = "Press any key to start"
		if math.sin(currentState.time*5.0) > 0 then 
			shadowText(start, love.window.getWidth()/2 - bigFont:getWidth(start)/2, love.window.getHeight() - bigFont:getHeight()*4)
		end

		love.graphics.setFont(smallFont)
		lines = {
			"Programming - Joel Schumacher",
			"Art - Lukas Schnitzler",
			"Programming - Markus Over", 
			"Music - Philipp Koerver",
		}
		for i = 1, 4 do 
			shadowText(lines[i], love.window.getWidth() - smallFont:getWidth(lines[i]) - 5, love.window.getHeight() - i * 30)
		end 
	end
	love.graphics.setFont(curFont)
end

function shadowText(t, x, y)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(t, x+2, y+2)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(t, x, y)
end