world = {}
platform = {}
player = {}

function love.load()
-- player starting vals
    player.img = love.graphics.newImage("img/bird-monster.png")
    player.h = 100
    player.w = 100/player.img:getHeight()*player.img:getWidth()
    -- scale factor
    player.sf = 100/player.img:getHeight()
    player.dir = 1
    player.x = 50
    player.y = 50
    player.a = 800
    player.isKin = false
    player.velocity = {0,0}

-- platform starting vals
    platform.w = love.graphics.getWidth()
    platform.h = love.graphics.getHeight()

    platform.x = 0
    platform.y = 500
end

function love.update(dt)
-- move player

    if love.keyboard.isDown("right") then
        player.velocity[1]= 100
        player.dir = 0
    elseif love.keyboard.isDown("left") then
        player.velocity[1]= -100
        player.dir = 1
    elseif collide(player, platform) then
        player.velocity[1] = 0
    end
    if collide(player, platform) then
        player.velocity[2] = 0
        collideResponse(player,platform)
        if love.keyboard.isDown("up") then
            player.velocity[2] = -400
        end
    end

    player.velocity[2] = player.velocity[2] + player.a*dt
    player.x = player.x + player.velocity[1]*dt
    player.y = player.y + player.velocity[2]*dt
end

function love.draw()
    love.graphics.setColor(255,255,255)
    if player.dir == 0 then
        love.graphics.draw(player.img, player.x+player.w, player.y,0,-player.sf,player.sf,0,32)
    else 
        love.graphics.draw(player.img, player.x, player.y,0,player.sf,player.sf,0,32)
    end
    love.graphics.rectangle('fill',platform.x, platform.y, platform.w, platform.h)
end

function collide(a,b)
    return CheckCollision(a.x,a.y,a.w,a.h,b.x,b.y,b.w,b.h)
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function collideResponse(a,b)
    x = math.max(a.x, b.x)
    y = math.max(a.y, b.y)
    w =  math.min(a.x+a.w,b.x+b.w) - x
    h = math.min(a.y + a.h, b.y+b.h) - y
    if w < h then
        if a.x > b.x then
            a.x = a.x + w
        else
            a.x = a.x - w
        end
    elseif a.y > b.y then
        a.y = a.y + h
    else 
        a.y = a.y - h
    end
end