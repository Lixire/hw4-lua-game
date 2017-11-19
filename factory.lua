local factory = {}
function factory.enemyFactory(x,y,w,h,sf,health,dmg, speed, wallhack, img)
    local enemy = {}
    enemy.x = x
    enemy.y = y
    enemy.w = w
    enemy.h = h
    enemy.health = health
    enemy.maxhealth = health
    enemy.dmg = dmg
    enemy.speed = speed
    enemy.wallhack = wallhack
    enemy.sf = sf
    enemy.a = 1250
    enemy.img = img
    enemy.dir = 0
    enemy.hcolour = 0
    enemy.isChar = true
    enemy.velocity ={0,0}

    function enemy:update(dt,world)
    -- move enemy towards player
        if player.x < self.x then
            self.velocity[1]= -speed
            self.dir = 1
        else
            self.velocity[1]= speed
            self.dir = 0
        end

        if self.wallhack then
            if player.y - 50 < self.y then
                self.velocity[2]= -speed
            else
                self.velocity[2]= speed
            end
        end

        -- TODO: better AI, what direction the collision was in? So I can change velocity accordingly. I'm assuming in this
        -- iteration that I'm only dealing with vertical collision
        -- collision detection and response
        if not self.wallhack and collidy.collideAll(self, world) then
            self.velocity[2] = 0
            collidy.collideResponseAll(self, world)
        end

        -- attack using attack hitbox
        local damaged_entities = collidy.collideResponseAll({x=self.x - 10, y=self.y, w=self.w + 20, h=self.h},world)
        for _, entity in ipairs(damaged_entities) do
            if entity.attack ~= nil then entity:attacked(self, self.dmg * dt) end -- attack the player
        end

        -- perform physics updates
        self.velocity[2] = self.velocity[2] + self.a*dt
        self.x = self.x + self.velocity[1]*dt        
        self.y = self.y + self.velocity[2]*dt
    end

    function enemy:attacked(source, damage)
        self.health = self.health - damage
    end

    function enemy:draw(window)
        if self.dir == 0 then
            love.graphics.draw(self.img, self.x+self.w+window[1], self.y+window[2],0,-self.sf,self.sf,0,0)
        else 
            love.graphics.draw(self.img, self.x+window[1], self.y+window[2],0,self.sf,self.sf,0,0)
        end
        love.graphics.setColor(self.hcolour,self.hcolour,self.hcolour)
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
    player.img = love.graphics.newImage("img/bird-monster.png")
    player.attack = love.graphics.newImage("img/bird-monster-attack.png")

    -- physics properties
    player.x = 100
    player.y = 0
    player.h = 150
    player.w = player.h/player.img:getHeight()*player.img:getWidth()
    player.velocity = {0,0}
    player.a = 1250
    
    -- scale factor
    player.sf = player.h/player.img:getHeight()
    player.w1 = player.h/player.attack:getHeight()*player.attack:getWidth()
    -- scale factor
    player.sf1 = player.h/player.attack:getHeight()
    player.dir = 1
    player.health = 100
    player.maxhealth = 100
    player.dmg = 50
    player.hcolour = 0
    player.message = "Do you ever think this game will be finished"
    function player:update(dt,world)
        local is_colliding = collidy.collideAll(self, world)

        self.is_attacking = love.keyboard.isDown("a")

        -- player movement
        if not self.is_attacking and love.keyboard.isDown("right") then
            self.velocity[1]= 300
            self.dir = 0
        elseif not self.is_attacking and love.keyboard.isDown("left") then
            self.velocity[1]= -300
            self.dir = 1
        elseif is_colliding then
            self.velocity[1] = 0
        end

        -- collision detection and response
        if is_colliding then
            self.velocity[2] = 0
            if love.keyboard.isDown("up") then 
                self.velocity[2] = -600
            elseif CheckCollisionHorizontal(self,world) then
                self.velocity[2] = -600
            end
            collidy.collideResponseAll(self,world)
        end


        -- player combat
        if self.is_attacking then
            local weapon_entity
            if self.dir == 0 then
                weapon_entity = {x=self.x + self.w, y=self.y, w=50, h=self.h}
            else
                weapon_entity = {x=self.x - 50, y=self.y, w=50, h=self.h}
            end
            local damaged_entities = collidy.collideResponseAll(weapon_entity,world)
            for _, entity in ipairs(damaged_entities) do
                if entity.isChar then entity:attacked(self, self.dmg * dt) end
            end
        end

        -- perform physics updates
        self.velocity[2] = self.velocity[2] + self.a*dt
        self.x = self.x + self.velocity[1]*dt
        self.y = self.y + self.velocity[2]*dt
    end

    function player:attacked(source, damage)
        self.message = "Ouch!"
        self.health = self.health - damage
    end

    function player:draw(window)
        if not self.is_attacking then
            if self.dir == 0 then
                love.graphics.draw(self.img, self.x+self.w+window[1], self.y+window[2],0,-self.sf,self.sf,0,0)
            else 
                love.graphics.draw(self.img, self.x+ window[1], self.y+window[2],0,self.sf,self.sf,0,0)
            end
        else
            if self.dir == 0 then
                love.graphics.draw(self.attack, self.x+window[1], self.y+window[2],0,self.sf1,self.sf1,0,0)
            else 
                love.graphics.draw(self.attack, self.x+self.w+60+ window[1], self.y+window[2],0,-self.sf1,self.sf1,0,0)
            end
        end

        -- draw health bar
        love.graphics.setColor(self.hcolour,self.hcolour,self.hcolour)
        love.graphics.rectangle("fill", self.x + window[1],self.y-10+window[2],self.health,5)
        love.graphics.rectangle("line", self.x + window[1],self.y-10+window[2],self.maxhealth,5)
        love.graphics.setColor(255,255,255)

        -- draw message
        love.graphics.setColor(255,255,255)
        love.graphics.print(self.message,50 ,50)
    end
    return player
end

return factory