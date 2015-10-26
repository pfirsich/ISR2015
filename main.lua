require "utility"
require "inputs"
require "camera"
require "knobs"
require "textWidgets"
require "level"
require "moveGraph"
require "states.game"
require "plant"
require "face"
require "ants"
require "director"
require "background"
require "states.start"
lush = require "lush"

currentState = {time = 0} -- empty state, does nothing
function enterState(state, ...)
    if currentState.onExit then currentState.onExit(state) end
    if state.onEnter then state.onEnter(...) end
    currentState = state
end 

function love.load()
	lush.setPath("sounds/")
    textWidgets.load()

    ants.load()
    level.load()
    camera.load()
    level.generate()

    if startState.load then startState.load() end
    if gameState.load then gameState.load() end

    --enterState(gameState)

    enterState(startState)

    camera.setScale(1.0)

    music = lush.play("NighttimeinSanFrancisco.mp3", {stream = true})

    --autoFullscreen()
end

function love.update(dt)
    if dt then simulationDt = dt end

    updateDelayedCalls()
    updateWatchedInputs()

    currentState.time = (currentState.time or 0) + simulationDt
    if currentState.update then currentState.update() end
end

function love.textinput(text)
    if currentState.textinput then currentState.textinput(text) end
end

function love.draw()
    local time = love.timer.getTime()
    drawDt = time - (lastDrawTime or time)
    lastDrawTime = time 
    if accum then accum = accum + drawDt end

    if currentState.draw then currentState.draw() end

    if love.keyboard.isDown("q") then
        for i = 1,100 do print("Hello World") end
    end
end

function love.keypressed(key, isrepeat)
    if key == " " then 
        accum = 0
    end 

    if currentState.keypressed then currentState.keypressed(key, isrepeat) end
end

function love.keyreleased(key)
    print(accum); accum = nil
    if currentState.keyreleased then currentState.keyreleased(key) end
end

function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
        for i=1,3 do love.math.random() end
    end

    if love.event then
        love.event.pump()
    end

    simulationTime = love.timer.getTime()
    simulationDt = 1.0/40.0

    if love.load then love.load(arg) end

    -- Main loop
    while true do
        while simulationTime < love.timer.getTime() do
            simulationTime = simulationTime + simulationDt

            -- Process events.
            if love.event then
                love.event.pump()
                for e,a,b,c,d in love.event.poll() do
                    if e == "quit" then
                        if not love.quit or not love.quit() then
                            if love.audio then
                                love.audio.stop()
                            end
                            return
                        end
                    end
                    love.handlers[e](a,b,c,d)
                end
            end

            love.update()
        end

        lush.update()

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end