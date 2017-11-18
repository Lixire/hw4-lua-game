collidy = require "collidy"
factory = require "factory"
-- player stuff

function love.load()
    success = love.window.setMode(1000,800)
    love.graphics.setBackgroundColor(0, 0, 0)
    background = love.graphics.newImage("img/background-normal.png");
-- player starting vals
    player = factory.playerFactory()
    enemytype1 = love.graphics.newImage("img/rabbit-monster.png")
    enemytype2 = love.graphics.newImage("img/lamp-monster.png")
    state = "menu"

-- create entities
    a = factory.enemyFactory(200,50,150/enemytype1:getHeight()*enemytype1:getWidth(),150,150/enemytype1:getHeight(), 40, 0.05, enemytype1)
    b =  factory.enemyFactory(400,50,200/enemytype2:getHeight()*enemytype2:getWidth(),200,200/enemytype2:getHeight(),100,0.1,enemytype2)
    p = factory.platformFactory(0,600,4000,love.graphics.getHeight())
    window = 0
    entity = {player,a,b}
    world1 = {p, player,a,b}
end

function love.update(dt)
    for i,v in ipairs(entity) do
        if v == player then
            startx = v.x
        end
        if v ~= nil and v.health <= 0 then
            v = nil
        else
            v:update(dt,world1)
        end
        if v == player then
        print(v.x,window)
            if v.x -window > 500 and v.x > startx then
                window = window -v.x + startx
            elseif v.x -window< 500 and v.x < startx then
                window = window -v.x + startx
            end
        end
    end
end

function love.draw()
    love.graphics.draw(background, window, 0,0,1,1,0,0)
    for i,v in ipairs(world1)do
        if v ~= nil and (v.isChar == false or v.health > 0) then 
            v:draw(window) 
        end
    end
end


