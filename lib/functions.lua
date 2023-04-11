--[[non utilisé]]--GetOn = function(on) if on then return "on" else return "off" end end
--[[non utilisé]]--InSession = function() return util.is_session_started() and not util.is_session_transition_active() end
--[[non utilisé]]--GetPathVal = function(path) return menu.get_value(menu.ref_by_path(path)) end
SetPathVal = function(path,state) local path_ref = menu.ref_by_path(path) if menu.is_ref_valid(path_ref) then menu.set_value(path_ref,state) end end
--[[non utilisé]]--ClickPath = function(path) local path_ref = menu.ref_by_path(path) if menu.is_ref_valid(path_ref) then menu.trigger_command(path_ref) end end
--[[non utilisé]]--Notify = function(str) if notifications_enabled or update_available then if notifications_mode == 2 then util.show_corner_help("~p~NyScript~s~~n~"..str ) else util.toast("[= NyScript =]"..str) end end end
local function BitTest(bits, place)
    return (bits & (1 << place)) ~= 0
end

local self = {}
---@alias HudColour integer
HudColour =
{
	pureWhite = 0,
	white = 1,
	black = 2,
	grey = 3,
	greyLight = 4,
	greyDrak = 5,
	red = 6,
	redLight = 7,
	redDark = 8,
	blue = 9,
	blueLight = 10,
	blueDark = 11,
	yellow = 12,
	yellowLight = 13,
	yellowDark = 14,
	orange = 15,
	orangeLight = 16,
	orangeDark = 17,
	green = 18,
	greenLight = 19,
	greenDark = 20,
	purple = 21,
	purpleLight = 22,
	purpleDark = 23,
	radarHealth = 25,
	radarArmour = 26,
	friendly = 118,
}
--[[
	~r~ rouge
	~b~ bleu
	--~x~ bleu clair
	~g~ vert
	--~t~ vert clair
	~y~ jaune
	~p~ purple
	~q~ pink
	~o~ orange
	~c~ gris
	~m~ gris foncé
	~u~ noir
	~w~ white
	~s~ default white
	~n~ new line
	~h~ gras
	~italic~ italic
	¦ Rockstar Verified Icon
	÷ Rockstar Icon
	∑ = Rockstar Icon 2
]]
--------------------------
-- NOTIFICATION
--------------------------
local sound_notif = {}
util.create_tick_handler(function()
	::start::
	for key, value in pairs(sound_notif) do
		if value + 120 < util.current_unix_time_seconds() then
			sound_notif.key = nil
		end
	end
	util.yield(120000)
	goto start
end)
---@class Notification
notification = {
	txdDict = "NyTextures",
	txdName = "nylogo",
	title = SCRIPT_NAME,
	subtitle = "~c~" .. util.get_label_text("PM_PANE_FEE") .. "~s~",
	defaultColour = HudColour.black
}

---@param msg string
function notification.stand(msg, ...)
	assert(type(msg) == "string", "msg must be a string, got " .. type(msg))
	msg = string.format(msg, ...)
	msg = msg:gsub('~[%w_]-~', ""):gsub('<C>(.-)</C>', '%1')
	util.toast("["..SCRIPT_NAME.."] " .. msg)
	local time
	local current_time = util.current_unix_time_seconds()
	if sound_notif[msg] then
		time = sound_notif[msg] + 60
	else
		time = 0
	end
	if time < current_time then
		sound_notif[msg] = current_time
		AUDIO.PLAY_SOUND(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", false, 0, false)
	end
end

---@param msg string
function notification.draw_debug_text(msg, ...)
	assert(type(msg) == "string", "msg must be a string, got " .. type(msg))
	msg = string.format(msg, ...)
	msg = msg:gsub('~[%w_]-~', ""):gsub('<C>(.-)</C>', '%1')
	util.draw_debug_text(msg)
end

---@param format string
---@param colour? HudColour
function notification:help(format, colour, ...)
	assert(type(format) == "string", "msg must be a string, got " .. type(format))

	local msg = string.format(format, ...)
	--if Config.general.standnotifications then
	--	return self.stand(msg)
	--end

	HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(colour or self.defaultColour)
	util.BEGIN_TEXT_COMMAND_THEFEED_POST("~BLIP_INFO_ICON~ " .. msg)
	HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER_WITH_TOKENS(true, true)
end


---@param format string
---@param colour? HudColour
function notification:normal(format, colour, ...)
	assert(type(format) == "string", "msg must be a string, got " .. type(format))

	local msg = string.format(format, ...)
	--if Config.general.standnotifications then
	--	return self.stand(msg)
	--end

	HUD.THEFEED_SET_BACKGROUND_COLOR_FOR_NEXT_POST(colour or self.defaultColour)
	util.BEGIN_TEXT_COMMAND_THEFEED_POST(msg)
	HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT(self.txdDict, self.txdName, true, 4, self.title, self.subtitle)
	HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, false)
