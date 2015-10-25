
printf = require("superprintf")


do

	textWidgets = {
		list = {},
	}

	resourceInfo = {
		{name = "H2O", icon = love.graphics.newImage("images/UI/h2oicon.png"), color = {80,120,255}},
		{name = "Glucose", icon = love.graphics.newImage("images/UI/glucoseicon.png"), color = {240,230,22}},
		{name = "Minerals", icon = love.graphics.newImage("images/UI/mineralsicon.png"), color = {160,110,32}},
	}

	function textWidgets.load()
		textWidgets.image = love.graphics.newImage("images/UI/Textbox.png")
		textWidgets.imageScale = 0.5
		textWidgets.width = textWidgets.imageScale * textWidgets.image:getWidth()
		textWidgets.height = textWidgets.imageScale * textWidgets.image:getHeight()
		-- Branch [color:255,0,0,textWidgets.alpha]This is red text.[n][color:255,255,255,textWidgets.alpha]In a new line, I include an inside the text
		textWidgets.list["createBranch"] = {caption = "Create Branch", cost = {5,5,0},
			text="Add a new branch to your plant which will grow eventually and provide more leaf growth spots."}
		textWidgets.list["createLeaf"] = {caption = "Create Leaf", cost = {3,3,0},
			text="Add a leaf to your plant which will generate valuable glucose"}
		textWidgets.list["upgradePoisonLeaf"] = {caption = "Create Poisoned Leaf", cost = {3,6,2},
			text="Grow a poisonous leaf that will hurt any foes eating from it. Will generate fewer glucose"}
		textWidgets.list["upgradeSpiderLeaf"] = {caption = "Call for Spider", cost = {2,2,6},
			text="Grows a leaf that attracks spiders due to its amazing web supporting capabilities. Will generate fewer glucose."}
		textWidgets.list["dropLeaf"] = {caption = "Drop leaf", cost = {0, 0, 0}, 
			text="Drops the leaf."}
		textWidgets.list["dance"] = {caption = "Shake it off", cost = {2,2,4},
			text="Shake yourself in order to get rid of any unwanted guests."}
		textWidgets.list["strikeRoots"] = {caption = "Strike Roots", cost = {4,6,0},
			text="Strike further roots to gain more water at the cost of glucose collection."}
		textWidgets.list["growThorns"] = {caption = "Grow Thorns", cost = {8,8,2},
			text="Grows thornes that damage insects on contact"}
		textWidgets.list["openBud"] = {caption = "Rebuild Yourself", cost = {0, 0, 0}, text = "Open your bud and start anew."}
		-- Complete list
		for k, v in pairs(textWidgets.list) do
			v.x = 0
			v.y = 0
			v.visible = 0.0
		end
	end


	function textWidgets.show(widget, x, y)
		widget.x = x
		widget.y = y
		widget.visible = clamp(widget.visible + simulationDt*2.5, 0, 1.2)
	end

	function textWidgets.draw()
		local margin = 24
		for i, v in pairs(textWidgets.list) do
			local widget = textWidgets.list[i]
			if widget.visible > 0 then
				local alpha = 255*clamp(widget.visible,0,1)
				textWidgets.alpha = alpha
				-- Background
				love.graphics.setColor(255,255,255,alpha)
				love.graphics.draw(textWidgets.image, widget.x, widget.y, 0, textWidgets.imageScale, textWidgets.imageScale, textWidgets.image:getWidth()/2, textWidgets.image:getHeight()/2)
				local x1 = widget.x - textWidgets.width/2
				local y1 = widget.y - textWidgets.height/2
				local x2 = x1 + textWidgets.width
				local y2 = y1 + textWidgets.height
				-- Caption
				love.graphics.print(widget.caption, x1+margin,y1+margin, 0, 1.25, 1.25)
				-- Text
				printf(widget.text, x1+margin, y1+margin+24, x2-x1-2*margin, "left", y2-y1-3*margin, "top")
				-- Resources
				local y = y2-margin-12
				local pos = 0
				for i = 1,3 do
					if widget.cost[i] > 0 then
						pos = pos + 1
						local x = x1 + textWidgets.width*(pos-0.5)/3.0
						-- Draw
						resourceInfo[i].color[4] = alpha
						if resourceInfo[i].icon then
							love.graphics.draw(resourceInfo[i].icon, x-16, y+4, 0, 0.7,0.7, 32,32)
							love.graphics.setColor(resourceInfo[i].color)
						else
							love.graphics.setColor(resourceInfo[i].color)
							love.graphics.circle("fill", x-16, y+4,14)
						end
						love.graphics.print(widget.cost[i], x+16, y, 0, 1.5, 1.5)
						love.graphics.setColor(255,255,255,alpha)
					end
				end
				-- Hide it
				widget.visible = clamp(widget.visible - simulationDt*1.2, 0, 1.2)
			end
		end
	end



end