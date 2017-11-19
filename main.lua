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
    spawnrate = 5
    cooldown = 0.5
    success = love.window.setMode(1000,800)
    love.graphics.setFont(love.graphics.newFont(30))
    love.graphics.setBackgroundColor(255, 255, 255)
    splashes = {love.graphics.newImage("img/splash1.png"),love.graphics.newImage("img/splash2.png")}
    splashrate = 0.5
    splashstate = 0
    background = love.graphics.newImage("img/background-normal.png")
    background2 = love.graphics.newImage("img/background-monster.png")
    sky2 = love.graphics.newImage("img/sky-monster.png")
    sky = love.graphics.newImage("img/sky-normal.png")
    gameovers = {love.graphics.newImage("img/game-over1.png"),love.graphics.newImage("img/game-over2.png")}
    player = factory.playerFactory()
    enemytype1 = love.graphics.newImage("img/rabbit-monster.png")
    enemytype2 = love.graphics.newImage("img/lamp-monster.png")
    enemytype3 = love.graphics.newImage("img/bird-normal.png")
    state = "menu"
    window = {0,0}
    entity = {player}
    world1 = {player}
    thisisbadidea = player
    for i,v in ipairs(platforms) do
        local plat = factory.platformFactory(v[1],v[2],v[3],v[4]);
        table.insert(world1, plat)
    end
    

end

function love.update(dt)
    if state == "menu" or state == "endgame" then
        splashrate = splashrate - dt
    end
    if state == "menu" then
        if love.keyboard.isDown("space") then
            state = "game"
        end
        return
    end
    if love.keyboard.isDown("s") then
        if state == "hide" and cooldown <= 0 then
            state = "game"
            love.graphics.setBackgroundColor(255, 255, 255)
            cooldown = 0.5
            for i,v in ipairs(entity) do
                v.hcolour = 0
            end
        elseif cooldown <= 0 then
            state = "hide"
            love.graphics.setBackgroundColor(0, 0, 0)
            for i,v in ipairs(entity) do
                v.hcolour = 255
            end
            cooldown = 0.5
        end
    end
    if cooldown >= 0 then cooldown = cooldown - dt end
    spawnrate = spawnrate - dt
    if state == "hide" then
        player.health = player.health + dt*5
        if player.health > player.maxhealth then
            player.health = player.maxhealth
        end
        return
    end
    if spawnrate < 0 then
        local enemy_type = math.random(1, 3)
        local new_entity
        if enemy_type == 1 then
            new_entity = factory.enemyFactory(player.x,-150,150/enemytype1:getHeight()*enemytype1:getWidth(),150,150/enemytype1:getHeight(), 40, 100, 40, true, enemytype1)
        elseif enemy_type == 2 then
            new_entity = factory.enemyFactory(player.x,-150,200/enemytype2:getHeight()*enemytype2:getWidth(),200,200/enemytype2:getHeight(),100,20,100, false,enemytype2)
        elseif enemy_type == 3 then
            new_entity = factory.enemyFactory(player.x,-150,150/enemytype3:getHeight()*enemytype3:getWidth(),150,150/enemytype3:getHeight(), 60, 50, 60, false, enemytype3)
        end
        table.insert(entity,new_entity)
        table.insert(world1,new_entity)
        spawnrate = 10
    end
    for i,v in ipairs(entity) do
        if v == player then
            startx = v.x
            starty = v.y
            if v.health <= 0 then
                state = "endgame"
            end
        end
        if v ~= nil and v.health <= 0 then
            v = nil
        else
            v:update(dt,world1)
        end
        if v == player then
            if v.y < 600 and v.y > 400 then
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
        love.graphics.print("press space to start",350,600)
        love.graphics.setColor(255,255,255)
        return
    elseif state == "endgame" then
        if splashrate < 0 then
            splashstate = 1- splashstate
            splashrate = 0.15
        end
        love.graphics.draw(gameovers[splashstate+1],190,90,0,0.3,0.3,0,0)
        love.graphics.setColor(0,0,0)
        love.graphics.print("You punched: "..tostring(player.score).." enemies, wow!",280,600)
        love.graphics.print("press space to restart",330,700)
        love.graphics.setColor(255,255,255)
        if love.keyboard.isDown("space") then
            love.load()
        end
        return
    end
    if state == "hide" then
        love.graphics.draw(sky2, window[1]*0.6, window[2]*0.6,0,0.8,0.8,0,0)
        love.graphics.draw(background2, window[1], window[2],0,1,1,0,0)
    else
        love.graphics.draw(sky, window[1]*0.6, window[2]*0.6,0,0.8,0.8,0,0)
        love.graphics.draw(background, window[1], window[2],0,1,1,0,0)
    end
    for i,v in ipairs(world1)do
        if v ~= nil and (v.isChar == false or v.health > 0) then 
            v:draw(window)
        end
    end
end


