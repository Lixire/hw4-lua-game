local factory = {}
function factory.enemyFactory(x,y,w,h,sf,health,dmg, img)
    local enemy = {}
    enemy.x = x
    enemy.y = y
    enemy.w = w
    enemy.h = h
    enemy.health = health
    enemy.maxhealth = health
    enemy.dmg = dmg
    enemy.sf = sf
    enemy.a = 1250
    enemy.img = img
    enemy.dir = 0
    enemy.isChar = true
    enemy.velocity ={0,0}

    function enemy:update(dt,world)
    -- move enemy towards player
        if player.x < self.x then
            self.velocity[1]= -70
            self.dir = 1
        else
            self.velocity[1]= 70
            self.dir = 0
        end
        -- TODO: better AI, what direction the collision was in? So I can change velocity accordingly. I'm assuming in this
        -- iteration that I'm only dealing with vertical collision
        if collidy.collideAll(self, world) then
            collidy.collideResponseAll(self, world, false)
            self.velocity[2] = 0
        else 
            self.velocity[2] = self.velocity[2] + self.a*dt
        end
        self.x = self.x + self.velocity[1]*dt        
        self.y = self.y + self.velocity[2]*dt
    end

    function enemy:draw(window)
        if self.dir == 0 then
            love.graphics.draw(self.img, self.x+self.w+window[1], self.y+window[2],0,-self.sf,self.sf,0,0)
        else 
            love.graphics.draw(self.img, self.x+window[1], self.y+window[2],0,self.sf,self.sf,0,0)
        end
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", self.x+ window[1],self.y+window[2]-10,self.health,5)
        love.graphics.rectangle("line", self.x+ window[1],self.y+window[2]-10,self.maxhealth,5)
        love.graphics.setColor(255,255,255)
    end

    return enemy
end

function factory.platformFactory(x,y,w,h)
    local platform = {}

    platform.x = x
    platform.y = y
    platform.w = w
    platform.h = h
    platform.isChar = false

    function platform:draw(window)
    --[[
        love.graphics.setColor(100,0,0)
        print(self.x,self.y,self.w,self.h)
        love.graphics.rectangle('line',self.x-window[1], self.y-window[2], self.w, self.h)
        love.graphics.setColor(255,255,255)
    ]]
    end

    return platform
end

function factory.playerFactory()
    player = {}
    player.img= love.graphics.newImage("img/bird-monster.png")
    player.attack = love.graphics.newImage("img/bird-monster-attack.png")
    player.isAttack = 0
    player.h = 150
    player.w = player.h/player.img:getHeight()*player.img:getWidth()
    -- scale factor
    player.sf = player.h/player.img:getHeight()
    player.w1 = player.h/player.attack:getHeight()*player.attack:getWidth()
    -- scale factor
    player.sf1 = player.h/player.attack:getHeight()
    player.dir = 1
    player.x = 50
    player.y = 300
    player.a = 1250
    player.health = 100
    player.maxhealth = 100
    player.dmg = 0.5
    player.velocity = {0,0}
    player.saved = "Do you ever think this game will be finished"
    player.message = "Do you ever think this game will be finished"
    function player:update(dt,world)

        if love.keyboard.isDown("a") then
            if player.isAttack <= 0 then
                player.isAttack = 0.1
            end
        end
    -- move player
        if love.keyboard.isDown("right") then
            self.velocity[1]= 200
            self.dir = 0
        elseif love.keyboard.isDown("left") then
            self.velocity[1]= -200
            self.dir = 1
        elseif collidy.collideAll(self, world) then
            self.velocity[1] = 0
        end
        if collidy.collideAll(self, world) then
            self.velocity[2] = 0
            collidy.collideResponseAll(self,world,true)
            if love.keyboard.isDown("up") then
                self.velocity[2] = -600
            end
        end

        if player.isAttack > 0 then
            player.isAttack = player.isAttack - dt
        end

        self.velocity[2] = self.velocity[2] + self.a*dt
        self.x = self.x + self.velocity[1]*dt
        self.y = self.y + self.velocity[2]*dt
    end

    -- TODO: debounce combat so it no go so fast
    function player:combat(b, flag)
        if self.messaged ~= "ouch" then self.saved =  self.message end
        self.message = "ouch"
        if b ~= nil then
            if flag then
                b.health = b.health - self.dmg
            end
            if b.health > 0 then
                self.health = self.health - b.dmg
            end
        end
    end

    function player:draw(window)
        if self.isAttack <= 0 then
            self.isAttack = 0
            if self.dir == 0 then
                love.graphics.draw(self.img, self.x+self.w+window[1], self.y+window[2],0,-self.sf,self.sf,0,0)
            else 
                love.graphics.draw(self.img, self.x+ window[1], self.y+window[2],0,self.sf,self.sf,0,0)
            end
        else
            if self.dir == 0 then
                love.graphics.draw(self.attack, self.x+self.w+window[1], self.y+window[2],0,self.sf1,self.sf1,0,0)
            else 
                love.graphics.draw(self.attack, self.x+ window[1], self.y+window[2],0,-self.sf1,self.sf1,0,0)
            end
        end
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", self.x+ window[1],self.y-10+window[2],self.health,5)
        love.graphics.rectangle("line", self.x+ window[1],self.y-10+window[2],self.maxhealth,5)
        love.graphics.setColor(255,255,255)
        love.graphics.setColor(0,0,0)
        love.graphics.print(self.message,50 ,50)
        love.graphics.setColor(255,255,255)
    end
    return player
end

return factory