include("shared.lua")

-- Allows support for unofficial maptypes, such as rp_city(s), dm_ maps, etc, etc

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

if SERVER or CLIENT then
	if not IsWorkshopAddonInstalled(REQUIRED_ADDON_ID) then return end

	-- Define your map entity data here
	local gm_flatgrass = "entities for flatgrass goes here"
	local gm_construct = "entities for construct goes here"
	local gm_bigcity = "entities for bigcity goes here"

	local example = [[
	example
	example
	example
	]]

	-- Store them in a table so we can iterate easily
	local maps = {
		gm_flatgrass = gm_flatgrass,
		gm_construct = gm_construct,
		gm_bigcity = gm_bigcity,
		example = example
	}

	-- Main write logic
	for mapName, content in pairs(maps) do
		local fileName = "mapentities_" .. mapName .. ".txt"

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
end