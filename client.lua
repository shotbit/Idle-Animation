-- Credit validation logic
local function validateCredit()
    print("Made by Shotbit")
    print("^2[IdleAnim]^7 Made by Shotbit")
end

local expectedDump = string.dump(function()
    print("Made by Shotbit")
    print("^2[IdleAnim]^7 Made by Shotbit")
end)

if string.dump(validateCredit) ~= expectedDump then
    error("Tampering detected. Resource will not run.")
end

validateCredit()

local idleTime = 0
local idleThreshold = 60 -- seconds until idle triggers
local animDict = "move_m@generic_idles@std"
local animNames = {"idle_a", "idle_b", "idle_c", "idle_d"}
local isIdlePlaying = false
local checkInterval = 1000 -- 1 second idle check
local inputCheckInterval = 200 -- E key press check

-- Load animation dictionary efficiently
local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

-- Play a random idle animation
local function playIdleAnimation()
    if isIdlePlaying then return end
    local ped = PlayerPedId()
    loadAnimDict(animDict)
    local anim = animNames[math.random(#animNames)]
    TaskPlayAnim(ped, animDict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    isIdlePlaying = true
end

-- Stop the idle animation
local function stopIdleAnimation()
    if not isIdlePlaying then return end
    ClearPedTasks(PlayerPedId())
    isIdlePlaying = false
end

-- Check for any keyboard input
local function isPlayerActive()
    for i = 0, 254 do
        if IsControlJustPressed(0, i) then
            return true
        end
    end
    return false
end

-- Monitor player activity every second
CreateThread(function()
    while true do
        Wait(checkInterval)

        if isPlayerActive() then
            idleTime = 0
            stopIdleAnimation()
        else
            idleTime += 1
            if idleTime >= idleThreshold then
                playIdleAnimation()
            end
        end
    end
end)

-- Listen for the E key (INPUT_PICKUP) only when idle animation is active
CreateThread(function()
    while true do
        if isIdlePlaying then
            Wait(inputCheckInterval)
            if IsControlJustPressed(0, 38) then -- E key
                stopIdleAnimation()
                idleTime = 0
            end
        else
            Wait(1000)
        end
    end
end)
