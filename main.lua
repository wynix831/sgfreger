if game.PlaceId ~= 13253735473 then
    game.Players.LocalPlayer:Kick("Game not support")
    return
end

if identifyexecutor then
    local name = identifyexecutor()
    if name then
        local lowerName = name:lower()
        if lowerName:find("xeno") or lowerName:find("solara") or lowerName:find("velocity") or lowerName:find("swift") or lowerName:find("volcano") or lowerName:find("volt") or lowerName:find("potassium") or lowerName:find("seliware") or lowerName:find("madium") or lowerName:find("delta") or lowerName:find("sirhurt") or lowerName:find("wave") or lowerName:find("synapse z") or lowerName:find("synapsez") or lowerName:find("synapse-z") or lowerName:find("Arceus") then
        else
            game.Players.LocalPlayer:Kick("Unsupported Executor")
            return
        end
    else
        game.Players.LocalPlayer:Kick("Unsupported Executor")
        return
    end
else
    if not getgenv().Solara then
        game.Players.LocalPlayer:Kick("Unsupported Executor")
        return
    end
end

local workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local PathfindingService = cloneref(game:GetService("PathfindingService"))

local _CFramenew = CFrame.new
local _Vector2new = Vector2.new
local _FindFirstChild = game.FindFirstChild
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _IsA = game.IsA
local mathfloor = math.floor



local cheat = { connections = { heartbeats = {}, renderstepped = {} }, drawings = {}, hooks = {}, metahooks = {}, game_hooks = {} }
-- Сброс локальных регистров
local function reset_registers()
    local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
    local _1,_2,_3,_4,_5,_6,_7,_8,_9,_10,_11,_12,_13,_14,_15,_16,_17,_18,_19,_20
    local aa,bb,cc,dd,ee,ff,gg,hh,ii,jj,kk,ll,mm,nn,oo,pp,qq,rr,ss,tt,uu,vv,ww,xx,yy,zz
    local _ = game, workspace, Players, RunService, UserInputService, Camera, CFrame, Vector2, Color3
    local vehicleKillEnabled,vehicleKillTarget,vehicleKillPath,vehicleKillLastUpdate,vehicleKillMomentum
end
reset_registers()

cheat.utility = {}
do
    cheat.utility.anti_trace = function()
        local success, stack = pcall(function() return getstack() end)
        if success and stack and #stack > 80 then return true end
        return false
    end

    cheat.utility.new_heartbeat = function(func)
        cheat.utility.anti_trace()
        local obj = {}
        cheat.connections.heartbeats[func] = func
        function obj:Disconnect()
            if func then cheat.connections.heartbeats[func] = nil func = nil end
        end
        return obj
    end

    cheat.utility.new_renderstepped = function(func)
        cheat.utility.anti_trace()
        local obj = {}
        cheat.connections.renderstepped[func] = func
        function obj:Disconnect()
            if func then cheat.connections.renderstepped[func] = nil func = nil end
        end
        return obj
    end

    cheat.utility.new_drawing = function(drawobj, args)
        cheat.utility.anti_trace()
        local obj = Drawing.new(drawobj)
        for i, v in pairs(args or {}) do obj[i] = v end
        cheat.drawings[obj] = obj
        return obj
    end

    cheat.utility.hook_metamethod = function(instance, metamethod, newf)
        cheat.utility.anti_trace()
        local old = hookmetamethod(instance, metamethod, newcclosure(newf))
        cheat.metahooks[metamethod] = {instance = instance, func = old}
        return old
    end

    local connection = RunService.Heartbeat:Connect(function(delta)
        cheat.utility.anti_trace()
        for _, func in pairs(cheat.connections.heartbeats) do
            if type(func) == "function" then pcall(func, delta) end
        end
    end)

    local connection1 = RunService.RenderStepped:Connect(function(delta)
        cheat.utility.anti_trace()
        for _, func in pairs(cheat.connections.renderstepped) do
            if type(func) == "function" then pcall(func, delta) end
        end
    end)

    cheat.utility.unload = function()
        cheat.utility.anti_trace()
        for _, t in pairs(heliTexts) do safeRemoveDrawing(t) end
        for _, t in pairs(corpseTexts) do safeRemoveDrawing(t) end
        connection:Disconnect()
        connection1:Disconnect()
        for _, drawing in pairs(cheat.drawings) do
            pcall(function() if drawing and drawing.Remove then drawing:Remove() end end)
        end
    end
end

local function safeRemoveDrawing(drawing)
    if drawing and drawing.Remove then
        pcall(function()
            drawing.Visible = false
            drawing:Remove()
        end)
    end
end

spawn(function()
    cheat.utility.anti_trace()
    local old_random_hook = cheat.utility.hook_metamethod(Random.new(), "__namecall", function(self, ...)
        cheat.utility.anti_trace()
        local method = getnamecallmethod()
        local args = {...}
        if method == "NextNumber" and args[1] == -100 and args[2] == 100 then
            return cheat.metahooks.__namecall.func(self, -1, 1)
        end
        return cheat.metahooks.__namecall.func(self, ...)
    end)
    cheat.game_hooks["Random"] = {instance = Random.new(), metamethod = "__namecall", func = old_random_hook}
end)

local redictionEnabled = false
local hitScannerEnabled = false
local redictionFOVSize = 150
local redictionWorkingDistance = 2000
local redictionTargetPart = nil
local redictionTargetPos = nil
local redictionCachedTarget = nil
local redictionIgnoreSleeper = false
local redictionIgnoreBot = false

local globalESPEnabled = true
local globalESPDistance = 2000
local vehicleESPEnabled = true
local vehicleESPDistance = 2000
local resourceESPEnabled = true
local resourceESPDistance = 2000
local materialESPEnabled = true
local materialESPDistance = 2000
local vehicleTurnSpeed = 180

local silentAimEnabled = false
local silentAimFOV = 199
local silentAimMaxDistance = 1000


local fovChangerEnabled = false
local desiredFOV = 120

local freecamMode = false
local freecamKey = Enum.KeyCode.J
local freecamSpeed = 160

local espSettings = {
    Enemy = { Enabled = true, Box = true, BoxOutline = true, Name = true, NameOutline = true, Weapon = true, WeaponOutline = true, Distance = true, DistanceOutline = true, BoxColor = Color3.new(1, 0, 0), BoxOutlineColor = Color3.new(0, 0, 0), NameColor = Color3.new(1, 1, 1), NameOutlineColor = Color3.new(0, 0, 0), WeaponColor = Color3.new(1, 1, 1), WeaponOutlineColor = Color3.new(0, 0, 0), DistanceColor = Color3.new(1, 1, 1), DistanceOutlineColor = Color3.new(0, 0, 0), Corpse = true, CorpseColor = Color3.new(1, 0.4, 0.4), CorpseOutline = true, CorpseOutlineColor = Color3.new(0,0,0) },
    Sleeper = { Enabled = true, Box = true, BoxOutline = true, Name = true, NameOutline = true, Weapon = true, WeaponOutline = true, Distance = true, DistanceOutline = true, BoxColor = Color3.new(0, 1, 0), BoxOutlineColor = Color3.new(0, 0, 0), NameColor = Color3.new(1, 1, 1), NameOutlineColor = Color3.new(0, 0, 0), WeaponColor = Color3.new(1, 1, 1), WeaponOutlineColor = Color3.new(0, 0, 0), DistanceColor = Color3.new(1, 1, 1), DistanceOutlineColor = Color3.new(0, 0, 0) },
    Bot = { Enabled = true, Box = true, BoxOutline = true, Name = true, NameOutline = true, Weapon = true, WeaponOutline = true, Distance = true, DistanceOutline = true, BoxColor = Color3.new(1, 1, 0), BoxOutlineColor = Color3.new(0, 0, 0), NameColor = Color3.new(1, 1, 1), NameOutlineColor = Color3.new(0, 0, 0), WeaponColor = Color3.new(1, 1, 1), WeaponOutlineColor = Color3.new(0, 0, 0), DistanceColor = Color3.new(1, 1, 1), DistanceOutlineColor = Color3.new(0, 0, 0) }
}

