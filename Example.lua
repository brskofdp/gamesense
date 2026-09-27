--[[
	Example.lua — template d'utilisation de la nouvelle API (style Lumen).

	Chaque méthode utilisée ici existe dans Source.lua :
	  Library:Window, :On, :Notify, :Unload, :Disable, :SetColor, :GetConfigs
	  UI:Page / Page:SubPage / Section (Side, Fill, Icon)
	  Section:Toggle, :Slider, :Dropdown, :MultiBox, :Input, :Button,
	           :List, :Label, :Paragraph, :Keybind, :Colorpicker, :ImageDropdown
	  Toggle/Slider/Dropdown/Input/List : Get / Set / SetVisible / SetEnabled
	  List : Add / Remove / Clear / Get / Set
	  Dropdown : Refresh / UpdateOptions
	  Button : SetText
]]

local Players = game:GetService("Players")

local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/brskofdp/gamesense/refs/heads/main/Source.lua"
))()

--==========================================================================--
--  FENÊTRE
--==========================================================================--

local UI = Library:Window({
	Title = "My UI",          -- affiché en bas à gauche
	Footer = "My Script",     -- affiché en bas à droite
	Logo = 10734910430,       -- (optionnel) logo dans la barre latérale
	Keybind = Enum.KeyCode.Insert, -- touche d'ouverture du menu
})

--==========================================================================--
--  PAGES / SOUS-PAGES / SECTIONS
--==========================================================================--

local Main = UI:Page({
	Name = "Main",
	Icon = 18248771514, -- nombre ou "rbxassetid://..." ou "lucide:crosshair"
})

local Settings = UI:Page({
	Name = "Settings",
	Icon = 15453349637,
})

-- Sous-page (onglets dans le header de la page)
local Controls = Main:SubPage({
	Name = "Controls",
})

-- Side = "Left" | "Right"   /   Fill = true → la section remplit la colonne
local Section = Controls:Section({
	Name = "Main",
	Side = "Left",
})

--==========================================================================--
--  COMPOSANTS
--==========================================================================--

-- TOGGLE — garde une référence, pas besoin de Flag
local EnableAimbot = Section:Toggle({
	Name = "Enable Aimbot",
	Value = false,

	Callback = function(Value)
		print("Enabled:", Value)
	end,
})

-- SLIDER — Value = valeur initiale, Increment = pas
local FOV = Section:Slider({
	Name = "FOV",
	Value = 90,
	Min = 0,
	Max = 180,
	Increment = 1,

	Callback = function(Value)
		print("FOV:", Value)
	end,
})

-- DROPDOWN — Options (Content marche aussi), Value = option sélectionnée
local Mode = Section:Dropdown({
	Name = "Mode",
	Options = {
		"Default",
		"Silent",
		"Aggressive",
	},
	Value = "Default",

	Callback = function(Value)
		print("Mode:", Value)
	end,
})

-- MULTIBOX — dropdown multi-sélection (table en retour)
local Targets = Section:MultiBox({
	Name = "Targets",
	Options = { "Head", "Torso", "Arms" },
	Value = {},

	Callback = function(Values)
		print("Targets:", table.concat(Values, ", "))
	end,
})

-- INPUT (zone de texte)
local Notes = Section:Input({
	Name = "Notes",
	Value = "",
	Placeholder = "Type something…",

	Callback = function(Value)
		print("Notes:", Value)
	end,
})

-- BUTTON — Confirmation = true → double clic pour confirmer
Section:Button({
	Name = "Print state",
	Callback = function()
		print(
			"Aimbot:", EnableAimbot:Get(),
			"| FOV:", FOV:Get(),
			"| Mode:", Mode:Get()
		)
	end,
})

-- LABEL — rangée simple, peut héberger Keybind/Colorpicker à droite
Section:Label({ Text = "Menu color" }):Colorpicker({
	Color = Library.Theme.Accent,

	Callback = function(Color)
		Library:SetColor("Accent", Color) -- thème mis à jour en direct
	end,
})

--==========================================================================--
--  LISTE (avec images — ajouts dynamiques)
--==========================================================================--

local ListSection = Controls:Section({
	Name = "Players",
	Side = "Right",
})

local PlayerList = ListSection:List({
	Name = "Players",
	Size = 200,

	Callback = function(Selected)
		print("Selected player:", Selected)
	end,
})

local function AddPlayer(Player)
	local Thumbnail = Players:GetUserThumbnailAsync(
		Player.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)

	-- Add accepte une table {Name, Image, Color} ou (Name, {Image = ...})
	PlayerList:Add({
		Name = Player.Name,
		Image = Thumbnail,
	})
end

for _, Player in Players:GetPlayers() do
	AddPlayer(Player)
end

--==========================================================================--
--  ÉVÉNEMENTS — Library:On (déconnexion propre possible)
--==========================================================================--

local PlayerAdded = Library:On(Players.PlayerAdded, function(Player)
	print("Player joined:", Player.Name)
	AddPlayer(Player)
end)

Library:On(Players.PlayerRemoving, function(Player)
	print("Player left:", Player.Name)
	PlayerList:Remove(Player.Name)
end)

-- PlayerAdded:Disconnect() -- pour couper manuellement

--==========================================================================--
--  ACTIONS DIVERSES
--==========================================================================--

local ActionsSection = Settings:Section({
	Name = "Actions",
	Side = "Left",
	Fill = true,
})

ActionsSection:Button({
	Name = "Hide FOV slider",
	Callback = function()
		FOV:SetVisible(not FOV.Visible)
	end,
})

ActionsSection:Button({
	Name = "Lock aimbot toggle",
	Callback = function()
		local Locked = EnableAimbot.Enabled
		EnableAimbot:SetEnabled(not Locked)
	end,
})

ActionsSection:Button({
	Name = "Disable all",
	Callback = Library.Disable,
})

ActionsSection:Button({
	Name = "Unload",
	Callback = Library.Unload,
})

--==========================================================================--
--  NOTIFICATIONS
--==========================================================================--

Library:Notify({
	Title = "Welcome",
	Text = "Press Insert to toggle the menu",
	Type = "Success",
	Duration = 3,
})
