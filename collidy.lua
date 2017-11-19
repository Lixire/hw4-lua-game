local collidy = {}

-- collidy functions
function collidy.collide(a,b)
    return CheckCollision(a.x,a.y,a.w,a.h,b.x,b.y,b.w,b.h)
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function CheckCollisionHorizontal(a,world)
    for i,b in ipairs(world) do
        if b ~= a and b.isChar == false then
            if collidy.collide(a,b) then
                if a.velocity[1] < 0 and a.dir == 1 and a.x > b.x then
                    return true
                elseif a.velocity[1] > 0 and a.dir == 0 and a.x < b.x then
                    return true
                end
            end
        end
    end
    return false
end

function collidy.collideResponse(a,b)
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

function collidy.collideAll(a,world)
    for i,v in ipairs(world) do
        if v~= a and (v.isChar == false or v.health > 0) and collidy.collide(a,v) then
            return true
        end
    end
    return false
end

function collidy.collideResponseAll(a, world)
    local colliding_entities = {}
    for i,v in ipairs(world) do
        if v~= a and (v.isChar == false or v.health > 0) and collidy.collide(a,v) then
            table.insert(colliding_entities, v)
            collidy.collideResponse(a,v)
        end
    end
    return colliding_entities
end

--- end of collidy functions
return collidy