
--vars for buttons


clickable = true
mode = "trail"

--width and hieght of all buttons
cw = 200
ch = love.graphics.getHeight() / 3

--touch input
x = {0,0,0,0}
y = {0,0,0,0}
touchX = {0,0,0,0}
touchY = {0,0,0,0}
index = 0
pressure = 0


gravityMode = false
theta = 0
gravity = 1000

--vars for circular motion
r = 400
rx = 0
ry = 0
ctheta = 0


function love.load()
	planets = {x = 900, y = 600}
	boxes = {x = 150, y = 150, xvel = 0, yvel = 0}
	
	font = love.graphics.newFont("font.ttf" , 75)
	love.graphics.setFont(font)

end

function love.draw()
	love.graphics.setBackgroundColor(186,186,186)
	drawPlanets()
	drawBoxes()
	--displayButtons()
	--displayHUD()
	ui_Handler()
	--debug()
end


function love.update(dt)
	touchInput()
	button_Handler()
	ui_TooltipsFade(dt)
	createBoxMode(dt) --creates box 
	physicsMode(dt) --
end

function physicsMode(dt)
	if gravityMode then
	for k, box in ipairs( boxes ) do
  		--[[
  		if gravityMode and love.touch.getTouchCount() >= 1  and touchX[1] > 200 then 
  			for t = 1, love.touch.getTouchCount() do                                   //revisit
  				gravitaion(box, dt, t, touchX[t], touchY[t])
  			end 
		end
		]]
		for q, planet in ipairs( planets ) do
			pGravitaion(box, planet, dt)
		end

   		physics(box, dt)
	end
	end
end

function createBoxMode(dt)
	if love.touch.getTouchCount() >= 1 and touchX[1] > 200 then
		for i = 1, love.touch.getTouchCount() do
			circularMotion(i, dt)
			if mode == "trail" or mode == "circle" then newBox(i) 
			elseif mode == "planet" and hold then 
				newPlanet()
				hold = false 
			end
		end
	else hold = true end
end

function circularMotion(i, dt)
	ctheta = ctheta + math.pi * 4 * dt

	rx = touchX[i] + r * math.cos(ctheta)
	ry = touchY[i] + r * math.sin(ctheta)
end

function physics(box, dt)
	box.x = box.x + box.xvel * dt
	box.y = box.y + box.yvel * dt

	--gravity box.xvel = box.xvel + (2000 + table.getn(boxes)) * dt

	--boundry(box)
end

function boundry(box)
	if box.x > love.graphics.getWidth() - 75 then
		box.x = love.graphics.getWidth() - 75
		box.xvel = -box.xvel/2
	end
end

function touchInput()
	for i = 1, love.touch.getTouchCount() do
		index, x[i], y[i], pressure = love.touch.getTouch(i)

		touchX[i] = x[i] * love.graphics.getWidth()
		touchY[i] = y[i] * love.graphics.getHeight()
	end
end

function newBox(i)
	if mode == "circle" then table.insert( boxes, {x = rx,y = ry, xvel = 0, yvel = 0, life = 4, red = math.random(0,255) , green = math.random(0,255), blue = math.random(0,255) , alpha = 255 } ) 
	else table.insert( boxes, {x = touchX[i] ,y = touchY[i], xvel = 0, yvel = 0, life = 4, red = math.random(0,255) , green = math.random(0,255), blue = math.random(0,255) , alpha = 255 } ) end
end

function newPlanet()
	if mode == "planet" then table.insert( planets, {x = touchX[1], y = touchY[1]}) end
end

function removeBox(box, k)
	table.remove(boxes, k)
end

function removePlanet(planet, k)
	table.remove(planets, k)
end