local vehicleSettings = {
    Car = { Enabled = true, Name = true, NameColor = Color3.new(1, 0.5, 0), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Quad = { Enabled = true, Name = true, NameColor = Color3.new(0, 1, 0.8), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Helicopter = { Enabled = true, Name = true, NameColor = Color3.new(1, 0, 1), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Boat = { Enabled = true, Name = true, NameColor = Color3.new(0, 0.5, 1), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) }
}

local resourceSettings = {
    Box = { Enabled = true, Name = true, NameColor = Color3.new(1, 0.8, 0), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    MiniBox = { Enabled = true, Name = true, NameColor = Color3.new(0, 1, 1), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Metal = { Enabled = true, Name = true, NameColor = Color3.new(0.6, 0.6, 0.6), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Bloxy = { Enabled = true, Name = true, NameColor = Color3.new(1, 0, 0), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) }
}

local materialSettings = {
    Cactus = { Enabled = true, Name = true, NameColor = Color3.new(0, 0.8, 0), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Tree = { Enabled = true, Name = true, NameColor = Color3.new(0, 1, 0), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Stone = { Enabled = true, Name = true, NameColor = Color3.new(0.5, 0.5, 0.5), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Nitrate = { Enabled = true, Name = true, NameColor = Color3.new(1, 1, 1), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) },
    Iron = { Enabled = true, Name = true, NameColor = Color3.new(0.8, 0.4, 0.2), NameOutline = true, NameOutlineColor = Color3.new(0,0,0) }
}

local weapons = {
    Bow = {"Arrow","Fabric","Meshes/Bow","Handle","AnimationController"},
    AR15 = {"AnimSaves","Barrel","Body","Bolt","ChargingHandle","Decor","Grip","Handle","Mag","Rails","Stock","ADS","Muzzle","AnimationController"},
    Bandage = {"Handle","Bandage","AnimationController"},
    Beans = {"Beans","Handle","AnimationController"},
    BloxyCola = {"Bloxy Cola HD","Handle","AnimationController"},
    Blunderbuss = {"Body","Handle","Tube","thing","ADS","Muzzle","AnimationController"},
    C9 = {"Barrel","Body","Bolt","Decor","Grip","Handle","LowerSlide","Mag","Sight1","Sight2","UpperSlide","ADS","Muzzle","AnimationController"},
    CrossBow = {"AnimationController","FrontNails","SpringSteel","Body","Slide","Release","Wheel","BackMetal","String","Arrow","Handle","ADS"},
    EnergyRifle = {"DefaultSight","FrontCover","Glowing","Grip","Handle","Mag","Metal","Metal2","RearCover","RearDecor","Screws","Tubes","AnimationController"},
    FlameThrower = {"Barrel","Body","Decor","Grip","Handle","Hoses","LowerTank","Mag","Strap","Tubes","Particle","AnimationController"},
    GaussRifle = {"DefaultSight","Barrel","Body","CoilHolders","Coils","Decals1","Decals2","Grip","Handle","Housing","Mag","StockBack","AnimationController"},
    HMAR = {"DefaultSight","Body","Bolt","Bolts","Cover","Handle","Mag","Rails","Spring","Stock","Wood","Muzzle","AnimationController"},
    HealingBandage = {"Handle","Bandage","AnimationController"},
    LeverActionRifle = {"9mm","DefaultSight","Body","Brass","Hammer","Handle","Lever","Metal","Thing","Wood","Muzzle","AnimationController"},
    M4A1 = {"DefaultSight","Body","Bolt","ChargeHandle","Grip","Handle","Mag","Metal","mbrk","Muzzle","AnimationController"},
    MedSerum = {"Body","Cross","Handle","Injector","Plunger","Spring","AnimationController"},
    MiningDrill = {"Bearings","Body","DrillBit","Handle","Inlets","Tubes","VisualHandle","AnimationController"},
    PipePistol = {"DefaultSight","Body","Bolt","Handle","Mag","Muzzle","AnimationController","Animator"},
    PipeSMG = {"DefaultSight","Barrel","Body","Bolt","Flap","Grip","Handle","Mag","Stock","Muzzle","AnimationController"},
    PumpShotgun = {"Barrel","Body","Handle","MainMetal","RearSight","Shell","Slider","ADS","Muzzle","AnimationController"},
    RPG = {"RocketModel","Body","Body2","Caps","Fasteners","FireMech","Handle","Safety","Sight","Trigger","ADS","Muzzle","AnimationController"},
    SCAR = {"DefaultSight","Barrel","Body","ChargingHandle","Decals","Handle","Mag","Rails","ShoulderPad","Stock","Muzzle","AnimationController"},
    SVD = {"DefaultSight","Body","Bolt","Handle","Magazine","Magazine2","Metal2","Wood","AnimationController"},
    USP9 = {"Body","Handle","Mag","Slide","ADS","Muzzle","AnimationController"},
    UZI = {"DefaultSight","Body","Body2","Bolt","ChargingHandle","Decor","Grip","Handle","Mag","Stock","Muzzle","AnimationController"},
    MAGNUM = {"Cylinder", "Decor", "EjectRod", "EjectRodDecal", "Body", "Grip", "Hammer", "SwingArm", "ADS", "Muzzle", "Handle", "MagnumBullet1"}
}

local weaponCache = setmetatable({}, { __mode = "k" })
local typeCache = setmetatable({}, { __mode = "k" })
local weaponConnections = setmetatable({}, { __mode = "k" })
local entities = setmetatable({}, { __mode = "k" })

local vehicleCache = { Car = {}, Quad = {}, Helicopter = {}, Boat = {} }
local vehicleTexts = { Car = {}, Quad = {}, Helicopter = {}, Boat = {} }

local lootCache = { Box = {}, MiniBox = {}, Metal = {}, Bloxy = {} }
local lootTexts = { Box = {}, MiniBox = {}, Metal = {}, Bloxy = {} }

local materialCache = { Cactus = {}, Tree = {}, Stone = {}, Nitrate = {}, Iron = {} }
local materialTexts = { Cactus = {}, Tree = {}, Stone = {}, Nitrate = {}, Iron = {} }

local hitMarkerEnabled = false
local hitMarkerColor = Color3.fromRGB(158, 0, 153)

local hitSoundEnabled = false
local hitSoundVolume = 1
local selectedHitSound = "Hit Sound 1"

local hitIndicatorEnabled = false
local trailEnabled = false

local jumpShootEnabled = false
local jumpShootPart = nil

local speedHackEnabled = false

local vehicleFlyEnabled = false
local vehicleNoclipEnabled = false
local boatSpeedEnabled = false
local vehicleHorizontalSpeed = 15
local vehicleVerticalSpeed = 15
local boatHorizontalSpeed = 15
local currentCar = nil
local lastCarSearch = 0
local CAR_SEARCH_COOLDOWN = 0.3

local vehicleMomentumEnabled = true
local vehicleMomentumDecay = 5

local vehicleKillEnabled = false
local vehicleKillTarget = nil
local vehicleKillActive = false
local vehicleKillPath = {}
local vehicleKillLastUpdate = 0
local vehicleKillMomentum = Vector3.new()

-- =============================================
-- === МАКСИМАЛЬНЫЙ ЖЁСТКИЙ СБРОС ВСЕГО ===
-- =============================================

-- Основные переключатели
redictionEnabled = false
hitScannerEnabled = false
redictionIgnoreSleeper = false
redictionIgnoreBot = false

globalESPEnabled = false
vehicleESPEnabled = false
resourceESPEnabled = false
materialESPEnabled = false

fovChangerEnabled = false
freecamMode = false
speedHackEnabled = false

vehicleFlyEnabled = false
vehicleNoclipEnabled = false
boatSpeedEnabled = false
vehicleKillEnabled = false
vehicleReliefEnabled = false
vehicleMomentumEnabled = true

hitMarkerEnabled = false
hitSoundEnabled = false
hitIndicatorEnabled = false
trailEnabled = false
jumpShootEnabled = false
timeChangerEnabled = false

-- Полный сброс ESP (все категории + все подопции)
for _, cat in pairs(espSettings) do
    if typeof(cat) == "table" then
        cat.Enabled = false
        cat.Box = false
        cat.BoxOutline = false
        cat.Name = false
        cat.NameOutline = false
        cat.Weapon = false
        cat.WeaponOutline = false
        cat.Distance = false
        cat.DistanceOutline = false
        cat.Corpse = false
        cat.CorpseOutline = false
    end
end

for _, v in pairs(vehicleSettings) do
    v.Enabled = false
    v.Name = false
    v.NameOutline = false
end

for _, v in pairs(resourceSettings) do
    v.Enabled = false
    v.Name = false
    v.NameOutline = false
end

for _, v in pairs(materialSettings) do
    v.Enabled = false
    v.Name = false
    v.NameOutline = false
end

-- Сброс FOV круга и Snapline
if fovOutline then fovOutline.Visible = false end
if fovFill then fovFill.Visible = false end
if redictionSnapline then redictionSnapline.Visible = false end




local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/addons/ThemeManager.lua"))()

local Window = Library:CreateWindow({ Title = "Nyxon Project | dsc.gg/NyxonProject", Center = true, AutoShow = true })
local Tabs = { Combat = Window:AddTab("Combat"), Visuals = Window:AddTab("Visuals"), Misc = Window:AddTab("Misc"), Settings = Window:AddTab("Settings") }

local CombatGroup = Tabs.Combat:AddLeftGroupbox("Manipulation")
local SilentAimGroup = Tabs.Combat:AddRightGroupbox("Silent Aim")

SilentAimGroup:AddToggle("SilentAimToggle", {
    Text = "Enabled",
    Default = false,
    Callback = function(v)
        silentAimEnabled = v
    end
})

SilentAimGroup:AddSlider("SilentAimFOVSlider", {
    Text = "FOV",
    Default = 199,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        silentAimFOV = v
    end
})

SilentAimGroup:AddSlider("SilentAimDistanceSlider", {
    Text = "Max Distance",
    Default = 1000,
    Min = 100,
    Max = 3000,
    Rounding = 0,
    Callback = function(v)
        silentAimMaxDistance = v
    end
})

-- =============================================
--           HITBOX EXPANDER (ОТДЕЛЬНАЯ КАТЕГОРИЯ)
-- =============================================

-- =============================================
--           HITBOX EXPANDER (ФИНАЛЬНАЯ ВЕРСИЯ)
-- =============================================

local hitboxExpanderEnabled = false
local hitboxSizeX = 8
local hitboxSizeY = 8
local hitboxSizeZ = 8
local hitboxIgnoreSleeper = true
local hitboxIgnoreBot = true

local originalHeadSize = nil
local hitboxCache = setmetatable({}, { __mode = "k" })

-- Самостоятельные проверки (чтобы не зависеть от функций ниже)
local function isSleeping(model)
    if not model then return false end
    local torso = model:FindFirstChild("LowerTorso")
    if not torso then return false end
    local rootRig = torso:FindFirstChild("RootRig")
    return rootRig and typeof(rootRig.CurrentAngle) == "number" and rootRig.CurrentAngle ~= 0
end

local function isPlayer(model)
    if not model then return false end
    local torso = model:FindFirstChild("Torso")
    if not torso then return false end
    return torso:FindFirstChild("LeftBooster") ~= nil
end

local function getOriginalHeadSize()
    if originalHeadSize then return end
    pcall(function()
        local ref = game:GetService("ReplicatedStorage"):FindFirstChild("Shared", true)
        if ref then
            local entities = ref:FindFirstChild("entities", true)
            if entities then
                local model = entities:FindFirstChild("Player", true)
                if model and model:FindFirstChild("Model") then
                    local head = model.Model:FindFirstChild("Head")
                    if head then originalHeadSize = head.Size end
                end
            end
        end
    end)
end

local function applyHitbox(model)
    if not model or not model.Parent then return end
    
    local head = model:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then return end

    local sleeping = isSleeping(model)
    local realPlayer = isPlayer(model)

    if (hitboxIgnoreSleeper and sleeping) or (hitboxIgnoreBot and not realPlayer) then
        if originalHeadSize then
            head.Size = originalHeadSize
            head.Transparency = 0
            head.CanCollide = true
        end
        return
    end

    head.Size = Vector3.new(hitboxSizeX, hitboxSizeY, hitboxSizeZ)
    head.Transparency = 0.6
    head.CanCollide = false
    hitboxCache[model] = true
end

local function restoreAllHitboxes()
    for model in pairs(hitboxCache) do
        pcall(function()
            if model and model.Parent then
                local head = model:FindFirstChild("Head")
                if head and originalHeadSize then
                    head.Size = originalHeadSize
                    head.Transparency = 0
                    head.CanCollide = true
                end
            end
        end)
    end
    table.clear(hitboxCache)
end

-- ==================== UI ====================
local HitboxGroup = Tabs.Combat:AddLeftGroupbox("Hitbox Expander")

HitboxGroup:AddToggle("HitboxToggle", {
    Text = "Enabled",
    Default = false,
    Callback = function(v)
        hitboxExpanderEnabled = v
        if not v then restoreAllHitboxes() end
    end
})

HitboxGroup:AddSlider("HitboxSizeX", { Text = "Size X", Default = 8, Min = 1, Max = 20, Rounding = 1, Callback = function(v) hitboxSizeX = v end })
HitboxGroup:AddSlider("HitboxSizeY", { Text = "Size Y", Default = 8, Min = 1, Max = 20, Rounding = 1, Callback = function(v) hitboxSizeY = v end })
HitboxGroup:AddSlider("HitboxSizeZ", { Text = "Size Z", Default = 8, Min = 1, Max = 20, Rounding = 1, Callback = function(v) hitboxSizeZ = v end })

HitboxGroup:AddToggle("HitboxIgnoreSleeper", { Text = "Ignore Sleeper", Default = true, Callback = function(v) hitboxIgnoreSleeper = v end })
HitboxGroup:AddToggle("HitboxIgnoreBot",     { Text = "Ignore Bot",     Default = true, Callback = function(v) hitboxIgnoreBot = v end })

-- ==================== ЗАПУСК ====================
getOriginalHeadSize()

cheat.utility.new_heartbeat(function()
    if not hitboxExpanderEnabled then return end
    
    for model in pairs(entities) do
        if model and model.Parent then
            applyHitbox(model)
        end
    end
end)

-- Очистка
local oldUnload = cheat.utility.unload
cheat.utility.unload = function()
    restoreAllHitboxes()
    if oldUnload then oldUnload() end
end



local ESPTabBox = Tabs.Visuals:AddLeftTabbox()
local VehicleTabBox = Tabs.Visuals:AddLeftTabbox()
local ResourceTabBox = Tabs.Visuals:AddLeftTabbox()
local MaterialTabBox = Tabs.Visuals:AddLeftTabbox()
local GlobalESPGroup = Tabs.Visuals:AddRightGroupbox("ESP Settings")
local CombatSettingsGroup = Tabs.Visuals:AddRightGroupbox("Combat Settings")
local CombatFeedbackGroup = Tabs.Visuals:AddRightGroupbox("Combat Feedback")
local CameraSettingsGroup = Tabs.Visuals:AddRightGroupbox("Camera Settings")
local WorldSettingsGroup = Tabs.Visuals:AddRightGroupbox("World Settings")

local WeaponHooksGroup = Tabs.Misc:AddLeftGroupbox("Weapon Hooks")
local PlayerSettingsGroup = Tabs.Misc:AddRightGroupbox("Player Settings")
local VehicleSettingsGroup = Tabs.Misc:AddLeftGroupbox("Vehicle Settings")

-- === FIX LOCAL REGISTERS ===
local _ = game
_ = workspace
_ = Players
_ = RunService
_ = UserInputService
_ = Camera
_ = CFrame
_ = Vector2
_ = Color3
-- и т.д. (чтобы "съесть" часть регистров заранее)

-- Добавьте ограничение для всех кэшей:

local function limitCacheSize(cache, maxSize)
    local count = 0
    for _ in pairs(cache) do
        count = count + 1
        if count > maxSize then
            for k, v in pairs(cache) do
                cache[k] = nil
                break
            end
        end
    end
end
local function cleanCaches()
    limitCacheSize(entities, 100)
    limitCacheSize(weaponCache, 100)
    limitCacheSize(typeCache, 100)
    limitCacheSize(corpseTexts, 50)
    limitCacheSize(heliTexts, 50)
end

-- Добавьте в heartbeat:
cheat.utility.new_heartbeat(function()
    cleanCaches() -- Каждый тик очищаем
    for model in pairs(entities) do
        if model and model.Parent then detectWeapon(model) end
    end
end)

local function globalMemoryCleanup()
    local collected = 0
    for _ in pairs(entities) do collected = collected + 1 end
    if collected > 200 then
        -- Очищаем старые энтити
        for model, _ in pairs(entities) do
            if not model or not model.Parent then
                removeEntity(model)
            end
        end
    end
    
    -- Принудительная сборка мусора
    if collected % 50 == 0 then
        task.wait()
        collectgarbage("collect")
    end
end

local playerTexts = {}


CombatGroup:AddToggle("RedictionToggle", { Text = "Enabled", Default = false, Callback = function(v) redictionEnabled = v end })
CombatGroup:AddToggle("HitscanToggle", { Text = "Hit Scanner", Default = false, Callback = function(v) hitScannerEnabled = v end })
CombatGroup:AddToggle("IgnoreSleeperToggle", { Text = "Ignore Sleeper", Default = false, Callback = function(v) redictionIgnoreSleeper = v end })
CombatGroup:AddToggle("IgnoreBotToggle", { Text = "Ignore Bot", Default = false, Callback = function(v) redictionIgnoreBot = v end })
CombatGroup:AddSlider("FOVSlider", { Text = "FOV Size", Default = 50, Min = 50, Max = 500, Rounding = 0, Callback = function(v) redictionFOVSize = v end })
CombatGroup:AddSlider("DistanceSlider", { Text = "Max Distance", Default = 100, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) redictionWorkingDistance = v end })





-- ==================== ESP TABS UI (Optimized with do-end) ====================

do
    local EnemyTab = ESPTabBox:AddTab("Enemy")
    EnemyTab:AddToggle("EnemyEnabled", { Text = "Enabled", Default = false, Callback = function(v) espSettings.Enemy.Enabled = v end })
    EnemyTab:AddToggle("EnemyBox", { Text = "Box", Default = false, Callback = function(v) espSettings.Enemy.Box = v end }):AddColorPicker("EnemyBoxColor", { Default = Color3.new(1, 0, 0), Callback = function(v) espSettings.Enemy.BoxColor = v end })
    EnemyTab:AddToggle("EnemyBoxOutline", { Text = "Box Outline", Default = false, Callback = function(v) espSettings.Enemy.BoxOutline = v end }):AddColorPicker("EnemyBoxOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Enemy.BoxOutlineColor = v end })
    EnemyTab:AddToggle("EnemyName", { Text = "Name", Default = false, Callback = function(v) espSettings.Enemy.Name = v end }):AddColorPicker("EnemyNameColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Enemy.NameColor = v end })
    EnemyTab:AddToggle("EnemyNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) espSettings.Enemy.NameOutline = v end }):AddColorPicker("EnemyNameOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Enemy.NameOutlineColor = v end })
    EnemyTab:AddToggle("EnemyCorpse", { Text = "Corpse", Default = false, Callback = function(v) espSettings.Enemy.Corpse = v end }):AddColorPicker("EnemyCorpseColor", { Default = Color3.new(1, 0.4, 0.4), Callback = function(v) espSettings.Enemy.CorpseColor = v end })
    EnemyTab:AddToggle("EnemyCorpseOutline", { Text = "Corpse Outline", Default = false, Callback = function(v) espSettings.Enemy.CorpseOutline = v end }):AddColorPicker("EnemyCorpseOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) espSettings.Enemy.CorpseOutlineColor = v end })
    EnemyTab:AddToggle("EnemyWeapon", { Text = "Weapon", Default = false, Callback = function(v) espSettings.Enemy.Weapon = v end }):AddColorPicker("EnemyWeaponColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Enemy.WeaponColor = v end })
    EnemyTab:AddToggle("EnemyWeaponOutline", { Text = "Weapon Outline", Default = false, Callback = function(v) espSettings.Enemy.WeaponOutline = v end }):AddColorPicker("EnemyWeaponOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Enemy.WeaponOutlineColor = v end })
    EnemyTab:AddToggle("EnemyDistance", { Text = "Distance", Default = false, Callback = function(v) espSettings.Enemy.Distance = v end }):AddColorPicker("EnemyDistanceColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Enemy.DistanceColor = v end })
    EnemyTab:AddToggle("EnemyDistanceOutline", { Text = "Distance Outline", Default = false, Callback = function(v) espSettings.Enemy.DistanceOutline = v end }):AddColorPicker("EnemyDistanceOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Enemy.DistanceOutlineColor = v end })
end

do
    local SleeperTab = ESPTabBox:AddTab("Sleeper")
    SleeperTab:AddToggle("SleeperEnabled", { Text = "Enabled", Default = false, Callback = function(v) espSettings.Sleeper.Enabled = v end })
    SleeperTab:AddToggle("SleeperBox", { Text = "Box", Default = false, Callback = function(v) espSettings.Sleeper.Box = v end }):AddColorPicker("SleeperBoxColor", { Default = Color3.new(0, 1, 0), Callback = function(v) espSettings.Sleeper.BoxColor = v end })
    SleeperTab:AddToggle("SleeperBoxOutline", { Text = "Box Outline", Default = false, Callback = function(v) espSettings.Sleeper.BoxOutline = v end }):AddColorPicker("SleeperBoxOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Sleeper.BoxOutlineColor = v end })
    SleeperTab:AddToggle("SleeperName", { Text = "Name", Default = false, Callback = function(v) espSettings.Sleeper.Name = v end }):AddColorPicker("SleeperNameColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Sleeper.NameColor = v end })
    SleeperTab:AddToggle("SleeperNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) espSettings.Sleeper.NameOutline = v end }):AddColorPicker("SleeperNameOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Sleeper.NameOutlineColor = v end })
    SleeperTab:AddToggle("SleeperWeapon", { Text = "Weapon", Default = false, Callback = function(v) espSettings.Sleeper.Weapon = v end }):AddColorPicker("SleeperWeaponColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Sleeper.WeaponColor = v end })
    SleeperTab:AddToggle("SleeperWeaponOutline", { Text = "Weapon Outline", Default = false, Callback = function(v) espSettings.Sleeper.WeaponOutline = v end }):AddColorPicker("SleeperWeaponOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Sleeper.WeaponOutlineColor = v end })
    SleeperTab:AddToggle("SleeperDistance", { Text = "Distance", Default = false, Callback = function(v) espSettings.Sleeper.Distance = v end }):AddColorPicker("SleeperDistanceColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Sleeper.DistanceColor = v end })
    SleeperTab:AddToggle("SleeperDistanceOutline", { Text = "Distance Outline", Default = false, Callback = function(v) espSettings.Sleeper.DistanceOutline = v end }):AddColorPicker("SleeperDistanceOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Sleeper.DistanceOutlineColor = v end })
end

do
    local BotTab = ESPTabBox:AddTab("Bot")
    BotTab:AddToggle("BotEnabled", { Text = "Enabled", Default = false, Callback = function(v) espSettings.Bot.Enabled = v end })
    BotTab:AddToggle("BotBox", { Text = "Box", Default = false, Callback = function(v) espSettings.Bot.Box = v end }):AddColorPicker("BotBoxColor", { Default = Color3.new(1, 1, 0), Callback = function(v) espSettings.Bot.BoxColor = v end })
    BotTab:AddToggle("BotBoxOutline", { Text = "Box Outline", Default = false, Callback = function(v) espSettings.Bot.BoxOutline = v end }):AddColorPicker("BotBoxOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Bot.BoxOutlineColor = v end })
    BotTab:AddToggle("BotName", { Text = "Name", Default = false, Callback = function(v) espSettings.Bot.Name = v end }):AddColorPicker("BotNameColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Bot.NameColor = v end })
    BotTab:AddToggle("BotNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) espSettings.Bot.NameOutline = v end }):AddColorPicker("BotNameOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Bot.NameOutlineColor = v end })
    BotTab:AddToggle("BotWeapon", { Text = "Weapon", Default = false, Callback = function(v) espSettings.Bot.Weapon = v end }):AddColorPicker("BotWeaponColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Bot.WeaponColor = v end })
    BotTab:AddToggle("BotWeaponOutline", { Text = "Weapon Outline", Default = false, Callback = function(v) espSettings.Bot.WeaponOutline = v end }):AddColorPicker("BotWeaponOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Bot.WeaponOutlineColor = v end })
    BotTab:AddToggle("BotDistance", { Text = "Distance", Default = false, Callback = function(v) espSettings.Bot.Distance = v end }):AddColorPicker("BotDistanceColor", { Default = Color3.new(1, 1, 1), Callback = function(v) espSettings.Bot.DistanceColor = v end })
    BotTab:AddToggle("BotDistanceOutline", { Text = "Distance Outline", Default = false, Callback = function(v) espSettings.Bot.DistanceOutline = v end }):AddColorPicker("BotDistanceOutlineColor", { Default = Color3.new(0, 0, 0), Callback = function(v) espSettings.Bot.DistanceOutlineColor = v end })
end

do
    local CarTab = VehicleTabBox:AddTab("Car")
    CarTab:AddToggle("CarEnabled", { Text = "Enabled", Default = false, Callback = function(v) vehicleSettings.Car.Enabled = v end })
    CarTab:AddToggle("CarName", { Text = "Name", Default = false, Callback = function(v) vehicleSettings.Car.Name = v end }):AddColorPicker("CarNameColor", { Default = Color3.new(1, 0.5, 0), Callback = function(v) vehicleSettings.Car.NameColor = v end })
    CarTab:AddToggle("CarNameOutline", { Text = "Name Outline", Default = trufalsee, Callback = function(v) vehicleSettings.Car.NameOutline = v end }):AddColorPicker("CarNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) vehicleSettings.Car.NameOutlineColor = v end })
end

do
    local QuadTab = VehicleTabBox:AddTab("Quad bike")
    QuadTab:AddToggle("QuadEnabled", { Text = "Enabled", Default = false, Callback = function(v) vehicleSettings.Quad.Enabled = v end })
    QuadTab:AddToggle("QuadName", { Text = "Name", Default = false, Callback = function(v) vehicleSettings.Quad.Name = v end }):AddColorPicker("QuadNameColor", { Default = Color3.new(0, 1, 0.8), Callback = function(v) vehicleSettings.Quad.NameColor = v end })
    QuadTab:AddToggle("QuadNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) vehicleSettings.Quad.NameOutline = v end }):AddColorPicker("QuadNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) vehicleSettings.Quad.NameOutlineColor = v end })
end

do
    local HeliTab = VehicleTabBox:AddTab("Heli")
    HeliTab:AddToggle("HeliEnabled", { Text = "Enabled", Default = false, Callback = function(v) vehicleSettings.Helicopter.Enabled = v end })
    HeliTab:AddToggle("HeliName", { Text = "Name", Default = false, Callback = function(v) vehicleSettings.Helicopter.Name = v end }):AddColorPicker("HeliNameColor", { Default = Color3.new(1, 0, 1), Callback = function(v) vehicleSettings.Helicopter.NameColor = v end })
    HeliTab:AddToggle("HeliNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) vehicleSettings.Helicopter.NameOutline = v end }):AddColorPicker("HeliNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) vehicleSettings.Helicopter.NameOutlineColor = v end })
end

do
    local BoatTab = VehicleTabBox:AddTab("Boat")
    BoatTab:AddToggle("BoatEnabled", { Text = "Enabled", Default = false, Callback = function(v) vehicleSettings.Boat.Enabled = v end })
    BoatTab:AddToggle("BoatName", { Text = "Name", Default = false, Callback = function(v) vehicleSettings.Boat.Name = v end }):AddColorPicker("BoatNameColor", { Default = Color3.new(0, 0.5, 1), Callback = function(v) vehicleSettings.Boat.NameColor = v end })
    BoatTab:AddToggle("BoatNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) vehicleSettings.Boat.NameOutline = v end }):AddColorPicker("BoatNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) vehicleSettings.Boat.NameOutlineColor = v end })
end

do
    local BoxTab = ResourceTabBox:AddTab("Box")
    BoxTab:AddToggle("BoxEnabled", { Text = "Enabled", Default = false, Callback = function(v) resourceSettings.Box.Enabled = v end })
    BoxTab:AddToggle("BoxName", { Text = "Name", Default = false, Callback = function(v) resourceSettings.Box.Name = v end }):AddColorPicker("BoxNameColor", { Default = Color3.new(1, 0.8, 0), Callback = function(v) resourceSettings.Box.NameColor = v end })
    BoxTab:AddToggle("BoxNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) resourceSettings.Box.NameOutline = v end }):AddColorPicker("BoxNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) resourceSettings.Box.NameOutlineColor = v end })
end

do
    local MiniBoxTab = ResourceTabBox:AddTab("Mini Box")
    MiniBoxTab:AddToggle("MiniBoxEnabled", { Text = "Enabled", Default = false, Callback = function(v) resourceSettings.MiniBox.Enabled = v end })
    MiniBoxTab:AddToggle("MiniBoxName", { Text = "Name", Default = false, Callback = function(v) resourceSettings.MiniBox.Name = v end }):AddColorPicker("MiniBoxNameColor", { Default = Color3.new(0, 1, 1), Callback = function(v) resourceSettings.MiniBox.NameColor = v end })
    MiniBoxTab:AddToggle("MiniBoxNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) resourceSettings.MiniBox.NameOutline = v end }):AddColorPicker("MiniBoxNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) resourceSettings.MiniBox.NameOutlineColor = v end })
end

do
    local MetalTab = ResourceTabBox:AddTab("Metal")
    MetalTab:AddToggle("MetalEnabled", { Text = "Enabled", Default = false, Callback = function(v) resourceSettings.Metal.Enabled = v end })
    MetalTab:AddToggle("MetalName", { Text = "Name", Default = false, Callback = function(v) resourceSettings.Metal.Name = v end }):AddColorPicker("MetalNameColor", { Default = Color3.new(0.6, 0.6, 0.6), Callback = function(v) resourceSettings.Metal.NameColor = v end })
    MetalTab:AddToggle("MetalNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) resourceSettings.Metal.NameOutline = v end }):AddColorPicker("MetalNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) resourceSettings.Metal.NameOutlineColor = v end })
end

do
    local BloxyTab = ResourceTabBox:AddTab("Bloxy")
    BloxyTab:AddToggle("BloxyEnabled", { Text = "Enabled", Default = false, Callback = function(v) resourceSettings.Bloxy.Enabled = v end })
    BloxyTab:AddToggle("BloxyName", { Text = "Name", Default = false, Callback = function(v) resourceSettings.Bloxy.Name = v end }):AddColorPicker("BloxyNameColor", { Default = Color3.new(1, 0, 0), Callback = function(v) resourceSettings.Bloxy.NameColor = v end })
    BloxyTab:AddToggle("BloxyNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) resourceSettings.Bloxy.NameOutline = v end }):AddColorPicker("BloxyNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) resourceSettings.Bloxy.NameOutlineColor = v end })
end

do
    local CactusTab = MaterialTabBox:AddTab("Cactus")
    CactusTab:AddToggle("CactusEnabled", { Text = "Enabled", Default = false, Callback = function(v) materialSettings.Cactus.Enabled = v end })
    CactusTab:AddToggle("CactusName", { Text = "Name", Default = false, Callback = function(v) materialSettings.Cactus.Name = v end }):AddColorPicker("CactusNameColor", { Default = Color3.new(0, 0.8, 0), Callback = function(v) materialSettings.Cactus.NameColor = v end })
    CactusTab:AddToggle("CactusNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) materialSettings.Cactus.NameOutline = v end }):AddColorPicker("CactusNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) materialSettings.Cactus.NameOutlineColor = v end })
end

do
    local TreeTab = MaterialTabBox:AddTab("Tree")
    TreeTab:AddToggle("TreeEnabled", { Text = "Enabled", Default = false, Callback = function(v) materialSettings.Tree.Enabled = v end })
    TreeTab:AddToggle("TreeName", { Text = "Name", Default = false, Callback = function(v) materialSettings.Tree.Name = v end }):AddColorPicker("TreeNameColor", { Default = Color3.new(0, 1, 0), Callback = function(v) materialSettings.Tree.NameColor = v end })
    TreeTab:AddToggle("TreeNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) materialSettings.Tree.NameOutline = v end }):AddColorPicker("TreeNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) materialSettings.Tree.NameOutlineColor = v end })
end

do
    local StoneTab = MaterialTabBox:AddTab("Stone")
    StoneTab:AddToggle("StoneEnabled", { Text = "Enabled", Default = false, Callback = function(v) materialSettings.Stone.Enabled = v end })
    StoneTab:AddToggle("StoneName", { Text = "Name", Default = false, Callback = function(v) materialSettings.Stone.Name = v end }):AddColorPicker("StoneNameColor", { Default = Color3.new(0.5, 0.5, 0.5), Callback = function(v) materialSettings.Stone.NameColor = v end })
    StoneTab:AddToggle("StoneNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) materialSettings.Stone.NameOutline = v end }):AddColorPicker("StoneNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) materialSettings.Stone.NameOutlineColor = v end })
