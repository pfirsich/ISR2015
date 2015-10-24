gameState = {}

function gameState.load()
    print("YISSSSS")
end

function gameState.update()
    --print(gameState.time)
end


function gameState.draw()
    love.graphics.push()
    love.graphics.translate(camera.position[1] + love.window.getWidth()/2, camera.position[2] + love.window.getHeight()/2)
    love.graphics.scale(camera.scale)
    level.draw()
    love.graphics.pop()
end