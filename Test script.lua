local Window = OrionLib:MakeWindow({Name = "Kaze Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local main = Window:MakeTab({
	Name = "Tab 1",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = main:AddSection({
	Name = "Speed 5 plus"
})

Tabs.main:Button({
    Title = "Button test",
    Desc = "",
    Callback = function()
        local plr = game:GetService("Players").LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed + 5
        end
    end
})