function gravitaion(box, dt, t , xx, yy)
	
	xDistance = box.x - xx
	yDistance = box.y - yy

	theta = math.atan(-yDistance/xDistance)
	
	if xDistance > 0 then box.xvel = box.xvel - 5000 * math.abs(math.cos(theta)) * dt end
	if xDistance < 0 then box.xvel = box.xvel + 5000 * math.abs(math.cos(theta)) * dt end

	if yDistance > 0 then box.yvel = box.yvel - 5000 * math.abs(math.sin(theta)) * dt end
	if yDistance < 0 then box.yvel = box.yvel + 5000 * math.abs(math.sin(theta)) * dt end
	--box.yvel = box.yvel - 500000/math.abs(yDistance) * math.sin(theta) * dt
end

function pGravitaion(box, planet, dt)
	xDistance = box.x - planet.x
	yDistance = box.y - planet.y

	theta = math.atan(-yDistance/xDistance)
	
	if xDistance > 0 then box.xvel = box.xvel - 1000 * math.abs(math.cos(theta)) * dt end
	if xDistance < 0 then box.xvel = box.xvel + 1000 * math.abs(math.cos(theta)) * dt end

	if yDistance > 0 then box.yvel = box.yvel - 1000 * math.abs(math.sin(theta)) * dt end
	if yDistance < 0 then box.yvel = box.yvel + 1000 * math.abs(math.sin(theta)) * dt end
	--box.yvel = box.yvel - 500000/math.abs(yDistance) * math.sin(theta) * dt
end

--[[
function buttons(dt)
	if 	love.touch.getTouchCount() >= 1 then 
		
		--clear button
		if touchX[1] > cx and touchX[1] < cx + 100 and touchY[1] > cy and touchY[1] < cy + 300 then
			if gravityMode then
				for y, planet in ipairs( planets ) do
					removePlanet(planet, y)
				end
			else
				for k, box in ipairs( boxes ) do
  					removeBox(box, k)
				end
			end
		end

		if clickable == true then

			--mode button
			if touchX[1] > mx and touchX[1] < mx + cw and touchY[1] > my and touchY[1] < my + ch then
				if gameMode == false then 
					gameMode = true
					mode = "orbit"
				else
					gameMode = false 
					mode = "trail"
				end
			end

			--bodies button		 
			if touchX[1] > bx and touchX[1] < bx + cw and touchY[1] > by and touchY[1] < by + ch then
				if gameMode == false then
					if mode == "trail" then mode = "circle"
					else mode = "trail" end
				else 
					if mode == "orbit" then mode = "planet"
					else mode = "orbit" end
				end
			end
			clickable = false
		else clickable = false end
	else clickable = true end
end

function displayButtons()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", cx,cy,cw,ch)
	--love.graphics.setColor(255,0,255)
	love.graphics.rectangle("fill", mx,my,cw,ch)
	--love.graphics.setColor(0,255,128)
	love.graphics.rectangle("fill", bx,by,cw,ch)
end

function displayHUD()
	love.graphics.setColor(128,128,128)
	if gameMode then 
		love.graphics.print("Add", 100, 1000, -3.14/2) 
		--love.graphics.setColor(0,255,128)
		love.graphics.print("mode: "..mode.."", 100, 700, -3.14/2) 
	end
	if gameMode == false then 
		love.graphics.print("Add", 100, 1000, -3.14/2)
		--love.graphics.setColor(0,255,128)
		love.graphics.print("Brush: "..mode.."", 100, 700, -3.14/2) 
	end
	--love.graphics.setColor(255,128,0)
	love.graphics.print(table.getn(boxes), 100, 300, -3.14/2)
end
]]



function drawBoxes()
	for j, box in ipairs(boxes) do
		love.graphics.setColor(box.red,box.green, box.blue, box.alpha)
		love.graphics.circle("fill", box.x, box.y, 150, 50)
	end
end

function drawPlanets()
	for w, planet in ipairs(planets) do
		love.graphics.setColor(128,128,128)
		love.graphics.circle("fill", planet.x, planet.y, 75, 50)
	end
end

function ui_Box()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill",0,0,200,love.graphics.getHeight())
	ui_Fade()
end

