

do

	background = {}


	function background.load()
		background.img1 = love.graphics.newImage("images/bg/bigtree.png")
		background.img2 = love.graphics.newImage("images/bg/smalltree1.png")
		background.img3 = love.graphics.newImage("images/bg/smalltree2.png")
		background.img4 = love.graphics.newImage("images/bg/background.png")
		background.layer1 = {scale = 0.4, color = {0.8,0.8,0.8,1}} -- huge tree (nearest)
		background.layer2 = {scale = 0.2, color = {1,1,1.0,1}} -- small trees
		background.layer3 = {scale = 0.1, color = {1,1,1.0,0.7}} -- background
		-- First Layer
		for i = 1,2 do
			local x = (i == 1 and 1 or -1) * (400 + love.math.random()*1000)
			background.addToLayer(background.layer1, background.img1, x, 200*love.math.random(), 2.0, 1.2+0.3*(i-1))
		end
		-- Second Layer
		for i = 1, 5 do
			background.addToLayer(background.layer2, (love.math.random() < 0.5) and background.img2 or background.img3, 
				-2000 + 4000*love.math.random(), 200*love.math.random(), 1.2, 1.0 + 0.6*love.math.random())
		end
		-- Third Layer
		for i = -0,0 do
			local x = i * background.img4:getWidth()
			background.addToLayer(background.layer3, background.img4, x, -500, 1)
		end
	end


	function background.addToLayer(layer, img, x, y, sc, sx)
		local object = {
			img = img,
			x = x,
			y = y,
			scalex = (sx or 1)*(sc or 1)/layer.scale,
			scaley = (sc or 1)/layer.scale
		}
		table.insert(layer, object)
		return object
	end



	function background.draw()
		background.drawLayer(background.layer3)
		background.drawLayer(background.layer2)
		background.drawLayer(background.layer1)
	end

	function background.drawLayer(layer)
		local oldScale = camera.scale
		camera.scale = layer.scale
		camera.push()
		love.graphics.setColor(layer.color[1]*255, layer.color[2]*255, layer.color[3]*255, layer.color[4]*255)
			for i = 1,#layer do
				background.drawImage(layer[i])
			end
		love.graphics.pop()
		camera.scale = oldScale
	end

		function background.drawImage(img)
			local image = img.img
			love.graphics.draw(image, img.x, img.y, 0.0, img.scalex, img.scaley, image:getWidth()/2, image:getHeight()/2)
		end






end