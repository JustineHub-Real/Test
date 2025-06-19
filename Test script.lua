local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Gradient function
local function gradient(text, startColor, endColor)
    local result = ""
    local length = #text

    for i = 1, length do  
        local t = (i - 1) / math.max(length - 1, 1)  
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)  
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)  
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)  

        local char = text:sub(i, i)  
        result = result .. "<font color=\"rgb(" .. r ..", " .. g .. ", " .. b .. ")\">" .. char .. "</font>"  
    end  

    return result
end

local Window = WindUI:CreateWindow({
    Title = "The Mimic",
    Icon = "star",
    Author = "by KAZE",
    Folder = "Kaze Hub",
    Size = UDim2.fromOffset(550, 200),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function() print("clicked") end,
        Anonymous = false
    },
    SideBarWidth = 175,
    HasOutline = true
})

Window:EditOpenButton({
    Title = "Open Kaze Hub",
    Icon = "star",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    Draggable = true,
})

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local lowFPS = false
local fpsConnection

Window:CreateTopbarButton("LowFPSMode", "battery-plus", function(self)
    lowFPS = not lowFPS

    if fpsConnection then
        fpsConnection:Disconnect()
        fpsConnection = nil
    end

    if lowFPS then
        -- SUPER SUPER LOW GFX SETTINGS
        sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 0
        Lighting.Brightness = 0
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.Ambient = Color3.new(0, 0, 0)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            elseif obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("UnionOperation") or obj:IsA("WedgePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end
        end

        -- Lower FPS rendering pressure
        fpsConnection = RunService.Heartbeat:Connect(function()
            task.wait(0.25)
        end)

        self:SetTitle("LowFPS: ON")
    else
        -- RESTORE DEFAULT
        sethiddenproperty(Lighting, "Technology", Enum.Technology.Future)
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

        if Terrain then
            Terrain.WaterWaveSize = 0.1
            Terrain.WaterWaveSpeed = 10
            Terrain.WaterReflectance = 0.05
            Terrain.WaterTransparency = 0.5
        end

        self:SetTitle("LowFPS: OFF")
    end
end, 991)


local Tabs = {    
    Player = Window:Tab({    
        Title = "Player",    
        Icon = "user",    
        Desc = "",    
        ShowTabTitle = true    
    }),    
    
    Ashikaga = Window:Tab({    
        Title = "Ashikaga",    
        Icon = "ghost",    
        Desc = "",    
        ShowTabTitle = true    
    }),    
    
    Office = Window:Tab({    
        Title = "Office",    
        Icon = "building",    
        Desc = "",    
        ShowTabTitle = true    
    }),    
    
    Mall = Window:Tab({    
        Title = "Mall",    
        Icon = "shopping-cart",    
        Desc = "",    
        ShowTabTitle = true    
    }),

    Car = Window:Tab({    
        Title = "Car",    
        Icon = "car",    
        Desc = "",    
        ShowTabTitle = true    
    }),

    Painting = Window:Tab({
        Title = "Painting",
        Icon = "brush", 
        Desc = "",
        ShowTabTitle = true
    }),

    Boss = Window:Tab({
        Title = "Boss",
        Icon = "skull",
        Desc = "",
        ShowTabTitle = true
    })
}

Tabs.Player:Section({ Title = "Lighting Effects" })

--// Services
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local originalLighting = nil
local fullbrightActive = false
local noclipActive = false

--// Save current lighting state
local function cacheLighting()
	if not originalLighting then
		originalLighting = {
			Ambient = Lighting.Ambient,
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd,
			FogColor = Lighting.FogColor,
			GlobalShadows = Lighting.GlobalShadows,
			EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
			Sky = Lighting:FindFirstChildWhichIsA("Sky") and Lighting:FindFirstChildWhichIsA("Sky"):Clone() or nil
		}
	end
end

--// Restore original lighting state
local function restoreLighting()
	if not originalLighting then return end
	for property, value in pairs(originalLighting) do
		if property ~= "Sky" then
			Lighting[property] = value
		end
	end
	if originalLighting.Sky and not Lighting:FindFirstChildOfClass("Sky") then
		originalLighting.Sky.Parent = Lighting
	end
end

--// Fullbright Toggle
Tabs.Player:Toggle({
	Title = "Fullbright",
	Desc = "",
	Value = false,
	Callback = function(state)
		fullbrightActive = state
		if state then
			cacheLighting()
			Lighting.Ambient = Color3.fromRGB(145, 145, 145)
			Lighting.Brightness = 3
			Lighting.ClockTime = 14
			Lighting.FogStart = 0
			Lighting.FogEnd = 1e5
			Lighting.FogColor = Color3.fromRGB(255, 255, 255)
			Lighting.GlobalShadows = false
			Lighting.EnvironmentDiffuseScale = 1
			Lighting.EnvironmentSpecularScale = 1
		else
			restoreLighting()
		end
	end
})

--// UI Section
Tabs.Player:Section({ Title = "Walk Through Walls" })

--// Noclip Logic
RunService.Stepped:Connect(function()
	if not noclipActive then return end
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end)

--// Noclip Toggle
Tabs.Player:Toggle({
	Title = "Noclip",
	Desc = "",
	Value = false,
	Callback = function(state)
		noclipActive = state
	end
})

Tabs.Player:Section({ Title = "Yen [Nightmare]" })

--// UI Section
Tabs.Ashikaga:Section({ Title = "Ashikaga" })

--// Auto Cutscene Button
Tabs.Ashikaga:Button({
	Title = "Auto Cutscenes",
	Desc = "",
	Callback = function()
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

		local Section = workspace:FindFirstChild("Section0")
		local Cutscene = Section and Section:FindFirstChild("Cutscene")
		local Trigger = Cutscene and Cutscene:FindFirstChild("Trigger")

		if HumanoidRootPart and Trigger and (HumanoidRootPart.Position - Trigger.Position).Magnitude <= 1000 then
			HumanoidRootPart.CFrame = Trigger.CFrame + Vector3.new(0, 3, 0)
		end
	end
})

--// UI Sections
Tabs.Office:Section({ Title = "Office Door" })

--// Auto Office Door Button
Tabs.Office:Button({
	Title = "Auto Office Door",
	Desc = "",
	Callback = function()
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

		local section = workspace:FindFirstChild("Section1")
		local teleportTarget = section and section:FindFirstChild("OfficeTeleA")

		if HumanoidRootPart and teleportTarget and (HumanoidRootPart.Position - teleportTarget.Position).Magnitude <= 1000 then
			HumanoidRootPart.CFrame = teleportTarget.CFrame + Vector3.new(0, 3, 0)
		end
	end
})


--// Talk to Boss Section
Tabs.Office:Section({ Title = "Talk to Boss" })

--// Auto Talk to Boss Button
Tabs.Office:Button({
	Title = "Auto Talk to Boss",
	Desc = "",
	Callback = function()
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

		local section = workspace:FindFirstChild("Section1")
		local objective = section and section:FindFirstChild("PlayerObjective")
		local npc = objective and objective:FindFirstChild("QuestGiverNPC")
		local targetPart = npc and (npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart"))

		if HumanoidRootPart and targetPart and (HumanoidRootPart.Position - targetPart.Position).Magnitude <= 1000 then
			HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
			task.wait(0.3)

			for _, descendant in ipairs(npc:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") and descendant.Enabled then
					fireproximityprompt(descendant)
					break
				end
			end
		end
	end
})

--// UI Section
Tabs.Office:Section({ Title = "Keypad" })

--// Auto Keypad Button
Tabs.Office:Button({
	Title = "Go & Auto Input Keypad",
	Desc = "",
	Callback = function()
		local Players = game:GetService("Players")
		local Workspace = game:GetService("Workspace")
		local LocalPlayer = Players.LocalPlayer
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local HRP = Character:WaitForChild("HumanoidRootPart", 5)

		local section = Workspace:FindFirstChild("Section1")
		local objective = section and section:FindFirstChild("PlayerObjective")
		local codeDoor = objective and objective:FindFirstChild("CodeDoor")
		local keypad = codeDoor and codeDoor:FindFirstChild("Keypad")
		local remote = codeDoor and codeDoor:FindFirstChild("Remote")
		local codeNumbers = objective and objective:FindFirstChild("CodeNumbers")

		if not (section and keypad and HRP and remote and codeNumbers) then return end

		local targetPart = keypad:FindFirstChild("Screen") or keypad:FindFirstChildWhichIsA("BasePart")
		if not targetPart or (HRP.Position - targetPart.Position).Magnitude > 1000 then return end

		-- Move player
		HRP.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
		task.wait(0.2)

		-- Trigger keypad prompt
		for _, prompt in ipairs(keypad:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent:IsA("BasePart") then
				if (prompt.Parent.Position - HRP.Position).Magnitude <= 5 then
					fireproximityprompt(prompt)
					break
				end
			end
		end

		task.wait(0.6)

		-- Read codes from CodeNumbers
		local codeList = {}

		for _, floor in ipairs(codeNumbers:GetChildren()) do
			local gui = floor:FindFirstChildWhichIsA("SurfaceGui", true)
			if gui then
				local label = gui:FindFirstChildWhichIsA("TextLabel", true)
					or gui:FindFirstChildWhichIsA("TextBox", true)
					or gui:FindFirstChildWhichIsA("TextButton", true)

				if label and tonumber(label.Text) then
					table.insert(codeList, {
						Floor = tonumber(floor.Name:match("%d+")) or 0,
						Value = tonumber(label.Text)
					})
				end
			end
		end

		table.sort(codeList, function(a, b)
			return a.Floor > b.Floor
		end)

		-- Format and send 6-digit code
		local finalCode = {}
		for i = 1, 6 do
			finalCode[i] = codeList[i] and codeList[i].Value or 0
		end

		remote:FireServer(1, finalCode)
	end
})

--// UI Section
Tabs.Office:Section({ Title = "Rooftop" })

--// Auto Rooftop Button
Tabs.Office:Button({
	Title = "Auto Rooftop",
	Desc = "",
	Callback = function()
		local Players = game:GetService("Players")
		local Workspace = game:GetService("Workspace")
		local LocalPlayer = Players.LocalPlayer
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local HRP = Character:WaitForChild("HumanoidRootPart", 3)
		if not HRP then return end

		local section = Workspace:FindFirstChild("Section1")
		local objective = section and section:FindFirstChild("PlayerObjective")
		if not objective then return end

		-- Step 1: Go to ShovelGiver and interact
		local shovelGiver = objective:FindFirstChild("CodeDoor") and objective.CodeDoor:FindFirstChild("ShovelGiver")
		if shovelGiver and shovelGiver:IsA("BasePart") then
			HRP.CFrame = shovelGiver.CFrame + Vector3.new(0, 3, 0)
			task.wait(0.3)

			for _, p in ipairs(shovelGiver:GetDescendants()) do
				if p:IsA("ProximityPrompt") and p.Enabled then
					fireproximityprompt(p)
					break
				end
			end
		end

		-- Step 2: Wait and equip shovel tool
		local toolName = "Mimic@Tool_Shovel"
		local backpack = LocalPlayer:WaitForChild("Backpack")
		local tool = backpack:FindFirstChild(toolName)

		while not tool do
			tool = backpack:FindFirstChild(toolName)
			task.wait(0.2)
		end

		tool.Parent = Character
		task.wait(0.2)

		-- Optional: align to hand
		local rightHand = Character:FindFirstChild("RightHand")
		if rightHand and tool:FindFirstChild("Handle") then
			pcall(function()
				tool.Handle.CFrame = rightHand.CFrame
				tool.Parent = rightHand
			end)
		end

		-- Step 3: Dig at dirt objective
		local digPos = Vector3.new(4450, 44, 1638)
		HRP.CFrame = CFrame.new(digPos)
		task.wait(0.3)

		local dirtObjective = objective:FindFirstChild("DirtDigObjective")
		if dirtObjective then
			for i = 1, 5 do
				for _, prompt in ipairs(dirtObjective:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") and prompt.Enabled then
						fireproximityprompt(prompt)
						break
					end
				end
				task.wait(0.4)
			end
		end

		-- Step 4: Go to teleport door and fire prompt
		task.wait(0.5)
		HRP.CFrame = CFrame.new(4434, 44, 1638)
		task.wait(0.3)

		local teleportDoor = objective:FindFirstChild("TeleportDoor")
		local promptContainer = teleportDoor and teleportDoor:FindFirstChild("PROMPT")

		if promptContainer then
			for _, p in ipairs(promptContainer:GetDescendants()) do
				if p:IsA("ProximityPrompt") and p.Enabled then
					fireproximityprompt(p)
					break
				end
			end
		end
	end
})

Tabs.Office:Button({
    Title = "Auto Escape",
    Desc = "",
    Callback = function()
        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local player = Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 3)
        if not root then return end

        -- Helper function to fire proximity prompts near a given position
        local function fireNearbyPrompt(maxDistance)
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local parent = obj.Parent
                    local part = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart")
                    if part and (part.Position - root.Position).Magnitude <= maxDistance then
                        fireproximityprompt(obj)
                        return true
                    end
                end
            end
            return false
        end

        -- Step 1: Teleport to PieceA
        local lantern = Workspace:FindFirstChild("WHITE_FLAME_LANTERN")
        local pieceA = lantern and lantern:FindFirstChild("PieceA")
        if not pieceA then return end

        root.CFrame = pieceA.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.3)
        fireNearbyPrompt(15)

        -- Step 2: Teleport to escape point and fire prompt
        task.wait(0.4)
        root.CFrame = CFrame.new(4977, 27, 1223)
        task.wait(0.3)
        fireNearbyPrompt(15)
    end
})

Tabs.Mall:Section({ Title = "ESP All Monsters" })

local espEnabled = false
local espObjects = {}

local function createESP(model)
    if not model:IsA("Model") or espObjects[model] then return end
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 5000
    billboard.Parent = root

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = billboard

    espObjects[model] = { highlight, billboard, label }

    task.spawn(function()
        while espEnabled and model and root do
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                label.Text = string.format("%s\n[%d]", model.Name, math.floor(dist))
            end
            task.wait(0.1)
        end
    end)
end

local function removeESP()
    for _, objects in pairs(espObjects) do
        for _, obj in pairs(objects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
    end
    espObjects = {}
end

local function setupESP()
    local W = workspace.Section2
    local M1 = W.Floor1.Monster:FindFirstChild("Tenome")
    local M2 = W.Floor2.Monster:FindFirstChild("Rin")
    local M3 = W.Floor3.Monster:FindFirstChild("Tsukiya")
    for _, model in ipairs({ M1, M2, M3 }) do
        if model then createESP(model) end
    end
end

Tabs.Mall:Toggle({
    Title = "ESP Monsters",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if state then
            setupESP()
        else
            removeESP()
        end
    end
})

Tabs.Mall:Section({ Title = "Objectives" })

Tabs.Mall:Button({
    Title = "Auto Walkie Talkie",
    Desc = "",
    Callback = function()
        local P = game:GetService("Players")
        local L = P.LocalPlayer
        local C = L.Character or L.CharacterAdded:Wait()
        local R = C:WaitForChild("HumanoidRootPart", 3)
        if not R then return end

        local F = workspace:FindFirstChild("Section2")
        local W = F and F:FindFirstChild("WalkieTalkis")
        if not W then return end

        local T = {
            W:FindFirstChild("WalkieTalkie"),
            W:GetChildren()[6],
            W:GetChildren()[7],
            W:GetChildren()[8],
        }

        for _, v in ipairs(T) do
            if v and v:IsA("BasePart") then
                R.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.1)
                for _, d in ipairs(v:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled and (d.Parent.Position - R.Position).Magnitude <= 10 then
                        fireproximityprompt(d)
                        break
                    end
                end
                task.wait(0.016)
            end
        end
    end
})


Tabs.Mall:Button({
    Title = "Go back to entrance",
    Desc = "",
    Callback = function()
        local P = game:GetService("Players")
        local L = P.LocalPlayer
        local C = L.Character or L.CharacterAdded:Wait()
        local R = C:WaitForChild("HumanoidRootPart", 3)
        if not R then return end

        local S = workspace:FindFirstChild("Section2")
        local F = S and S:FindFirstChild("Floor1")
        local T = F and F:FindFirstChild("TRIGGER")

        if T and (R.Position - T.Position).Magnitude <= 1000 then
            R.CFrame = T.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.2)
        end

        R.CFrame = CFrame.new(-1333, -165, -1119)
    end
})

local P = game:GetService("Players").LocalPlayer

local function getPart(obj)
    if obj:IsA("BasePart") and obj.Transparency < 1 then
        return obj
    end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 1 then
            return d
        end
    end
end

local function tpAndPrompt(obj)
    local R = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
    local part = getPart(obj)
    if R and part then
        R.CFrame = part.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.2)
        for _, p in ipairs(obj:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled then
                fireproximityprompt(p)
                break
            end
        end
        task.wait(0.016)
        return true
    end
    return false
end

Tabs.Mall:Button({
    Title = "Auto Collect and Insert Coins",
    Desc = "",
    Callback = function()
        local S = workspace:FindFirstChild("Section2")
        local F2 = S and S:FindFirstChild("Floor2")
        if not F2 then return end

        local coins = F2:FindFirstChild("Coins")
        local slot = F2:FindFirstChild("Carousel") and F2.Carousel:FindFirstChild("CoinSlot")
        if not coins or not slot then return end

        local got, seen, pool = 0, {}, {}
        for _, c in ipairs(coins:GetChildren()) do
            if getPart(c) then
                table.insert(pool, c)
            end
        end

        while got < 5 and #pool > 0 do
            local i = math.random(1, #pool)
            local coin = table.remove(pool, i)
            if coin and not seen[coin] then
                seen[coin] = true
                if tpAndPrompt(coin) then
                    got += 1
                end
            end
        end

        tpAndPrompt(slot)
    end
})

Tabs.Mall:Button({
    Title = "Auto Blind Kyogi",
    Desc = "",
    Callback = function()
        local lp = game:GetService("Players").LocalPlayer

        local function getPart(obj)
            if obj:IsA("BasePart") then return obj end
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then return d end
            end
            return nil
        end

        local function tpAndPrompt(folder)
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            for _, item in ipairs(folder:GetChildren()) do
                local part = getPart(item)
                if part then
                    root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.3)
                    for _, obj in ipairs(item:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            fireproximityprompt(obj)
                            task.wait(obj.HoldDuration + 0.1)
                        end
                    end
                    task.wait(0.2)
                end
            end
        end

        local trial = workspace:FindFirstChild("Section2")
            and workspace.Section2:FindFirstChild("Floor1")
            and workspace.Section2.Floor1:FindFirstChild("TimedTrial")

        if not trial then return end

        for i = 1, 3 do
            local f = trial:FindFirstChild(tostring(i))
            if f then
                tpAndPrompt(f)
            end
        end
    end
})

Tabs.Mall:Button({
    Title = "Auto Deaf Tsukiya",
    Desc = "",
    Callback = function()
        local lp = game:GetService("Players").LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local bp = lp:WaitForChild("Backpack")
        local spk = workspace:FindFirstChild("Section2") and workspace.Section2:FindFirstChild("Speaker")
        if not spk then return end

        local function getPart(obj)
            if obj:IsA("BasePart") then return obj end
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then return d end
            end
        end

        local function firePrompt(obj)
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    fireproximityprompt(d)
                    return true
                end
            end
        end

        -- Step 1: Teleport to Speaker and fire prompt
        local part = getPart(spk)
        if part then
            hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.1)
            firePrompt(spk)
        end

        -- Step 2: Teleport to drop position and fire Signal
        hrp.CFrame = CFrame.new(-1364, -120, -937)
        task.wait(0.1)
        if spk:FindFirstChild("Signal") then
            spk.Signal:FireServer()
        end

        -- Step 3: Wait and fire proximity prompt again (no teleport)
        task.wait(0.2)
        firePrompt(spk)
    end
})


Tabs.Mall:Button({
    Title = "Auto take 2nd item and exit",
    Desc = "",
    Callback = function()
        local plr = game:GetService("Players").LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local t = workspace:FindFirstChild("Section2")
        t = t and t:FindFirstChild("Floor3")
        t = t and t:FindFirstChild("Monster")
        t = t and t:FindFirstChild("Tsukiya")

        if t and t:IsA("BasePart") then
            hrp.CFrame = t.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
            for _, d in ipairs(t:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled and d.Parent:IsA("BasePart") then
                    if (hrp.Position - d.Parent.Position).Magnitude <= 10 then
                        fireproximityprompt(d)
                        break
                    end
                end
            end
        end

        local e = workspace:FindFirstChild("Section2")
        e = e and e:FindFirstChild("Exit")

        if e and e:IsA("BasePart") then
            hrp.CFrame = e.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
        end
    end
})

Tabs.Mall:Section({ Title = "Chase Phase" })

Tabs.Mall:Button({
    Title = "Auto Chase 1",
    Desc = "",
    Callback = function()
        local TweenService = game:GetService("TweenService")
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        local function tweenTo(pos, speed)
            local dist = (hrp.Position - pos).Magnitude
            local time = dist / speed
            local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
            tween:Play()
            task.wait(time)
        end

        local seq = workspace:FindFirstChild("Section2.5") and workspace["Section2.5"]:FindFirstChild("ChaseSequence")
        if not seq then return end

        local start = seq:FindFirstChild("StartPoint")
        local endp = seq:FindFirstChild("EndPoint")
        if not start or not endp then return end

        hrp.CFrame = start:GetPivot() + Vector3.new(0, 3, 0)
        task.wait(0.3)

        local path = {
            Vector3.new(-2935, -153, 48),
            Vector3.new(-3001, -155, 107),
            Vector3.new(-3009, -157, 3),
            Vector3.new(-3073, -161, 3),
            Vector3.new(-3080, -161, 49),
            Vector3.new(-3151, -164, 53),
            Vector3.new(-3150, -165, 6),
            Vector3.new(-3346, -176, 0),
            Vector3.new(-3449, -182, -57),
            Vector3.new(-3305, -180, -386),
            Vector3.new(-3365, -183, -409),
            Vector3.new(-3340, -183, -471),
            Vector3.new(-3538, -195, -571),
            Vector3.new(-3561, -196, -512),
            Vector3.new(-3712, -208, -787),
            Vector3.new(-3594, -206, -1062)
        }

        for _, pos in ipairs(path) do
            tweenTo(pos, 70)
            task.wait(0.05)
        end

        tweenTo(endp:GetPivot().Position + Vector3.new(0, 3, 0), 100)
        task.wait(0.05)
        tweenTo(Vector3.new(-3216, -213, -903), 70)
    end
})

Tabs.Mall:Button({
    Title = "Auto Chase 2",
    Desc = "",
    Callback = function()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 3)
        if not hrp then return end

        local s25 = workspace:FindFirstChild("Section2.5")
        local elevator = s25 and s25:FindFirstChild("Elevator")
        local part = elevator and elevator:FindFirstChild("Elevator")

        if part then
            local tpTarget = part:IsA("BasePart") and part or part:FindFirstChildWhichIsA("BasePart", true)
            if tpTarget then
                hrp.CFrame = tpTarget.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

Tabs.Car:Section({ Title = "Repair Car" })

Tabs.Car:Button({
    Title = "Auto Car Parts",
    Desc = "",
    Callback = function()
        local plr = game:GetService("Players").LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 3)
        if not hrp then return end

        local s25 = workspace:FindFirstChild("Section2.5")
        local mg = s25 and s25:FindFirstChild("ChihiroMinigame")
        local obj = mg and mg:FindFirstChild("CarFixObjective")
        local parts = obj and obj:FindFirstChild("CarParts")
        if not parts then return end

        local function getPart(o)
            if o:IsA("BasePart") then return o end
            for _, d in ipairs(o:GetDescendants()) do
                if d:IsA("BasePart") then return d end
            end
        end

        local function firePrompt(o)
            for _, d in ipairs(o:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    fireproximityprompt(d)
                    return true
                end
            end
        end

        for _, item in ipairs(parts:GetChildren()) do
            local part = getPart(item)
            if part then
                hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
                firePrompt(item)
                task.wait(0.2)
            end
        end
    end
})

Tabs.Car:Section({ Title = "Chihiro minigame" })

Tabs.Car:Button({
    Title = "Fix Chihiro minigame",
    Desc = "",
    Callback = function()
        local plr = game:GetService("Players").LocalPlayer
        local gui = plr:FindFirstChild("PlayerGui")
        local s25 = gui and gui:FindFirstChild("S2.5")
        local ls = s25 and s25:FindFirstChild("LocalScript")
        if ls and ls:IsA("LocalScript") and not ls:FindFirstChildOfClass("LocalScript") then
            local f = loadstring(ls.Source)
            if f then f() end
        end
    end
})

Tabs.Car:Button({
    Title = "Answer Quiz",
    Desc = "",
    Callback = function()
        local plr = game:GetService("Players").LocalPlayer
        local gui = plr:WaitForChild("PlayerGui"):WaitForChild("S2.5")
        local selectors = gui:WaitForChild("Selectors")
        local question = gui:WaitForChild("Questions"):WaitForChild("Question")
        local qText = question.Text:lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")

        local answers = {
            ["i was once a curious girl, now i wear a white dress and a pink hat, forever smiling. who am i?"] = "Hiachi Masashige",
            ["i sit quietly, made of stone, and show the way to a sacred throne. what am i?"] = "Torii Gate",
            ["flames consume at my decree, yokai kneel and follow me. jealous hearts, i twist and pry, for my father, worlds will die. speak my name, who am i?"] = "Enzukai",
            ["i guard the shrine in silence, standing still with fierce eyes. what am i?"] = "A Komainu",
            ["what is our cult name?"] = "Kiiroibara Cult",
            ["i am pathetic, regretful, and i'm the reason my brother died. who am i?"] = "Me",
            ["i bloom in spring, soft and sweet, pink and white, on branches i greet. i am kintoru's favorite. what am i?"] = "Cherry Blossom",
            ["i have no voice, yet i tell stories in ink. i'm soft in your hand, but i carve into time. what am i?"] = "A Brush",
            ["four i shaped in shadows dire— flames of envy, a burning pyre. chains of control, unyielding, tight, one reborn, one filled with spite, who forged them all? speak my fate."] = "Evil God"
        }

        local correct = answers[qText]
        if not correct then
            WindUI:Notify({
                Title = "No Match Found",
                Content = "Question not recognized.\n\n" .. question.Text,
                Duration = 5,
            })
            return
        end

        local selectedIndex
        for i, v in ipairs(selectors:GetChildren()) do
            local lbl = v:FindFirstChild("Label", true)
            if lbl and lbl:IsA("TextLabel") then
                local labelText = lbl.Text:lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                local correctClean = correct:lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                if labelText == correctClean then
                    selectedIndex = i
                    break
                end
            end
        end

        if selectedIndex then
            local signal = workspace:FindFirstChild("Section2.5")
                and workspace["Section2.5"]:FindFirstChild("ChihiroMinigame")
                and workspace["Section2.5"].ChihiroMinigame:FindFirstChild("Trivia")
                and workspace["Section2.5"].ChihiroMinigame.Trivia:FindFirstChild("Signal")
            if signal then
                signal:FireServer(1, selectedIndex)
                WindUI:Notify({
                    Title = "Correct Answer",
                    Content = "Your answer: " .. correct,
                    Duration = 5,
                })
            end
        else
            WindUI:Notify({
                Title = "Answer Not Found",
                Content = "Correct answer wasn’t in the 3 choices.",
                Duration = 5,
            })
        end
    end
})

Tabs.Painting:Section({ Title = "ESP monster" })

Tabs.Painting:Toggle({
    Title = "ESP Senzai",
    Desc = "",
    Default = false,
    Callback = function(S)
        local RunService = game:GetService("RunService")
        local CoreGui = game:GetService("CoreGui")
        local ESPFolder = CoreGui:FindFirstChild("SenzaiESP") or Instance.new("Folder", CoreGui)
        ESPFolder.Name = "SenzaiESP"
        ESPFolder:ClearAllChildren()

        local monster = workspace:FindFirstChild("Section3")
            and workspace.Section3:FindFirstChild("Monster")
            and workspace.Section3.Monster:FindFirstChild("Senzai")

        if not S or not monster or not monster:IsA("Model") then return end

        local root = monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChildWhichIsA("BasePart")
        if not root then return end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = monster
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.2
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = ESPFolder

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = ESPFolder

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 0, 0)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(1, 1, 1)
        label.TextScaled = false
        label.TextSize = 16
        label.Font = Enum.Font.SourceSansBold
        label.Text = "Senzai - 0m"
        label.Parent = billboard

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not S or not monster.Parent then
                ESPFolder:ClearAllChildren()
                if connection then connection:Disconnect() end
                return
            end
            local plr = game.Players.LocalPlayer
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = math.floor((root.Position - hrp.Position).Magnitude)
                label.Text = "Senzai - " .. dist .. "m"
            end
        end)
    end
})







Tabs.Boss:Section({ Title = "Survivor" })

Tabs.Boss:Button({
    Title = "Auto Rescue",
    Desc = "",
    Callback = function()
        local P = game:GetService("Players")
        local L = P.LocalPlayer
        local C = L.Character or L.CharacterAdded:Wait()
        local H = C:WaitForChild("HumanoidRootPart", 5)
        if not H then return end

        local W = workspace
        local S4 = W:FindFirstChild("Section4")
        local R = S4 and S4:FindFirstChild("Rescue")
        local N = R and R:FindFirstChild("NPCs")
        if not N then return end

        local Poses = {}
        for _, V in ipairs(N:GetChildren()) do
            if #Poses >= 3 then break end
            if V:IsA("Model") and V.Name:lower():find("pose") then
                table.insert(Poses, V)
            end
        end

        local function GetPart(M)
            return M:IsA("Model") and M.PrimaryPart or M:FindFirstChild("HumanoidRootPart") or M:FindFirstChildWhichIsA("BasePart")
        end

        for _, V in ipairs(Poses) do
            local Part = GetPart(V)
            if Part then
                H.CFrame = Part.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
                for _, X in ipairs(V:GetDescendants()) do
                    if X:IsA("ProximityPrompt") and X.Enabled then
                        fireproximityprompt(X)
                        break
                    end
                end
                task.wait(0.3)
            end
        end

        local RescuePoint = R:FindFirstChild("RescuePoint")
        if RescuePoint and RescuePoint:IsA("BasePart") then
            H.CFrame = RescuePoint.CFrame + Vector3.new(0, 3, 0)
        end
    end
})


Tabs.Boss:Section({ Title = "Yokai" })

local espEnabled = false
local espObjects = {}

local function createESP(model)
    if not model:IsA("Model") then return end
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 5000
    billboard.Name = "ESP_GUI"
    billboard.Parent = rootPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Parent = billboard

    espObjects[model] = { highlight, billboard, textLabel }

    task.spawn(function()
        while espEnabled and model and rootPart do
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distance = (hrp.Position - rootPart.Position).Magnitude
                textLabel.Text = string.format("%s\n[%d]", model.Name, math.floor(distance))
            end
            task.wait(0.1)
        end
    end)
end

local function removeESP()
    for _, group in pairs(espObjects) do
        for _, obj in pairs(group) do
            if obj then obj:Destroy() end
        end
    end
    espObjects = {}
end

local function setupESP()
    local models = {
        workspace.Section4.Monster3:FindFirstChild("Tenome2"),
        workspace.Section4.Monster4:FindFirstChild("Tsukiya2"),
        workspace.Section4.Monster2:FindFirstChild("Rin2"),
    }
    for _, model in pairs(models) do
        if model then createESP(model) end
    end
end

Tabs.Boss:Toggle({
    Title = "ESP Yokai",
    Value = espEnabled,
    Callback = function(state)
        espEnabled = state
        if state then
            setupESP()
        else
            removeESP()
        end
    end
})

Tabs.Boss:Section({ Title = "First Boss" })

Tabs.Boss:Button({
    Title = "Auto SuperCharged",
    Desc = "",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local lp = Players.LocalPlayer
        local chr = lp.Character or lp.CharacterAdded:Wait()
        local hrp = chr:WaitForChild("HumanoidRootPart")
        local pointsFolder = workspace.Section4.WeakPoints.Points
        local teleportTarget = workspace.Section4.TeleportPoint

        local function waitForSpiritBow()
            while true do
                chr = lp.Character or lp.CharacterAdded:Wait()
                local bow = chr:FindFirstChild("SpiritBow")
                if bow and bow:FindFirstChild("RemoteEvent") then
                    return bow
                end
                chr.ChildAdded:Wait()
            end
        end

        local floatConn
        local function startFloatAt(cframe)
            if floatConn then floatConn:Disconnect() end
            floatConn = RunService.RenderStepped:Connect(function()
                hrp.Velocity = Vector3.zero
                hrp.CFrame = cframe
            end)
        end

        local function stopFloat()
            if floatConn then floatConn:Disconnect() end
        end

        local function fireAtEyesFloat(bow, model)
            local eyes = {"EyeA", "EyeB", "EyeC", "EyeD", "EyeE"}
            local root = model:FindFirstChild("RootPart")
            local icon = root and root:FindFirstChild("Icon")
            if not icon or not icon.Enabled then return end

            while icon.Enabled do
                for _, eyeName in ipairs(eyes) do
                    local eye = model:FindFirstChild(eyeName)
                    if eye and eye:IsA("BasePart") then
                        -- Step 1: Go 70 studs above Eye
                        local above = eye.Position + Vector3.new(0, 70, 0)
                        -- Step 2: Face the Eye
                        local faceEye = CFrame.new(above, eye.Position)
                        -- Step 3: Move 30 studs back
                        local floatCFrame = faceEye * CFrame.new(0, 0, -30)
                        -- Step 4: Float
                        startFloatAt(floatCFrame)

                        -- Step 5: Fire SpiritBow
                        local dir = (eye.Position - hrp.Position).Unit
                        bow.RemoteEvent:FireServer(0, true)
                        task.wait(1.3)
                        bow.RemoteEvent:FireServer(0, false, dir)
                        task.wait(0.3)
                    end
                end
            end
            stopFloat()
        end

        task.spawn(function()
            local bow = waitForSpiritBow()
            task.wait(0.2)

            for _, model in ipairs(pointsFolder:GetChildren()) do
                local root = model:FindFirstChild("RootPart")
                local icon = root and root:FindFirstChild("Icon")

                if root and icon and icon:IsA("ImageLabel") and icon.Enabled then
                    fireAtEyesFloat(bow, model)
                    break
                end
            end

            stopFloat()
            hrp.CFrame = teleportTarget.CFrame
        end)
    end
})


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local autoKillRyujin = false
local floatConn

local function waitForBow()
	while true do
		local char = lp.Character or lp.CharacterAdded:Wait()
		local bow = char:FindFirstChild("SpiritBow")
		if bow and bow:FindFirstChild("RemoteEvent") then return bow end
		char.ChildAdded:Wait()
	end
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local autoKillRyujin = false
local floatConn

local function waitForBow()
	while true do
		local char = lp.Character or lp.CharacterAdded:Wait()
		local bow = char:FindFirstChild("SpiritBow")
		if bow and bow:FindFirstChild("RemoteEvent") then return bow end
		char.ChildAdded:Wait()
	end
end

Tabs.Boss:Toggle({
	Title = "Auto Kill Ryujin",
	Value = false,
	Callback = function(state)
		autoKillRyujin = state

		if not state and floatConn then  
			floatConn:Disconnect()  
			floatConn = nil  

			local char = lp.Character or lp.CharacterAdded:Wait()
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local tp = workspace.Section4:FindFirstChild("TeleportPoint")
			if hrp and tp then
				hrp.CFrame = tp.CFrame
			end

			return  
		end  

		task.spawn(function()  
			local char = lp.Character or lp.CharacterAdded:Wait()  
			local hrp = char:WaitForChild("HumanoidRootPart")  
			local ryujin = workspace.Section4.BossMonster:FindFirstChild("EnzukaiRyu")  
			local head = ryujin and ryujin:FindFirstChild("HeadHitBox")  
			if not head then return end  

			local bow = waitForBow()  
			task.wait(0.3)  

			floatConn = RunService.RenderStepped:Connect(function()  
				if not autoKillRyujin or not head then return end  
				hrp.Velocity = Vector3.zero  
				local floatPos = head.CFrame * CFrame.new(0, 40, 40)  
				hrp.CFrame = CFrame.new(floatPos.Position)  
			end)  

			local targets = {  
				ryujin:FindFirstChild("ArrowHitBox"),  
				ryujin:FindFirstChild("Hitbox"),  
				ryujin:GetChildren()[11],  
				ryujin:GetChildren()[16],  
				ryujin:GetChildren()[17],  
				ryujin:GetChildren()[18],  
			}  

			while autoKillRyujin do  
				for _, target in ipairs(targets) do  
					if target and target:IsA("BasePart") then  
						local dir = (target.Position - hrp.Position).Unit  
						bow.RemoteEvent:FireServer(0, true)  
						task.wait(0.8)  
						bow.RemoteEvent:FireServer(0, false, dir)  
						task.wait(0.5)  
					end  
				end  
			end  

			if floatConn then floatConn:Disconnect() end  
		end)  
	end
})