end
--------------------------
-- FIN NOTIFICATION
--------------------------
local orgLog = util.log

---@param format string
---@param ... any
util.log = function(format, ...)
	local strg = type(format) ~= "string" and tostring(format) or format:format(...)
	orgLog("["..SCRIPT_NAME.."] " .. strg)
end

function draw_debug_text(...)
	local arg = {...}
	local strg = ""
	for _, w in ipairs(arg) do
		strg = strg .. tostring(w) .. '\n'
	end
	local colour = {r = 1.0, g = 0.0, b = 0.0, a = 1.0}
	directx.draw_text(0.05, 0.05, strg, ALIGN_TOP_LEFT, 1.0, colour, false)
end

--------------------------
-- FIN AFFICHAGE
--------------------------

--weapon function
local all_weapons = {}
local temp_weapons = util.get_weapons()
for a,b in pairs(temp_weapons) do
    all_weapons[#all_weapons + 1] = {hash = b['hash'], label_key = b['label_key']}
end
function WeaponFromHash(hash)
    for k, v in pairs(all_weapons) do
        if v.hash == hash then
            return util.get_label_text(v.label_key)
        end
    end
    return 'Unarmed'
end

--vehicle function
local all_vehicles = {}
local temp_vehicles = util.get_vehicles()
for a,b in pairs(temp_weapons) do
    all_vehicles[#all_vehicles + 1] = {hash = b['hash'], label_key = b['label_key']}
end
--[[
function VehicleFromHash(hash)
    for k, v in pairs(all_vehicles) do
        if v.hash == hash then
            return util.get_label_text(v.label_key)
        end
    end
    return 'none'
end
]]

local anti_vehicle_menus  = {}
function BuildVehiclesList()
	for _, anti_vehicle_menu in pairs(anti_vehicle_menus) do
		if anti_vehicle_menu:isValid() then
			menu.delete(anti_vehicle_menu)
		end
	end

	Menus.anti_menu = {}
	for hash, model in Anti_vehicles_list do
		Menus.anti_menu = Menus.vehlist:list(model)
		Menus.anti_delete = Menus.anti_menu:action(Translations.protection_anti_vehicles_list_delete, {}, Translations.protection_anti_vehicles_list_delete_desc, function()
			Anti_vehicles_list[hash] = nil
			BuildVehiclesList()
		end)
		table.insert(anti_vehicle_menus, Menus.anti_menu)
	end
end


--------------------------
-- ENTITIES
--------------------------

function SetBit(bits, place)
	return (bits | (1 << place))
end

function ClearBit(bits, place)
	return (bits & ~(1 << place))
end

function BitTest(bits, place)
	return (bits & (1 << place)) ~= 0
end

--------------------------
-- REQUEST CONTROL
--------------------------
--non utilisé
	--timer
	---@class Timer
	---@field elapsed fun(): integer
	---@field reset fun()
	---@field isEnabled fun(): boolean
	---@field disable fun()

	---@return Timer
	local function NewTimer()
		self.start = util.current_time_millis()
		self.m_enabled = false

		local function reset()
			self.start = util.current_time_millis()
			self.m_enabled = true
		end

		local function elapsed()
			return util.current_time_millis() - self.start
		end

		local function disable() self.m_enabled = false end
		local function isEnabled() return self.m_enabled end

		return
		{
			isEnabled = isEnabled,
			reset = reset,
			elapsed = elapsed,
			disable = disable,
		}
	end


	---@param entity Entity
	---@return boolean
	local function RequestControlOnce(entity)
		if not NETWORK.NETWORK_IS_IN_SESSION() then
			return true
		end
		local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
		return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
	end


	---@param entity Entity
	---@param timeOut? integer #time in `ms` trying to get control
	---@return boolean
	function RequestControl(entity, timeOut)
		if not ENTITY.DOES_ENTITY_EXIST(entity) then
			return false
		end
		timeOut = timeOut or 500
		local start = NewTimer()
		while not RequestControlOnce(entity) and start.elapsed() < timeOut do
			util.yield_once()
		end
		return start.elapsed() < timeOut
	end
--------------------------
-- FIN REQUEST CONTROL
--------------------------

function RequestControlLoop(entity)
	local tick = 0
	while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and tick < 25 do
		util.yield()
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
		tick = tick + 1
	end
	if NETWORK.NETWORK_IS_SESSION_STARTED() then
		local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
	end
end


---@param start v3
---@param to v3
---@param colour Colour
local draw_line = function (start, to, colour)
	GRAPHICS.DRAW_LINE(start.x, start.y, start.z, to.x, to.y, to.z, colour.r, colour.g, colour.b, colour.a)
end

---@param pos0 v3
---@param pos1 v3
---@param pos2 v3
---@param pos3 v3
---@param colour Colour
local draw_rect = function (pos0, pos1, pos2, pos3, colour)
	GRAPHICS.DRAW_POLY(pos0.x, pos0.y, pos0.z, pos1.x, pos1.y, pos1.z, pos3.x, pos3.y, pos3.z, colour.r, colour.g, colour.b, colour.a)
	GRAPHICS.DRAW_POLY(pos3.x, pos3.y, pos3.z, pos2.x, pos2.y, pos2.z, pos0.x, pos0.y, pos0.z, colour.r, colour.g, colour.b, colour.a)
end

---@param entity Entity
---@param showPoly? boolean
---@param colour? Colour	
function DrawBoundingBox(entity, showPoly, colour)
	if not ENTITY.DOES_ENTITY_EXIST(entity) then
		return
	end
	colour = colour or {r = 255, g = 0, b = 0, a = 255}
	local min = v3.new()
	local max = v3.new()
	MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(entity), min, max)
	min:abs(); max:abs()

	local upperLeftRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, -max.y, max.z)
	local upperRightRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, -max.y, max.z)
	local lowerLeftRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, -max.y, -min.z)
	local lowerRightRear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, -max.y, -min.z)

	draw_line(upperLeftRear, upperRightRear, colour)
	draw_line(lowerLeftRear, lowerRightRear, colour)
	draw_line(upperLeftRear, lowerLeftRear, colour)
	draw_line(upperRightRear, lowerRightRear, colour)

	local upperLeftFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, min.y, max.z)
	local upperRightFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, min.y, max.z)
	local lowerLeftFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, -max.x, min.y, -min.z)
	local lowerRightFront = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, min.x, min.y, -min.z)

	draw_line(upperLeftFront, upperRightFront, colour)
	draw_line(lowerLeftFront, lowerRightFront, colour)
	draw_line(upperLeftFront, lowerLeftFront, colour)
	draw_line(upperRightFront, lowerRightFront, colour)

	draw_line(upperLeftRear, upperLeftFront, colour)
	draw_line(upperRightRear, upperRightFront, colour)
	draw_line(lowerLeftRear, lowerLeftFront, colour)
	draw_line(lowerRightRear, lowerRightFront, colour)

	if type(showPoly) ~= "boolean" or showPoly then
		draw_rect(lowerLeftRear, upperLeftRear, lowerLeftFront, upperLeftFront, colour)
		draw_rect(upperRightRear, lowerRightRear, upperRightFront, lowerRightFront, colour)

		draw_rect(lowerLeftFront, upperLeftFront, lowerRightFront, upperRightFront, colour)
		draw_rect(upperLeftRear, lowerLeftRear, upperRightRear, lowerRightRear, colour)

		draw_rect(upperRightRear, upperRightFront, upperLeftRear, upperLeftFront, colour)
		draw_rect(lowerRightFront, lowerRightRear, lowerLeftFront, lowerLeftRear, colour)
	end