end

do
    local NitrateTab = MaterialTabBox:AddTab("Nitrate")
    NitrateTab:AddToggle("NitrateEnabled", { Text = "Enabled", Default = false, Callback = function(v) materialSettings.Nitrate.Enabled = v end })
    NitrateTab:AddToggle("NitrateName", { Text = "Name", Default = false, Callback = function(v) materialSettings.Nitrate.Name = v end }):AddColorPicker("NitrateNameColor", { Default = Color3.new(1, 1, 1), Callback = function(v) materialSettings.Nitrate.NameColor = v end })
    NitrateTab:AddToggle("NitrateNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) materialSettings.Nitrate.NameOutline = v end }):AddColorPicker("NitrateNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) materialSettings.Nitrate.NameOutlineColor = v end })
end

do
    local IronTab = MaterialTabBox:AddTab("Iron")
    IronTab:AddToggle("IronEnabled", { Text = "Enabled", Default = false, Callback = function(v) materialSettings.Iron.Enabled = v end })
    IronTab:AddToggle("IronName", { Text = "Name", Default = false, Callback = function(v) materialSettings.Iron.Name = v end }):AddColorPicker("IronNameColor", { Default = Color3.new(0.8, 0.4, 0.2), Callback = function(v) materialSettings.Iron.NameColor = v end })
    IronTab:AddToggle("IronNameOutline", { Text = "Name Outline", Default = false, Callback = function(v) materialSettings.Iron.NameOutline = v end }):AddColorPicker("IronNameOutlineColor", { Default = Color3.new(0,0,0), Callback = function(v) materialSettings.Iron.NameOutlineColor = v end })
end

local timeChangerEnabled = false
local desiredTime = 12

WorldSettingsGroup:AddToggle("TimeChangerToggle", {
    Text = "Time Changer",
    Default = false,
    Callback = function(v) timeChangerEnabled = v end
})

WorldSettingsGroup:AddSlider("TimeChangerSlider", {
    Text = "Time (Hours)",
    Default = 12,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Callback = function(v) desiredTime = v end
})

GlobalESPGroup:AddToggle("GlobalESPToggle", { Text = "Enabled ESP", Default = false, Callback = function(v) globalESPEnabled = v end })
GlobalESPGroup:AddSlider("GlobalESPDistance", { Text = "ESP Distance", Default = 2000, Min = 100, Max = 10000, Rounding = 0, Callback = function(v) globalESPDistance = v end })
GlobalESPGroup:AddToggle("VehicleESPToggle", { Text = "Enabled Vehicle ESP", Default = false, Callback = function(v) vehicleESPEnabled = v end })
GlobalESPGroup:AddSlider("VehicleESPDistance", { Text = "Vehicle ESP Distance", Default = 2000, Min = 100, Max = 10000, Rounding = 0, Callback = function(v) vehicleESPDistance = v end })
GlobalESPGroup:AddToggle("ResourceESPToggle", { Text = "Enabled Resource ESP", Default = false, Callback = function(v) resourceESPEnabled = v end })
GlobalESPGroup:AddSlider("ResourceESPDistance", { Text = "Resource ESP Distance", Default = 2000, Min = 100, Max = 10000, Rounding = 0, Callback = function(v) resourceESPDistance = v end })
GlobalESPGroup:AddToggle("MaterialESPToggle", { Text = "Enabled Material ESP", Default = false, Callback = function(v) materialESPEnabled = v end })
GlobalESPGroup:AddSlider("MaterialESPDistance", { Text = "Material ESP Distance", Default = 2000, Min = 100, Max = 10000, Rounding = 0, Callback = function(v) materialESPDistance = v end })

local redictionSnapline = Drawing.new("Line") 
redictionSnapline.Thickness = 1 
redictionSnapline.Color = Color3.new(1, 1, 1) 
redictionSnapline.Visible = false 
cheat.drawings[redictionSnapline] = redictionSnapline

-- ==================== FOV CIRCLE (два объекта) ====================
-- ==================== FOV CIRCLES (Outline + Fill) ====================
local fovOutline = Drawing.new("Circle")
fovOutline.Thickness = 1.5
fovOutline.NumSides = 64
fovOutline.Filled = false
fovOutline.Visible = false
fovOutline.Transparency = 0
fovOutline.Color = Color3.new(1, 1, 1)
cheat.drawings[fovOutline] = fovOutline

local fovFill = Drawing.new("Circle")
fovFill.Thickness = 0
fovFill.NumSides = 64
fovFill.Filled = true
fovFill.Visible = false
fovFill.Transparency = 0.7
fovFill.Color = Color3.new(1, 0, 0)
cheat.drawings[fovFill] = fovFill

