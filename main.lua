require "utility"
require "inputs"
require "camera"
require "states.game"
lush = require "lush"

currentState = {} -- empty state, does nothing
function enterState(state, ...)
    if currentState.onExit then currentState.onExit(state) end
    if state.onEnter then state.onEnter(...) end
    currentState = state
end 

function love.load()
	lush.setPath("media/sounds/")
    if gameState.load then gameState.load() end
    enterState(gameState)
end

function love.update()
    updateDelayedCalls()
    updateWatchedInputs()

    currentState.time = (currentState.time or 0) + simulationDt
    if currentState.update then currentState.update() end
end

function love.textinput(text)
    if currentState.textinput then currentState.textinput(text) end
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)
    if currentState.draw then currentState.draw() end
end

function love.keypressed(key, isrepeat)
    if currentState.keypressed then currentState.keypressed(key, isrepeat) end
end

function love.keyreleased(key)
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
