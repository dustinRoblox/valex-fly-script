-- Quick service access
local Services = setmetatable({}, {
    __index = function(_, serviceName)
        return cloneref(game:GetService(serviceName))
    end
})

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer

-- Load Luarmor library
local Luarmor = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
Luarmor.script_id = "07ac396fc8f43891e2385a4b648b8c34"

-- Skip all key and age checks, just load the script
Luarmor.load_script()