-- ==================== FOV UI ====================
CombatSettingsGroup:AddToggle("FOVToggle", { 
    Text = "Show FOV Circle", 
    Default = false, 
    Callback = function(v) 
        fovOutline.Visible = v
        fovFill.Visible = v and fovFill.Filled
    end 
}):AddColorPicker("FOVOutlineColor", { 
    Default = Color3.new(1, 1, 1), 
    Callback = function(v) fovOutline.Color = v end 
})

CombatSettingsGroup:AddSlider("FOVOutlineTransparency", { 
    Text = "Outline Transparency", 
    Default = 1, 
    Min = 0, 
    Max = 1, 
    Rounding = 2, 
    Callback = function(v) 
        fovOutline.Transparency = 1 - v
    end 
})

CombatSettingsGroup:AddToggle("FOVFillToggle", { 
    Text = "FOV Fill", 
    Default = false, 
    Callback = function(v) 
        fovFill.Filled = v
        fovFill.Visible = v and fovOutline.Visible
    end 
}):AddColorPicker("FOVFillColor", { 
    Default = Color3.new(1, 0, 0), 
    Callback = function(v) fovFill.Color = v end 
})

CombatSettingsGroup:AddSlider("FOVFillTransparency", { 
    Text = "Fill Transparency", 
    Default = 0.3, 
    Min = 0, 
    Max = 1, 
    Rounding = 2, 
    Callback = function(v) 
        fovFill.Transparency = 1 - v 
    end 
})

CombatSettingsGroup:AddToggle("SnaplineToggle", { Text = "Show Snapline", Default = false, Callback = function(v) 
    redictionSnapline.Visible = v 
end }):AddColorPicker("SnaplineColor", { Default = Color3.new(1, 1, 1), Callback = function(v) 
    redictionSnapline.Color = v 
end })

CombatFeedbackGroup:AddToggle("HitMarkerToggle", { Text = "Hit Marker", Default = false, Callback = function(v) hitMarkerEnabled = v end }):AddColorPicker("HitMarkerColor", { Default = Color3.fromRGB(158, 0, 153), Callback = function(v) hitMarkerColor = v end })

local hitSoundDropdownValues = {"Hit Sound 1"}
CombatFeedbackGroup:AddToggle("HitSoundToggle", { Text = "Hit Sound", Default = false, Callback = function(v) hitSoundEnabled = v end })
CombatFeedbackGroup:AddDropdown("HitSoundDropdown", { Text = "Hit Sound", Default = "Hit Sound 1", Values = hitSoundDropdownValues, Callback = function(v) selectedHitSound = v end })
CombatFeedbackGroup:AddSlider("HitSoundVolume", { Text = "Hit Sound Volume", Default = 1, Min = 0, Max = 2, Rounding = 2, Callback = function(v) hitSoundVolume = v end })

CombatFeedbackGroup:AddToggle("HitIndicatorToggle", { Text = "Hit Indicator", Default = false, Callback = function(v) hitIndicatorEnabled = v end })
CombatFeedbackGroup:AddToggle("TrailToggle", { Text = "Bullet Tracer", Default = false, Callback = function(v) trailEnabled = v end })

WeaponHooksGroup:AddToggle("JumpShootToggle", { Text = "Jump Shoot", Default = false, Callback = function(v) 
    jumpShootEnabled = v 
    if not v and jumpShootPart then
        jumpShootPart:Destroy()
        jumpShootPart = nil
    end
end })

PlayerSettingsGroup:AddToggle("SpeedHackToggle", { Text = "Speed Hack", Default = false, Callback = function(v) speedHackEnabled = v end })

CameraSettingsGroup:AddToggle("FOVChangerToggle", { Text = "FOV Changer", Default = false, Callback = function(v) fovChangerEnabled = v end })
CameraSettingsGroup:AddSlider("CameraFOVSlider", { Text = "Camera FOV", Default = 120, Min = 75, Max = 120, Rounding = 0, Callback = function(v) desiredFOV = v end })

CameraSettingsGroup:AddToggle("FreeCameraToggle", { Text = "Free Camera Mode", Default = false, Callback = function(v) freecamMode = v end })

local keyOptions = {"J","F","V","X","Z","C","B","K","L","H"}
CameraSettingsGroup:AddDropdown("FreeCameraKeyDropdown", {
    Text = "Free Camera Key",
    Values = keyOptions,
    Default = "J",
    Multi = false,
    Callback = function(Value)
        if Value == "J" then freecamKey = Enum.KeyCode.J
        elseif Value == "F" then freecamKey = Enum.KeyCode.F
        elseif Value == "V" then freecamKey = Enum.KeyCode.V
        elseif Value == "X" then freecamKey = Enum.KeyCode.X
        elseif Value == "Z" then freecamKey = Enum.KeyCode.Z
        elseif Value == "C" then freecamKey = Enum.KeyCode.C
        elseif Value == "B" then freecamKey = Enum.KeyCode.B
        elseif Value == "K" then freecamKey = Enum.KeyCode.K
        elseif Value == "L" then freecamKey = Enum.KeyCode.L
        elseif Value == "H" then freecamKey = Enum.KeyCode.H
        end
    end
})

CameraSettingsGroup:AddSlider("FreeCameraSpeed", { Text = "Free Camera Speed", Default = 160, Min = 50, Max = 500, Rounding = 0, Callback = function(v) freecamSpeed = v end })

VehicleSettingsGroup:AddToggle("VehicleFlyToggle", { Text = "Vehicle Fly", Default = false, Callback = function(v) vehicleFlyEnabled = v end })
VehicleSettingsGroup:AddLabel("B - Up | N - Down")
VehicleSettingsGroup:AddLabel("← → ↑ ↓ - Move")
VehicleSettingsGroup:AddLabel("Z - Left | X - Right rotate")
VehicleSettingsGroup:AddSlider("VehicleHorizontalSpeed", { Text = "Horizontal Speed", Default = 15, Min = 10, Max = 500, Rounding = 0, Callback = function(v) vehicleHorizontalSpeed = v end })
VehicleSettingsGroup:AddSlider("VehicleVerticalSpeed", { Text = "Vertical Speed", Default = 15, Min = 10, Max = 50, Rounding = 0, Callback = function(v) vehicleVerticalSpeed = v end })
VehicleSettingsGroup:AddSlider("VehicleTurnSpeed", { Text = "Rotate Speed", Default = 180, Min = 90, Max = 360, Rounding = 0, Callback = function(v) vehicleTurnSpeed = v end })
VehicleSettingsGroup:AddToggle("VehicleNoclipToggle", { Text = "Vehicle Noclip", Default = false, Callback = function(v) vehicleNoclipEnabled = v end })
VehicleSettingsGroup:AddToggle("VehicleMomentumToggle", { Text = "Smooth Stop", Default = true, Callback = function(v) vehicleMomentumEnabled = v end })
VehicleSettingsGroup:AddSlider("VehicleMomentumDecay", { Text = "Smooth stop Speed", Default = 5, Min = 1, Max = 20, Rounding = 1, Callback = function(v) vehicleMomentumDecay = v end })
VehicleSettingsGroup:AddToggle("VehicleReliefToggle", { Text = "Relief Movement(Bag)", Default = false, Callback = function(v) vehicleReliefEnabled = v end })
VehicleSettingsGroup:AddSlider("ReliefHeightOffset", { Text = "Height Offset", Default = 3, Min = 0, Max = 10, Rounding = 1, Callback = function(v) reliefHeightOffset = v end })
VehicleSettingsGroup:AddToggle("BoatSpeedToggle", { Text = "Boat Speed(Not work)", Default = false, Callback = function(v) boatSpeedEnabled = v end })
VehicleSettingsGroup:AddSlider("BoatHorizontalSpeed", { Text = "Boat Speed", Default = 15, Min = 10, Max = 50, Rounding = 0, Callback = function(v) boatHorizontalSpeed = v end })

VehicleSettingsGroup:AddToggle("VehicleKillToggle", { Text = "Player Killed by Vehicle (V)", Default = false, Callback = function(v) 
    vehicleKillEnabled = v 
    if not v then vehicleKillActive = false; vehicleKillTarget = nil end 
end })

-- Keybind V
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.V and vehicleKillEnabled then
        vehicleKillActive = not vehicleKillActive
        if vehicleKillActive and redictionTargetPart then
            vehicleKillTarget = redictionTargetPart
            vehicleKillPath = {}
        else
            vehicleKillTarget = nil
            vehicleKillPath = {}
        end
    end
end)

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Trident")
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("Trident")
SaveManager:BuildConfigSection(Tabs.Settings)

local UPDATE_RATE_PLAYERS = 2
local UPDATE_RATE_OTHERS = 4
local FOV_UPDATE_RATE = 3

local frameCountPlayers = 0
local frameCountOthers = 0

local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local freecam = {
    Enabled = false,
    Speed = 160,
    Sensitivity = 0.35,
    Connection = nil,
    Position = Vector3.new(),
    RotationX = 0,
    RotationY = 0,
    Velocity = Vector3.new()
}
local bottomPart = nil
local bottomOriginalCFrame = nil
local bottomOriginalVelocity = nil
local bottomOriginalAnchored = nil

local function getBottomPart()
    local const = workspace:FindFirstChild("Const")
    if not const then return nil end
    local ignore = const:FindFirstChild("Ignore")
    if not ignore then return nil end
    local localCharacter = ignore:FindFirstChild("LocalCharacter")
    if not localCharacter then return nil end
    local bottom = localCharacter:FindFirstChild("Bottom")
    if bottom and bottom:IsA("BasePart") then
        return bottom
    end
    return nil
end

local function freezeBottom()
    bottomPart = getBottomPart()
    if not bottomPart then
        return false
    end
    bottomOriginalCFrame = bottomPart.CFrame
    bottomOriginalVelocity = bottomPart.Velocity
    bottomOriginalAnchored = bottomPart.Anchored
    bottomPart.Velocity = Vector3.new(0, 0, 0)
    bottomPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    bottomPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    bottomPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
    bottomPart.Anchored = true
    return true
end

local function unfreezeBottom()
    if not bottomPart then
        bottomPart = getBottomPart()
        if not bottomPart then return end
    end
    if bottomPart and bottomPart.Parent then
        bottomPart.CustomPhysicalProperties = PhysicalProperties.new(1, 1, 1, 1, 1)
        bottomPart.Anchored = bottomOriginalAnchored or false
        if bottomOriginalCFrame then
            bottomPart.CFrame = bottomOriginalCFrame
        end
        if bottomOriginalVelocity then
            bottomPart.Velocity = bottomOriginalVelocity
            bottomPart.AssemblyLinearVelocity = bottomOriginalVelocity
        end
        bottomPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    bottomPart = nil
    bottomOriginalCFrame = nil
    bottomOriginalVelocity = nil
    bottomOriginalAnchored = nil
end

local function maintainFrozenState()
    if bottomPart and bottomPart.Parent then
        bottomPart.Velocity = Vector3.new(0, 0, 0)
        bottomPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        bottomPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        if not bottomPart.Anchored then
            bottomPart.Anchored = true
        end
    else
        bottomPart = getBottomPart()
        if bottomPart then
            freezeBottom()
        end
    end
end

local function forceScriptable()
    Camera.CameraType = Enum.CameraType.Scriptable
end

local function toggleFreecam()
    freecam.Enabled = not freecam.Enabled
    if freecam.Enabled then
        local success = freezeBottom()
        local cf = Camera.CFrame
        freecam.Position = cf.Position
        local rx, ry, _ = cf:ToOrientation()
        freecam.RotationX = math.deg(rx)
        freecam.RotationY = math.deg(ry)
        forceScriptable()
        freecam.Connection = RunService.RenderStepped:Connect(function(delta)
            if not freecam.Enabled then return end
            if Camera.CameraType ~= Enum.CameraType.Scriptable then
                forceScriptable()
            end
            maintainFrozenState()
            local mouseDelta = UIS:GetMouseDelta()
            freecam.RotationY = freecam.RotationY - mouseDelta.X * freecam.Sensitivity
            freecam.RotationX = math.clamp(freecam.RotationX - mouseDelta.Y * freecam.Sensitivity, -89, 89)
            local lookCFrame = CFrame.fromEulerAnglesYXZ(
                math.rad(freecam.RotationX),
                math.rad(freecam.RotationY),
                0
            )
            local moveDir = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += lookCFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= lookCFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= lookCFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += lookCFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end
            freecam.Velocity = freecam.Velocity:Lerp(moveDir * freecam.Speed, 0.22)
            freecam.Position = freecam.Position + freecam.Velocity * delta
            Camera.CFrame = CFrame.new(freecam.Position) * lookCFrame
        end)
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        if freecam.Connection then
            freecam.Connection:Disconnect()
            freecam.Connection = nil
        end
        unfreezeBottom()
        Camera.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        freecam.Velocity = Vector3.new()
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == freecamKey and freecamMode then
        toggleFreecam()
    end
end)

local fovEnforceConnection = RunService.RenderStepped:Connect(function()
    if fovChangerEnabled then Camera.FieldOfView = desiredFOV
    elseif Camera.FieldOfView ~= 75 then Camera.FieldOfView = 75 end
end)

