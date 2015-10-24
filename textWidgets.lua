
printf = require("superprintf")


do

	textWidgets = {
		list = {},
	}

	resourceInfo = {
		{name = "H2O", icon = nil, color = {80,120,255}},
		{name = "Glucose", icon = nil, color = {240,230,22}},
		{name = "Minerals", icon = nil, color = {160,110,32}},
	}

	function textWidgets.load()
		textWidgets.image = love.graphics.newImage("images/messagebox.bmp")
		textWidgets.width = textWidgets.image:getWidth()
		textWidgets.height = textWidgets.image:getHeight()
		-- Branch [color:255,0,0,textWidgets.alpha]This is red text.[n][color:255,255,255,textWidgets.alpha]In a new line, I include an inside the text
		textWidgets.list["createBranch"] = {caption = "Create Branch", cost = {5,5,0},
			text="Add a new branch to your plant which will grow eventually and provide more leaf growth spots."}
		textWidgets.list["createLeaf"] = {caption = "Create Leaf", cost = {3,3,0},
			text="Add a leaf to your plant which will generate valuable glucose"}
		textWidgets.list["upgradePoisonLeaf"] = {caption = "Create Poisoned Leaf", cost = {3,6,2},
			text="Grow a poisonous leaf that will hurt any foes eating from it. Will generate fewer glucose"}
		textWidgets.list["upgradeSpiderLeaf"] = {caption = "Call for Spider", cost = {2,2,6},
			text="Grows a leaf that attracks spiders due to its amazing web supporting capabilities. Will generate fewer glucose."}
		textWidgets.list["dance"] = {caption = "Shake it off", cost = {2,2,4},
			text="Shake yourself in order to get rid of any unwanted guests."}
		textWidgets.list["strikeRoots"] = {caption = "Enhance Roots", cost = {4,6,0},
			text="Strike further roots to gain more water at the cost of glucose collection."}
		textWidgets.list["spawnThorns"] = {caption = "Grow Thorns", cost = {8,8,2},
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
				love.graphics.setColor(255,255,255,alpha)
				-- Background
				love.graphics.draw(textWidgets.image, widget.x, widget.y, 0, 1,1, textWidgets.image:getWidth()/2, textWidgets.image:getHeight()/2)
				local x1 = widget.x - textWidgets.width/2
				local y1 = widget.y - textWidgets.height/2
				local x2 = x1 + textWidgets.width
				local y2 = y1 + textWidgets.height
				-- Caption
				love.graphics.print(widget.caption, x1+margin,y1+margin, 0, 1.25, 1.25)
				-- Text
				printf(widget.text, x1+margin, y1+margin+24, x2-x1-2*margin, "left", y2-y1-3*margin, "top")
				-- Resources
				local x = x1+margin+12
				local y = y2-margin-12
				for i = 1,3 do
					if widget.cost[i] > 0 then
						-- Draw
						resourceInfo[i].color[4] = alpha
						if resourceInfo[i].image then
							love.graphics.draw(resourceInfo[i].image, x, y+4)
							love.graphics.setColor(resourceInfo[i].color)
							love.graphis.print(widget.cost[i], x+24, y)
						else
							love.graphics.setColor(resourceInfo[i].color)
							love.graphics.circle("fill", x, y+4,14)
							love.graphics.print(widget.cost[i], x+24, y)
						end
						love.graphics.setColor(255,255,255,alpha)
						-- Proceed
						x = x + 80
					end
				end
				-- Hide it
				widget.visible = clamp(widget.visible - simulationDt*1.2, 0, 1.2)
			end
		end
	end



end