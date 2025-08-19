local AppMode = require("app_mode")

-- Engineering Mode - just apps + simple Colima check
local engineeringMode = AppMode.new("Engineering", {
    hotkey = {{"cmd", "alt"}, "E"},
    apps = {"Visual Studio Code", "Ghostty"},
    onEnable = function()
        -- Simple Colima check without PATH issues
        local colimaPath = "/opt/homebrew/bin/colima"
        local status = hs.execute(colimaPath .. " status 2>/dev/null")
        
        if status and status:match("running") then
            -- Already running, do nothing
        else
            hs.notify.new({
                title = "🐳 Starting Docker",
                informativeText = "Colima starting...",
                autoWithdraw = true
            }):send()
            hs.execute(colimaPath .. " start &")  -- Start in background
        end
    end
})

-- Work Mode - just apps
local workMode = AppMode.new("Work", {
    hotkey = {{"cmd", "alt"}, "W"},
    apps = {"Microsoft Teams", "Claude", "Safari"}
})

-- Initialize modes
engineeringMode.init()
workMode.init()

print("🎯 Modes loaded!")