local function createHitImage(position)
    if not hitMarkerEnabled then return end
    local distance = (Camera.CFrame.Position - position).Magnitude
    local sizeMultiplier = math.clamp(distance / 40, 0.8, 3.5) / 2
    local part = Instance.new("Part")
    part.Name = "HitImagePart"
    part.Size = Vector3.new(1, 1, 1)
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Position = position + Vector3.new(0, 3, 0)
    part.Parent = workspace
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(6 * sizeMultiplier, 0, 6 * sizeMultiplier, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = part
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = "rbxassetid://113750946560821"
    imageLabel.ImageColor3 = hitMarkerColor
    imageLabel.Parent = billboard
    task.delay(2, function()
        if part and part.Parent then
            part:Destroy()
        end
    end)
end

task.spawn(function()
    local const = workspace:FindFirstChild("Const")
    if not const then return end
    local ignore = const:FindFirstChild("Ignore")
    if not ignore then return end
    ignore.ChildRemoved:Connect(function(obj)
        if obj.Name ~= "Arrow" and obj.Name ~= "Bullet" and obj.Name ~= "BlueBullet" then
            return
        end
        local arrowPos = obj.Position
        task.wait(0.05)
        local sound = workspace:FindFirstChild("PlayerHitHeadshot", true) or workspace:FindFirstChild("PlayerHit2", true)
        if sound and sound:IsA("Sound") then
            createHitImage(arrowPos)
        end
    end)
end)

local hitSoundMySound = nil
local hitSoundLastTarget = nil

local function hitSoundGetTargetSound()
	local sound = workspace:FindFirstChild("PlayerHitHeadshot")
	if sound and sound:IsA("Sound") then
		return sound
	end
	return nil
end

local function hitSoundCreateCloneFromTarget(target)
	if not target then return nil end
	local clone = Instance.new("Sound")
	local properties = {
		"Volume",
		"Pitch",
		"PlaybackSpeed",
		"Looped",
		"RollOffMode",
		"EmitterSize",
		"MaxDistance",
		"MinDistance",
		"PlayOnRemove",
		"TimePosition",
		"PlaybackRegionsEnabled",
		"PlaybackRegion",
		"PlaybackLoudness",
		"PlayInBackground",
		"RespectFilteringEnabled"
	}
	for _, prop in ipairs(properties) do
		pcall(function()
			clone[prop] = target[prop]
		end)
	end
	clone.SoundId = "rbxassetid://7130144078"
	clone.Volume = hitSoundVolume
	return clone
end

RunService.Stepped:Connect(function()
    if not hitSoundEnabled then return end
	pcall(function()
		local targetSound = hitSoundGetTargetSound()
		if targetSound then
			if targetSound ~= hitSoundLastTarget then
				if hitSoundMySound then
					hitSoundMySound:Destroy()
				end
				hitSoundMySound = hitSoundCreateCloneFromTarget(targetSound)
				if hitSoundMySound then
					hitSoundMySound.Parent = workspace
				end
				hitSoundLastTarget = targetSound
			end
			if targetSound.IsPlaying then
				targetSound:Pause()
				targetSound.Volume = 0
				if hitSoundMySound then
					hitSoundMySound.TimePosition = targetSound.TimePosition
					if not hitSoundMySound.IsPlaying then
						hitSoundMySound:Play()
					end
				end
			end
		end
	end)
end)

local initialSound = hitSoundGetTargetSound()
if initialSound then
	hitSoundMySound = hitSoundCreateCloneFromTarget(initialSound)
	if hitSoundMySound then
		hitSoundMySound.Parent = workspace
	end
end

local KillFeed = { 
    Messages = {}, 
    MaxMessages = 5, 
    Drawings = {}, 
    Backgrounds = {},
    CleanupInterval = nil
}

local ScreenSize = Vector2.new(1920, 1080)
local FeedX = 960
local FeedStartY = 700
local MessageHeight = 30
local MessageWidth = 300

local function CreateBackground(yOffset)
    local bg = Drawing.new("Square")
    bg.Position = Vector2.new(FeedX - MessageWidth / 2, FeedStartY - (yOffset * MessageHeight) - 4)
    bg.Size = Vector2.new(MessageWidth, MessageHeight - 2)
    bg.Color = Color3.fromRGB(0, 0, 0)
    bg.Transparency = 0.6
    bg.Filled = true
    bg.Visible = true
    bg.ZIndex = 0
    return bg
end

local function CreateBorder(yOffset)
    local border = Drawing.new("Square")
    border.Position = Vector2.new(FeedX - MessageWidth / 2, FeedStartY - (yOffset * MessageHeight) - 4)
    border.Size = Vector2.new(MessageWidth, MessageHeight - 2)
    border.Color = Color3.fromRGB(100, 100, 100)
    border.Thickness = 1
    border.Filled = false
    border.Visible = true
    border.ZIndex = 1
    return border
end

local function CreateKillFeedMessage(text, yOffset, isDead)
    local msg = Drawing.new("Text")
    msg.Text = text
    msg.Size = 18
    msg.Font = 2
    msg.Center = true
    msg.Outline = true
    msg.OutlineColor = Color3.fromRGB(0, 0, 0)
    msg.Color = isDead and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(255, 255, 255)
    msg.Position = Vector2.new(FeedX, FeedStartY - (yOffset * MessageHeight))
    msg.Visible = true
    msg.ZIndex = 2
    return msg
end

local function ClearMessage(msgData)
    if msgData.drawing then
        msgData.drawing.Visible = false
        msgData.drawing:Remove()
    end
    if msgData.background then
        msgData.background.Visible = false
        msgData.background:Remove()
    end
    if msgData.border then
        msgData.border.Visible = false
        msgData.border:Remove()
    end
end

local function UpdateKillFeedPositions()
    for i, msgData in ipairs(KillFeed.Messages) do
        local yOffset = i - 1
        if msgData.drawing then
            msgData.drawing.Position = Vector2.new(FeedX, FeedStartY - (yOffset * MessageHeight))
        end
        if msgData.background then
            msgData.background.Position = Vector2.new(FeedX - MessageWidth / 2, FeedStartY - (yOffset * MessageHeight) - 4)
        end
        if msgData.border then
            msgData.border.Position = Vector2.new(FeedX - MessageWidth / 2, FeedStartY - (yOffset * MessageHeight) - 4)
        end
    end
end

-- Функция периодической очистки
local function startKillFeedCleanup()
    if KillFeed.CleanupInterval then return end
    KillFeed.CleanupInterval = task.spawn(function()
        while true do
            task.wait(60) -- Каждую минуту
            for i = #KillFeed.Messages, 1, -1 do
                local msgData = KillFeed.Messages[i]
                if msgData and msgData.time and (tick() - msgData.time) > 10 then
                    ClearMessage(msgData)
                    table.remove(KillFeed.Messages, i)
                end
            end
            UpdateKillFeedPositions()
        end
    end)
end

-- Измените AddKillFeedMessage
local function AddKillFeedMessage(text, isDead)
    -- Ограничиваем общее количество сообщений жестко
    if #KillFeed.Messages >= KillFeed.MaxMessages then
        local oldest = table.remove(KillFeed.Messages, #KillFeed.Messages)
        if oldest then ClearMessage(oldest) end
    end
    
    local newYOffset = 0
    for i, msgData in ipairs(KillFeed.Messages) do
        msgData.yOffset = i - 1
    end
    
    local background = CreateBackground(newYOffset)
    local border = CreateBorder(newYOffset)
    local drawing = CreateKillFeedMessage(text, newYOffset, isDead)
    
    local newMessage = {
        text = text,
        drawing = drawing,
        background = background,
        border = border,
        time = tick(),
        isDead = isDead
    }
    
    table.insert(KillFeed.Messages, 1, newMessage)
    
    -- Жесткое ограничение по времени
    task.delay(5, function()
        for i, msgData in ipairs(KillFeed.Messages) do
            if msgData.drawing == drawing then
                ClearMessage(msgData)
                table.remove(KillFeed.Messages, i)
                UpdateKillFeedPositions()
                break
            end
        end
    end)
    
    -- Запускаем очистку
    startKillFeedCleanup()
end

local function ParseDamageMessage(message)
    local pattern = "^(%S+)%s+%->(%S+)%s+(%d+)s%s+(%S+)%s+(%d+%.?%d*)%->(%d+%.?%d*)hp$"
    local myName, targetName, time, weapon, oldHp, newHp = string.match(message, pattern)
    if myName and targetName and weapon and oldHp and newHp then
        newHp = tonumber(newHp)
        if newHp == 0 then
            AddKillFeedMessage(targetName .. " dead " .. weapon, true)
        else
            AddKillFeedMessage(targetName .. " hitted " .. weapon .. " hp left " .. newHp, false)
        end
        return true
    end
    return false
end

game:GetService("LogService").MessageOut:Connect(function(message, messageType)
    if hitIndicatorEnabled then
        ParseDamageMessage(message)
    end
end)

local function isPlayer(model)
    local cached = typeCache[model]
    if cached ~= nil then return cached end
    local torso = _FindFirstChild(model, "Torso")
    if not torso then typeCache[model] = false return false end
    local result = _FindFirstChild(torso, "LeftBooster") and true or false
    typeCache[model] = result
    return result
end

local function isSleeping(model)
    local torso = _FindFirstChild(model, "LowerTorso")
    if not torso then return false end
    local rootRig = _FindFirstChild(torso, "RootRig")
    if rootRig and typeof(rootRig.CurrentAngle) == "number" and rootRig.CurrentAngle ~= 0 then return true end
    return false
end

local function getEntityType(model)
    if isSleeping(model) then return "Sleeper" end
    if isPlayer(model) then return "Enemy" end
    return "Bot"
end

local function detectWeapon(model)
    local handModel = _FindFirstChild(model, "HandModel")
    if not handModel then weaponCache[model] = "None" return end
    local bestMatch, bestCount = "None", 0
    for weaponName, parts in pairs(weapons) do
        local count = 0
        for _, partName in ipairs(parts) do
            if handModel:FindFirstChild(partName, true) then count = count + 1 end
        end
        if count > bestCount then bestMatch = weaponName bestCount = count end
    end
    weaponCache[model] = bestCount >= 3 and bestMatch or "None"
end

local function hookWeapon(model)
    if weaponConnections[model] then return end
    weaponConnections[model] = true
    local handModel = _FindFirstChild(model, "HandModel")
    if handModel then
        detectWeapon(model)
        handModel.DescendantAdded:Connect(function() detectWeapon(model) end)
        handModel.DescendantRemoving:Connect(function() detectWeapon(model) end)
    end
end

local function addEntity(model)
    if not model or entities[model] or model == LocalPlayer.Character then return end
    if not _FindFirstChild(model, "HumanoidRootPart") then return end
    entities[model] = true
    hookWeapon(model)
end

local function removeEntity(model)
    if entities[model] then
        entities[model] = nil
        if playerTexts[model] then
            for _, drawing in pairs(playerTexts[model]) do
                safeRemoveDrawing(drawing)
            end
            playerTexts[model] = nil
        end

        weaponCache[model] = nil
        typeCache[model] = nil
        weaponConnections[model] = nil
        boxes[model] = nil
    end
end

local boxes = setmetatable({}, { __mode = "k" })

local function createPlayerDrawings()
    local data = {}
    data.box = cheat.utility.new_drawing("Square", { Visible = false, Filled = false, Thickness = 2, ZIndex = 1 })
    data.nameText = cheat.utility.new_drawing("Text", { Visible = false, Size = 14, Center = true, Font = 2, Outline = true, ZIndex = 2 })
    data.weaponText = cheat.utility.new_drawing("Text", { Visible = false, Size = 13, Center = true, Font = 2, Outline = true, ZIndex = 2 })
    data.distanceText = cheat.utility.new_drawing("Text", { Visible = false, Size = 13, Center = true, Font = 2, Outline = false, ZIndex = 2 })
    return data
end

local function updatePlayerESP()
    if not globalESPEnabled then
        for _, data in pairs(playerTexts) do
            for _, drawing in pairs(data) do
                if drawing then drawing.Visible = false end
            end
        end
        return
    end

    local camPos = Camera.CFrame.Position
    local maxDist = globalESPDistance
    local currentFOV = Camera.FieldOfView
    local fovTan = math.tan(math.rad(currentFOV * 0.5))

    -- Очистка несуществующих объектов
    for model, data in pairs(playerTexts) do
        if not model or not model.Parent or not model:FindFirstChild("HumanoidRootPart") then
            for _, drawing in pairs(data) do safeRemoveDrawing(drawing) end
            playerTexts[model] = nil
        end
    end

    for model in pairs(entities) do
        if not model or not model.Parent then
            removeEntity(model)
            continue
        end

        local hrp = model:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local distance = (camPos - hrp.Position).Magnitude
        if distance > maxDist then
            if playerTexts[model] then
                for _, drawing in pairs(playerTexts[model]) do
                    drawing.Visible = false
                end
            end
            continue
        end

        local entityType = getEntityType(model)
        local settings = espSettings[entityType]
        if not settings or not settings.Enabled then
            if playerTexts[model] then
                for _, drawing in pairs(playerTexts[model]) do drawing.Visible = false end
            end
            continue
        end

        if not playerTexts[model] then
            playerTexts[model] = createPlayerDrawings()
        end

        local data = playerTexts[model]
        local pos, onscreen = _WorldToViewportPoint(Camera, hrp.Position)

        if not onscreen then
            for _, drawing in pairs(data) do drawing.Visible = false end
            continue
        end

        -- ==================== МАСШТАБИРОВАНИЕ ====================
        -- ==================== МАСШТАБИРОВАНИЕ ====================
        -- Чем дальше игрок, тем меньше ESP, но не меньше указанного размера
        local referenceDistance = 30 -- дистанция, на которой ESP будет в полный размер
        local minWidth = 8 -- минимальная ширина бокса (дальше не уменьшается)
        local minHeight = 12 -- минимальная высота бокса (дальше не уменьшается)
        
        local scaleFactor = referenceDistance / distance
        
        -- Вычисляем размер, но с минимальными границами
        local width = mathfloor(math.max(60 * scaleFactor, minWidth))
        local height = mathfloor(math.max(80 * scaleFactor, minHeight))

        if width < 2 or height < 2 then
            for _, drawing in pairs(data) do drawing.Visible = false end
            continue
        end

        local boxSize = Vector2.new(width, height)

        if settings.Box then
            data.box.Size = boxSize
            data.box.Position = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
            data.box.Color = settings.BoxColor
            data.box.Thickness = settings.BoxOutline and 3 or 2
            data.box.Visible = true
        else
            data.box.Visible = false
        end

        local weapon = weaponCache[model] or "None"
        local playerType = (entityType == "Sleeper" and "SLEEPER") or (entityType == "Enemy" and "ENEMY") or "BOT"

        if settings.Name then
            data.nameText.Text = playerType
            data.nameText.Position = Vector2.new(pos.X, pos.Y - boxSize.Y/2 - 18)
            data.nameText.Color = settings.NameColor
            data.nameText.Outline = settings.NameOutline
            data.nameText.OutlineColor = settings.NameOutlineColor
            data.nameText.Visible = true
        else
            data.nameText.Visible = false
        end

        if settings.Weapon then
            data.weaponText.Text = weapon
            data.weaponText.Position = Vector2.new(pos.X, pos.Y + boxSize.Y/2 + 6)
            data.weaponText.Color = settings.WeaponColor
            data.weaponText.Outline = settings.WeaponOutline
            data.weaponText.OutlineColor = settings.WeaponOutlineColor
            data.weaponText.Visible = true
        else
            data.weaponText.Visible = false
        end

        if settings.Distance then
            local yOffset = pos.Y + boxSize.Y/2 + (settings.Weapon and 26 or 6)
            data.distanceText.Text = mathfloor(distance) .. "m"
            data.distanceText.Position = Vector2.new(pos.X, yOffset)
            data.distanceText.Color = settings.DistanceColor
            data.distanceText.Outline = settings.DistanceOutline
            data.distanceText.OutlineColor = settings.DistanceOutlineColor
            data.distanceText.Visible = true
        else
            data.distanceText.Visible = false
        end
    end
end

local function updateRedictionTargets()
    local mousePos = UserInputService:GetMouseLocation()
    local closestPart, closestPos, closestDist = nil, nil, redictionFOVSize
    for model in pairs(entities) do
        if model and model.Parent then
            local sleeping = isSleeping(model)
            local bot = not isPlayer(model)
            if not (redictionIgnoreSleeper and sleeping) and not (redictionIgnoreBot and bot) then
                local part = _FindFirstChild(model, "Head")
                if part then
                    local distance = (Camera.CFrame.Position - part.Position).Magnitude
                    if distance <= redictionWorkingDistance then
                        local pos, onscreen = _WorldToViewportPoint(Camera, part.Position)
                        if onscreen then
                            local dist = (_Vector2new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestPart = part
                                closestPos = _Vector2new(pos.X, pos.Y)
                            end
                        end
                    end
                end
            end
        else
            removeEntity(model)
        end
    end
    redictionTargetPart = closestPart
    redictionTargetPos = closestPos
end

local bulletConnections = setmetatable({}, { __mode = "k" })

local function on_bullet(bullet)
    if not redictionEnabled or not _IsA(bullet, "BasePart") then return end
    
    -- Очищаем старые коннекшены для этой пули
    if bulletConnections[bullet] then
        for _, conn in pairs(bulletConnections[bullet]) do
            if conn then conn:Disconnect() end
        end
        bulletConnections[bullet] = nil
    end
    
    local connections = {}
    local confirmed = false
    
    connections.cfConn = bullet:GetPropertyChangedSignal("CFrame"):Connect(function()
        if not bullet.Parent then 
            for _, conn in pairs(connections) do pcall(function() conn:Disconnect() end) end
            return 
        end
        
        if not confirmed and (Camera.CFrame.Position - bullet.Position).Magnitude < 5 then 
            confirmed = true 
        end
        
        local t = redictionCachedTarget or redictionTargetPart
        if confirmed and t and t.Parent and hitScannerEnabled then
            local sleeping = isSleeping(t.Parent)
            local bot = not isPlayer(t.Parent)
            if redictionIgnoreSleeper and sleeping then return end
            if redictionIgnoreBot and bot then return end
            redictionCachedTarget = t
            local hrp = _FindFirstChild(t.Parent, "HumanoidRootPart") or t
            if hrp then pcall(function() hrp.CFrame = _CFramenew(bullet.Position.X, hrp.Position.Y, bullet.Position.Z) end) end
        end
    end)
    
    connections.ancestryConn = bullet.AncestryChanged:Connect(function(_, parent)
        if not parent then 
            redictionCachedTarget = nil 
            for _, conn in pairs(connections) do pcall(function() conn:Disconnect() end) end
            bulletConnections[bullet] = nil
        end
    end)
    
    bulletConnections[bullet] = connections
end

if workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore") then
    workspace.Const.Ignore.ChildAdded:Connect(function(v)
        if _IsA(v, "BasePart") and (v.Name == "Arrow" or v.Name == "Bullet" or v.Name == "BulletBlue") then
            on_bullet(v)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    redictionCachedTarget = nil
    redictionTargetPart = nil
    redictionTargetPos = nil
end)


local function clearType(tbl)
    for _, text in pairs(tbl) do if text then text.Visible = false end end
end

local function registerVehicle(model, vtype)
    local body = (vtype == "Helicopter" and model:FindFirstChild("BodyDummy")) or (vtype == "Boat" and model:FindFirstChild("Hull")) or model:FindFirstChild("Body")
    if body and body:IsA("BasePart") then vehicleCache[vtype][body] = true end
end

local function registerLoot(model, ltype)
    local part = (ltype == "Box" and model:FindFirstChild("Body")) or (ltype == "MiniBox" and model:FindFirstChild("box")) or (ltype == "Metal" and model:FindFirstChild("default")) or (ltype == "Bloxy" and model:FindFirstChild("Sign"))
    if part and part:IsA("BasePart") then lootCache[ltype][part] = true end
end

local function registerMaterial(model, mtype)
    if mtype == "Cactus" then
        local part = model:FindFirstChild("Part")
        if part and part:IsA("BasePart") then materialCache[mtype][part] = true end
    elseif mtype == "Tree" then
        local part = model:FindFirstChild("default")
        if part and part:IsA("BasePart") then materialCache[mtype][part] = true end
    elseif mtype == "Stone" or mtype == "Nitrate" or mtype == "Iron" then
        local part = model:FindFirstChild("Part")
        if part and part:IsA("BasePart") then materialCache[mtype][part] = true end
    end
end

-- New Corpse ESP
local function compareSizes(s1, s2)
    local tolerance = 0.01
    return math.abs(s1.X - s2.X) <= tolerance and math.abs(s1.Y - s2.Y) <= tolerance and math.abs(s1.Z - s2.Z) <= tolerance
end
-- ==================== CORPSE ESP ====================

-- ==================== IMPROVED CORPSE ESP ====================
local corpseTexts = {}

local function createCorpseText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Color = Color3.new(1, 0.4, 0.4)
    text.Text = "CORPSE"
    text.Font = 2
    return text
end

local function updateCorpseESP()
    if not espSettings.Enemy.Corpse then
        for body, text in pairs(corpseTexts) do
            safeRemoveDrawing(text)
            corpseTexts[body] = nil
        end
        return
    end

    -- Очистка мертвых
    for body, text in pairs(corpseTexts) do
        if not body or not body.Parent or not body.Parent.Parent then
            safeRemoveDrawing(text)
            corpseTexts[body] = nil
        end
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "Model" then
            local body = obj:FindFirstChild("Part")
            if body and body:IsA("BasePart") then
                local size = body.Size
                if math.abs(size.X - 0.19) <= 0.05 and math.abs(size.Y - 0.39) <= 0.05 and math.abs(size.Z - 0.19) <= 0.05 then
                    
                    if not corpseTexts[body] then
                        corpseTexts[body] = createCorpseText()
                    end

                    local text = corpseTexts[body]
                    local pos, onScreen = Camera:WorldToViewportPoint(body.Position + Vector3.new(0, 1.5, 0))

                    if onScreen then
                        text.Position = Vector2.new(pos.X, pos.Y)
                        text.Visible = true
                    else
                        text.Visible = false
                    end
                end
            end
        end
    end
end

-- New Helicopter ESP (text only, no size check)
local heliTexts = {}
local function createHeliText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Color = Color3.new(1, 0, 1)
    text.Text = "Helicopter"
    return text
end
local function updateHelicopterESP()
    if not vehicleSettings.Helicopter.Enabled then
        for _, t in pairs(heliTexts) do if t then t.Visible = false end end
        return
    end
    for obj, text in pairs(heliTexts) do
        if not obj or not obj.Parent then
            text:Remove()
            heliTexts[obj] = nil
        end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "Model" then
            local body = obj:FindFirstChild("BodyDummy")
            if body and body:IsA("BasePart") then
                if not heliTexts[body] then
                    heliTexts[body] = createHeliText()
                end
                local text = heliTexts[body]
                local pos, onScreen = Camera:WorldToViewportPoint(body.Position)
                if onScreen then
                    text.Position = Vector2.new(pos.X, pos.Y)
                    text.Visible = true
                else
                    text.Visible = false
                end
            end
        end
    end
end

local function updateVehicleESP()
    if not vehicleESPEnabled then 
        for _, tbl in pairs(vehicleTexts) do
            for _, text in pairs(tbl) do safeRemoveDrawing(text) end
            table.clear(tbl)
        end
        return 
    end

    local camPos = Camera.CFrame.Position
    local maxDist = vehicleESPDistance

    for vtype, textsTable in pairs(vehicleTexts) do
        for body, text in pairs(textsTable) do
            if not body or not body.Parent then
                safeRemoveDrawing(text)
                textsTable[body] = nil
                if vehicleCache[vtype][body] then vehicleCache[vtype][body] = nil end
            end
        end
    end

    for vtype, settings in pairs(vehicleSettings) do
        if vtype == "Helicopter" then
            updateHelicopterESP()
            continue
        end

        if not settings.Enabled then
            for _, text in pairs(vehicleTexts[vtype]) do safeRemoveDrawing(text) end
            table.clear(vehicleTexts[vtype])
            continue
        end

        for body in pairs(vehicleCache[vtype]) do
            if body and body.Parent then
                local dist = (camPos - body.Position).Magnitude
                if dist <= maxDist then
                    if not vehicleTexts[vtype][body] then
                        local label = (vtype == "Quad") and "QUAD BIKE" or vtype:upper()
                        vehicleTexts[vtype][body] = cheat.utility.new_drawing("Text", {
                            Size = 14, Center = true, Outline = true, Font = 2,
                            Text = label, Color = settings.NameColor
                        })
                    end

                    local text = vehicleTexts[vtype][body]
                    local pos, onscreen = _WorldToViewportPoint(Camera, body.Position)

                    if onscreen then
                        text.Position = _Vector2new(pos.X, pos.Y)
                        text.Color = settings.NameColor
                        text.Outline = settings.NameOutline
                        text.OutlineColor = settings.NameOutlineColor
                        text.Visible = true
                    else
                        text.Visible = false
                    end
                else
                    if vehicleTexts[vtype][body] then
                        vehicleTexts[vtype][body].Visible = false
                    end
                end
            else
                safeRemoveDrawing(vehicleTexts[vtype][body])
                vehicleTexts[vtype][body] = nil
                vehicleCache[vtype][body] = nil
            end
        end
    end
end

local function updateResourceESP()
    if not resourceESPEnabled then 
        for _, tbl in pairs(lootTexts) do
            for _, t in pairs(tbl) do safeRemoveDrawing(t) end
            table.clear(tbl)
        end
        return 
    end

    local camPos = Camera.CFrame.Position
    local maxDist = resourceESPDistance

    for ltype, textsTable in pairs(lootTexts) do
        for part, text in pairs(textsTable) do
            if not part or not part.Parent then
                safeRemoveDrawing(text)
                textsTable[part] = nil
                lootCache[ltype][part] = nil
            end
        end
    end

    for ltype, settings in pairs(resourceSettings) do
        if not settings.Enabled then
            for _, t in pairs(lootTexts[ltype]) do safeRemoveDrawing(t) end
            table.clear(lootTexts[ltype])
            continue
        end

        for part in pairs(lootCache[ltype]) do
            if part and part.Parent then
                local dist = (camPos - part.Position).Magnitude
                if dist <= maxDist then
                    if not lootTexts[ltype][part] then
                        local label = ltype == "MiniBox" and "MINI BOX" or ltype:upper()
                        lootTexts[ltype][part] = cheat.utility.new_drawing("Text", {
                            Size = 14, Center = true, Outline = true, Font = 2, Text = label
                        })
                    end

                    local t = lootTexts[ltype][part]
                    local pos, onscreen = _WorldToViewportPoint(Camera, part.Position)

                    if onscreen then
                        t.Position = _Vector2new(pos.X, pos.Y)
                        t.Color = settings.NameColor
                        t.Outline = settings.NameOutline
                        t.OutlineColor = settings.NameOutlineColor
                        t.Visible = true
                    else
                        t.Visible = false
                    end
                else
                    if lootTexts[ltype][part] then lootTexts[ltype][part].Visible = false end
                end
            else
                safeRemoveDrawing(lootTexts[ltype][part])
                lootTexts[ltype][part] = nil
                lootCache[ltype][part] = nil
            end
        end
    end
end

local function updateMaterialESP()
    if not materialESPEnabled then 
        -- Полная очистка при выключенном ESP
        for _, tbl in pairs(materialTexts) do
            for _, t in pairs(tbl) do
                safeRemoveDrawing(t)
            end
            table.clear(tbl)
        end
        return 
    end

    local camPos = Camera.CFrame.Position
    local maxDist = materialESPDistance

    -- Очистка несуществующих объектов
    for mtype, textsTable in pairs(materialTexts) do
        for part, text in pairs(textsTable) do
            if not part or not part.Parent then
                safeRemoveDrawing(text)
                textsTable[part] = nil
                materialCache[mtype][part] = nil
            end
        end
    end

    -- Основное обновление
    for mtype, settings in pairs(materialSettings) do
        if not settings.Enabled then
            -- Выключаем все тексты этого типа
            for _, t in pairs(materialTexts[mtype]) do
                safeRemoveDrawing(t)
            end
            table.clear(materialTexts[mtype])
            continue
        end

        for part in pairs(materialCache[mtype]) do
            if part and part.Parent then
                local dist = (camPos - part.Position).Magnitude
                
                if dist <= maxDist then
                    -- Создаём текст, если его ещё нет
                    if not materialTexts[mtype][part] then
                        materialTexts[mtype][part] = cheat.utility.new_drawing("Text", {
                            Size = 14,
                            Center = true,
                            Outline = true,
                            Font = 2,
                            Text = mtype:upper(),
                            Color = settings.NameColor
                        })
                    end

                    local t = materialTexts[mtype][part]
                    local pos, onscreen = _WorldToViewportPoint(Camera, part.Position)

                    if onscreen then
                        t.Position = _Vector2new(pos.X, pos.Y)
                        t.Color = settings.NameColor
                        t.Outline = settings.NameOutline
                        t.OutlineColor = settings.NameOutlineColor
                        t.Visible = true
                    else
                        t.Visible = false
                    end
                else
                    -- Слишком далеко — скрываем
                    if materialTexts[mtype][part] then
                        materialTexts[mtype][part].Visible = false
                    end
                end
            else
                -- Объект удалён
                safeRemoveDrawing(materialTexts[mtype][part])
                materialTexts[mtype][part] = nil
                materialCache[mtype][part] = nil
            end
        end
    end
end

local function scanForAll()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "Model" then
            if obj:FindFirstChild("Body") then
                local s = obj.Body.Size
                if math.abs(s.X - 6.80) <= 0.05 then registerVehicle(obj, "Car")
                elseif math.abs(s.X - 7.76) <= 0.05 then registerVehicle(obj, "Quad")
                elseif math.abs(s.X - 2.63) <= 0.05 then registerLoot(obj, "Box")
                elseif math.abs(s.X - 3.59) <= 0.05 then registerLoot(obj, "MiniBox")
                elseif math.abs(s.X - 1.96) <= 0.05 then registerLoot(obj, "Metal")
                elseif math.abs(s.X - 4.83) <= 0.05 or math.abs(s.X - 4.93) <= 0.05 then registerMaterial(obj, "Cactus") end
            elseif obj:FindFirstChild("BodyDummy") then registerVehicle(obj, "Helicopter")
            elseif obj:FindFirstChild("Hull") then registerVehicle(obj, "Boat")
            elseif obj:FindFirstChild("Sign") then registerLoot(obj, "Bloxy")
            elseif obj:FindFirstChild("default") then registerMaterial(obj, "Tree")
            elseif obj:FindFirstChild("Part") then
                local part = obj:FindFirstChild("Part")
                if part and part:IsA("BasePart") then
                    local r = math.round(part.Color.R * 255)
                    local g = math.round(part.Color.G * 255)
                    local b = math.round(part.Color.B * 255)
                    local count = #obj:GetChildren()
                    if r == 72 and g == 72 and b == 72 and count == 1 then registerMaterial(obj, "Stone")
                    elseif r == 248 and g == 248 and b == 248 and count == 2 then registerMaterial(obj, "Nitrate")
                    elseif r == 199 and g == 172 and b == 120 and count == 2 then registerMaterial(obj, "Iron") end
                end
            end
        end
    end
end

local function CreateJumpPart()
    local p = Instance.new("Part")
    p.Name = "!.!"
    p.Size = Vector3.new(4, 0.2, 4)
    p.Anchored = true
    p.Color = Color3.fromRGB(255, 255, 255)
    p.Transparency = 0
    p.Material = Enum.Material.Neon
    p.CanCollide = false
    p.Parent = workspace
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.Parent = p
    return p
end

local holdingMouse = false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingMouse = true
        if jumpShootPart then
            jumpShootPart.CanCollide = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingMouse = false
        if jumpShootPart then
            jumpShootPart.CanCollide = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not jumpShootEnabled then 
        if jumpShootPart then
            jumpShootPart:Destroy()
            jumpShootPart = nil
        end
        return 
    end
    local success, middle = pcall(function()
        return workspace.Const.Ignore.LocalCharacter.Middle.Position
    end)
    if success then
        if not jumpShootPart or not jumpShootPart.Parent then
            jumpShootPart = CreateJumpPart()
        end
        if jumpShootPart then
            jumpShootPart.Position = middle - Vector3.new(0, 3.5, 0)
        end
    end
end)

local Speedhack = { Enabled = true, Speed = 40, Middle = nil }
local speedHackIsMoving = false
local speedHackJumpStartTime = 0
local speedHackScriptActive = true
local speedHackHasAppliedBoost = false
local speedHackBoostedVerticalSpeed = 0
local speedHackIsBhopActive = false

local function GetMiddle()
    pcall(function()
        Speedhack.Middle = workspace.Const.Ignore.LocalCharacter.Middle
    end)
end

GetMiddle()

RunService.RenderStepped:Connect(function(delta)
    if not speedHackEnabled then return end
    if not Speedhack.Middle or not Speedhack.Middle.Parent then
        GetMiddle()
        return
    end
    local middle = Speedhack.Middle
    local shiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    local cPressed = UserInputService:IsKeyDown(Enum.KeyCode.C)
    local isBhop = speedHackEnabled and shiftPressed and cPressed
    if isBhop then
        if not speedHackIsBhopActive then
            speedHackIsBhopActive = true
            speedHackIsMoving = false
        end
        local moveDir = Vector3.new(0, 0, 0)
        local look = Camera.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z).Unit
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Vector3.new(-flatLook.Z, 0, flatLook.X) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir += Vector3.new(flatLook.Z, 0, -flatLook.X) end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            if not speedHackIsMoving then
                speedHackIsMoving = true
                speedHackJumpStartTime = tick()
                speedHackBoostedVerticalSpeed = middle.AssemblyLinearVelocity.Y + 4
                speedHackHasAppliedBoost = false
            end
            local elapsed = tick() - speedHackJumpStartTime
            if elapsed < 0.9 then
                if not speedHackHasAppliedBoost then
                    middle.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * Speedhack.Speed,
                        speedHackBoostedVerticalSpeed,
                        moveDir.Z * Speedhack.Speed
                    )
                    speedHackHasAppliedBoost = true
                else
                    middle.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * Speedhack.Speed,
                        speedHackBoostedVerticalSpeed,
                        moveDir.Z * Speedhack.Speed
                    )
                end
            else
                local currentVel = middle.AssemblyLinearVelocity
                middle.AssemblyLinearVelocity = Vector3.new(
                    currentVel.X * 1,
                    currentVel.Y,
                    currentVel.Z * 1
                )
            end
        else
            speedHackIsMoving = false
            speedHackHasAppliedBoost = false
        end
    else
        if speedHackIsBhopActive then
            speedHackIsBhopActive = false
            speedHackIsMoving = false
            speedHackHasAppliedBoost = false
        end
    end
