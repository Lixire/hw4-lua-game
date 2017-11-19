collidy = require "collidy"
factory = require "factory"
math.randomseed(os.time())
math.random(); math.random(); math.random()
platforms = {{0, 132,103,800},
{103, 448,310,800},
{413, 492,375,800},
{788, 453,551,800},
{1339, 517,135,800},
{1474, 576,185,800},
{1659, 654,316,800},
{1975, 688,355,800},
{2330, 642,358,800},
{2688, 716,604,800},
{3292, 689,391,800},
{3683, 674,647,800},
{4330, 637,333,800},
{4663, 597,197,800},
{4860, 536,140,800},
{5000, 483,145,800},
{5145, 437,118,800},
{5263, 403,155,800},
{5418, 353,90,800},
{5508, 312,109,800},
{5617, 267,70,800},
{5687, 226,107,800},
{5794, 278,67,800},
{5861, 408,64,800},
{5925, 525,52,800},
{5977, 587,373,800},
{6350, 102,405,800}}

function love.load()
    spawnrate = 10
    success = love.window.setMode(1000,800)
    love.graphics.setFont(love.graphics.newFont(30))
    love.graphics.setBackgroundColor(255, 255, 255)
    splashes = {love.graphics.newImage("img/splash1.png"),love.graphics.newImage("img/splash2.png")}
    splashrate = 0.5
    splashstate = 0
    background = love.graphics.newImage("img/background-normal.png");
-- player starting vals
    player = factory.playerFactory()
    enemytype1 = love.graphics.newImage("img/rabbit-monster.png")
    enemytype2 = love.graphics.newImage("img/lamp-monster.png")
    enemytype3 = love.graphics.newImage("img/bird-normal.png")
    state = "menu"

-- create entities
    --a = factory.enemyFactory(200,50,150/enemytype1:getHeight()*enemytype1:getWidth(),150,150/enemytype1:getHeight(), 40, 0.05, enemytype1)
    --b =  factory.enemyFactory(400,50,200/enemytype2:getHeight()*enemytype2:getWidth(),200,200/enemytype2:getHeight(),100,0.1,enemytype2)
    window = {0,0}
    entity = {player}
    world1 = {player}
    for i,v in ipairs(platforms) do
        local plat = factory.platformFactory(v[1],v[2],v[3],v[4]);
        table.insert(world1, plat)
    end
    

end

function love.update(dt)
    if state == "menu" then
        splashrate = splashrate - dt
        if love.keyboard.isDown("s") then
            state = "game"
        end
        return
    end
    spawnrate = spawnrate - dt
    if spawnrate < 0 then
        local tmp = factory.enemyFactory(200,300,150/enemytype3:getHeight()*enemytype3:getWidth(),150,150/enemytype3:getHeight(), 40, 50, enemytype3)
        table.insert(entity,tmp)
        table.insert(world1,tmp)
        spawnrate = 10
    end
    for i,v in ipairs(entity) do
        if v == player then
            startx = v.x
            starty = v.y
        end
        if v ~= nil and v.health <= 0 then
            v = nil
        else
            v:update(dt,world1)
        end
        if v == player then
            if v.y < 400 and v.y > 100 then
                window[2] = window[2] - (v.y -starty)
            end
            if startx +window[1] > 500 and window[1] > -5700 and v.x> startx then
                window[1] = window[1]  - (v.x -startx)
            elseif startx +window[1]< 500 and window[1] < 0 and v.x < startx then
                window[1] = window[1] - (v.x -startx)
            end
        end
    end
end

function love.draw()
    if state == "menu" then
        if splashrate < 0 then
            splashstate = 1- splashstate
            splashrate = 0.15
        end
        love.graphics.draw(splashes[splashstate+1],0,0,0,1,1,0,0)
        love.graphics.setColor(0,0,0)
        love.graphics.print("press s to start",300,600)
        love.graphics.setColor(255,255,255)
        return
    end
    love.graphics.draw(background, window[1], window[2],0,1,1,0,0)
    for i,v in ipairs(world1)do
        if v ~= nil and (v.isChar == false or v.health > 0) then 
            v:draw(window)
        end
    end
end


