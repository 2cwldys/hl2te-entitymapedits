include("shared.lua")

-- Workshop ID of required addon
local REQUIRED_ADDON_ID = "3389859848"
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3389859848
--   Map Entity Adder + [Base]

-- Function to check if the addon is installed and mounted
local function IsWorkshopAddonInstalled(wsid)
	for _, addon in ipairs(engine.GetAddons()) do
		if tostring(addon.wsid) == tostring(wsid) then
			return addon.mounted
		end
	end
	return false
end

-- Cleanup function that only checks the current map
function ExcludeForbiddenEntEdits()
	if not SERVER then return end
	if not customEntityMaps then return end

	local currentMap = game.GetMap() -- gets the current map name
	local fileName = "mapentities_" .. currentMap .. ".txt"

	-- Remove the file if this map is not in the maps table
	if not customEntityMaps[currentMap] and file.Exists(fileName, "DATA") then
		file.Delete(fileName)
		print("[MapEntities] Removed " .. fileName .. " (current map not in maps table)")
	end
end

if SERVER or CLIENT then
	if not IsWorkshopAddonInstalled(REQUIRED_ADDON_ID) then return end

	local placeholder = "insert custom entity string here"

	-- Store them in a GLOBAL table so we can iterate easily
	customEntityMaps = {
		gm_nestor = gm_nestor,
		gm_quarantine = gm_quarantine,
		gm_hazard = gm_hazard,
		gm_barren = gm_barren,
		gm_bridges = gm_bridges,
		ow_breach_final = ow_breach_final,
		ow_citadel = ow_citadel,
		owc_traverse_clean = owc_traverse_clean,
		placeholder = placeholder
	}

	-- Keep a list of valid filenames for cleanup
	local validFiles = {}

	-- Main write logic
	for mapName, content in pairs(customEntityMaps) do
		local fileName = "mapentities_" .. mapName .. ".txt"
		validFiles[fileName] = true

		if file.Exists(fileName, "DATA") then
			local existing = file.Read(fileName, "DATA")

			-- Only overwrite if content differs
			if existing ~= content then
				file.Write(fileName, content)
				print("[MapEntities] Updated " .. fileName .. " (content changed)")
			else
				print("[MapEntities] No change in " .. fileName)
			end
		else
			-- File doesn’t exist — create it
			file.Write(fileName, content)
			print("[MapEntities] Created new " .. fileName)
		end
	end
	ExcludeForbiddenEntEdits()
end