end

--------------------------
-- PLAYER
--------------------------

--[[non utilisé
function GetEntityOwner(entity)
	local pEntity = entities.handle_to_pointer(entity)
	local addr = memory.read_long(pEntity + 0xD0)
	return (addr ~= 0) and memory.read_byte(addr + 0x49) or -1
end]]

---@param player Player
---@return boolean
function IsPlayerFriend(player)
	local pHandle = memory.alloc(104)
	NETWORK.NETWORK_HANDLE_FROM_PLAYER(player, pHandle, 13)
	local isFriend = NETWORK.NETWORK_IS_HANDLE_VALID(pHandle, 13) and NETWORK.NETWORK_IS_FRIEND(pHandle)
	return isFriend
end
--[[
---@param player Player
---@return Vehicle
function get_vehicle_player_is_in(player)
	local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player)
	if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
		return PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
	end
	return 0
end

---@param player Player
---@return Entity
function get_entity_player_is_aiming_at(player)
	if not PLAYER.IS_PLAYER_FREE_AIMING(player) then
		return NULL
	end
	local entity, pEntity = NULL, memory.alloc_int()
	if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, pEntity) then
		entity = memory.read_int(pEntity)
	end
	if entity ~= NULL and ENTITY.IS_ENTITY_A_PED(entity) and PED.IS_PED_IN_ANY_VEHICLE(entity, false) then
		entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
	end
	return entity
