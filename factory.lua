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

    function enemy:draw()
        if self.dir == 0 then
            love.graphics.draw(self.img, self.x+self.w, self.y,0,-self.sf,self.sf,0,0)
        else 
            love.graphics.draw(self.img, self.x, self.y,0,self.sf,self.sf,0,0)
        end
        love.graphics.rectangle("fill", self.x,self.y-10,self.health,5)
        love.graphics.rectangle("line", self.x,self.y-10,self.maxhealth,5)
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

    function platform:draw()
        love.graphics.rectangle('fill',self.x, self.y, self.w, self.h)
    end

    return platform
end

function factory.playerFactory()
    player = {}
    player.img= love.graphics.newImage("img/bird-monster.png")
    player.h = 150
    player.w = player.h/player.img:getHeight()*player.img:getWidth()
    -- scale factor
    player.sf = player.h/player.img:getHeight()
    player.dir = 1
    player.x = 50
    player.y = 50
    player.a = 1250
    player.health = 100
    player.maxhealth = 100
    player.dmg = 0.5
    player.velocity = {0,0}
    function player:update(dt,world)
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

        self.velocity[2] = self.velocity[2] + self.a*dt
        self.x = self.x + self.velocity[1]*dt
        self.y = self.y + self.velocity[2]*dt
    end

    -- TODO: debounce combat so it no go so fast
    function player:combat(b)
        if b ~= nil then
            b.health = b.health - self.dmg
            if b.health > 0 then
                self.health = self.health - b.dmg
            end
        end
    end

    function player:draw()
        if self.dir == 0 then
            love.graphics.draw(self.img, self.x+self.w, self.y,0,-self.sf,self.sf,0,0)
        else 
            love.graphics.draw(self.img, self.x, self.y,0,self.sf,self.sf,0,0)
        end
        love.graphics.rectangle("fill", self.x,self.y-10,self.health,5)
        love.graphics.rectangle("line", self.x,self.y-10,self.maxhealth,5)
    end
    return player
end

return factory