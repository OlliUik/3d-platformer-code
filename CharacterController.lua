local selfEntity = script:SelfEntity()
local swinger = nil
local owner = nil
local ownerMovable = nil
local originalPos = float3.New(0,0,0)
local function Dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end
local function Magnitude(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end
local function GetAngle(v1, v2)

    local cos = Dot(v1,v2) / (Magnitude(v1) * Magnitude(v2))
    return math.acos(cos) * 180 / math.pi
end

local function Substract(v1, v2)
    return float3.New(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

local function Div(vector, d)
    local v1 = vector
    local v = float3.New(v1.x / d, v1.y / d, v1.z / d)
    return v
end
local function Normalize(vector)
    local v1 = vector
	local num = Magnitude(v1)
	if num == 1 then
        local v = v1
        return v
    elseif num > 1e-5 then
        return Div(v1,num)
    else
        local v = float3.New(0, 0, 0)
        return v
	end
end


local function Update()
    --print(os.clock())
   -- print("updating")
    local gTimer = YaTime:WaitFor(0.02)
    EventHelper.AddListener(gTimer, "TimeEvent", function(...)
        local swingerPos = YaScene:GetComponent(script:GetComponentType("YaMovableComponent"), swinger):GetPosition()
        --print("WAAAA!!!!!!!!!")
        --[[  if grappling then
        print("Kepp right going!!!")
         SetupGarpple(grapplePoints[rightGrapplePoint], false)
       end
       if leftGrappling then
        print("Kepp left going!!!")
         SetupGarpple(grapplePoints[leftGrapplePoint], true)
       end]]

       -- currentPlatform = 2
        --platform1Movable:SetPosition(float3.New(ownerMovable:GetPosition().x,ownerMovable:GetPosition().y - 0.5, 3))
       -- ownerMovable:SetPosition(float3.New(swingerPos.x,swingerPos.y, 3))
        --currentPlatform = 1
        --platform2Movable:SetPosition(float3.New(ownerMovable:GetPosition().x,ownerMovable:GetPosition().y - 0.5, 3))
        local moveChange =  ownerMovable:GetPosition() - originalPos
        local swingerVel = PhysicsAPI.GetLinearVelocity(swinger)
        local newVel = float3.New(moveChange.x * 200,0,moveChange.z * 200)
        if Magnitude(newVel) > 0 then
            PhysicsAPI.AddForce(swinger, newVel)
        end
        
        ownerMovable:SetPosition(originalPos)
        --local swingerVel = PhysicsAPI.GetLinearVelocity(swinger)
        --local swingerSpeed = Magnitude(swingerVel)
        --local swingerMovable = YaScene:GetComponent(script:GetComponentType("YaMovableComponent"), swinger)
       -- swingerMovable:SetGlobalRotationEuler(float3.New(0,0,swingerVel.x * 1.2))
      -- print(swingerSpeed)
       --[[if swingerSpeed > 100 then
            local normalizedVel = Normalize(swingerVel)
           -- normalizedVel = float3.New(normalizedVel.x * 100,normalizedVel.y * 100,0)
           -- PhysicsAPI.SetLinearVelocity(swinger, normalizedVel)
       end]]
       
       Update()
    end)
end

local function Setup(abilityOwner)
    print("Settin up the controller")
    owner = abilityOwner
    swinger = YaScene:Spawn("Ball", float3.New(0,10,0))
    print("Swinger", swinger.EntityId)
    print("selfENt", selfEntity.EntityId)
    print("script", script)
   -- YaCameraAPI.SetCameraPosition(owner, float3.New(0,18,0))
    YaCameraAPI.SetCameraFollowAt(owner, swinger)
    --ownerMovable = YaScene:GetComponent(script:GetComponentType("YaMovableComponent"), ability.Owner)
    Update()
    --[[PhysicsAPI.Instance(bottomTrigger):OnTriggerEnter(function(entity)

        if entity.EntityId == swinger.EntityId then
            print("YOU HIT THE BOTTOM!!!!!!!!!!!!!!!!")
            local sound = "Body Fall 2"
            local position = YaScene:GetComponent(script:GetComponentType("YaMovableComponent"), swinger):GetPosition()
            local soundBlock = YaScene:Spawn(sound, float3.New(position))
            local soundEnt = YaSoundAPI.Instance(soundBlock)
            soundEnt:PlaySound(sound, false, 0)
            DeleteSound(soundBlock)
            PhysicsAPI.AddForce(swinger, float3.New(0,400000,0))
        end
    end)]]
   -- CameraUpdate()
end

local function Jump(abilityOwner)
    print("JUMP!!!!!!!!!!!!!!!!!")
    PhysicsAPI.AddForce(swinger, float3.New(0,180,0))
end


local setupDone = false
local Bind = FunctionHelper.Bind
--local selfEntity = script:SelfEntity();
--print("self ENTITY", selfEntity.EntityId)
--print("self SCRIPT", script)
local T_characterComponent = script:GetComponentType("YaCharacterComponent")
local T_playerComponent = script:GetComponentType("YaPlayerComponent")

function OnAvatarSpawned(player, playerId, spawnPointEntity, avatarEntity)
    if not setupDone then
        local avatar = player:GetAvatar()
        local character = YaScene:GetComponent(T_characterComponent, avatarEntity)
        ownerMovable = YaScene:GetComponent(script:GetComponentType("YaMovableComponent"), avatarEntity)
        originalPos = ownerMovable:GetPosition()
        --print("Avatar spawned self ENTITYDown", selfEntity.EntityId)
        print("Avatar spawned self SCRIPTDown", script)
        print("player", playerId, "spawned.")
        setupDone = true
        local controller = YaScene:Spawn("Controller", float3.New(0,0,0))
        YaCharacterAPI.Instance(avatarEntity):Equip(selfEntity, YaEquipParameter.CreateFromToolHandlePoint(selfEntity))
        Setup(avatarEntity)
    end
end

function OnPlayerJoined(playerId)
  if not setupDone then
    --print("Player spawn self ENTITYDown", selfEntity.EntityId)
  
        local player = YaGame:GetPlayer(playerId)
        EventHelper.AddListener(player, "SpawnedEvent", Bind(OnAvatarSpawned, player))
    end
end


EventHelper.AddListener(YaGame, "PlayerJoinedEvent", OnPlayerJoined)
print("ability selfentity", selfEntity.EntityId)
--YaToolAPI.OnAbilityActivate(selfEntity, "Setup", Setup)
--YaToolAPI.OnAbilityActivate(selfEntity, "Stop", Stop)
--YaToolAPI.OnAbilityActivate(selfEntity, "Attack", Fire)
YaToolAPI.OnAbilityActivate(selfEntity, "Jump", Jump)
--YaToolAPI.OnAbilityActivate(selfEntity, "LeftStop", LeftStop)