end

---@param player Player
---@return boolean
function is_player_passive(player)
	if player ~= players.user() then
		local address = memory.script_global(1894573 + (player * 608 + 1) + 8)
		if address ~= NULL then return memory.read_byte(address) == 1 end
	else
		local address = memory.script_global(1574582)
		if address ~= NULL then return memory.read_int(address) == 1 end
	end
	return false
end
]]

function IsPlayerUsingOrbitalCannon(player)
    return BitTest(memory.read_int(memory.script_global((2657589 + (player * 466 + 1) + 427))), 0) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_427), 0
end

function IsPlayerFlyingAnyDrone(player)
   return BitTest(memory.read_int(memory.script_global(1853910 + (player * 862 + 1) + 267 + 365)), 26) -- Global_1853910[PLAYER::PLAYER_ID() /*862*/].f_267.f_365, 26
end

function GetDroneType(player)
	return memory.read_int(memory.script_global(1914091 + (player * 297 + 1) + 97))
end

function GetPlayerDroneObject(player)
	return memory.read_int(memory.script_global(1914091 + (players.user() * 297 + 1) + 64 + (player + 1)))
end

function IsPlayerUsingGuidedMissile(player)
    return (memory.read_int(memory.script_global(2657589 + 1 + (player * 466) + 321 + 10)) ~= -1 and IsPlayerFlyingAnyDrone(player)) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_321.f_10 
end

function IsPlayerInRcPersonalVehicle(player)
		return BitTest(memory.read_int(memory.script_global(1853910 + (player * 862 + 1) + 267 + 428 + 3)), 6)
end

function IsPlayerInRcBandito(player)
    return BitTest(memory.read_int(memory.script_global(1853910 + (player * 834 + 1) + 267 + 348)), 29)  -- Global_1853910[PLAYER::PLAYER_ID() /*834*/].f_267.f_348, 29
end