end)

local arrowTrailPart = nil
local arrowTrailFollowPart = nil
local arrowTrailCurrentTrail = nil
local arrowTrailHeartbeatConn = nil
local arrowTrailAncestryConn = nil

local function createFollowPart()
    local followPart = Instance.new("Part")
    followPart.Name = "ArrowTrailFollow"
    followPart.Anchored = true
    followPart.CanCollide = false
    followPart.Transparency = 1
    followPart.Size = Vector3.new(1, 1, 1)
    followPart.Position = Vector3.new(0, 0, 0)
    followPart.Parent = workspace
    followPart.Material = Enum.Material.ForceField
    task.wait()
    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "Attachment1"
    attachment1.Position = Vector3.new(0, 0, 0)
    attachment1.Parent = followPart
    local attachment2 = Instance.new("Attachment")
    attachment2.Name = "Attachment2"
    attachment2.Position = Vector3.new(0.586, 0, 0)
    attachment2.Parent = followPart
    local trail = Instance.new("Trail")
    trail.Name = "Trail"
    trail.Lifetime = 6
    trail.Texture = "rbxassetid://90089489358574"
    trail.MaxLength = 0
    trail.MinLength = 0.1
    trail.Enabled = true
    trail.Attachment0 = attachment1
    trail.Attachment1 = attachment2
    trail.Parent = followPart
    trail.FaceCamera = true
    trail.WidthScale = NumberSequence.new(0.2)
    return followPart, trail
