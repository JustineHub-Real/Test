local Window = OrionLib:MakeWindow({Name = "Kaze Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})
local main = Window:MakeTab({
	Name = "Tab 1",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local Section = main:AddSection({
	Name = "Section"
})
