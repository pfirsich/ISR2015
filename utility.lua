function filter(list, func)
	local ret = {}
	for i = 1, #list do
		if func(list[i]) then ret[#ret+1] = list[i] end
	end
	return ret
end


function setResolution(w, h, flags) -- this is encapsulated, so if canvases are used later, they can be updated here!
	if not love.window.setMode(w, h, flags) then
		error(string.format("Resolution %dx%d could not be set successfully.", w, h))
	end
end

function autoFullscreen()
	local supported = love.window.getFullscreenModes()
	table.sort(supported, function(a, b) return a.width*a.height < b.width*b.height end)

	local scrWidth, scrHeight = love.window.getDesktopDimensions()
	supported = filter(supported, function(mode) return mode.width*scrHeight == scrWidth*mode.height end)

	local max = supported[#supported]
	local flags = {fullscreen = true}
	setResolution(max.width, max.height, flags)
end

-- returns deep recursive copy
function copyTable(from)
	local to = {}
	for k, v in pairs(from) do
		if type(v) == "table" then
			to[k] = copyTable(v)
		else
			to[k] = v
		end
	end
	return to
end

function clamp(v, lo, hi)
    return math.max(math.min(v, hi), lo)
end

function lerp(a, b, t)
	return a + (b - a) * t
end 

function bezier(a, b, va, vb, t)
    local invT = 1.0 - t 
    return a * invT*invT*invT + va * 3.0 * invT*invT*t + vb * 3.0 * invT*t*t + b * t*t*t
end 

function intervalsOverlap(A, B) -- interval: {left, right}
	-- they dont overlap if left_B > right_A or right_B < left_A
	-- negate: left_B <= right_A and right_B >= left_A
	return A[1] <= B[2] and B[1] <= A[2]
end

function aabbCollision(A, B) -- box = {{topleftx, toplefty}, {sizex, sizey}}
	-- returns the MTV (minimal translation vector to resolve the collision) for the shape A if there is a collision, otherwise nil

	if  intervalsOverlap({A[1][1], A[1][1] + A[2][1]}, {B[1][1], B[1][1] + B[2][1]})
    and intervalsOverlap({A[1][2], A[1][2] + A[2][2]}, {B[1][2], B[1][2] + B[2][2]}) then
        local yOverlap = 0
		local yMTVSign = 1
		if A[1][2] + A[2][2] - B[1][2] < B[1][2] + B[2][2] - A[1][2] then
			yOverlap = A[1][2] + A[2][2] - B[1][2]
			yMTVSign = -1
		else
			yOverlap = B[1][2] + B[2][2] - A[1][2]
			yMTVSign = 1
		end

        return {0.0, math.max(0, yOverlap) * yMTVSign}
	else
		return nil
	end
end

delayedCalls = {}
function delay(func, seconds)
	table.insert(delayedCalls, {func, love.timer.getTime() + seconds})
end

function updateDelayedCalls()
	-- Iterate back to front for save deletion while iterating
	for i = #delayedCalls, 1, -1 do
		local dcall = delayedCalls[i]
		if dcall[2] < love.timer.getTime() then
			dcall[1]()
			table.remove(delayedCalls, i)
		end
	end
end

function randf(min, max)
	return love.math.random() * (max - min) + min
end