end

local function updateFollowPart()
    if arrowTrailFollowPart and arrowTrailPart and arrowTrailPart.Parent then
        arrowTrailFollowPart.Position = arrowTrailPart.Position
    end
end

local function makeTrailVisible(followPart, trail)
    if followPart then
        followPart.Transparency = 0
        if trail then
            trail.Enabled = false
        end
        task.delay(6, function()
            if followPart and followPart.Parent then
                followPart:Destroy()
            end
        end)
    end
end

local function cleanupTrail()
    if arrowTrailHeartbeatConn then
        arrowTrailHeartbeatConn:Disconnect()
        arrowTrailHeartbeatConn = nil
    end
    if arrowTrailAncestryConn then
        arrowTrailAncestryConn:Disconnect()
        arrowTrailAncestryConn = nil
    end
    if arrowTrailFollowPart then
        makeTrailVisible(arrowTrailFollowPart, arrowTrailCurrentTrail)
        arrowTrailFollowPart = nil
        arrowTrailCurrentTrail = nil
    end
    arrowTrailPart = nil
end

local function onArrowAdded(obj)
    if not trailEnabled then return end
    if not obj or not obj.Parent then return end
    if not (obj.Name:upper():find("ARROW") or obj.Name:upper():find("BULLET")) then return end
    task.wait(0.03)
    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local isMine = (Camera.CFrame.Position - part.Position).Magnitude < 1 or 
                   (part.Position - Camera.CFrame.Position).Unit:Dot(Camera.CFrame.LookVector) > 0.85
    if not isMine then return end
    if arrowTrailFollowPart then
        makeTrailVisible(arrowTrailFollowPart, arrowTrailCurrentTrail)
        arrowTrailFollowPart = nil
        arrowTrailCurrentTrail = nil
    end
    arrowTrailPart = part
    local existingTrail = part:FindFirstChildOfClass("Trail")
    if existingTrail then
        existingTrail.Enabled = false
    end
    arrowTrailFollowPart, arrowTrailCurrentTrail = createFollowPart()
    if arrowTrailHeartbeatConn then arrowTrailHeartbeatConn:Disconnect() end
    arrowTrailHeartbeatConn = RunService.Heartbeat:Connect(updateFollowPart)
    if arrowTrailAncestryConn then arrowTrailAncestryConn:Disconnect() end
    arrowTrailAncestryConn = part.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanupTrail()
        end
    end)
end

local function setupTrail()
    local const = workspace:FindFirstChild("Const")
    local ignore = const and const:FindFirstChild("Ignore")
    if ignore then
        for _, obj in ipairs(ignore:GetChildren()) do
            onArrowAdded(obj)
        end
        ignore.ChildAdded:Connect(onArrowAdded)
    end
end

setupTrail()

-- Vehicle Fly System
local function isNewPerformanceCar(model)
    if not model or not model:IsA("Model") then return false end
    return model:FindFirstChild("Color") and model:FindFirstChild("Metal") and model:FindFirstChild("Seats")
end

local function isNormalCar(model)
    if not model or not model:IsA("Model") then return false end
    local hasWheels = model:FindFirstChild("FRWheel") or model:FindFirstChild("FLWheel") 
                    or model:FindFirstChild("BRWheel") or model:FindFirstChild("BLWheel")
    local hasBody = model:FindFirstChild("Frame") or model:FindFirstChild("Body") or model:FindFirstChild("Hull")
    return hasWheels and hasBody
end

local function isCar(model)
    return isNormalCar(model) or isNewPerformanceCar(model)
end