function IsPlayerInRcTank(player)
    return BitTest(memory.read_int(memory.script_global(1853910 + (player * 834 + 1) + 267 + 428 + 2)), 16) -- Global_1853910[PLAYER::PLAYER_ID() /*862*/].f_267.f_428.f_2
end

function GetSpawnState(pid)
    return memory.read_int(memory.script_global(((2657589 + 1) + (pid * 466)) + 232)) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_232
end

function IsPlayerInInterior(pid)
    return memory.read_int(memory.script_global(((2657589 + 1) + (pid * 466)) + 245)) -- Global_2657589[bVar0 /*466*/].f_245)
end

function IsPlayerInKosatka(player)
    return BitTest(memory.read_int(memory.script_global(1853910 + (player * 862 + 1 ) + 267 + 479)), 2) -- Global_1853910[PLAYER::PLAYER_ID() /*862*/].f_267.f_479, 2
end

---@param player Player
---@return boolean
function IsPlayerInAnyRcVehicle(player)
	if is_player_in_rc_bandito(player) then
		return true
	end

	if is_player_in_rc_tank(player) then
		return true
	end

	if is_player_in_rc_personal_vehicle(player) then
		return true
	end

	return false
end

---@diagnostic disable: exp-in-action, unknown-symbol, action-after-return, undefined-global
---@param colour integer
---@return integer
local function get_hud_colour_from_org_colour(colour)
	switch colour do
		case 0:
			return 192
		case 1:
			return 193
		case 2:
			return 194
		case 3:
			return 195
		case 4:
			return 196
		case 5:
			return 197
		case 6:
			return 198
		case 7:
			return 199
		case 8:
			return 200
		case 9:
			return 201
		case 10:
			return 202
		case 11:
			return 203
		case 12:
			return 204
		case 13:
			return 205
		case 14:
			return 206
	end
	return 1
end


---@diagnostic enable: exp-in-action, unknown-symbol, action-after-return, undefined-global
---@param player Player
---@return integer
local function get_player_org_blip_colour(player)
	if players.get_boss(player) ~= -1 then
		local hudColour = get_hud_colour_from_org_colour(players.get_org_colour(player))
		local rgba = get_hud_colour(hudColour)
		return (rgba.r << 24) + (rgba.g << 16) + (rgba.b << 8) + rgba.a
	end
	return 0
end


---@param player Player
---@return string
function GetCondensedPlayerName(player)
	local condensed = "<C>" .. PLAYER.GET_PLAYER_NAME(player) .. "</C>"

	if players.get_boss(player) ~= -1  then
		local colour = players.get_org_colour(player)
		local hudColour = get_hud_colour_from_org_colour(colour)
		return string.format("~HC_%d~%s~s~", hudColour, condensed)
	end

	return condensed
end


---@param player Player
---@param isPlaying boolean
---@param inTransition boolean
---@return boolean
function IsPlayerActive(player, isPlaying, inTransition)
	if player == -1 or not NETWORK.NETWORK_IS_PLAYER_ACTIVE(player) then
		return false
	end
	if isPlaying and not PLAYER.IS_PLAYER_PLAYING(player) then
		return false
	end
	if inTransition and Read_global.int(2657589 + (player * 466 + 1)) ~= 4 then
		return false
	end
	return true
end




--------------------------
-- MEMORY
--------------------------

Write_global = {
	byte = function(global, value)
		local address = memory.script_global(global)
		memory.write_byte(address, value)
	end,
	int = function(global, value)
		local address = memory.script_global(global)
		memory.write_int(address, value)
	end,
	float = function(global, value)
		local address = memory.script_global(global)
		memory.write_float(address, value)
	end
}

Read_global = {
	byte = function(global)
		local address = memory.script_global(global)
		return memory.read_byte(address)
	end,
	int = function(global)
		local address = memory.script_global(global)
		return memory.read_int(address)
	end,
	float = function(global)
		local address = memory.script_global(global)
		return memory.read_float(address)
	end,
	string = function(global)
		local address = memory.script_global(global)
		return memory.read_string(address)
	end
}