function ui_Fade()
	linea = 128
	for i = 1, 64 do
		linea = linea - 2
		if linea <= 0 then linea = 0 end
		love.graphics.setColor(0,0,0,linea)
		love.graphics.line(200+i,0,200+i,love.graphics.getHeight())
	end
end



menu = "main"
--add
function ui_Handler()
	ui_Box()
	ui_Add()
	ui_Play()
	ui_Erase()
	ui_Tooltips()
	countBar()
end 

function ui_Add()
	if menu == "main" then
		love.graphics.setColor(128,128,128)
		love.graphics.print("|     Add", 75, 550, -3.14/2)
	elseif menu == "add" then
		love.graphics.setColor(128,128,128)
		love.graphics.print("Back   |", 75, 1000, -3.14/2)
		ui_Brush()
	end
end

function ui_Play()
	if menu == "main" then
		if gravityMode then
			love.graphics.print("|   Pause",75,800, -3.14/2)
		else
			love.graphics.print("|    Play",75,800, -3.14/2)
		end
	end
end

function ui_Erase()
	love.graphics.print("|   Erase",75,300, -3.14/2)
end

function ui_Brush()
	love.graphics.setColor(237,170,11)
	love.graphics.rectangle("fill", 75 ,350, 100, 250)
	love.graphics.setColor(128,128,128)
	love.graphics.print("Brush:", 75, 800, -3.14/2)
	love.graphics.print(""..mode.."",75, 550, -3.14/2)
end

function button_Handler()
	if 	love.touch.getTouchCount() >= 1 then
		button_Add()
		button_Erase()

		if menu == "main" then
			button_Play()
		elseif menu == "add" then
			button_Brush()
		end
	else clickable = true end
end

function button_Add()
	if menu == "main" and clickable then
		if touchX[1] > 0 and touchX[1] < 200 and touchY[1] > 300 and touchY[1] < 550 then
			menu = "add"
			clickable = false
		end
	elseif menu == "add" and clickable then
		if touchX[1] > 0 and touchX[1] < 200 and touchY[1] > 800 and touchY[1] < love.graphics.getHeight() then
			menu = "main"
			clickable = false
		end
	end	
end

function button_Brush()
	if touchX[1] > 0 and touchX[1] < 200 and touchY[1] > 350 and touchY[1] < 800 and clickable then
		if mode == "trail" then mode = "circle"
		elseif mode == "circle" then mode = "planet"
		elseif mode == "planet" then mode = "trail" end
		clickable = false
	end
end

function button_Play()
	if touchX[1] > 0 and touchX[1] < 200 and touchY[1] > 550 and touchY[1] < 800 and clickable then
		if gravityMode == false then 
			gravityMode = true
			clickable = false
		else
			gravityMode = false 
			clickable = false
		end
	end
end

function debug()
	love.graphics.setColor(0,0,0)
	if clickable then love.graphics.print("Clickable",500,500)
	else love.graphics.print("Not Clickable",500,500) end
end

addTooltip = true
addTooltipA = 255

function ui_Tooltips()
	if gravityMode and table.getn(boxes) == 0 and table.getn(planets) == 0 then
		love.graphics.setColor(128,128,128,addTooltipA)
		love.graphics.print("Try adding some colors and a planet",250,950)
	end
end

function ui_TooltipsFade(dt)
	if menu == "add" and gravityMode and table.getn(boxes) == 0 and table.getn(planets) == 0 then
		addTooltipA = addTooltipA - 100 * dt
		if addTooltipA <= 0 then addTooltipA = 0 end
	end
end

function button_Erase()
	if touchX[1] > 0 and touchX[1] < 200 and touchY[1] > 0 and touchY[1] < 300 and clickable then
		for y, planet in ipairs( planets ) do
			removePlanet(planet, y)
		end
		for k, box in ipairs( boxes ) do
			removeBox(box, k)
		end
	end
end

function countBar()
	love.graphics.setColor(237,170,11)
	love.graphics.rectangle("fill", love.graphics.getWidth() - 20 ,love.graphics.getHeight() - table.getn(boxes), 20, table.getn(boxes))
end