-- Исправленная функция с учётом Noclip
local function updateCarPhysics(car)
    if not car or not car.Parent then return end
    
    for _, part in ipairs(car:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if vehicleFlyEnabled then
                part.Anchored = true
                if vehicleNoclipEnabled then
                    part.CanCollide = false
                else
                    part.CanCollide = true
                end
            else
                part.Anchored = false
                part.CanCollide = true
            end
        end
    end
end

local function checkCollisionAndAdjust(position, rotation, moveVector)
    if vehicleNoclipEnabled then
        return moveVector
    end
    
    local car = currentCar
    if not car then return moveVector end
    
    local minBounds, maxBounds = Vector3.new(999, 999, 999), Vector3.new(-999, -999, -999)
    
    for _, part in ipairs(car:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            local worldPos = part.Position
            minBounds = Vector3.new(math.min(minBounds.X, worldPos.X), math.min(minBounds.Y, worldPos.Y), math.min(minBounds.Z, worldPos.Z))
            maxBounds = Vector3.new(math.max(maxBounds.X, worldPos.X), math.max(maxBounds.Y, worldPos.Y), math.max(maxBounds.Z, worldPos.Z))
        end
    end
    
    local size = (maxBounds - minBounds)
    local center = (minBounds + maxBounds) / 2
    local halfSize = size / 2
    local newMove = moveVector
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {car, workspace:FindFirstChild("Const")}
    
    local xRay = workspace:Raycast(center + Vector3.new(halfSize.X * math.sign(moveVector.X), 0, 0), Vector3.new(moveVector.X, 0, 0), rayParams)
    if xRay and xRay.Distance < math.abs(moveVector.X) then
        newMove = Vector3.new(xRay.Distance * math.sign(moveVector.X) - 0.1, newMove.Y, newMove.Z)
    end
    
    local zRay = workspace:Raycast(center + Vector3.new(0, 0, halfSize.Z * math.sign(moveVector.Z)), Vector3.new(0, 0, moveVector.Z), rayParams)
    if zRay and zRay.Distance < math.abs(moveVector.Z) then
        newMove = Vector3.new(newMove.X, newMove.Y, zRay.Distance * math.sign(moveVector.Z) - 0.1)
    end
    
    local yRay = workspace:Raycast(center + Vector3.new(0, halfSize.Y, 0), Vector3.new(0, moveVector.Y, 0), rayParams)
    if yRay and yRay.Distance < math.abs(moveVector.Y) then
        newMove = Vector3.new(newMove.X, yRay.Distance * math.sign(moveVector.Y) - 0.1, newMove.Z)
    end
    
    return newMove
end

local function releaseCar()
    if currentCar and currentCar.Parent then
        for _, part in ipairs(currentCar:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Anchored = false
                part.CanCollide = true
            end
        end
    end
    currentCar = nil
    vehicleMomentum = Vector3.new(0, 0, 0)
end

local function findNearbyCar()
    if currentCar and currentCar.Parent and tick() - lastCarSearch < CAR_SEARCH_COOLDOWN then
        return currentCar
    end

    lastCarSearch = tick()
    local closestCar = nil
    local closestDist = 100
    local camPos = Camera.CFrame.Position

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and isCar(obj) then
            local mainPart = obj:FindFirstChild("Frame") or obj:FindFirstChild("Body") 
                          or obj:FindFirstChild("BodyDummy") or obj:FindFirstChild("Hull") 
                          or obj:FindFirstChild("Color") or obj:FindFirstChild("Metal")

            if mainPart then
                local dist = (mainPart.Position - camPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestCar = obj
                end
            end
        end
    end
    return closestCar
end

local function getGroundHeight(position)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {currentCar, workspace:FindFirstChild("Const")}
    local rayResult = workspace:Raycast(position, Vector3.new(0, -500, 0), rayParams)
    if rayResult then
        return rayResult.Position.Y
    end
    return position.Y - 10
end

vehicleFlyLoop = function()
    function checkCollisionAndAdjust(position, rotation, moveVector)
        if vehicleNoclipEnabled then
            return moveVector
        end
        
        local car = currentCar
        if not car then return moveVector end
        
        local minBounds, maxBounds = Vector3.new(999, 999, 999), Vector3.new(-999, -999, -999)
        
        for _, part in ipairs(car:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                local worldPos = part.Position
                minBounds = Vector3.new(math.min(minBounds.X, worldPos.X), math.min(minBounds.Y, worldPos.Y), math.min(minBounds.Z, worldPos.Z))
                maxBounds = Vector3.new(math.max(maxBounds.X, worldPos.X), math.max(maxBounds.Y, worldPos.Y), math.max(maxBounds.Z, worldPos.Z))
            end
        end
        
        local size = (maxBounds - minBounds)
        local center = (minBounds + maxBounds) / 2
        local halfSize = size / 2
        local newMove = moveVector
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {car, workspace:FindFirstChild("Const")}
        
        local xRay = workspace:Raycast(center + Vector3.new(halfSize.X * math.sign(moveVector.X), 0, 0), Vector3.new(moveVector.X, 0, 0), rayParams)
        if xRay and xRay.Distance < math.abs(moveVector.X) then
            newMove = Vector3.new(xRay.Distance * math.sign(moveVector.X) - 0.1, newMove.Y, newMove.Z)
        end
        
        local zRay = workspace:Raycast(center + Vector3.new(0, 0, halfSize.Z * math.sign(moveVector.Z)), Vector3.new(0, 0, moveVector.Z), rayParams)
        if zRay and zRay.Distance < math.abs(moveVector.Z) then
            newMove = Vector3.new(newMove.X, newMove.Y, zRay.Distance * math.sign(moveVector.Z) - 0.1)
        end
        
        local yRay = workspace:Raycast(center + Vector3.new(0, halfSize.Y, 0), Vector3.new(0, moveVector.Y, 0), rayParams)
        if yRay and yRay.Distance < math.abs(moveVector.Y) then
            newMove = Vector3.new(newMove.X, yRay.Distance * math.sign(moveVector.Y) - 0.1, newMove.Z)
        end
        
        return newMove
    end

    if not vehicleFlyEnabled then
        if currentCar then releaseCar() end
        return
    end

    if not currentCar or not currentCar.Parent then
        currentCar = findNearbyCar()
        if currentCar then updateCarPhysics(currentCar) end
    end

    if not currentCar or not currentCar.Parent then return end
    updateCarPhysics(currentCar)

    local baseSpeed = vehicleHorizontalSpeed
    if isNewPerformanceCar(currentCar) then
        baseSpeed = baseSpeed * 3
    end

    local delta = RunService.Heartbeat:Wait() or 0.016
    local moveDir = Vector3.new()
    local isMoving = false
    local rotateLeft = UserInputService:IsKeyDown(Enum.KeyCode.Z)
    local rotateRight = UserInputService:IsKeyDown(Enum.KeyCode.X)
    local verticalVelocity = 0
    local manualVertical = false

    if vehicleKillEnabled and vehicleKillActive and vehicleKillTarget and vehicleKillTarget.Parent then
        local targetPos = vehicleKillTarget.Position
        local carPos = currentCar:GetPivot().Position
        local dist = (carPos - targetPos).Magnitude

        if dist > 100 then
            local dir = (targetPos - carPos).Unit
            vehicleKillMomentum = dir * 300
            isMoving = true
        elseif dist > 40 then
            local dir = (targetPos - carPos).Unit
            vehicleKillMomentum = dir * 300
            isMoving = true
        else
            local circleRadius = 7
            local circleSpeed = 100
            local time = tick()
            local angle = time * circleSpeed
            local offset = Vector3.new(math.cos(angle) * circleRadius, 0, math.sin(angle) * circleRadius)
            local idealPos = targetPos + offset + Vector3.new(0, 4 + math.sin(time * 3) * 1.5, 0)
            vehicleKillMomentum = vehicleKillMomentum:Lerp((idealPos - carPos).Unit * 100, 0.35)
            isMoving = true
        end

        if dist > 200 then
            vehicleKillActive = false
            vehicleKillTarget = nil
        end
    else
        local look = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        local flatLook = Vector3.new(look.X, 0, look.Z).Unit
        local flatRight = Vector3.new(right.X, 0, right.Z).Unit

        if UserInputService:IsKeyDown(Enum.KeyCode.Up) then moveDir += flatLook isMoving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.Down) then moveDir -= flatLook isMoving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.Left) then moveDir -= flatRight isMoving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.Right) then moveDir += flatRight isMoving = true end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            isMoving = true
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.B) then
            verticalVelocity = vehicleVerticalSpeed
            manualVertical = true
        elseif UserInputService:IsKeyDown(Enum.KeyCode.N) then
            verticalVelocity = -vehicleVerticalSpeed
            manualVertical = true
        else
            manualVertical = false
        end

        if isMoving then
            vehicleKillMomentum = vehicleKillMomentum:Lerp(moveDir * baseSpeed, 0.25)
        end
    end

    if vehicleMomentumEnabled then
        if not isMoving and not (vehicleKillEnabled and vehicleKillActive) then
            vehicleKillMomentum = vehicleKillMomentum * (1 - vehicleMomentumDecay * delta * 2.3)
            if vehicleKillMomentum.Magnitude < 1 then 
                vehicleKillMomentum = Vector3.new() 
            end
        end
    else
        if not (vehicleKillEnabled and vehicleKillActive) then
            vehicleKillMomentum = moveDir * baseSpeed
        end
    end

    local finalMove = vehicleKillMomentum * delta
    
    if manualVertical then
        finalMove = finalMove + Vector3.new(0, verticalVelocity * delta, 0)
    end

    if vehicleReliefEnabled and (isMoving or (vehicleKillEnabled and vehicleKillActive)) and not manualVertical then
        local currentPos = currentCar:GetPivot().Position
        local moveDirection = vehicleKillMomentum.Unit
        local targetPos = currentPos + finalMove
        
        if math.abs(moveDirection.X) < 0.01 and math.abs(moveDirection.Z) < 0.01 then
            local groundY = getGroundHeight(targetPos)
            local newY = groundY + (reliefHeightOffset or 3)
            finalMove = Vector3.new(finalMove.X, newY - currentPos.Y, finalMove.Z)
        else
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {currentCar, workspace:FindFirstChild("Const")}
            
            local forwardRay = workspace:Raycast(currentPos + Vector3.new(0, 2, 0), moveDirection * 8, rayParams)
            local upForwardRay = workspace:Raycast(currentPos + Vector3.new(0, 2, 0), (moveDirection + Vector3.new(0, 1, 0)).Unit * 10, rayParams)
            local downForwardRay = workspace:Raycast(currentPos + Vector3.new(0, 4, 0), (moveDirection + Vector3.new(0, -0.5, 0)).Unit * 10, rayParams)
            local groundRay = workspace:Raycast(targetPos, Vector3.new(0, -500, 0), rayParams)
            local groundY = groundRay and groundRay.Position.Y or (targetPos.Y - 10)
            local targetHeight = groundY + (reliefHeightOffset or 3)
            
            local obstacleDistance = nil
            local obstacleNormal = nil
            
            if forwardRay then
                obstacleDistance = (forwardRay.Position - currentPos).Magnitude
                obstacleNormal = forwardRay.Normal
            end
            
            local needClimb = false
            local climbHeight = 0
            
            if obstacleDistance and obstacleDistance < 6 then
                local slopeAngle = math.deg(math.acos(math.abs(obstacleNormal.Y)))
                
                if slopeAngle > 70 then
                    local horizontalMove = Vector3.new(finalMove.X, 0, finalMove.Z)
                    local dot = horizontalMove.Unit:Dot(Vector3.new(obstacleNormal.X, 0, obstacleNormal.Z).Unit)
                    if dot < -0.3 then
                        finalMove = Vector3.new(0, finalMove.Y, 0)
                    end
                else
                    needClimb = true
                    local slopeFactor = math.clamp((90 - slopeAngle) / 90, 0.3, 1.5)
                    climbHeight = (reliefHeightOffset or 3) + 2 * slopeFactor
                    
                    if upForwardRay then
                        local upHitPos = upForwardRay.Position
                        local surfaceHeight = upHitPos.Y
                        climbHeight = math.max(climbHeight, (surfaceHeight - currentPos.Y) + 1)
                    end
                end
            end
            
            if needClimb then
                local newY = math.max(targetHeight, currentPos.Y + climbHeight)
                finalMove = Vector3.new(finalMove.X, newY - currentPos.Y, finalMove.Z)
            else
                local newY = targetHeight
                finalMove = Vector3.new(finalMove.X, newY - currentPos.Y, finalMove.Z)
            end
            
            if downForwardRay and not needClimb then
                local downHitPos = downForwardRay.Position
                local downSurfaceY = downHitPos.Y
                if downSurfaceY < currentPos.Y - 2 then
                    local descentHeight = math.max(targetHeight, downSurfaceY + 1)
                    finalMove = Vector3.new(finalMove.X, descentHeight - currentPos.Y, finalMove.Z)
                end
            end
        end
    end

    finalMove = checkCollisionAndAdjust(currentCar:GetPivot().Position, currentCar:GetPivot().Rotation, finalMove)

    local currentPivot = currentCar:GetPivot()
    local newPos = currentPivot.Position + finalMove
    local newRotation = currentPivot.Rotation

    if rotateLeft then
        newRotation = newRotation * CFrame.Angles(0, math.rad(vehicleTurnSpeed * delta), 0)
    elseif rotateRight then
        newRotation = newRotation * CFrame.Angles(0, math.rad(-vehicleTurnSpeed * delta), 0)
    end

    if newPos.X ~= newPos.X or newPos.Y ~= newPos.Y or newPos.Z ~= newPos.Z then
        return
    end
    
    currentCar:PivotTo(CFrame.new(newPos) * newRotation)
end
-- Подключение
local flyConnection = RunService.Heartbeat:Connect(vehicleFlyLoop)


cheat.utility.new_renderstepped(function()
    frameCountOthers = frameCountOthers + 1   -- переиспользуем как счётчик
    
    if frameCountOthers >= 100 then
        frameCountOthers = 0
        globalMemoryCleanup()
        cleanCaches()
    end

    frameCountPlayers = frameCountPlayers + 1

    local mousePos = UserInputService:GetMouseLocation()

    if timeChangerEnabled then
        pcall(function()
            game:GetService("Lighting").ClockTime = desiredTime
        end)
    end

    fovOutline.Position = mousePos
    fovFill.Position = mousePos
    fovOutline.Radius = redictionFOVSize
    fovFill.Radius = redictionFOVSize

    if frameCountPlayers >= UPDATE_RATE_PLAYERS then
        frameCountPlayers = 0
        if globalESPEnabled then
            updatePlayerESP()
        end
    end

    if frameCountOthers >= UPDATE_RATE_OTHERS then
        frameCountOthers = 0
        
        if redictionEnabled then 
            updateRedictionTargets() 
        end

        if globalESPEnabled then
            updateVehicleESP()
            updateResourceESP()
            updateMaterialESP()
            updateCorpseESP()
        else
            for _, data in pairs(playerTexts) do
                for _, d in pairs(data) do 
                    if d then d.Visible = false end 
                end
            end
            for _, tbl in pairs(vehicleTexts) do
                for _, t in pairs(tbl) do if t then t.Visible = false end end
            end
            for _, tbl in pairs(lootTexts) do
                for _, t in pairs(tbl) do if t then t.Visible = false end end
            end
            for _, tbl in pairs(materialTexts) do
                for _, t in pairs(tbl) do if t then t.Visible = false end end
            end
            for _, t in pairs(corpseTexts) do if t then t.Visible = false end end
            for _, t in pairs(heliTexts) do if t then t.Visible = false end end
        end
    end

    if redictionEnabled and redictionTargetPos then
        redictionSnapline.Visible = true
        redictionSnapline.From = mousePos
        redictionSnapline.To = redictionTargetPos
    else
        redictionSnapline.Visible = false
    end
end)

cheat.utility.new_heartbeat(function()
    for model in pairs(entities) do
        if model and model.Parent then detectWeapon(model) end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then Library:Toggle() end
    if input.KeyCode == Enum.KeyCode.End then
        cheat.utility.unload()
        if fovEnforceConnection then fovEnforceConnection:Disconnect() end
        Library:Unload()
    end
end)
-- INITIAL SCAN - MINIMUM LOCALS
task.spawn(function()
    local list = workspace:GetChildren()
    for i = 1, #list do
        local m = list[i]
        if m:IsA("Model") and m ~= LocalPlayer.Character then
            task.spawn(function()
                task.wait(0.1)
                if m:FindFirstChild("HumanoidRootPart") then
                    addEntity(m)
                end
            end)
        end
    end
end)

workspace.ChildAdded:Connect(function(obj)
    task.spawn(function()
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            task.wait(0.1)
            if obj:FindFirstChild("HumanoidRootPart") then
                addEntity(obj)
            end
        end
        if obj:IsA("Model") and obj.Name == "Model" then
            task.wait(0.2)
            local body = obj:FindFirstChild("Body")
            if body then
                local s = body.Size
                if math.abs(s.X - 6.80) <= 0.05 then registerVehicle(obj, "Car")
                elseif math.abs(s.X - 7.76) <= 0.05 then registerVehicle(obj, "Quad")
                elseif math.abs(s.X - 2.63) <= 0.05 then registerLoot(obj, "Box")
                elseif math.abs(s.X - 3.59) <= 0.05 then registerLoot(obj, "MiniBox")
                elseif math.abs(s.X - 1.96) <= 0.05 then registerLoot(obj, "Metal")
                elseif math.abs(s.X - 4.83) <= 0.05 or math.abs(s.X - 4.93) <= 0.05 then registerMaterial(obj, "Cactus") end
            elseif obj:FindFirstChild("BodyDummy") then registerVehicle(obj, "Helicopter")
            elseif obj:FindFirstChild("Hull") then registerVehicle(obj, "Boat")
            elseif obj:FindFirstChild("Sign") then registerLoot(obj, "Bloxy")
            elseif obj:FindFirstChild("default") then registerMaterial(obj, "Tree")
            elseif obj:FindFirstChild("Part") then
                local part = obj:FindFirstChild("Part")
                if part and part:IsA("BasePart") then
                    local r,g,b = math.round(part.Color.R*255), math.round(part.Color.G*255), math.round(part.Color.B*255)
                    local count = #obj:GetChildren()
                    if r == 72 and g == 72 and b == 72 and count == 1 then registerMaterial(obj, "Stone")
                    elseif r == 248 and g == 248 and b == 248 and count == 2 then registerMaterial(obj, "Nitrate")
                    elseif r == 199 and g == 172 and b == 120 and count == 2 then registerMaterial(obj, "Iron") end
                end
            end
        end
    end)
end)

workspace.ChildRemoved:Connect(removeEntity)

-- ==================== SILENT AIM ====================
-- ==================== SILENT AIM (СТАТИЧНЫЙ FOV) ====================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false

local snapLine = Drawing.new("Line")
snapLine.Visible = false
snapLine.Color = Color3.fromRGB(255, 255, 255)
snapLine.Thickness = 1

local targetCircle = Drawing.new("Circle")
targetCircle.Visible = false
targetCircle.Thickness = 1
targetCircle.Color = Color3.fromRGB(255, 255, 255)
targetCircle.Radius = 2
targetCircle.Filled = false

local Classes = getrenv()._G.classes
local CameraClient = Classes.Camera
local FPSClient = Classes.FPS
local Camera = cloneref(workspace.CurrentCamera)

local GetFunction = function(Script, Line)
    for _, v in pairs(getgc()) do
        if typeof(v) == "function" and debug.info(v, "sl") then
            local src, lineNum = debug.info(v, "s"), debug.info(v, "l")
            if src:find(Script) and lineNum == Line then
                return v
            end
        end
    end
end

local SetInfraredEnabled = GetFunction("PlayerClient", 588)
local PlayerReg = debug.getupvalue(SetInfraredEnabled, 2)

local validGuns = {"AR15", "C9", "Crossbow", "Bow", "EnergyRifle", "GaussRifle", "HMAR", "KABAR", "LeverActionRifle", "M4A1", "PipePistol", "PipeSMG", "PumpShotgun", "SCAR", "SVD", "USP9", "UZI", "Blunderbuss"}

local function IsValidGun(gun)
    return table.find(validGuns, tostring(gun)) ~= nil
end

local function GetClosestTarget(maxDistance)
    local closestTarget, targetVelocity, closestDistance = nil, nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, v in next, PlayerReg do
        if v.type == "Player" and not v.sleeping and v.model and v.model:FindFirstChild("Head") then
            local distanceToPlayer = (v.model.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            local screenPoint = Camera:WorldToViewportPoint(v.model.Head.Position)
            local distanceFromMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
            
            if distanceToPlayer <= maxDistance and distanceFromMouse <= fovCircle.Radius and distanceToPlayer < closestDistance then
                closestTarget = v.model
                targetVelocity = v.velocityVector
                closestDistance = distanceToPlayer
            end
        end
    end
    return closestTarget, targetVelocity
end

local function CalculateBulletDrop(tPos, tVel, cPos, pSpeed, pDrop)
    local dTT = (tPos - cPos).Magnitude
    local tTT = dTT / pSpeed
    local horizontalVel = Vector3.new(tVel.X, 0, tVel.Z) * 7
    local verticalVel = Vector3.new(0, tVel.Y, 0) * 2
    local pTP = tPos + (horizontalVel + verticalVel) * tTT
    local dP = -pDrop ^ (tTT * pDrop) + 1
    return pTP - Vector3.new(0, dP, 0)
end

local oldGetCFrame = CameraClient.GetCFrame
local silentAimConnection = nil

local function updateSilentAim()
    if not silentAimEnabled then
        fovCircle.Visible = false
        snapLine.Visible = false
        targetCircle.Visible = false
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    
    -- СТАТИЧНЫЙ FOV — просто берём значение из слайдера
    fovCircle.Position = mousePos
    fovCircle.Radius = silentAimFOV
    fovCircle.Visible = true

    local closest, _ = GetClosestTarget(silentAimMaxDistance)
    if closest and closest:FindFirstChild("Head") then
        local headPos = Camera:WorldToViewportPoint(closest.Head.Position)
        
        snapLine.From = mousePos
        snapLine.To = Vector2.new(headPos.X, headPos.Y)
        snapLine.Visible = true
        
        targetCircle.Position = Vector2.new(headPos.X, headPos.Y)
        targetCircle.Visible = true
    else
        snapLine.Visible = false
        targetCircle.Visible = false
    end
end

-- ХУК Silent Aim
CameraClient.GetCFrame = function(...)
    if not silentAimEnabled then
        return oldGetCFrame(...)
    end

    local closest, velocityVector = GetClosestTarget(silentAimMaxDistance)
    local equippedData = FPSClient.GetEquippedItem()
    
    if equippedData and closest and closest:FindFirstChild("HumanoidRootPart") and IsValidGun(equippedData.type) then
        local itemClass = Classes[equippedData.type]
        if itemClass and itemClass.ProjectileSpeed then
            local predictedPos = CalculateBulletDrop(closest.Head.Position, velocityVector, Camera.CFrame.Position, itemClass.ProjectileSpeed, itemClass.ProjectileDrop)
            return CFrame.new(Camera.CFrame.Position, predictedPos)
        end
    end
    return oldGetCFrame(...)
end

silentAimConnection = RunService.RenderStepped:Connect(updateSilentAim)
scanForAll()
