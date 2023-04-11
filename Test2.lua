util.keep_running()--ceci fait que le script ne s'arrête pas après avoir fait son travail
local scriptStartTime = util.current_time_millis()
local SCRIPT_VERSION = "0.1"
local Tree_V = 43

--[[
--===============--
-- Auto-Updater Lib Install
--===============--
    -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
    local status, auto_updater = pcall(require, "auto-updater")
    if not status then
        local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
        async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
                function(result, headers, status_code)
                    local function parse_auto_update_result(result, headers, status_code)
                        local error_prefix = "Error downloading auto-updater: "
                        if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                        if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                        filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                        local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                        if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                        file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
                    end
                    auto_update_complete = parse_auto_update_result(result, headers, status_code)
                end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
        async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
        if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
        auto_updater = require("auto-updater")
    end
    if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

    --- Config
    local languages = {
        'french',
        'english',
    }

    --- Auto-Update
    local auto_update_config = {
        source_url="https://raw.githubusercontent.com/NyCreamZ/"..SCRIPT_NAME.."/main/"..SCRIPT_NAME..".lua",
        script_relpath=SCRIPT_RELPATH,
        --silent_updates=true,
        dependencies={
            {
                name="functions",
                source_url="https://raw.githubusercontent.com/NyCreamZ/"..SCRIPT_NAME.."/main/lib/"..SCRIPT_NAME.."/functions.lua",
                script_relpath="lib/"..SCRIPT_NAME.."/functions.lua",
            },
            {
                name="weapons",
                source_url="https://raw.githubusercontent.com/NyCreamZ/"..SCRIPT_NAME.."/main/lib/"..SCRIPT_NAME.."/weapons.lua",
                script_relpath="lib/"..SCRIPT_NAME.."/weapons.lua",
            },
            {
                name="vehicles",
                source_url="https://raw.githubusercontent.com/NyCreamZ/"..SCRIPT_NAME.."/main/lib/"..SCRIPT_NAME.."/vehicles.lua",
                script_relpath="lib/"..SCRIPT_NAME.."/vehicles.lua",
            },
        }
    }

    for _, language in pairs(languages) do
        local language_config = {
            name=language,
            source_url="https://raw.githubusercontent.com/NyCreamZ/"..SCRIPT_NAME.."/main/lib/"..SCRIPT_NAME.."/Languages/"..language..".lua",
            script_relpath="lib/"..SCRIPT_NAME.."/Languages/"..language..".lua",
        }
        table.insert(auto_update_config.dependencies, language_config)
    end

    auto_updater.run_auto_update(auto_update_config)
--===============--
-- FIN Auto-Updater Lib Install
--===============--
]]
--===============--
-- Fichier
--===============--
    local required <const> = {
    	"lib/natives-1663599433.lua",
    	"lib/"..SCRIPT_NAME.."/functions.lua",
    	"lib/"..SCRIPT_NAME.."/vehicles.lua",
    	"lib/"..SCRIPT_NAME.."/weapons.lua",
    }
    local scriptdir <const> = filesystem.scripts_dir()
    local libDir <const> = scriptdir .. "\\lib\\"..SCRIPT_NAME.."\\"
    local languagesDir <const> = libDir .. "\\Languages\\"
    local relative_languagesDir <const> = "./lib/"..SCRIPT_NAME.."/Languages/"

    for _, file in ipairs(required) do
    	assert(filesystem.exists(scriptdir .. file), "required file not found: " .. file)
    end

    require "Test2.functions"
    require "Test2.vehicles"
    require "Test2.weapons"
    local Json = require("json")
    --util.require_natives("natives-1672190175-uno")
    util.ensure_package_is_installed('lua/natives-1663599433')
    util.require_natives(1663599433)
    --util.require_natives(1640181023)

    if not filesystem.exists(libDir) then
    	filesystem.mkdir(libDir)
    end

    if not filesystem.exists(languagesDir) then
    	filesystem.mkdir(languagesDir)
    end
    
    if filesystem.exists(filesystem.resources_dir() .. "NyTextures.ytd") then
        util.register_file(filesystem.resources_dir() .. "NyTextures.ytd")
        notification.txdDict = "NyTextures"
        notification.txdName = "nylogo"
        util.spoof_script("main_persistent", function()
            GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT("NyTextures", false)
        end)
    else
        error("required file not found: NyTextures.ytd" )
    end
--===============--
-- FIN Fichier
--===============--
--===============--
-- Translation
--===============--
    -- credit http://lua-users.org/wiki/StringRecipes
    local function ends_with(str, ending)
        return ending == "" or str:sub(-#ending) == ending
    end

    Translations = {}
    setmetatable(Translations, {
        __index = function(self, key)
            return key
        end
    })

    local languageDir_files = {}
    local just_language_files = {}
    for i, path in ipairs(filesystem.list_files(languagesDir)) do
        local file_str = path:gsub(languagesDir, '')
        languageDir_files[#languageDir_files + 1] = file_str
        if ends_with(file_str, '.lua') then
            just_language_files[#just_language_files + 1] = file_str
        end
    end

    -- do not play with this unless you want shit breakin!
    local need_default_language

    if not table.contains(languageDir_files, 'english.lua') then
        need_default_language = true
        async_http.init('raw.githubusercontent.com', 'NyCreamZ/'..SCRIPT_NAME..'/main/lib/'..SCRIPT_NAME..'/Languages/english.lua', function(data)
            local file = io.open(translations_dir .. "/english.lua",'w')
            file:write(data)
            file:close()
            need_default_language = false
        end, function()
            util.toast('!!! Failed to retrieve default translation table. All options that would be translated will look weird. Please check your connection to GitHub.')
        end)
        async_http.dispatch()
    else
        need_default_language = false
    end

    while need_default_language do
        util.toast("Looks like there was an update! Installing default/english translation now.")
        util.yield()
    end

    local selected_lang_path = languagesDir .. 'selected_language.txt'
    if not table.contains(languageDir_files, 'selected_language.txt') then
        local file = io.open(selected_lang_path, 'w')
        file:write('english.lua')
        file:close()
    end

    -- read selected language 
    local selected_lang_file = io.open(selected_lang_path, 'r')
    local selected_language = selected_lang_file:read()
    if not table.contains(languageDir_files, selected_language) then
        notification.stand(selected_language .. ' was not found. Defaulting to English.')
        Translations = require(relative_languagesDir .. "english")
    else
        Translations = require(relative_languagesDir .. '\\' .. selected_language:gsub('.lua', ''))
    end

--===============--
-- COMPTEUR D'UTilisation
--===============--
-- BEGIN ANONYMOUS USAGE TRACKING 
async_http.init('pastebin.com', '89Js2RDM', function() end)
async_http.dispatch()
-- END ANONYMOUS USAGE TRACKING 

--===============--
-- Local
--===============--

    local interior_stuff = {0, 233985, 169473, 169729, 169985, 170241, 177665, 177409, 185089, 184833, 184577, 163585, 167425, 167169}
    local Commands = menu.trigger_commands
    local StandEdition = menu.get_edition()
    local lua_path = "Stand>Lua Scripts>"..string.gsub(string.gsub(SCRIPT_RELPATH,".lua",""),"\\",">")
        --lua_path..">"..Translations.self_root..">"..Translations.self_cleanloop,

    -------------
    -- JOIN
    -------------
        --Language JOIN
            --local lang = {'en-US','fr-FR','de-DE','it-IT','es-ES','pt-BR','pl-PL','ru-RU','ko-KR','zh-TW','ja-JP','es-MX','zh-CN'}
            local nation_lang2 = {"EN", "FR", "DE", "IT", "ES", "BR", "PL", "RU", "KR", "TW", "JP", "MX", "CN"}
            local nation_lang = {Translations.nation_us, Translations.nation_fr, Translations.nation_de, Translations.nation_it, Translations.nation_es, Translations.nation_br, Translations.nation_pl, Translations.nation_ru, Translations.nation_kr, Translations.nation_tw, Translations.nation_jp, Translations.nation_mx, Translations.nation_cn}
            local nation_notify = false
            local nation_save = false
            local nation_select = 1
    -------------
    -- SELF
    -------------
        --GOD
            local self_list = {
                god = {
                    "Self>Immortality",
                    "Self>Auto Heal",
                    "Self>Gracefulness",
                    "Self>Glued To Seats",
                    "Self>Lock Wanted Level",
                    "Self>Infinite Stamina",
                    "Self>Appearance>No Blood",
                },
            }

            local self_value = {god = {}, ghost = {}}

    -------------
    -- WEAPON
    -------------
        ---AIMBOT SILENCIEUX
            local aimbot = {targetplayers = true, targetfriends = false, targetinterior = false, targetgodmode = false, targetnpcs = false, targetvehs = true, targettw = false,
                damage = 100, owner = players.user_ped(), bone = 1, mode = 1, usefov = false, fov = 3, esp = 2, box = 2, marker = 2, alert = true,
                esprgb = {r = 1, g = 0.0, b = 0.0, a = 1.0}, boxrgb = {r = 1, g = 0.0, b = 0.0, a = 1.0}, markerrgb = {r = 1, g = 0.0, b = 0.0, a = 1.0}
            }

            local bones = {
                [1] = {name = "Aléatoire", bone = 0, x1 = 0, y1 = 0, z1 = 0, x2 = 0, y2 = 0, z2 = 0},
                [2] = {name = "Head", bone = 27474, x1 = 0.25, y1 = 0.04, z1 = 0, x2 = 0, y2 = 0.04, z2 = 0},
                [3] = {name = "Chest", bone = 24818, x1 = 0, y1 = 0.25, z1 = 0, x2 = 0, y2 = 0, z2 = 0},
                [4] = {name = "Pelvis", bone = 11816, x1 = 0.01, y1 = 0, z1 = 0, x2 = -0.01, y2 = 0, z2 = 0},
                [5] = {name = "Left Foot", bone = 14201, x1 = 0.01, y1 = 0, z1 = 0, x2 = -0.01, y2 = 0, z2 = 0},
                [6] = {name = "Right Foot", bone = 52301, x1 = 0.01, y1 = 0, z1 = 0, x2 = -0.01, y2 = 0, z2 = 0}
            }

            local function GetAimbotTarget()
                local dist = 1000000000
                -- an aimbot should have immaculate response time so we shouldnt rely on the other entity pools for this data
                for k,v in pairs(entities.get_all_peds_as_handles()) do
                    local target_this = true
                    local player_pos = players.get_position(players.user())
                    local ped_pos = ENTITY.GET_ENTITY_COORDS(v, true)
                    local this_dist = MISC.GET_DISTANCE_BETWEEN_COORDS(player_pos['x'], player_pos['y'], player_pos['z'], ped_pos['x'], ped_pos['y'], ped_pos['z'], true)
                    if players.user_ped() ~= v and not ENTITY.IS_ENTITY_DEAD(v) then
                        if not aimbot.targetplayers then
                            if PED.IS_PED_A_PLAYER(v) then
                                target_this = false
                            end
                        end
                        if not aimbot.targetnpcs then
                            if not PED.IS_PED_A_PLAYER(v) then
                                target_this = false
                            end
                        end
                        if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), v, 17) and not aimbot.targettw then
                            target_this = false
                        end
                        if aimbot.usefov then
                            if not PED.IS_PED_FACING_PED(players.user_ped(), v, aimbot.fov) then
                                target_this = false
                            end
                        end
                        if aimbot.targetvehs then
                            if PED.IS_PED_IN_ANY_VEHICLE(v, true) then
                                target_this = false
                            end
                        end
                        if aimbot.targetgodmode then
                            if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(v) then
                                target_this = false
                            end
                        end
                        if not aimbot.targetfriends --[[and aimbot.targetplayers]] then
                            if PED.IS_PED_A_PLAYER(v) then
                                local pid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(v)
                                local hdl = PidToHandle(pid)
                                if NETWORK.NETWORK_IS_FRIEND(hdl) then
                                    target_this = false
                                end
                            end
                        end
                        if aimbot_mode == "closest" then
                            if this_dist <= dist then
                                if target_this then
                                    dist = this_dist
                                    aimbot_target = v
                                end
                            end
                        end
                    end
                end
                return aimbot_target
            end


            local function GetAimbotTargetV2()
                local dist = 1000000000
                local dist_screen_ped = 1
                local aimbot_target = 0
                for i, ped in entities.get_all_peds_as_handles() do
                    if players.user_ped() ~= ped and not PED.IS_PED_DEAD_OR_DYING(ped, 1) and ENTITY.DOES_ENTITY_EXIST(ped)  then
                        local target_this = true
                        local pid
                        local player_pos
                        local ped_pos
                        local this_dist
                        local screenX
                        local screenY
                        local visible
                        local dist_screen

                        if PED.IS_PED_A_PLAYER(ped) and not aimbot.targetplayers then
                            target_this = false
                            goto next
                        end

                        pid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)
                        if PED.IS_PED_A_PLAYER(ped) and not aimbot.targetfriends --[[and aimbot.targetplayers]] then
                            if IsPlayerFriend(pid) then
                                target_this = false
                                goto next
                            end
                        end

                        if PED.IS_PED_A_PLAYER(ped) and not aimbot.targetinterior then
                            if players.is_in_interior(pid) then
                                target_this = false
                                goto next
                            end
                        end

                        if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(ped) and not aimbot.targetgodmode then
                            target_this = false
                            goto next
                        end

                        if not PED.IS_PED_A_PLAYER(ped) and not aimbot.targetnpcs then
                            target_this = false
                            goto next
                        end

                        if PED.IS_PED_IN_ANY_VEHICLE(ped, true) and not aimbot.targetvehs then
                            target_this = false
                            goto next
                        end

                        if not ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(players.user_ped(), ped, 17) and not aimbot.targettw then
                            target_this = false
                            goto next
                        end

                        if not PED.IS_PED_FACING_PED(players.user_ped(), ped, aimbot.fov) and aimbot.usefov then
                            target_this = false
                            goto next
                        end

                        --player_pos = players.get_position(players.user())
                        ped_pos = ENTITY.GET_ENTITY_COORDS(ped, true)
                        --[[this_dist = SYSTEM.VDIST2(player_pos.x, player_pos.y, player_pos.z, ped_pos.x, ped_pos.y, ped_pos.z)
                        if this_dist >= dist then
                            target_this = false
                            goto next
                        end]]

                        screenX = memory.alloc(4)
                        screenY = memory.alloc(4)
                        visible = GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(ped_pos.x, ped_pos.y, ped_pos.z, screenX, screenY)
                        if not visible then
                            target_this = false
                            goto next
                        end

                        dist_screen = math.sqrt(((memory.read_float(screenX) -0.5)^2) + ((memory.read_float(screenY) - 0.5)^2))
                        if not aimbot.usefov and dist_screen >= dist_screen_ped then
                            target_this = false
                            goto next
                        end

                        ::next::

                        if target_this then
                            aimbot_target = ped
                            --dist = this_dist
                            dist_screen_ped = dist_screen
                            --AimbotTarget(aimbot_target)
                        end
                    end
                end
                if aimbot_target ~= 0 then return AimbotTarget(aimbot_target) else return end
            end

            function AimbotTarget(target)
                ---POSITION
                local t_pos
                local t_pos2
                local target_pos = ENTITY.GET_ENTITY_COORDS(target)
                local random = math.random(5)+1

                local weaponped = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped(), true)
                local min, max = v3.new(), v3.new()
                MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(weaponped), min, max)
                local startLine = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(weaponped,  max.x, 0, 0.04)

                if aimbot.bone == 1 then
                    t_pos = PED.GET_PED_BONE_COORDS(target, bones[random].bone, bones[random].x1, bones[random].y1, bones[random].z1)
                    t_pos2 = PED.GET_PED_BONE_COORDS(target, bones[random].bone, bones[random].x2, bones[random].y2, bones[random].z2)
                else
                    t_pos = PED.GET_PED_BONE_COORDS(target, bones[aimbot.bone].bone, bones[aimbot.bone].x1, bones[aimbot.bone].y1, bones[aimbot.bone].z1)
                    t_pos2 = PED.GET_PED_BONE_COORDS(target, bones[aimbot.bone].bone, bones[aimbot.bone].x2, bones[aimbot.bone].y2, bones[aimbot.bone].z2)
                end

                if aimbot.mode == 2 then
                    t_pos = startLine
                end

                if aimbot.alert then
                    if PED.IS_PED_A_PLAYER(target) then
                        local pid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(target)
                        local pname = PLAYER.GET_PLAYER_NAME(pid)
                        notification.stand("Target is %s", pname)
                    end
                end

                -- 1= désactivé / 2= crosshair / 3= weapon / 4=crosshair+weapon
                if aimbot.esp == 2 or aimbot.esp == 4 then
                    local screenX = memory.alloc(4)
                    local screenY = memory.alloc(4)
                    GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(target_pos.x, target_pos.y, target_pos.z, screenX, screenY)
                    --screenX = 1 -bord droit de l'écran / screenX = 0 -bord gauche de l'écran / screenY = 1 -haut de l'écran / screenY = 0 -bas de l'écran
                    directx.draw_line(0.5, 0.5, memory.read_float(screenX), memory.read_float(screenY), aimbot.esprgb)
                end

                if aimbot.esp == 3 or aimbot.esp == 4 then
                    local color = {
                        r = math.floor(aimbot.esprgb.r * 255),
                        g = math.floor(aimbot.esprgb.g * 255),
                        b = math.floor(aimbot.esprgb.b * 255),
                        a = math.floor(aimbot.esprgb.a * 255)
                    }
                    GRAPHICS.DRAW_LINE(startLine.x, startLine.y, startLine.z, t_pos2.x, t_pos2.y, t_pos2.z, color.r, color.g, color.b, color.a)
                    GRAPHICS.DRAW_LINE(t_pos.x, t_pos.y, t_pos.z, t_pos2.x, t_pos2.y, t_pos2.z, color.g, color.r, color.b, color.a)
                end

                if aimbot.box ~= 1 then
                    local color = {
                        r = math.floor(aimbot.boxrgb.r * 255),
                        g = math.floor(aimbot.boxrgb.g * 255),
                        b = math.floor(aimbot.boxrgb.b * 255),
                        a = math.floor(aimbot.boxrgb.a * 255)
                    }
                    local tbox = false
                    if aimbot.box == 3 then tbox = true end
                    DrawBoundingBox(target, tbox, color)
                end

                if aimbot.marker ~= 1 then
                    local color = {
                        r = math.floor(aimbot.markerrgb.r * 255),
                        g = math.floor(aimbot.markerrgb.g * 255),
                        b = math.floor(aimbot.markerrgb.b * 255),
                        a = math.floor(aimbot.markerrgb.a * 255)
                    }
                    if aimbot.marker == 2 then
                        GRAPHICS.DRAW_MARKER(0, target_pos.x, target_pos.y, target_pos.z+2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 1, color.r, color.g, color.b, color.a, false, true, 2, false, 0, 0, false)
                    elseif aimbot.marker == 3 then
                        GRAPHICS.DRAW_MARKER(2, target_pos.x, target_pos.y, target_pos.z+2, 0, 0, 0, 0.0, 180, 0.0, 1, 1, 1, color.r, color.g, color.b, color.a, false, true, 2, false, 0, 0, false)
                    end
                end

                if PED.IS_PED_SHOOTING(players.user_ped()) then
                   local wep = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
                   WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(wep, false)
                   local dmg = WEAPON.GET_WEAPON_DAMAGE(wep, 0) * aimbot.damage / 100
                   local veh = PED.GET_VEHICLE_PED_IS_IN(target, false)
                   MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(t_pos.x, t_pos.y, t_pos.z, t_pos2.x, t_pos2.y, t_pos2.z, dmg, true, wep, aimbot.owner, true, false, 2000.0)
                   --MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t_pos.x, t_pos.y, t_pos.z, t_pos2.x, t_pos2.y, t_pos2.z, dmg, true, wep, aimbot.owner, true, false, 2000.0, veh)
                end
            end
    -------------
    -- VEHICLE
    -------------
        local my_cur_car = entities.get_user_vehicle_as_handle() --gets updated in the tick loop at the bottom of the script

        --SPEED AND HANDLING
            local my_torque = 100
            local quickBrakeLvL = 1.5
            local carSettings carSettings = { --makes carSettings available inside this table
                launchControl = {on = false, setOption = function(toggle)
                    if PED.IS_PED_IN_ANY_PLANE(players.user_ped()) then
                        toggle = false
                    end
                    PHYSICS.SET_IN_ARENA_MODE(toggle)
                end},
                lowTraction = {on = false, setOption = function(toggle)
                    VEHICLE.SET_VEHICLE_REDUCE_GRIP(my_cur_car, toggle)
                    VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(my_cur_car, toggle and 0 or 3)
                end},
            }

            function setCarOptions(toggle)
                for k, option in pairs(carSettings) do
                    if option.on then option.setOption(toggle) end
                end
            end
        --fin speed and handling

        local carDoors = {
            'Driver Door',
            'Passenger Door',
            'Rear Left',
            'Rear Right',
            'Hood',
            'Trunk',
        }

    -------------
    -- ONLINE
    -------------
    
    -------------
    -- JOUEURS
    -------------

    local passivemode_block = false

    -------------
    -- MONDE
    -------------
        local all_sex_voicenames = {
            "S_F_Y_HOOKER_01_WHITE_FULL_01",
            "S_F_Y_HOOKER_01_WHITE_FULL_02",
            "S_F_Y_HOOKER_01_WHITE_FULL_03",
            "S_F_Y_HOOKER_02_WHITE_FULL_01",
            "S_F_Y_HOOKER_02_WHITE_FULL_02",
            "S_F_Y_HOOKER_02_WHITE_FULL_03",
            "S_F_Y_HOOKER_03_BLACK_FULL_01",
            "S_F_Y_HOOKER_03_BLACK_FULL_03",
        }
        local speeches = {
            "SEX_GENERIC_FEM",
            "SEX_HJ",
            "SEX_ORAL_FEM",
            "SEX_CLIMAX",
            "SEX_GENERIC"
        }

    -------------
    -- PROTECTIONS
    -------------

        ---ANTI AGRESSEURS
            local anti_muggers_options = {}
            anti_muggers_options["myself"] = {}
            anti_muggers_options["myself"]["block"] = false
            anti_muggers_options["myself"]["notif"] = true
            anti_muggers_options["someone_else"] = {}
            anti_muggers_options["someone_else"]["block"] = false
            anti_muggers_options["someone_else"]["notif"] = true

        ---ANTI VEHICULES
            Menus = {}
            Anti_vehicles_list = {}
            local anti_vehicles_model
            local anti_vehicles_options = {}
            anti_vehicles_options["remove"] = false
            anti_vehicles_options["notif"] = true
            local anti_vehicles_file = scriptdir.."lib/"..SCRIPT_NAME.."/anti_vehicles.json"
            if not filesystem.exists(anti_vehicles_file) then
                local filehandle = io.open(anti_vehicles_file, "w")
                if filehandle then
                    filehandle:write(Json.encode(Anti_vehicles_list))
                    filehandle:close()
                end
            else
                local filehandle = io.open(anti_vehicles_file, "r")
                if filehandle then
                    Anti_vehicles_list = Json.decode(filehandle:read())
                    filehandle:close()
                end
            end
        ---FIN ANTI VEHICLES

    -------------
    -- MISC
    -------------

        --Whitelist

            --returns a table of all players that aren't whitelisted
            local function getNonWhitelistedPlayers(whitelistListTable, whitelistGroups, whitelistedName)
                local playerList = players.list(whitelistGroups.user, whitelistGroups.friends, whitelistGroups.strangers)
                local notWhitelisted = {}
                for i = 1, #playerList do
                    if not whitelistListTable[playerList[i]] and not (players.get_name(playerList[i]) == whitelistedName) then
                        notWhitelisted[#notWhitelisted + 1] = playerList[i]
                    end
                end
                return notWhitelisted
            end

            local proxyStickySettings = {players = true, npcs = false, radius = 2.0}
            local whitelistGroups = {user = true, friends = true, strangers  = true}
            local whitelistListTable = {}
            local whitelistedName = false

            local function autoExplodeStickys(ped)
                local pos = ENTITY.GET_ENTITY_COORDS(ped, true)
                --util.log(pos)
                if MISC.IS_PROJECTILE_TYPE_WITHIN_DISTANCE(pos.x, pos.y, pos.z, util.joaat('weapon_stickybomb'), proxyStickySettings.radius, true) then
                    WEAPON.EXPLODE_PROJECTILES(players.user_ped(), util.joaat('weapon_stickybomb'))
                end
            end
        --Fin whitelist

--===============--
-- FIN Local
--===============--

players.on_join(function(pid)

    while not players.exists(pid) or not util.is_session_started() or util.is_session_transition_active() or GetSpawnState(pid) ~= 99 or not IsPlayerActive(pid, true, true) do
        util.yield()
    end

    if pid == players.user() then return end

    if nation_notify or nation_save then
        --[[util.yield(60000)
        while not players.get_rank(pid) or players.get_rank(pid) == 0 do
            util.yield(5000)
        end]]
        local player_language = players.get_language(pid) + 1
        if nation_select == player_language then
            local player_name = players.get_name(pid)
            if nation_notify then
                notification.stand(player_name .. Translations.nation_notify_arg .. nation_lang[player_language] .. ".")
                util.log(player_name .. Translations.nation_notify_arg .. nation_lang[player_language] .. ".")
            end
            if nation_save and menu.ref_by_command_name("historynote"..player_name:lower()).value == "" then
                --menu.ref_by_path("Online>Player History>"..players.get_name(pid).." [Publique]>Note", Tree_V).value
                --menu.ref_by_command_name("historynote"..players.get_name(pid):lower()).value
                Commands("historynote" .. player_name:lower() .. " " .. nation_lang2[player_language])
            end
        end
    end

    if passivemode_block then
        util.trigger_script_event(1 << pid, {1920583171, 1})
    end
end)

--===============--
--[[ Main ]] local main_root = menu.my_root()
--===============--

    main_root:toggle_loop("test", {}, "", function()
        --AUDIO.STOP_SOUND(-1)
        --AUDIO.STOP_PED_RINGTONE(players.user_ped())
        --util.yield(1000)
        --AUDIO.PLAY_SOUND(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", 0, 0, 0)
	    --AUDIO.PLAY_SOUND(-1, "Boss_Message_Orange", "GTAO_Biker_FM_Soundset", 0, 0, 0)
	    --AUDIO.PLAY_SOUND(-1, "Boss_Message_Orange", "GTAO_Boss_Goons_FM_Soundset", 0, 0, 0)
	    --AUDIO.PLAY_SOUND(-1, "FestiveGift", "Feed_Message_Sounds", 0, 0, 0)
        --local pos = players.get_position(players.user())
        --MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, 999999.0, 0)
        --local bullet = WEAPON.SET_PED_SHOOT_ORDNANCE_WEAPON(players.user_ped(), 0)
        --print(bullet)
        --PLAYER.SET_PLAYER_WEAPON_DAMAGE_MODIFIER(players.user(), 99999.0)
        --PLAYER.SET_PLAYER_WEAPON_DEFENSE_MODIFIER(players.user(), 99999.0)
    end)

    --===============--
    --[[ Self ]] local self_root = main_root:list(Translations.self_root, {}, Translations.self_root_desc)
    --===============--

        ---God
        self_root:toggle(Translations.self_godmode,{},Translations.self_godmode_desc, function(toggle)
            for _,path in pairs(self_list.god) do
                if toggle then
                    self_value.god[path] = menu.ref_by_path(path, Tree_V).value
                    menu.set_value(menu.ref_by_path(path, Tree_V), true)
                elseif not self_value.god[path] then
                    menu.set_value(menu.ref_by_path(path, Tree_V), false)
                end
            end
        end)

        ---Fantôme
        self_root:toggle(Translations.self_ghost, {}, Translations.self_ghost_desc, function(toggle)
            --Invisibility: 0=Disabled | 1=Locally Visible | 2=Enabled
            local path1 = "Self>Appearance>Invisibility"
            local path2 = "Vehicle>Invisibility"
            local path3 = "Online>Off The Radar"
            local path4 = "Stand>Lua Scripts>"..SCRIPT_NAME..">"..Translations.weapon_root..">"..Translations.weapon_invisibility
            if toggle then
                self_value.ghost[path1] = menu.ref_by_path(path1, Tree_V).value
                self_value.ghost[path2] = menu.ref_by_path(path2, Tree_V).value
                self_value.ghost[path3] = menu.ref_by_path(path3, Tree_V).value
                menu.set_value(menu.ref_by_path(path1, Tree_V), 1)
                menu.set_value(menu.ref_by_path(path2, Tree_V), 1)
                menu.set_value(menu.ref_by_path(path3, Tree_V), true)
                menu.set_value(menu.ref_by_path(path4, Tree_V), true)
            else
                if self_value.ghost[path1] ~= 1 or self_value.ghost[path1] ~= menu.ref_by_path(path1, Tree_V).value then
                    menu.set_value(menu.ref_by_path(path1, Tree_V), self_value.ghost[path1])
                end
                if self_value.ghost[path2] ~= 1 or self_value.ghost[path2] ~= menu.ref_by_path(path2, Tree_V).value then
                    menu.set_value(menu.ref_by_path(path2, Tree_V), self_value.ghost[path2])
                end
                if not self_value.ghost[path3] then
                    menu.set_value(menu.ref_by_path(path3, Tree_V), toggle)
                end
                if not self_value.ghost[path4] then
                    menu.set_value(menu.ref_by_path(path4, Tree_V), toggle)
                end
            end
        end, false)

        ---Respiration infinie
        self_root:toggle(Translations.self_unlimair, {}, Translations.self_unlimair_desc, function(toggle)
        	PED.SET_PED_DIES_IN_SINKING_VEHICLE(players.user_ped(), not toggle)
            PED.SET_PED_DIES_IN_WATER(players.user_ped(), not toggle)
            --PED.SET_PED_MAX_TIME_IN_WATER(players.user_ped(), -1)
            --PED.SET_PED_MAX_TIME_UNDERWATER(players.user_ped(), -1)
        end, false)

        ---Sang-Froid
        self_root:toggle(Translations.self_cold_blood, {}, Translations.self_cold_blood_desc, function(toggle)
            PED.SET_PED_HEATSCALE_OVERRIDE(players.user_ped(), (toggle and 0 or 1.0))
        end, false)

        ---Ninja
        self_root:toggle(Translations.self_ninja, {}, Translations.self_ninja_desc, function(toggle)
            AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(players.user_ped(), not toggle)
            AUDIO.SET_PED_CLOTH_EVENTS_ENABLED(players.user_ped(), not toggle)
        end, false)

        self_root:toggle(Translations.self_anti_aim_notify, {},  Translations.self_anti_aim_notify_desc, function(toggle)
            for k,pid in players.list(false, true, true) do
                local c1 = players.get_position(pid)
                local c2 =  players.get_position(players.user())
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if PED.IS_PED_FACING_PED(ped, players.user_ped(), 180) and ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(ped, players.user_ped(), 17) and MISC.GET_DISTANCE_BETWEEN_COORDS(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z) < 1000 and WEAPON.GET_SELECTED_PED_WEAPON(ped) ~= -1569615261 and PED.GET_PED_CONFIG_FLAG(ped, 78, true) then
                    notification.stand(Translations.self_anti_aim_notify_toast, players.get_name(pid))
                end
            end
        end)

        --Fun-menu
        --Aucun dommage critique
        self_root:toggle(Translations.self_no_critical, {}, Translations.self_no_critical_desc, function(toggle)
        	PED.SET_PED_SUFFERS_CRITICAL_HITS(players.user_ped(), not toggle)
        end, false)

        --Drink milk pour alcool
        self_root:action(Translations.self_drink_milk, {}, Translations.self_drink_milk_desc, function()
            AUDIO.SET_PED_IS_DRUNK(players.user_ped(), false)
	        PED.SET_PED_MOTION_BLUR(players.user_ped(), false)
            local shader_ref = menu.ref_by_path("Game>Rendering>Shader Override")
            local initial_shader_int = menu.get_value(shader_ref)
            menu.set_value(shader_ref, initial_shader_int)
            CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0.0)
	        GRAPHICS.SET_TIMECYCLE_MODIFIER_STRENGTH(0.0)
        end)

    --===============--
    -- FIN Self
    --===============--

    --===============--
    --[[ Weapon ]] local weapon_root = main_root:list(Translations.weapon_root, {}, Translations.weapon_root_desc)
    --===============--

        -------------------
        --- AIMBOT SILENCIEUX
        -------------------
        local aimbot_root = weapon_root:list(Translations.weapon_aimbot_root, {}, Translations.weapon_aimbot_root_desc)

            aimbot_root:toggle_loop(Translations.weapon_aimbot, {"nyaimbot"}, Translations.weapon_aimbot_desc, function(toggle)
                if PLAYER.IS_PLAYER_FREE_AIMING(players.user()) then
                    local target = GetAimbotTargetV2()
                    --[[if target ~= 0 then
                        ---ARME
                        local weaponped = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped(), true)
                        --local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(weapon, "gun_muzzle")
		                --local bonePos = ENTITY.GET_ENTITY_BONE_POSTION(weapon, bone)
                        local min, max = v3.new(), v3.new()
                        --Obtient les dimensions d'un modèle. Calculez (maximum - minimum) pour obtenir la taille, auquel cas, Y sera la longueur du modèle.
                        MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(weaponped), min, max)
                        --Les valeurs de décalage sont relatives à l'entité. x = left/right, y = forward/backward, z = up/down
                        --x max= avant(embout), x min= arriere(crosse) y max= droite(vue de face), y min = gauche (vue de face)
                        local startLine = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(weaponped,  max.x, 0, 0.04)
                        ---POSITION
                        local t_pos
                        local t_pos2
                        local t_pos_target = ENTITY.GET_ENTITY_COORDS(target, true)
                        --APPLY_PED_DAMAGE_DECAL
                        --HEAD, TORSO, RANDOM
                        local t_pos_search = {
                            --PED.GET_PED_BONE_COORDS(target, 31086, 0.05, 0.25, 0),-- 0.01, 0, 0 lancescript
                            PED.GET_PED_BONE_COORDS(target, 27474, 0.25, 0.04, 0), --head
                            --PED.GET_PED_BONE_COORDS(target, 12844, 0, -0.001, 0), --test head
                            PED.GET_PED_BONE_COORDS(target, 24818, 0, 0.25, 0),-- 0.01, 0, 0 torse
                        }
                        local t_pos2_search = {
                            --PED.GET_PED_BONE_COORDS(target, 31086, 0.125, 0, 0),-- -0.01, 0, 0.00 lancescript
                            PED.GET_PED_BONE_COORDS(target, 27474, 0, 0.04, 0),-- head
                            --PED.GET_PED_BONE_COORDS(target, 12844, 0, 0, 0), --test head
                            PED.GET_PED_BONE_COORDS(target, 24818, 0, 0, 0), --torse
                        }
                        local aimbot_options_cible_random = math.random(2)
                        --Cheat, Legit
                        if aimbot.mode == 1 then
                            if aimbot.bone ~= 3 then
                                t_pos = t_pos_search[aimbot.bone]
                            else
                                t_pos = t_pos_search[aimbot_options_cible_random]
                            end
                        else
                            t_pos = startLine
                        end
                        if aimbot.bone ~= 3 then
                            t_pos2 = t_pos2_search[aimbot.bone]
                        else
                            t_pos2 = t_pos2_search[aimbot_options_cible_random]
                        end
                        if aimbot.alert then
                            if aimbot.marker == 1 then
                                GRAPHICS.DRAW_MARKER(0, t_pos_target.x, t_pos_target.y, t_pos_target.z+2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 1, math.floor(aimbot.esprgb.r*255), math.floor(aimbot.esprgb.g*255), math.floor(aimbot.esprgb.b*255), math.floor(aimbot.esprgb.a*255), false, true, 2, false, 0, 0, false)
                            elseif aimbot.marker == 2 then
                                GRAPHICS.DRAW_MARKER(2, t_pos_target.x, t_pos_target.y, t_pos_target.z+2, 0, 0, 0, 0.0, 180, 0.0, 1, 1, 1, math.floor(aimbot.esprgb.r*255), math.floor(aimbot.esprgb.g*255), math.floor(aimbot.esprgb.b*255), math.floor(aimbot.esprgb.a*255), false, true, 2, false, 0, 0, false)
                            else
                                GRAPHICS.DRAW_LINE(startLine.x, startLine.y, startLine.z, t_pos2.x, t_pos2.y, t_pos2.z, math.floor(aimbot.esprgb.r*255), math.floor(aimbot.esprgb.g*255), math.floor(aimbot.esprgb.b*255), math.floor(aimbot.esprgb.a*255))
                                GRAPHICS.DRAW_LINE(t_pos.x, t_pos.y, t_pos.z, t_pos2.x, t_pos2.y, t_pos2.z, 0, 255,0, 255)
                            end
                        end
                        --PED.SET_PED_CONFIG_FLAG(players.user_ped(), 120, false)
                        if PED.IS_PED_SHOOTING(players.user_ped()) then
                            local wep = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
                            WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(wep, false)
                            local dmg = WEAPON.GET_WEAPON_DAMAGE(wep, 0) * aimbot.damage / 100
                            local veh = PED.GET_VEHICLE_PED_IS_IN(target, false)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(t_pos['x'], t_pos['y'], t_pos['z'], t_pos2['x'], t_pos2['y'], t_pos2['z'], dmg, true, wep, players.user_ped(), true, false, 2000.0, veh)
                        end
                    end]]
                end
            end)
            --Commands("nyaimbot", true)

            ---OPTIONS
            local aimbot_options_root = aimbot_root:list(Translations.weapon_aimbot_options_root, {}, Translations.weapon_aimbot_options_root_desc)

                aimbot_options_root:slider(Translations.weapon_aimbot_options_damage, {}, Translations.weapon_aimbot_options_damage_desc, 1, 1000, aimbot.damage, 10, function(s)
                    aimbot.damage = s
                end)

                aimbot_options_root:toggle(Translations.weapon_aimbot_options_use_fov, {}, Translations.weapon_aimbot_options_use_fov_desc, function(toggle)
                    aimbot.usefov = toggle
                end, aimbot.usefov)

                aimbot_options_root:slider(Translations.weapon_aimbot_options_fov, {}, Translations.weapon_aimbot_options_fov_desc, 1, 270, aimbot.fov, 1, function(s)
                    aimbot.fov = s
                end)

                aimbot_options_root:list_select(Translations.weapon_aimbot_options_mode, {}, Translations.weapon_aimbot_options_mode_desc, {"Cheat", "Legit"}, aimbot.mode, function(index)
                    aimbot.mode = index
                end)

                aimbot_options_root:list_select(Translations.weapon_aimbot_options_cible, {}, Translations.weapon_aimbot_options_cible_desc, {"Head", "Torso", "Random"}, aimbot.bone, function(index)
                    aimbot.bone = index
                end)

            aimbot_root:toggle(Translations.weapon_aimbot_players, {}, Translations.weapon_aimbot_players_desc, function(toggle)
                aimbot.targetplayers = toggle
            end, aimbot.targetplayers)

            aimbot_root:toggle(Translations.weapon_aimbot_friends, {}, Translations.weapon_aimbot_friends_desc, function(toggle)
                aimbot.targetfriends = toggle
            end, aimbot.targetfriends)

            aimbot_root:toggle(Translations.weapon_aimbot_interior, {}, Translations.weapon_aimbot_interior_desc, function(toggle)
                aimbot.targetinterior = toggle
            end, aimbot.targetinterior)

            aimbot_root:toggle(Translations.weapon_aimbot_godmode, {}, Translations.weapon_aimbot_godmode_desc, function(toggle)
                aimbot.targetgodmode = toggle
            end, aimbot.targetgodmode)

            aimbot_root:toggle(Translations.weapon_aimbot_npcs, {}, Translations.weapon_aimbot_npcs_desc, function(toggle)
                aimbot.targetnpcs = toggle
            end, aimbot.targetnpcs)

            aimbot_root:toggle(Translations.weapon_aimbot_vehicles, {}, Translations.weapon_aimbot_vehicles_desc, function(toggle)
                aimbot.targetvehs = toggle
            end, aimbot.targetvehs)

            aimbot_root:toggle("Through Walls", {}, "Turns on Shoot Through Walls with Aimbot", function (toggle)
                aimbot.targettw = toggle
            end)

            aimbot_root:toggle(Translations.weapon_aimbot_display, {}, Translations.weapon_aimbot_display_desc, function(toggle)
                aimbot.alert = toggle
            end, aimbot.alert)

            ---CUSTOM
            local aimbot_custom_root = aimbot_root:list(Translations.weapon_aimbot_custom_root, {}, Translations.weapon_aimbot_custom_root_desc)
                menu.divider(aimbot_custom_root, "MARKER")
                    --type
                    aimbot_custom_root:list_select(Translations.weapon_aimbot_custom_type, {}, Translations.weapon_aimbot_custom_type_desc, {"Désactivé", "Cône", "Chevron"}, aimbot.marker, function(index)
                        aimbot.marker = index
                    end)
                    --color
                    local aimbot_custom_marker_root = aimbot_custom_root:colour(Translations.weapon_aimbot_custom_colour_root, {"nyaimbotmarkcolor"}, Translations.weapon_aimbot_custom_colour_root_desc, aimbot.markerrgb, true, function(newColour)
                        aimbot.markerrgb = newColour
                    end)
                    aimbot_custom_marker_root:rainbow()

                menu.divider(aimbot_custom_root, "ESP")
                    --type
                    aimbot_custom_root:list_select(Translations.weapon_aimbot_custom_type, {}, Translations.weapon_aimbot_custom_type_desc, {"Désactivé", "Crosshair", "Weapon", "Crosshair + Weapon"}, aimbot.esp, function(index)
                        aimbot.esp = index
                    end)
                    --color
                    local aimbot_custom_esp_root = aimbot_custom_root:colour(Translations.weapon_aimbot_custom_colour_root, {"nyaimbotmarkcolor"}, Translations.weapon_aimbot_custom_colour_root_desc, aimbot.esprgb, true, function(newColour)
                        aimbot.esprgb = newColour
                    end)
                    aimbot_custom_esp_root:rainbow()

                menu.divider(aimbot_custom_root, "BOX")
                    --type
                    aimbot_custom_root:list_select(Translations.weapon_aimbot_custom_type, {}, Translations.weapon_aimbot_custom_type_desc, {"Désactivé", "Box", "Box pleine"}, aimbot.box, function(index)
                        aimbot.box = index
                    end)
                    --color
                    local aimbot_custom_box_root = aimbot_custom_root:colour(Translations.weapon_aimbot_custom_colour_root, {"nyaimbotmarkcolor"}, Translations.weapon_aimbot_custom_colour_root_desc, aimbot.boxrgb, true, function(newColour)
                        aimbot.boxrgb = newColour
                    end)
                    aimbot_custom_box_root:rainbow()

        --- FIN AIMBOT

        --jinx
        weapon_root:toggle_loop(Translations.weapon_fast_hands, {}, Translations.weapon_fast_hands_desc, function()
            if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 56) then
                PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped(), true, true)
            end
        end)

        --jinx
        ---Porté de verrouillage
        weapon_root:toggle_loop(Translations.weapon_max_lockon, {}, Translations.weapon_max_lockon_des, function()
            PLAYER.SET_PLAYER_LOCKON_RANGE_OVERRIDE(players.user(), 99999999.0)
        end)

        --jinx
        weapon_root:toggle_loop(Translations.weapon_lock_on_players, {}, Translations.weapon_lock_on_players_desc, function()
            for _, pid in pairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                PLAYER.ADD_PLAYER_TARGETABLE_ENTITY(players.user(), ped)
                ENTITY.SET_ENTITY_IS_TARGET_PRIORITY(ped, true, 0) --400.0
                --PLAYER.SET_PLAYER_LOCKON(pid, true)
            end
        end, function()
            for _, pid in pairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                PLAYER.REMOVE_PLAYER_TARGETABLE_ENTITY(players.user(), ped)
            end
        end)

        --jinx
        weapon_root:toggle_loop(Translations.weapon_bypass_anti_lockon, {}, Translations.weapon_bypass_anti_lockon_desc, function()
            for _, pid in players.list(false, true, true) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(veh, true)
                end
            end
        end)

        --JerryScript
        -------------------
        --- PROXY STICKYS
        -------------------
        local proxy_stickys_root = weapon_root:list(Translations.weapon_proxy_stickys_root, {}, Translations.weapon_proxy_stickys_root_desc)

            proxy_stickys_root:toggle_loop("Proxy stickys", {}, 'Makes your sticky bombs automatically detonate around players or npc\'s, works with the player whitelist.', function()
                if proxyStickySettings.players then
                    local specificWhitelistGroup = {user = false,  friends = whitelistGroups.friends, strangers = whitelistGroups.strangers}
                    local playerList = getNonWhitelistedPlayers(whitelistListTable, specificWhitelistGroup, whitelistedName)
                    for _, pid in pairs(playerList) do
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        autoExplodeStickys(ped)
                    end
                end
                if proxyStickySettings.npcs then
                    local pedHandles = entities.get_all_peds_as_handles()
                    for _, ped in pairs(pedHandles) do
                        if not PED.IS_PED_A_PLAYER(ped) then
                            autoExplodeStickys(ped)
                        end
                    end
                end
            end)

            proxy_stickys_root:toggle('Detonate near players', {}, 'If your sticky bombs automatically detonate near players.', function(toggle)
                proxyStickySettings.players = toggle
            end, proxyStickySettings.players)

            proxy_stickys_root:toggle('Detonate near npc\'s', {}, 'If your sticky bombs automatically detonate near npc\'s.', function(toggle)
                proxyStickySettings.npcs = toggle
            end, proxyStickySettings.npcs)

            proxy_stickys_root:slider('Detonation radius', {}, 'How close the sticky bombs have to be to the target to detonate.', 1, 10, proxyStickySettings.radius, 1, function(value)
                proxyStickySettings.radius = value
            end)

            proxy_stickys_root:action('Remove all sticky bombs', {}, 'Removes every single sticky bomb that exists (not only yours).', function()
                WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(util.joaat('weapon_stickybomb'), false)
            end)

        --- FIN PROXY STICKYS
        -----------------------------------

        local weapon_invisibility = weapon_root:toggle_loop(Translations.weapon_invisibility, {}, "", function()
            local curweap = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped())
            ENTITY.SET_ENTITY_VISIBLE(curweap, false, false)
        end, function ()
            local curweap = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(players.user_ped())
            ENTITY.SET_ENTITY_VISIBLE(curweap, true, false)
        end)

    --===============--
    -- FIN Weapon
    --===============--

    --===============--
    --[[ VEHICLES ]] local vehicle_root = main_root:list(Translations.vehicle_root, {}, Translations.vehicle_root_desc)
    --===============--

    --VEHICLE.SET_VEHICLE_MAX_SPEED(vmod, max) --ACCELERATION
    --VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vmod, top) --VITESSE MAX
    --VEHICLE.SET_VEHICLE_BURNOUT(vmod, false)

        --Auto-flip vehicle
        vehicle_root:toggle_loop(Translations.vehicle_auto_flip, {}, Translations.vehicle_auto_flip_desc, function()
            local player_vehicle = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
            local vehicle_distance_to_ground = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(player_vehicle)
            local am_i_on_ground = vehicle_distance_to_ground < 2 --and true or false
            if not VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(player_vehicle) and ENTITY.IS_ENTITY_UPSIDEDOWN(player_vehicle) and am_i_on_ground then
                --NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(player_vehicle)

                local rotation = CAM.GET_GAMEPLAY_CAM_ROT(2)
                local heading = v3.getHeading(v3.new(rotation))
                local speed = ENTITY.GET_ENTITY_SPEED(player_vehicle)

                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(player_vehicle, 5.0)
                ENTITY.SET_ENTITY_HEADING(player_vehicle, heading)
                util.yield()
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(player_vehicle, speed)
            end
        end)

        --jinx
        vehicle_root:toggle_loop(Translations.vehicle_fast_enter, {}, Translations.vehicle_fast_enter_desc, function()
            if (TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 160) or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 167) or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 165)) and not TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 195) then
                PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
            end
        end)
        --jinx
        vehicle_root:toggle_loop(Translations.vehicle_disable_godmode, {}, Translations.vehicle_disable_godmode_desc, function()
            if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(my_cur_car) then
                if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true), true)
                end
            end
        end)
        --jinx
        vehicle_root:toggle_loop(Translations.vehicle_stick_ground, {}, Translations.vehicle_stick_ground_desc, function()
            local vehicle = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
            local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
            if vehicle ~= 0 and class ~= 15 and class ~= 16 and ENTITY.GET_ENTITY_MODEL(vehicle) ~= util.joaat("oppressor") and ENTITY.GET_ENTITY_MODEL(vehicle) ~= util.joaat("oppressor2") then
                local height = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(vehicle)
                if height < 5.0 then
                    if ENTITY.IS_ENTITY_IN_AIR(vehicle) then
                        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle, 5.0)
                    end
                else
                    local controls = {32, 33, 34, 35}
                    for _, key in controls do
                        if vehicle ~= 0 and PAD.IS_CONTROL_PRESSED(0, key) then
                            local velocity = ENTITY.GET_ENTITY_VELOCITY(vehicle)
                            while not PAD.IS_CONTROL_RELEASED(0, key) and ENTITY.IS_ENTITY_IN_AIR(vehicle) do
                                ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 2, 0.0, 0.0, velocity.z, 0, 0, 0, 0, true, false, true, false, true)
                                util.yield()
                            end
                        end
                    end
                end
            end
        end)

        --Fun-menu
        vehicle_root:toggle_loop(Translations.vehicle_easy_enter, {}, Translations.vehicle_easy_enter_desc, function(toggle)
        	if not (PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(players.user_ped()) == 0) then
        		RequestControlLoop(PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(players.user_ped()))
        		VEHICLE.BRING_VEHICLE_TO_HALT(PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(players.user_ped()), 0, 1)
        	end
        	util.yield()
        end)
        --fun-menu
        vehicle_root:toggle_loop(Translations.vehicle_anti_carjacking, {}, Translations.vehicle_anti_carjacking_desc, function()
            local veh = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        	if not (veh == 0) then
        		local plyseat = 0
        		for i = -1, 30 do
        			if (VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, i) == players.user_ped()) then
        				plyseat = i
        			end
        		end
        		if PED.IS_PED_BEING_JACKED(players.user_ped()) then
        			PED.SET_PED_INTO_VEHICLE(players.user_ped(), veh, plyseat)
        		end
        	end
        end)

        --fun-menu
        vehicle_root:toggle_loop(Translations.vehicle_keep_on, {}, Translations.vehicle_keep_on_desc, function()
            local vehlast = my_cur_car
        	if VEHICLE.IS_THIS_MODEL_A_HELI(ENTITY.GET_ENTITY_MODEL(vehlast)) or VEHICLE.IS_THIS_MODEL_A_PLANE(ENTITY.GET_ENTITY_MODEL(vehlast)) then
        		VEHICLE.SET_HELI_BLADES_FULL_SPEED(vehlast)
        	else
        		VEHICLE.SET_VEHICLE_ENGINE_ON(vehlast, true, true, true)
        	end
        end)

        -----------------------------------
        --- SPEED AND HANDLING
        -----------------------------------
        local speed_handling_root = vehicle_root:list("SPEED and HANDLING"--[[Translations.vehicle_speed_handling_root]], {}, Translations.vehicle_speed_handling_root_desc)

            speed_handling_root:toggle("Low traction", {}, "Makes your vehicle have low traction, I recommend setting this to a hotkey.", function(toggle)
                carSettings.lowTraction.on = toggle
                carSettings.lowTraction.setOption(toggle)
            end)

            speed_handling_root:toggle("Launch control", {}, "Limits how much force your car applies when accelerating so it doesn\'t burnout, very noticeable in a Emerus.", function(toggle)
                carSettings.launchControl.on = toggle
                carSettings.launchControl.setOption(toggle)
            end)

            speed_handling_root:slider_float("Set torque", {"nytorque"}, "Modifies the speed of your vehicle.", -1000000, 1000000, my_torque, 50, function(value)
                my_torque = value
                util.create_tick_handler(function()
                    VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(my_cur_car, my_torque/100)
                    return (my_torque != 100)
                end)
            end)

            speed_handling_root:toggle_loop("Quick brake", {}, "Slows down your speed more when pressing \"S\".", function(toggle)
                if PAD.IS_CONTROL_JUST_PRESSED(2 --[['FRONTEND_CONTROL']], 72 --[[INPUT_VEH_BRAKE: S (LT)]]) and ENTITY.GET_ENTITY_SPEED(my_cur_car) >= 0 and not ENTITY.IS_ENTITY_IN_AIR(my_cur_car) and VEHICLE.GET_PED_IN_VEHICLE_SEAT(my_cur_car, -1, false) == players.user_ped() then
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(my_cur_car, ENTITY.GET_ENTITY_SPEED(my_cur_car) / quickBrakeLvL)
                    util.yield(250)
                end
            end)

            speed_handling_root:slider_float("Quick brake force", {}, "1.00 is ordinary brakes.", 100, 999, 150, 1,  function(value)
                quickBrakeLvL = value / 100
            end)
        --- FIN SPEED AND HANDLING

        vehicle_root:toggle_loop("Shut doors when driving", {}, "Closes all the vehicle doors when you start driving.", function()
            if not (VEHICLE.GET_PED_IN_VEHICLE_SEAT(my_cur_car, -1, false) == players.user_ped() and ENTITY.GET_ENTITY_SPEED(my_cur_car) > 1) then return end  --over a speed of 1 because car registers as moving then doors move

            if ENTITY.GET_ENTITY_SPEED(my_cur_car) < 10 then
                util.yield(800)
            else
                util.yield(600)
            end

            local closed = false
            for i, door in ipairs(carDoors) do
                if VEHICLE.GET_VEHICLE_DOOR_ANGLE_RATIO(my_cur_car, i - 1) > 0 and not VEHICLE.IS_VEHICLE_DOOR_DAMAGED(my_cur_car, i - 1) then
                    VEHICLE.SET_VEHICLE_DOOR_SHUT(my_cur_car, i - 1, false)
                    closed = true
                end
            end
            if closed then
                notification.stand("Closed your car doors.")
            end
        end)

        --AndyScript
        vehicle_root:toggle_loop("Turn Car On Instantly", {}, "Turns the car engine on instantly when you get into it, so you don't have to wait.", function()
            local localped = players.user_ped()
            if PED.IS_PED_GETTING_INTO_A_VEHICLE(localped) then
                local veh = PED.GET_VEHICLE_PED_IS_ENTERING(localped)
                if not VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(veh) then
                    VEHICLE.SET_VEHICLE_FIXED(veh)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
                end
                if VEHICLE.GET_VEHICLE_CLASS(veh) == 15 then --15 is heli
                    VEHICLE.SET_HELI_BLADES_FULL_SPEED(veh)
                end
            end
        end)

    --===============--
    --[[ Online ]] local online_root = main_root:list(Translations.online_root, {}, Translations.online_root_desc)
    --===============--

        -------------------
        --- SESSION
        -------------------
        local session_root = online_root:list(Translations.online_session_root, {}, Translations.online_session_root_desc)

            session_root:toggle(Translations.online_session_nation_notify, {}, Translations.online_session_nation_notify_desc, function(toggle)
                nation_notify = toggle
            end, nation_notify)

            session_root:toggle(Translations.online_session_nation_save, {}, Translations.online_session_nation_save_desc, function(toggle)
                nation_save = toggle
            end, nation_save)

            session_root:list_select(Translations.online_session_nation_select, {}, Translations.online_session_nation_select_desc, nation_lang, nation_select, function(index)
                nation_select = index
            end)

        --AcJocker
        -------------------
        --- TAXI AUTO
        -------------------
        --[[
        local curcoords = {}
        AClang.toggle_loop(onlineroot, "Auto TP to Taxi Pickup", {"tptaxi"}, "Auto teleports to the Taxi Pickup Person, picks them up and drops them off until you are not in a taxi anymore", function ()
        if curcoords.x == nil then
            curcoords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        return curcoords
        end
        
        
        
            local play_car = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
            local vhash = ENTITY.GET_ENTITY_MODEL(play_car)
            if play_car == 0 or util.reverse_joaat(vhash) ~= "taxi" then
                
                SEC(players.user_ped(), 895.1739, -179.2708, 74.70049, false, true, true, false)
                util.yield(2500)
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 51, 1)
                util.yield(10000)
            elseif play_car != 0 and util.reverse_joaat(vhash) == 'taxi' then
                while not HUD.DOES_BLIP_EXIST(HUD.GET_CLOSEST_BLIP_INFO_ID(280)) do
                    PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 29, 1)
                    util.yield(1000)
                    return
                end
            end
    
            local taxi_blip = HUD.GET_CLOSEST_BLIP_INFO_ID(280)
            local taxi_ent = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(taxi_blip)
            local taxi = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(taxi_ent, 0, 6, 0)
            if HUD.DOES_BLIP_EXIST(HUD.GET_CLOSEST_BLIP_INFO_ID(280)) then
                if taxi.x ~= 0 and taxi.y ~= 0 and taxi.z ~= 0 then
                    util.yield(500)
                    PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), taxi.x, taxi.y, taxi.z, false, false, false, false)
                    util.yield(1000)
                    PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 86, 1)
                    while HUD.DOES_BLIP_EXIST(HUD.GET_CLOSEST_BLIP_INFO_ID(280)) do
                        util.yield()
                    end
                    util.yield(500)
                    Commands("tpobjective")
                    
                else
                    if set.alert then
                        AClang.toast("No Person Found")
                    end
                end
                else
                    util.yield()
            end
        end, function ()
            SEC(players.user_ped(), curcoords.x, curcoords.y, curcoords.z, false, true, true, false)
            if set.alert then    
                AClang.toast("Not in a taxi turning off auto teleport")
            end
            curcoords = {}
        end)
        ]]
        -------------------
        --- FIN TAXI AUTO
        -------------------

        online_root:toggle_loop("Disable RP Gain", {}, "You will not gain any RP.", function()
            memory.write_float(memory.script_global(262145 + 1),0)
        end, function()
            memory.write_float(memory.script_global(262145 + 1),1)
        end)

        online_root:toggle_loop("Skip Dax Work Cooldown", {}, "", function() -- thx icedoomfist for the stat name <3
            STATS.STAT_SET_INT(util.joaat("MP"..util.get_char_slot().."_XM22JUGGALOWORKCDTIMER"), -1, true)
        end)

        --[[
        local max_health
        undead_otr = online:toggle(Tr("Undead OTR"),{},Tr("Turn you off the radar without notifying other players.\nNote: Trigger Modded Health detection."),function(on)
            if on then
                max_health = ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped())
                while menu.get_state(undead_otr) == "On" do
                    if ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) ~= 0 then
                        ENTITY.SET_ENTITY_MAX_HEALTH(players.user_ped(),0)
                    end
                    util.yield(200)
                end
            else
                ENTITY.SET_ENTITY_MAX_HEALTH(players.user_ped(),max_health)
            end
        end)
        ]]

        --AcJocker
        --[[ NE FONCTIONNE PAS
        online_root:toggle_loop('Increase Kosatka Missile Range', {}, 'You can use it anywhere in the map now', function()
            if util.is_session_started() then
                memory.write_float(memory.script_global(262145 + 30176), 200000.0)
            end
        end)
        ]]--

    --===============--
    -- FIN Online
    --===============--

    --===============--
    --[[ Joueurs ]] local players_root = main_root:list(Translations.players_root, {}, Translations.players_root_desc)
    --===============--

        --[[ Enleve le godmode mais reste invinsible
        players_root:action("Remove Vehicle Godmode for All", {}, "Removes everyone's vehicle godmode, making them easier to kill :)", function ()
            for i = 0, 31 do
                if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                    local ped = PLAYER.GET_PLAYER_PED(i)
                    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                        ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
                        ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
                    end
                end
            end
        end)
        ]]

        --[[
        -----------------------------------
        -- Whitelist
        -----------------------------------
        JSlang.list(_LR["Players"], "Whitelist", {"JSwhitelist"}, "Applies to most options in this section.")

        JSlang.toggle(_LR["Whitelist"], "Exclude self", {"JSWhitelistSelf"}, "Will make you not explode yourself. Pretty cool option if you ask me ;P", function(toggle)
            whitelistGroups.user = not toggle
        end)

        JSlang.toggle(_LR["Whitelist"], "Exclude friends", {"JSWhitelistFriends"}, "Will make you not explode your friends... if you have any. (;-;)", function(toggle)
            whitelistGroups.friends = not toggle
        end)

        JSlang.toggle(_LR["Whitelist"], "Exclude strangers", {"JSWhitelistStrangers"}, "If you only want to explode your friends I guess.", function(toggle)
            whitelistGroups.strangers = not toggle
        end)

        JSlang.text_input(_LR["Whitelist"], "Whitelist player", {"JSWhitelistPlayer"}, "Lets you whitelist a single player by name.", function(input)
            whitelistedName = input
        end, "")

        JSlang.list(_LR["Whitelist"], "Whitelist player list", {"JSwhitelistList"}, "Custom player list for selecting  players you wanna whitelist.")

        local whitelistTogglesTable = {}
        players.on_join(function(pid)
            local playerName = players.get_name(pid)
            whitelistTogglesTable[pid] = menu.toggle(_LR["Whitelist player list"], playerName, {"JSwhitelist".. playerName}, JSlang.str_trans("Whitelist") .." ".. playerName .." ".. JSlang.str_trans("from options that affect all players."), function(toggle)
                if toggle then
                    whitelistListTable[pid] = pid
                    if notifications then
                        util.toast(JSlang.str_trans("Whitelisted") .." ".. playerName)
                    end
                else
                    whitelistListTable[pid] = nil --removes the player from the whitelist
                end
            end)
        end)
        players.on_leave(function(pid)
            if not whitelistTogglesTable[pid] then return end
            menu.delete(whitelistTogglesTable[pid])
            whitelistListTable[pid] = nil --removes the player from the whitelist
        end)
        ]]

        --[[ Fonction existante sur stand
        players_root:toggle_loop("FORCE_VISIBLE", {}, "", function()
            for _, player in players.list(false, true, true) do
                ENTITY.SET_ENTITY_VISIBLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player), true, false)
            end
        end)
        ]]

        
        -------------
        -- PASSIVE
        -------------
        players_root:toggle("Block Passive", {}, "", function(toggle)
            passivemode_block = toggle
            for _, pid in players.list(true, true, true) do
                util.trigger_script_event(util.get_session_players_bitflag(), {1920583171, toggle and 1 or 0})
            end
        end, false)

        players_root:toggle_loop("Shoot gods", {}, "Disables godmode for other players when aiming at them. Mostly works on trash menus.", function()
            local playerList = getNonWhitelistedPlayers(whitelistListTable, whitelistGroups, whitelistedName)
            for k, playerPid in ipairs(playerList) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(playerPid)
                if (PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(players.user(), playerPed) or PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(playerPed, players.user())) and players.is_godmode(playerPid) then
                    util.trigger_script_event(1 << playerPid, {-1388926377, playerPid, -1762807505, math.random(0, 9999)})
                end
            end
        end)


        players_root:toggle_loop("Ghost Armed Players", {}, "Ghost players that have an sort of weapon out", function()
            for _, pid in players.list(false, true, true) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if WEAPON.IS_PED_ARMED(ped, 7) or TASK.GET_IS_TASK_ACTIVE(ped, 199) or TASK.GET_IS_TASK_ACTIVE(ped, 128) 
                or IsPlayerUsingGuidedMissile(pid) or IsPlayerInRcTank(pid) or IsPlayerInRcBandito(pid) or IsPlayerFlyingAnyDrone(pid) then
                    NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                else
                    NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                end
            end
        end, function()
            for _, pid in players.list(false, true, true) do
                NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end)

        players_root:toggle_loop("Ghost Godmode", {}, "Ghost players in Godmode", function()
            for _, pid in players.list(false, true, true) do
                if players.is_godmode(pid) then
                    NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                else
                    NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                end
            end
        end, function()
            for _, pid in players.list(false, true, true) do
                NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end)
    --===============--
    -- FIN Joueurs
    --===============--

    --===============--
    --[[ Monde ]] local world_root = main_root:list(Translations.world_root, {}, Translations.world_root_desc)
    --===============--

        world_root:toggle_loop("Ped Drops", {}, "Killed peds drop $2000", function(toggle)
            local _peds = entities.get_all_peds_as_handles()
            if _peds then
                for _index, _ped in pairs(_peds) do
                    if _ped and not PED.IS_PED_A_PLAYER(_ped) then
                        PED.SET_PED_MONEY(_ped, 2000)
                    end
                end
            end
            util.yield()
        end)

        world_root:toggle_loop("Car Drops", {}, "Cars exploded drop money", function(toggle)
            local _vehs = entities.get_all_vehicles_as_handles()
            if _vehs then
                for _index, _veh in pairs(_vehs) do
                    --if _veh and not PED.IS_PED_A_PLAYER(_veh) then
                        VEHICLE.SET_VEHICLE_DROPS_MONEY_WHEN_BLOWN_UP(_veh, true)
                    --end
                end
            end
            util.yield()
        end)

        world_root:toggle('Riot mode', {}, 'Makes peds hostile.', function(toggle)
            MISC.SET_RIOT_MODE_ENABLED(toggle)
        end)

        -----------------------------------
        -- Peds
        -----------------------------------
        local world_ped_root = world_root:list("Peds", {}, "")

        local pedToggleLoops = {
            {name = "Ragdoll peds", command = "JSragdollPeds", description = "Makes all nearby peds fall over lol.", action = function(ped)
                if PED.IS_PED_A_PLAYER(ped) then return end
                PED.SET_PED_TO_RAGDOLL(ped, 2000, 2000, 0, true, true, true)
            end},
            {name = "Death\'s touch", command = "JSdeathTouch", description = "Kills peds that touches you.", action = function(ped)
                if PED.IS_PED_A_PLAYER(ped) or PED.IS_PED_IN_ANY_VEHICLE(ped, true) or not ENTITY.IS_ENTITY_TOUCHING_ENTITY(ped, players.user_ped()) then return end
                ENTITY.SET_ENTITY_HEALTH(ped, 0, 0)
            end},
            {name = 'Cold peds', command = 'JScoldPeds', description = 'Removes the thermal signature from all peds.', action = function(ped)
                if PED.IS_PED_A_PLAYER(ped) then return end
                PED.SET_PED_HEATSCALE_OVERRIDE(ped, 0)
            end},
            {name = Translations.sex_voicelines, command = "", description = Translations.sex_voicelines_desc, action = function(ped)
                if PED.IS_PED_A_PLAYER(ped) then return end
                local voice_name = all_sex_voicenames[math.random(1, #all_sex_voicenames)]
                AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(ped, speeches[math.random(#speeches)], voice_name, "SPEECH_PARAMS_FORCE_SHOUTED", 0)
            end},
            {name = 'Mute peds', command = 'JSmutePeds', description = 'Because I don\'t want to hear that dude talk about his gay dog any more.', action = function(ped)
                if PED.IS_PED_A_PLAYER(ped) then return end
                AUDIO.STOP_PED_SPEAKING(ped, true)
            end},
            {name = 'Npc horn boost', command = 'JSnpcHornBoost', description = 'Boosts npcs that horn.', action = function(ped)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                if PED.IS_PED_A_PLAYER(ped) or not PED.IS_PED_IN_ANY_VEHICLE(ped, true) or not AUDIO.IS_HORN_ACTIVE(vehicle) then return end
                AUDIO.SET_AGGRESSIVE_HORNS(true) --Makes pedestrians sound their horn longer, faster and more agressive when they use their horn.
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, ENTITY.GET_ENTITY_SPEED(vehicle) + 1.2)
            end, onStop = function()
                AUDIO.SET_AGGRESSIVE_HORNS(false)
            end},
            {name = 'Npc siren boost', command = 'JSnpcSirenBoost', description = 'Boosts npcs cars with an active siren.', action = function(ped)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                if PED.IS_PED_A_PLAYER(ped) or not PED.IS_PED_IN_ANY_VEHICLE(ped, true) or not VEHICLE.IS_VEHICLE_SIREN_ON(vehicle) then return end
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, ENTITY.GET_ENTITY_SPEED(vehicle) + 1.2)
            end},
            {name = 'Auto kill enemies', command = 'JSautokill', description = 'Just instantly kills hostile peds.', action = function(ped) --basically copy pasted form wiri script
                local rel = PED.GET_RELATIONSHIP_BETWEEN_PEDS(players.user_ped(), ped)
                if PED.IS_PED_A_PLAYER(ped) or ENTITY.IS_ENTITY_DEAD(ped) or not( (rel == 4 or rel == 5) or PED.IS_PED_IN_COMBAT(ped, players.user_ped()) ) then return end
                ENTITY.SET_ENTITY_HEALTH(ped, 0, 0)
            end},
        }
        for i = 1, #pedToggleLoops do
            world_ped_root:toggle_loop(pedToggleLoops[i].name, {pedToggleLoops[i].command}, pedToggleLoops[i].description, function()
                local pedHandles = entities.get_all_peds_as_handles()
                for j = 1, #pedHandles do
                    pedToggleLoops[i].action(pedHandles[j])
                end
                util.yield(10)
            end, function()
                if pedToggleLoops[i].onStop then pedToggleLoops[i].onStop() end
            end)
        end

        --[[
        sex_voicelines = false
        world_root:toggle(Translations.sex_voicelines, {}, Translations.sex_voicelines_desc, function(toggle)
            local voice_name = all_sex_voicenames[math.random(1, #all_sex_voicenames)]
            local speeches = {
                "SEX_GENERIC_FEM",
                "SEX_HJ",
                "SEX_ORAL_FEM",
                "SEX_CLIMAX",
                "SEX_GENERIC"
            }
            AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(ped, speeches[math.random(#speeches)], voice_name, "SPEECH_PARAMS_FORCE_SHOUTED", 0)
        end)
        ]]

        world_root:action("Kill All Peds", {}, "For mission", function()
            local counter = 0
            for _, ped in entities.get_all_peds_as_handles() do
                if HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(ped)) == 1 or TASK.GET_IS_TASK_ACTIVE(ped, 352) then --shitty way to go about it but hey, it works (most of the time).
                    ENTITY.SET_ENTITY_HEALTH(ped, 0)
                    counter += 1
                    util.yield()
                end
            end
            if counter == 0 then
                util.toast("No Peds Found. :/")
            else
                util.toast("Killed ".. tostring(counter) .." Peds.")
            end
        end)

        world_root:toggle_loop("Friendly AI", {""}, "AIs won't target you.", function()
            PED.SET_PED_RESET_FLAG(players.user_ped(), 124, true)
        end)

        world_root:toggle_loop("PED_NERF", {}, "PED_NERF_DESC", function()
        	PED.SET_AI_WEAPON_DAMAGE_MODIFIER(0)
        	PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0)
        end, function()
        	PED.SET_AI_WEAPON_DAMAGE_MODIFIER(1)
        	PED.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(1)
        end)

        --[[
        --lancescript
        --speedrun
        menu.toggle_loop(speedrun_root, translations.speedrun_criminal_damage, {translations.speedrun_criminal_damage_cmd}, translations.seizure_warning, function(on)
            if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("am_criminal_damage")) ~= 0 then
                if memory.read_int(memory.script_local("am_criminal_damage", 2040 + 1+players.user()*7 + 2)) == 3 then
                    hash = util.joaat('titan')
                    local c = {}
                    c.x = 4497.2207
                    c.y = 8028.3086
                    c.z = -32.635174
                    request_model_load(hash) 
                    local v = entities.create_vehicle(hash, c, math.random(0, 270))
                    if v ~= 0 then
                        PED.SET_PED_INTO_VEHICLE(players.user_ped(), v, -1)
                        while not ENTITY.IS_ENTITY_IN_WATER(v) or not PED.IS_PED_IN_VEHICLE(players.user_ped(), v, false) do
                            util.yield()
                        end
                        util.yield(5)
                        entities.delete_by_handle(v)
                    end
                end
            end
        end)

        menu.toggle_loop(speedrun_root, translations.speedrun_checkpoint_collection, {translations.speedrun_checkpoint_collection}, translations.seizure_warning, function(cp_speedrun_on)
            if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("am_cp_collection")) ~= 0 then
                local cp_blip = HUD.GET_NEXT_BLIP_INFO_ID(431)
                if cp_blip ~= 0 then
                    local c = HUD.GET_BLIP_COORDS(cp_blip)
                    ENTITY.SET_ENTITY_COORDS(players.user_ped(), c.x, c.y, c.z, false, false, false, false)
                end
            end
        end)
    ]]
    --===============--
    -- FIN Monde
    --===============--

    --===============--
    --[[ Détections ]] local detex_root = main_root:list(Translations.detection_root, {}, Translations.detection_root_desc)
    --===============--

        -- PED
        menu.divider(detex_root, Translations.detection_divider_ped)

        detex_root:toggle_loop(Translations.detection_godmode, {}, Translations.detection_godmode_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                --local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
                for _, id in interior_stuff do
                    if players.is_godmode(pid) and not players.is_in_interior(pid) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and GetSpawnState(pid) == 99 and IsPlayerInInterior(pid) == id then
                        notification.draw_debug_text(Translations.detection_godmode_draw, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_glitched_godmode, {}, Translations.detection_glitched_godmode_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local height = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped)
                for _, id in interior_stuff do
                    if players.is_in_interior(pid) and players.is_godmode(pid) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and GetSpawnState(pid) == 99 and IsPlayerInInterior(pid) == id and height >= 0.0 then
                        notification.draw_debug_text(Translations.detection_glitched_godmode_draw, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_super_run, {}, Translations.detection_super_run_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local ped_speed = (ENTITY.GET_ENTITY_SPEED(ped)* 2.236936)
                if not util.is_session_transition_active() and IsPlayerInInterior(pid) == 0 and GetSpawnState(pid) ~= 0 and not PED.IS_PED_DEAD_OR_DYING(ped) 
                and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_IN_ANY_VEHICLE(ped, false)
                and not TASK.IS_PED_STILL(ped) and not PED.IS_PED_JUMPING(ped) and not ENTITY.IS_ENTITY_IN_AIR(ped) and not PED.IS_PED_CLIMBING(ped) and not PED.IS_PED_VAULTING(ped)
                and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) <= 300.0 and ped_speed > 30 then
                    notification.stand(Translations.detection_super_run_toast, players.get_name(pid))
                    break
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_tp, {}, Translations.detection_tp_desc, function()
            for _, pid in ipairs(players.list(true, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped) then
                    local oldpos = players.get_position(pid)
                    util.yield(50) --250
                    local currentpos = players.get_position(pid)
                    local distance_between_tp = v3.distance(oldpos, currentpos)
                    if distance_between_tp > 300.0 then --500.0
                        for i, id in interior_stuff do
                            if IsPlayerInInterior(pid) == id  and GetSpawnState(pid) ~= 0 and players.exists(pid) then
                                util.yield(100)
                                notification.stand(Translations.detection_tp_toast, players.get_name(pid), SYSTEM.ROUND(distance_between_tp))
                            end
                        end
                    end
                end
            end
        end)

        -- Jinx
        detex_root:toggle_loop(Translations.detection_tp_v2, {}, Translations.detection_tp_v2_desc, function()
            for _, pid in players.list(true, true, true) do
                local old_pos = players.get_position(pid)
                util.yield(50)
                local cur_pos = players.get_position(pid)
                local distance_between_tp = v3.distance(old_pos, cur_pos)
                for _, id in interior_stuff do
                    if IsPlayerInInterior(pid) == id and GetSpawnState(pid) ~= 0 and players.exists(pid) then
                        util.yield(100)
                        if distance_between_tp > 300.0 then
                            notification.stand(Translations.detection_tp_v2_toast, players.get_name(pid), SYSTEM.ROUND(distance_between_tp))
                        end
                    end
                end
            end
        end)

        --[[detex_root:toggle_loop(Translations.detection_no_clip, {}, Translations.detection_no_clip_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local ped_ptr = entities.handle_to_pointer(ped)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                local oldpos = players.get_position(pid)
                util.yield()
                local currentpos = players.get_position(pid)
                local vel = ENTITY.GET_ENTITY_VELOCITY(ped)
                if not util.is_session_transition_active() and players.exists(pid)
                and IsPlayerInInterior(pid) == 0 and GetSpawnState(pid) ~= 0
                and not PED.IS_PED_IN_ANY_VEHICLE(ped, false)
                and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped)
                and not PED.IS_PED_CLIMBING(ped) and not PED.IS_PED_VAULTING(ped) and not PED.IS_PED_USING_SCENARIO(ped)
                and not TASK.GET_IS_TASK_ACTIVE(ped, 160) and not TASK.GET_IS_TASK_ACTIVE(ped, 2)
                and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) <= 395.0  -- 400 was causing false positives
                and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped) > 5.0 and not ENTITY.IS_ENTITY_IN_AIR(ped) and entities.player_info_get_game_state(ped_ptr) == 0
                and oldpos.x ~= currentpos.x and oldpos.y ~= currentpos.y and oldpos.z ~= currentpos.z 
                and vel.x == 0.0 and vel.y == 0.0 and vel.z == 0.0 then
                    notification.stand(Translations.detection_no_clip_toast, players.get_name(pid))
                    break
                end
            end
        end)]]--

        --[[detex_root:toggle_loop("Modded Animation", {}, "", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if PED.IS_PED_USING_ANY_SCENARIO(player) then
                    notification.stand(players.get_name(pid).."\nIs In A Modded Scenario")
                end
            end 
        end)]]--

        -- WEAPON
        menu.divider(detex_root, Translations.detection_divider_weapon)

        detex_root:toggle_loop(Translations.detection_mod_weapon, {}, Translations.detection_mod_weapon_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local weapon_player_hash = WEAPON.GET_SELECTED_PED_WEAPON(ped)
                for i, hash in Modded_weapons do
                    local weapon_hash = util.joaat(hash)
                    --si le joueur possède une arme moddé et (a une arme a la main ou vise avec une arme ou vise avec une arme )
                    --WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX
                    --if WEAPON.HAS_PED_GOT_WEAPON(ped, weapon_hash, false) and (WEAPON.IS_PED_ARMED(ped, 7) or TASK.GET_IS_TASK_ACTIVE(ped, 8) or TASK.GET_IS_TASK_ACTIVE(ped, 9)) then
                    if weapon_player_hash == weapon_hash then
                        if WeaponFromHash(weapon_player_hash) then
                            notification.stand(Translations.detection_mod_weapon_toast1, players.get_name(pid), WeaponFromHash(weapon_player_hash))
                        else
                            notification.stand(Translations.detection_mod_weapon_toast2, players.get_name(pid), util.reverse_joaat(weapon_player_hash))
                        end
                        break
                    end
                end
            end
        end)

        --[[detex_root:toggle_loop("Weapon In Interior", {}, "", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if players.is_in_interior(pid) and WEAPON.IS_PED_ARMED(player, 7) then
                    notification.stand(players.get_name(pid).."\nHas A Weapon In An Interior")
                    break
                end
            end
        end)]]--

        -- VEHICULE
        menu.divider(detex_root, Translations.detection_divider_veh)

        detex_root:toggle_loop(Translations.detection_veh_godmode, {}, Translations.detection_veh_godmode_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                --local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) and VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1) ~= 0 then
                    for _, id in interior_stuff do
                        if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(vehicle) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and GetSpawnState(pid) == 99 and IsPlayerInInterior(pid) == id then
                            notification.draw_debug_text(Translations.detection_veh_godmode_draw, players.get_name(pid))
                            break
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_unreleased_vehicle, {}, Translations.detection_unreleased_vehicle_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                --PED.IS_PED_IN_ANY_VEHICLE(ped, false) return true si le ped est dans un vehicle
                if vehicle ~= 0 then
                    local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
                    if driver == pid then
                        local modelHash = players.get_vehicle_model(pid)
                        for i, name in ipairs(Unreleased_vehicles) do
                            if modelHash == util.joaat(name) then
                                notification.stand(Translations.detection_unreleased_vehicle_toats, players.get_name(pid), util.get_label_text(modelHash))
                                --notification.draw_debug_text(Translations.detection_unreleased_vehicle_draw, players.get_name(pid), name)
                                break
                            end
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_mod_veh, {}, Translations.detection_mod_veh_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
                if driver == pid then
                    local modelHash = players.get_vehicle_model(pid)
                    for i, name in Modded_vehicles do
                        if modelHash == util.joaat(name) then
                            if util.get_label_text(modelHash) == "NULL" then
                                notification.stand(Translations.detection_mod_veh_toast, players.get_name(pid), util.reverse_joaat(modelHash))
                            else
                                notification.stand(Translations.detection_mod_veh_toast, players.get_name(pid), util.get_label_text(modelHash))
                            end
                            --notification.draw_debug_text(Translations.detection_mod_veh_draw, players.get_name(pid), name)
                            break
                        end
                    end
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_super_drive, {}, Translations.detection_super_drive_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
                if driver == pid then
                    local veh_speed = (ENTITY.GET_ENTITY_SPEED(vehicle)* 3.6)
                    local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
                    --veh_speed >= 180
                    if class ~= 15 and class ~= 16 and veh_speed >= 245 and (players.get_vehicle_model(pid) ~= util.joaat("oppressor") or players.get_vehicle_model(pid) ~= util.joaat("oppressor2")) then -- not checking opressor mk1 cus its stinky
                        notification.stand(Translations.detection_super_drive_toast, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        -- Jinx
        detex_root:toggle_loop("Spawned Vehicle", {}, "Detects if someone use driving a spawned vehicle.", function()
            for _, pid in players.list(false, true, true) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
                local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
                if players.get_name(pid) ~= "InvalidPlayer" and players.get_vehicle_model(pid) ~= 0 then
                    if DECORATOR.DECOR_GET_INT(vehicle, "MPBitset") == 8 or DECORATOR.DECOR_GET_INT(vehicle, "MPBitset") == 1024 and PED.IS_PED_IN_ANY_VEHICLE(ped, false) and GetSpawnState(players.user()) ~= 0 then 
                        notification.draw_debug_text(players.get_name(driver) .. " Is Using A Spawned Vehicle " .. "(Model: " .. util.reverse_joaat(players.get_vehicle_model(pid)) .. ")")
                        break
                    end
                end
            end 
        end)

        -- PLAYER
        menu.divider(detex_root, Translations.detection_divider_player)

        --Ne fonctionne pas ?
        detex_root:toggle_loop(Translations.detection_spectate, {}, Translations.detection_spectate_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                for i, interior in interior_stuff do
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    if not util.is_session_transition_active() and GetSpawnState(pid) ~= 0 and IsPlayerInInterior(pid) == interior
                    and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped) then
                        if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_cam_pos(pid)) < 15.0 and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 20.0 then
                            notification.stand(Translations.detection_spectate_toast, players.get_name(pid))
                            break
                        end
                    end
                end
            end
        end)

        -- jinx
        detex_root:toggle_loop(Translations.detection_watch_you, {}, Translations.detection_watch_you_desc, function()
            for _, pid in players.list(false, true, true) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if not PED.IS_PED_DEAD_OR_DYING(ped) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) then
                    if v3.distance(players.get_position(players.user()), players.get_cam_pos(pid)) < 20.0 and v3.distance(players.get_position(players.user()), players.get_position(pid)) > 50.0 then
                        notification.stand(Translations.detection_watch_you_toast, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        -- Jinx
        detex_root:toggle_loop(Translations.detection_thunder_join, {}, Translations.detection_thunder_join_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                if GetSpawnState(players.user()) == 0 then return end
                local old_sh = players.get_script_host()
                util.yield(100)
                local new_sh = players.get_script_host()
                if old_sh ~= new_sh then
                    if GetSpawnState(pid) == 0 and players.get_script_host() == pid then
                        notification.stand(Translations.detection_thunder_join_toast, players.get_name(pid))
                        break
                    end
                end
            end
        end)

        -- ORBITAL CANNON
        menu.divider(detex_root, Translations.detection_divider_orbital_cannon)

        detex_root:toggle_loop(Translations.detection_mod_orbital_cannon, {}, Translations.detection_mod_orbital_cannon_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if IsPlayerUsingOrbitalCannon(pid) and not TASK.GET_IS_TASK_ACTIVE(ped, 135) and GetSpawnState(pid) ~= 0 then
                    notification.stand(Translations.detection_mod_orbital_cannon_toast, players.get_name(pid))
                    break
                end
            end
        end)

        detex_root:toggle_loop(Translations.detection_orbital_canon, {}, Translations.detection_orbital_canon_desc, function()
            for _, pid in ipairs(players.list(false, true, true)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if IsPlayerUsingOrbitalCannon(pid) and TASK.GET_IS_TASK_ACTIVE(ped, 135)then
                    notification.stand(Translations.detection_orbital_canon_toast, players.get_name(pid))
                    break
                end
            end
        end)


        --lancescript detection missile kosatka

        local kosatka_missile_blips = {}
        local draw_kosatka_blips = false
        detex_root:toggle(Translations.warn_kosatka_missiles, {}, "", function(toggle)
            draw_kosatka_blips = toggle
            while true do
                if not draw_kosatka_blips then
                    for hdl, blip in pairs(kosatka_missile_blips) do
                        kosatka_missile_blips[hdl] = nil
                        util.remove_blip(blip)
                    end
                    break
                end
                if util.is_session_started() then
                    local missile_ct = 0
                    for _, ent_ptr in pairs(entities.get_all_objects_as_pointers()) do
                        if entities.get_model_hash(ent_ptr) == util.joaat("h4_prop_h4_airmissile_01a") then
                            local hdl = entities.pointer_to_handle(ent_ptr)
                            local pos = entities.get_position(ent_ptr)
                            if kosatka_missile_blips[hdl] == nil then
                                local blip = HUD.ADD_BLIP_FOR_COORD(pos.x, pos.y, pos.z)
                                HUD.SET_BLIP_SPRITE(blip, 548)
                                HUD.SET_BLIP_COLOUR(blip, 59)
                                HUD.SET_BLIP_ROTATION(blip, math.ceil(ENTITY.GET_ENTITY_HEADING(hdl)))
                                kosatka_missile_blips[hdl] = blip
                            else
                                HUD.SET_BLIP_ROTATION(kosatka_missile_blips[hdl], math.ceil(ENTITY.GET_ENTITY_HEADING(hdl)+180))
                                HUD.SET_BLIP_COORDS(kosatka_missile_blips[hdl], pos.x, pos.y, pos.z)
                            end
                            missile_ct += 1
                        end
                    end
                    if missile_ct > 0 then
                        util.draw_debug_text(missile_ct .. Translations.kosatka_missile_alert)
                    end
                    for hdl, blip in pairs(kosatka_missile_blips) do
                        if not ENTITY.DOES_ENTITY_EXIST(hdl) then
                            kosatka_missile_blips[hdl] = nil
                            util.remove_blip(blip)
                        end
                    end
                end
                util.yield()
            end
        end)

        -- detection canon orbital

        local orbital_blips = {}
        local draw_orbital_blips = false
        detex_root:toggle(Translations.warn_orb, {}, "", function(toggle)
            draw_orbital_blips = toggle
            while true do
                if not draw_orbital_blips then
                    for pid, blip in pairs(orbital_blips) do
                        util.remove_blip(blip)
                        orbital_blips[pid] = nil
                    end
                    break
                end
                for _, pid in players.list(true, true, true) do
                    local cam_rot = players.get_cam_rot(pid)
                    local cam_pos = players.get_cam_pos(pid)
                    if cam_pos.z >= 390.0 and cam_pos.z <= 850.0 and cam_rot.x == 270.0 and cam_rot.y == 0.0 and cam_rot.z == 0.0 and players.is_in_interior(pid) then
                        util.draw_debug_text(players.get_name(pid) .. Translations.orbital_cannon_warn)
                        if orbital_blips[pid] == nil then
                            local blip = HUD.ADD_BLIP_FOR_COORD(cam_pos.x, cam_pos.y, cam_pos.z)
                            HUD.SET_BLIP_SPRITE(blip, 588)
                            HUD.SET_BLIP_COLOUR(blip, 59)
                            HUD.SET_BLIP_NAME_TO_PLAYER_NAME(blip, pid)
                            orbital_blips[pid] = blip
                        else
                            HUD.SET_BLIP_COORDS(orbital_blips[pid], cam_pos.x, cam_pos.y, cam_pos.z)
                        end
                    else
                        if orbital_blips[pid] ~= nil then
                            util.remove_blip(orbital_blips[pid])
                            orbital_blips[pid] = nil
                        end
                    end
                end
                util.yield()
            end
        end)

        -- CHEATER
        menu.divider(detex_root, "CHEATER")
        detex_root:toggle_loop("High-Money", {}, "Detects people with over 100 million", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                if players.get_money(pid) > 100000000 then --600000000
                    notification.draw_debug_text("%s has modded money", players.get_name(pid))
                end
            end
        end)

        detex_root:toggle_loop("High-Level", {}, "Detects people over level 1000", function()
            for _, pid in ipairs(players.list(false, true, true)) do
                if players.get_rank(pid) > 1000 then
                    notification.draw_debug_text("%s has a moddel level", players.get_name(pid))
                end
            end
        end)

    --===============--
    -- FIN Détections
    --===============--

    --===============--
    --[[ Protections ]] local protex_root = main_root:list(Translations.protection_root, {}, Translations.protection_root_desc)
    --===============--

        local protections_list = {
            mission = { -- on = 4
                "Online>Protections>Events>Crash Event",
                "Online>Protections>Events>Kick Event",
                "Online>Protections>Events>Modded Event",
                "Online>Protections>Events>Trigger Business Raid",
                "Online>Protections>Events>Start Freemode Mission",
                "Online>Protections>Events>Start Freemode Mission (Not My Boss)",
                "Online>Protections>Events>Teleport To Interior",
                "Online>Protections>Events>Teleport To Interior (Not My Boss)",
                "Online>Protections>Events>Give Collectible",
                "Online>Protections>Events>Give Collectible (Not My Boss)",
                "Online>Protections>Events>CEO/MC Kick",
                "Online>Protections>Events>Infinite Loading Screen",
                "Online>Protections>Events>Infinite Phone Ringing",
                "Online>Protections>Events>Teleport To Cayo Perico",
                "Online>Protections>Events>Cayo Perico Invite",
                "Online>Protections>Events>Apartment Invite",
                "Online>Protections>Events>Send To Cutscene",
                "Online>Protections>Events>Send To Job",
                "Online>Protections>Events>Transaction Error Event",
                "Online>Protections>Events>Vehicle Takeover",
                "Online>Protections>Events>Disable Driving Vehicles",
                "Online>Protections>Events>Kick From Vehicle",
                "Online>Protections>Events>Kick From Interior",
                "Online>Protections>Events>Freeze",
                "Online>Protections>Events>Force Camera Forward",
                "Online>Protections>Events>Love Letter Kick Blocking Event",
                "Online>Protections>Events>Camera Shaking Event",
                "Online>Protections>Events>Explosion Spam",
                "Online>Protections>Events>Ragdoll Event",

                    "Online>Protections>Events>Raw Network Events>Any Event",
                    "Online>Protections>Events>Raw Network Events>Script Event",
                    "Online>Protections>Events>Raw Network Events>OBJECT_ID_FREED_EVENT",
                    "Online>Protections>Events>Raw Network Events>OBJECT_ID_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>ARRAY_DATA_VERIFY_EVENT",
                    "Online>Protections>Events>Raw Network Events>SCRIPT_ARRAY_DATA_VERIFY_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_CONTROL_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_CONTROL_EVENT",
                    "Online>Protections>Events>Raw Network Events>WEAPON_DAMAGE_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_PICKUP_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_MAP_PICKUP_EVENT",
                    "Online>Protections>Events>Raw Network Events>RESPAWN_PLAYER_PED_EVENT",
                    "Online>Protections>Events>Raw Network Events>Give Weapon Event",
                    "Online>Protections>Events>Raw Network Events>Remove Weapon Event",
                    "Online>Protections>Events>Raw Network Events>Remove All Weapons Event",
                    "Online>Protections>Events>Raw Network Events>VEHICLE_COMPONENT_CONTROL_EVENT",
                    "Online>Protections>Events>Raw Network Events>Fire",
                    "Online>Protections>Events>Raw Network Events>Explosion",
                    "Online>Protections>Events>Raw Network Events>START_PROJECTILE_EVENT",
                    "Online>Protections>Events>Raw Network Events>UPDATE_PROJECTILE_TARGET_EVENT",
                    "Online>Protections>Events>Raw Network Events>BREAK_PROJECTILE_TARGET_LOCK_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOVE_PROJECTILE_ENTITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>ALTER_WANTED_LEVEL_EVENT",
                    "Online>Protections>Events>Raw Network Events>CHANGE_RADIO_STATION_EVENT",
                    "Online>Protections>Events>Raw Network Events>RAGDOLL_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>PLAYER_TAUNT_EVENT",
                    "Online>Protections>Events>Raw Network Events>PLAYER_CARD_STAT_EVENT",
                    "Online>Protections>Events>Raw Network Events>DOOR_BREAK_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOTE_SCRIPT_INFO_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOTE_SCRIPT_LEAVE_EVENT",
                    "Online>Protections>Events>Raw Network Events>MARK_AS_NO_LONGER_NEEDED_EVENT",
                    "Online>Protections>Events>Raw Network Events>CONVERT_TO_SCRIPT_ENTITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>SCRIPT_WORLD_STATE_EVENT",
                    "Online>Protections>Events>Raw Network Events>INCIDENT_ENTITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>CLEAR_AREA_EVENT",
                    "Online>Protections>Events>Raw Network Events>CLEAR_RECTANGLE_AREA_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_REQUEST_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_START_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_UPDATE_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_STOP_SYNCED_SCENE_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_PED_SCRIPTED_TASK_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_PED_SEQUENCE_TASK_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_CLEAR_PED_TASKS_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_START_PED_ARREST_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_START_PED_UNCUFF_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_SOUND_CAR_HORN_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_ENTITY_AREA_STATUS_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_GARAGE_OCCUPIED_STATUS_EVENT",
                    "Online>Protections>Events>Raw Network Events>PED_CONVERSATION_LINE_EVENT",
                    "Online>Protections>Events>Raw Network Events>SCRIPT_ENTITY_STATE_CHANGE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_PLAY_SOUND_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_STOP_SOUND_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_PLAY_AIRDEFENSE_FIRE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_BANK_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_AUDIO_BARK_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_DOOR_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_TRAIN_REQUEST_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_TRAIN_REPORT_EVENT",
                    "Online>Protections>Events>Raw Network Events>MODIFY_VEHICLE_LOCK_WORD_STATE_DATA",
                    "Online>Protections>Events>Raw Network Events>MODIFY_PTFX_WORD_STATE_DATA_SCRIPTED_EVOLVE_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_PHONE_EXPLOSION_EVENT",
                    "Online>Protections>Events>Raw Network Events>REQUEST_DETACHMENT_EVENT",
                    "Online>Protections>Events>Raw Network Events>KICK_VOTES_EVENT",
                    "Online>Protections>Events>Raw Network Events>GIVE_PICKUP_REWARDS_EVENT",
                    --"Online>Protections>Events>Raw Network Events>NETWORK_CRC_HASH_CHECK_EVENT",
                    "Online>Protections>Events>Raw Network Events>BLOW_UP_VEHICLE_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_SPECIAL_FIRE_EQUIPPED_WEAPON",
                    "Online>Protections>Events>Raw Network Events>NETWORK_RESPONDED_TO_THREAT_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_SHOUT_TARGET_POSITION",
                    "Online>Protections>Events>Raw Network Events>VOICE_DRIVEN_MOUTH_MOVEMENT_FINISHED_EVENT",
                    "Online>Protections>Events>Raw Network Events>PICKUP_DESTROYED_EVENT",
                    "Online>Protections>Events>Raw Network Events>UPDATE_PLAYER_SCARS_EVENT",
                    "Online>Protections>Events>Raw Network Events>NETWORK_CHECK_EXE_SIZE_EVENT",
                    "Online>Protections>Events>Raw Network Events>PTFX",
                    "Online>Protections>Events>Raw Network Events>NETWORK_PED_SEEN_DEAD_PED_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOVE_STICKY_BOMB_EVENT",
                    --"Online>Protections>Events>Raw Network Events>NETWORK_CHECK_CODE_CRCS_EVENT",
                    "Online>Protections>Events>Raw Network Events>INFORM_SILENCED_GUNSHOT_EVENT",
                    "Online>Protections>Events>Raw Network Events>PED_PLAY_PAIN_EVENT",
                    "Online>Protections>Events>Raw Network Events>CACHE_PLAYER_HEAD_BLEND_DATA_EVENT",
                    "Online>Protections>Events>Raw Network Events>REMOVE_PED_FROM_PEDGROUP_EVENT",
                    --"Online>Protections>Events>Raw Network Events>REPORT_MYSELF_EVENT",
                    "Online>Protections>Events>Raw Network Events>REPORT_CASH_SPAWN_EVENT",
                    "Online>Protections>Events>Raw Network Events>ACTIVATE_VEHICLE_SPECIAL_ABILITY_EVENT",
                    "Online>Protections>Events>Raw Network Events>BLOCK_WEAPON_SELECTION",
                    "Online>Protections>Events>Raw Network Events>NETWORK_CHECK_CATALOG_CRC",

                "Online>Protections>Detections>Spoofed Host Token (Aggressive)",
                "Online>Protections>Detections>Spoofed Host Token (Sweet Spot)",
                "Online>Protections>Detections>Spoofed Host Token (Handicap)",
                "Online>Protections>Detections>Spoofed Host Token (Other)",

                "Online>Protections>Syncs>World Object Sync",
                "Online>Protections>Syncs>Invalid Model Sync",
                    "Online>Protections>Syncs>Incoming>Any Incoming Sync",
                    "Online>Protections>Syncs>Incoming>Clone Create",
                    "Online>Protections>Syncs>Incoming>Clone Update",
                    "Online>Protections>Syncs>Incoming>Clone Delete",
                    "Online>Protections>Syncs>Incoming>Acknowledge Clone Create",
                    "Online>Protections>Syncs>Incoming>Acknowledge Clone Update",
                    "Online>Protections>Syncs>Incoming>Acknowledge Clone Delete",

                    "Online>Protections>Syncs>Outgoing>Clone Create",
                    "Online>Protections>Syncs>Outgoing>Clone Update",
                    "Online>Protections>Syncs>Outgoing>Clone Delete",

                "Online>Protections>Text Messages>Any Message",
                "Online>Protections>Text Messages>Advertisement",
                "Online>Protections>Text Messages>Bypassed Message Filter",

                "Online>Protections>Session Script Start>Any Script",
                "Online>Protections>Session Script Start>Uncategorised",
                "Online>Protections>Session Script Start>Freemode Activity",
                "Online>Protections>Session Script Start>Arcade Game",
                "Online>Protections>Session Script Start>Removed Freemode Activity",
                "Online>Protections>Session Script Start>Session Breaking",
                "Online>Protections>Session Script Start>Service",
                "Online>Protections>Session Script Start>Open Interaction Menu",
                "Online>Protections>Session Script Start>Flight School",
                "Online>Protections>Session Script Start>Lightning Strike For Random Player",
                "Online>Protections>Session Script Start>Disable Passive Mode",
                "Online>Protections>Session Script Start>Darts",
                "Online>Protections>Session Script Start>Impromptu Deathmatch",
                "Online>Protections>Session Script Start>Slasher",
                "Online>Protections>Session Script Start>Cutscene",

                "Online>Protections>Pickups>Any Pickup Collected",
                "Online>Protections>Pickups>Cash Pickup Collected",
                "Online>Protections>Pickups>RP Pickup Collected",
                "Online>Protections>Pickups>Invalid Pickup Collected",

                --"Online>Protections>Block Blaming",

                --"Online>Protections>Script Error Recovery",
            }
        }

        local protections_value = {mission = {}}

        protex_root:toggle(Translations.protection_mission, {}, Translations.protection_mission_desc, function(toggle)
            for _, path in pairs(protections_list.mission) do
                if toggle then
                    protections_value.mission[path..">Block"] = menu.ref_by_path(path..">Block", Tree_V).value
                    menu.ref_by_path(path..">Block", Tree_V):applyDefaultState()
                    --print(path .. ">Block : " .. protections_value.mission[path..">Block"])
                elseif menu.ref_by_path(path..">Block", Tree_V).value ~= menu.ref_by_path(path..">Block", Tree_V):getDefaultState() then
                    print("1")
                    SetPathVal(path..">Block", protections_value.mission[path..">Block"])
                end
            end
        end)

        -------------------
        --- ANTI-CAGES
        -------------------
        local anticage_root = protex_root:list("Anti-Cage", {}, "")

            local alpha = 88
            local radius = 10
            local cleanup = false
            local doors = {
                "v_ilev_ml_door1",
                "v_ilev_ta_door",
                "v_ilev_247door",
                "v_ilev_247door_r",
                "v_ilev_lostdoor",
                "v_ilev_bs_door",
                "v_ilev_cs_door01",
                "v_ilev_cs_door01_r",
                "v_ilev_gc_door03",
                "v_ilev_gc_door04",
                "v_ilev_clothmiddoor",
                "v_ilev_clothmiddoor",
                "prop_shop_front_door_l",
                "prop_shop_front_door_r"
            }
            --[[local values = {
                [1] = 50,
                [2] = 88,
                [3] = 160,
                [4] = 208,
            }]]
            local values = {
                [0] = 0,
                [1] = 51,
                [2] = 102,
                [3] = 153,
                [4] = 204,
                [5] = 255,
            }

            anticage_root:toggle_loop("Enable Anti-Cage", {"anticage"}, "", function()
                local user = players.user_ped()
                local veh = PED.GET_VEHICLE_PED_IS_USING(user)
                local my_ents = {user, veh}
                for i, obj_ptr in entities.get_all_objects_as_pointers() do
                    local net_obj = memory.read_long(obj_ptr + 0xd0)
                    if net_obj == 0 or memory.read_byte(net_obj + 0x49) == players.user() then
                        continue
                    end
                    local obj_handle = entities.pointer_to_handle(obj_ptr)
                    local owner = entities.get_owner(obj_ptr)
                    local id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(obj_handle)
                    CAM.SET_GAMEPLAY_CAM_IGNORE_ENTITY_COLLISION_THIS_UPDATE(obj_handle)
                    for _, door in doors do
                        if entities.get_model_hash(obj_ptr) ~= util.joaat(door) then
                            continue
                        end
                    end
                    for i, data in my_ents do
                        if v3.distance(players.get_position(players.user()), ENTITY.GET_ENTITY_COORDS(obj_handle)) <= radius then
                            if data ~= 0 and alpha >= 1 then
                                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(obj_handle, data, false)  
                                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(data, obj_handle, false)
                                ENTITY.SET_ENTITY_ALPHA(obj_handle, alpha, false)
                            end
                            if data ~= 0 and cleanup then
                                entities.set_can_migrate(obj_ptr, true)
                                ENTITY.SET_ENTITY_ALPHA(obj_handle, 0, false)
                                entities.delete_by_handle(obj_handle)
                            end
                            if data ~= 0 and ENTITY.IS_ENTITY_TOUCHING_ENTITY(data, obj_handle) then
                                util.toast("Blocked Cage From " .. players.get_name(owner))
                                util.log("Blocked Cage From " .. players.get_name(owner))
                            end
                        end
                    end
                    SHAPETEST.RELEASE_SCRIPT_GUID_FROM_ENTITY(obj_handle)
                end
            end)

            anticage_root:slider("Transparency", {}, "The amount of transparency that cage objects will have.", 0, #values, 2, 1, function(value)
                alpha = values[value]
            end)

            anticage_root:slider_float("Blocking Radius", {}, "The radius in which anti-cage will detect for cages.", 100, 2500, 1000, 100, function(value)
                radius = value/100
            end)

            anticage_root:toggle("Auto Cleanup", {}, "Automatically delete any cages that get spawned.", function(toggle)
                cleanup = toggle
            end, cleanup)

        -------------------
        --- ANTI-AGRESSEURS
        -------------------
        local anti_muggers_root = protex_root:list(Translations.protection_anti_mugger_root, {}, Translations.protection_anti_mugger_root_desc)

        local myself_notif = false
        local someone_else_notif = false

            --MYSELF
            local anti_muggers_myself_root = anti_muggers_root:list(Translations.protection_anti_mugger_myself_root, {}, Translations.protection_anti_mugger_myself_root_desc)

                anti_muggers_myself_root:toggle_loop(Translations.protection_anti_mugger_myself_active, {}, Translations.protection_anti_mugger_myself_active_desc, function() -- thx nowiry for improving my method :D
                    if NETWORK.NETWORK_IS_SESSION_ACTIVE() and NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
                        util.spoof_script("am_gang_call", function()
                            local ped_netId = memory.read_int(memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1)))
                            local mugger = NETWORK.NET_TO_PED(ped_netId)

                            --(sender ~= player and target == player and 
                            if NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(ped_netId) and NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(ped_netId) and
                            not ENTITY.IS_ENTITY_DEAD(mugger, false) then

                                local sender = memory.read_int(memory.script_local("am_gang_call", 287))
                                local target = memory.read_int(memory.script_local("am_gang_call", 288))
                                local player = players.user()

                                if not myself_notif and sender ~= 0 and --[[sender ~= player and ]]IsPlayerActive(sender, false, false) 
                                and target ~= 0 and target == player and IsPlayerActive(target, false, false) then

                                    local blip = HUD.ADD_BLIP_FOR_ENTITY(mugger)
                                    HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("Agresseur")
                                    HUD.ADD_TEXT_COMPONENT_SUBSTRING_BLIP_NAME(blip)
                                    HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                                    HUD.SET_BLIP_SPRITE(blip, 155) --radar_weapon_knife
                                    HUD.SET_BLIP_COLOUR(blip, 58) --East Bay
                                    --HUD.SHOW_HEADING_INDICATOR_ON_BLIP(mugger, true)

                                    local ped_pos = ENTITY.GET_ENTITY_COORDS(mugger, true)
                                    GRAPHICS.DRAW_MARKER(0, ped_pos.x, ped_pos.y, ped_pos.z+2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 1, 255, 0, 0, 80, false, true, 2, false, 0, 0, false)
                                    DrawBoundingBox(mugger, true, {r = 255, g = 0, b = 0, a = 80})

                                    if anti_muggers_options["myself"]["block"] then
                                        entities.delete_by_handle(mugger)
                                        if anti_muggers_options["myself"]["notif"] then
                                            notification:normal(Translations.protection_anti_mugger_myself_active_toast1, HudColour.purpleDark, GetCondensedPlayerName(sender))
                                            AUDIO.PLAY_SOUND(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", false, 0, false)
                                        end
                                    else
                                        notification:normal(Translations.protection_anti_mugger_myself_active_toast2, HudColour.purpleDark, GetCondensedPlayerName(sender))
                                        AUDIO.PLAY_SOUND(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", false, 0, false)
                                    end
                                end
                            end
                        end)
                    end
                end)

                --OPTIONS
                menu.divider(anti_muggers_myself_root, Translations.protection_anti_mugger_divider_options)

                anti_muggers_myself_root:toggle(Translations.protection_anti_mugger_options_block, {}, "", function(toggle)
                    anti_muggers_options["myself"]["block"] = toggle
                end)

                anti_muggers_myself_root:toggle(Translations.protection_anti_mugger_options_notif, {}, "", function(toggle)
                    anti_muggers_options["myself"]["notif"] = toggle
                end, true)

            --SOMEONE ELSE
            local anti_muggers_someone_else_root = anti_muggers_root:list(Translations.protection_anti_mugger_someone_else_root, {}, Translations.protection_anti_mugger_someone_else_root_desc)

                anti_muggers_someone_else_root:toggle_loop(Translations.protection_anti_mugger_someone_else_active, {}, Translations.protection_anti_mugger_someone_else_active_desc, function()
                    if NETWORK.NETWORK_IS_SESSION_ACTIVE() and NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
                        util.spoof_script("am_gang_call", function()
                            local ped_netId = memory.read_int(memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1)))
                            local mugger = NETWORK.NET_TO_PED(ped_netId)

                            --[[target ~= player and sender ~= player and ]]
                            if NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(ped_netId) and NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(ped_netId) and
                            not ENTITY.IS_ENTITY_DEAD(mugger, false) then

                                local sender = memory.read_int(memory.script_local("am_gang_call", 287))
                                local target = memory.read_int(memory.script_local("am_gang_call", 288))
                                local player = players.user()

                                if not someone_else_notif and sender ~= 0 and --[[sender ~= player and ]]IsPlayerActive(sender, false, false) 
                                and target ~= 0 and target ~= player and IsPlayerActive(target, false, false) then

                                    local blip = HUD.ADD_BLIP_FOR_ENTITY(mugger)
                                    HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("Agresseur")
                                    HUD.ADD_TEXT_COMPONENT_SUBSTRING_BLIP_NAME(blip)
                                    HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                                    HUD.SET_BLIP_SPRITE(blip, 155) --radar_weapon_knife
                                    HUD.SET_BLIP_COLOUR(blip, 58) --East Bay
                                    --HUD.SHOW_HEADING_INDICATOR_ON_BLIP(mugger, true)

                                    local ped_pos = ENTITY.GET_ENTITY_COORDS(mugger, true)
                                    GRAPHICS.DRAW_MARKER(0, ped_pos.x, ped_pos.y, ped_pos.z+2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 1, 255, 0, 0, 80, false, true, 2, false, 0, 0, false)
                                    DrawBoundingBox(mugger, true, {r = 255, g = 0, b = 0, a = 80})

                                    if anti_muggers_options["someone_else"]["block"] then
                                        entities.delete_by_handle(mugger)
                                        if anti_muggers_options["someone_else"]["notif"] then
                                            notification:normal(Translations.protection_anti_mugger_someone_else_active_toast1, HudColour.purpleDark, GetCondensedPlayerName(sender), GetCondensedPlayerName(target))
                                            AUDIO.PLAY_SOUND(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", false, 0, false)
                                        end
                                    else
                                        notification:normal(Translations.protection_anti_mugger_someone_else_active_toast2, HudColour.purpleDark, GetCondensedPlayerName(sender), GetCondensedPlayerName(target))
                                        AUDIO.PLAY_SOUND(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", false, 0, false)
                                    end
                                    someone_else_notif = true
                                end
                            end
                        end)
                    elseif someone_else_notif then
                        someone_else_notif = false
                    end
                end)

                --OPTIONS
                menu.divider(anti_muggers_someone_else_root, Translations.protection_anti_mugger_divider_options)

                anti_muggers_someone_else_root:toggle(Translations.protection_anti_mugger_options_block, {}, "", function(toggle)
                    anti_muggers_options["someone_else"]["block"] = toggle
                end)

                anti_muggers_someone_else_root:toggle(Translations.protection_anti_mugger_options_notif, {}, "", function(toggle)
                    anti_muggers_options["someone_else"]["notif"] = toggle
                end, true)

        --- FIN ANTI-AGRESSEURS

        ------------------
        --- ANTI-VEHICULES
        ------------------
        local anti_vehicles_root = protex_root:list(Translations.protection_anti_veh_root, {}, Translations.protection_anti_veh_root_desc)

            --[[anti_vehicles_root:toggle_loop(Translations.protection_anti_vehicles_active, {"nyav"}, Translations.protection_anti_vehicles_active_desc, function()

                local vehall = entities.get_all_vehicles_as_handles()
                for k, vid in pairs(vehall) do
                    local veh = ENTITY.GET_VEHICLE_INDEX_FROM_ENTITY_INDEX(vid)
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
                    if PED.IS_PED_A_PLAYER(ped) then
                        local model = ENTITY.GET_ENTITY_MODEL(vid)
                        local name = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(model)
                        local pid = PED.GET_PLAYER_PED_IS_FOLLOWING(ped)
                        if pid != players.user() then
                            local hash = ENTITY.GET_ENTITY_MODEL(vid)
                            if Anti_vehicles_list[hash] and RequestControl(veh, 1000) then
                                if VEHICLE.GET_VEHICLE_ENGINE_HEALTH(veh) > -4000 then
                                    --VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, -4000)
                                    --VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, true)
                                    --VEHICLE.BRING_VEHICLE_TO_HALT(veh, 100.0, 1)
                                    --VEHICLE.SET_HELI_BLADES_SPEED(veh, 0.0)
                                    if anti_vehicles_options["notif"] and not anti_vehicles_options["remove"] then
                                        notification.stand(Translations.protection_anti_vehicles_active_toast2, util.reverse_joaat(hash))
                                    end
                                end
                                if anti_vehicles_options["remove"] then
                                    entities.delete_by_handle(veh)
                                    if anti_vehicles_options["notif"] then
                                        notification.stand(Translations.protection_anti_vehicles_active_toast1, util.reverse_joaat(hash))
                                    end
                                end
                            end
                        end
                    end
                end
                util.yield(10)
            end)]]
            anti_vehicles_root:toggle_loop(Translations.protection_anti_vehicles_active, {}, Translations.protection_anti_vehicles_active_desc, function()
                for _, pid in ipairs(players.list(false, true, true)) do
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
                    local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1))
                    if driver == pid then
                        local hash = players.get_vehicle_model(pid)
                        if Anti_vehicles_list[hash] and RequestControl(veh, 1000) then
                            --NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                            if VEHICLE.GET_VEHICLE_ENGINE_HEALTH(veh) > -4000 then
                                --VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, -4000)
                                --VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, true)
                                --VEHICLE.BRING_VEHICLE_TO_HALT(veh, 100.0, 1)
                                --VEHICLE.SET_HELI_BLADES_SPEED(veh, 0.0)
                                if ENTITY.IS_ENTITY_IN_AIR(veh) then
                                    --ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, -0.8, 0, 0, 0.5, 0, false, false, true)
                                end
                                if anti_vehicles_options["notif"] and not anti_vehicles_options["remove"] then
                                    notification:normal(Translations.protection_anti_vehicles_active_toast2, HudColour.red, util.reverse_joaat(hash))
                                end
                            end
                            if anti_vehicles_options["remove"] then
                                entities.delete_by_handle(veh)
                                if anti_vehicles_options["notif"] then
                                    notification:normal(Translations.protection_anti_vehicles_active_toast1, HudColour.red, util.reverse_joaat(hash))
                                end
                            end
                        end
                    end
                end
                util.yield(10)
            end)

            --MANAGE
            menu.divider(anti_vehicles_root, Translations.protection_anti_vehicles_divider_manage)

            anti_vehicles_root:text_input(Translations.protection_anti_vehicles_model, {"nyantivehicleadd"}, Translations.protection_anti_vehicles_model_desc, function(on_input)
                if anti_vehicles_model ~= on_input then
                    if on_input ~= nil then
                        local i = util.joaat(on_input)
                        if Anti_vehicles_list[i] then
                            -- util.get_label_text(modelHash)
                            notification.stand(Translations.protection_anti_vehicles_model_toast1)
                        elseif VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(i) ~= 0 then
                            Anti_vehicles_list[i] = on_input
                            notification.stand(Translations.protection_anti_vehicles_model_toast2)
                        else
                            notification.stand(Translations.protection_anti_vehicles_model_toast3)
                        end
                    else
                        notification.stand(Translations.protection_anti_vehicles_model_toast4)
                    end
                    anti_vehicles_model = on_input
                end
            end, '')

            anti_vehicles_root:action(Translations.protection_anti_vehicles_save, {}, Translations.protection_anti_vehicles_save_desc, function()
                --sauvegarde de la liste
                local filehandle = io.open(anti_vehicles_file, "w")
                if filehandle then
                    filehandle:write(Json.encode(Anti_vehicles_list))
                    filehandle:flush()
                    filehandle:close()
                end
            end)

            Menus.vehlist = anti_vehicles_root:list(Translations.protection_anti_vehicles_list, {}, Translations.protection_anti_vehicles_list_desc, function()
                BuildVehiclesList()
            end)

            --OPTIONS
            menu.divider(anti_vehicles_root, Translations.protection_anti_vehicles_divider_options)

            anti_vehicles_root:toggle(Translations.protection_anti_vehicles_delete, {}, Translations.protection_anti_vehicles_delete_desc, function(toggle)
                anti_vehicles_options["remove"] = toggle
            end)

            anti_vehicles_root:toggle(Translations.protection_anti_vehicles_notif, {}, Translations.protection_anti_vehicles_notif_desc, function(toggle)
                anti_vehicles_options["notif"] = toggle
            end,true)

            anti_vehicles_root:action("test", {}, "", function()
                local vehall = entities.get_all_vehicles_as_handles()
                for k, vid in pairs(vehall) do
                    local veh = ENTITY.GET_VEHICLE_INDEX_FROM_ENTITY_INDEX(vid)
                    local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1)
                    --if PED.IS_PED_A_PLAYER(ped) then
                        local pid = PED.GET_PLAYER_PED_IS_FOLLOWING(ped)
                        --if pid != players.user() then
                            local hash = ENTITY.GET_ENTITY_MODEL(vid)
                            if Anti_vehicles_list[hash] and RequestControl(veh, 1000) then
                                notification:normal("test"..k..": "..VEHICLE.GET_VEHICLE_ENGINE_HEALTH(veh))
                                local pos = ENTITY.GET_ENTITY_COORDS(pid)
                                HUD.SET_NEW_WAYPOINT(pos.x, pos.y)
                                --VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, true)
                            end
                        --end
                    --end
                end
            end)
        --- FIN ANTI-VEHICULES

        ------------------
        --- ANTI-SPECTATEUR
        ------------------
        local anti_spectate_root = protex_root:list("anti spectateur", {}, Translations.protection_anti_veh_root_desc)

            local block_spec_syncs = anti_spectate_root:toggle_loop("Block Spectator Syncs", {}, "Block all syncs with people who spectate you.", function()
                for _, pid in players.list(false, true, true) do
                    local ped_dist = v3.distance(players.get_position(players.user()), players.get_position(pid))
                    if v3.distance(players.get_position(players.user()), players.get_cam_pos(pid)) < 25.0 and ped_dist > 30.0 or players.get_spectate_target(pid) == players.user() then
                        local outgoingSyncs = menu.ref_by_rel_path(menu.player_root(pid), "Outgoing Syncs>Block")
                        outgoingSyncs.value = true
                        local pos = players.get_position(players.user())
                        if v3.distance(pos, players.get_cam_pos(pid)) < 25.0 then
                            repeat 
                                util.yield()
                            until v3.distance(pos, players.get_cam_pos(pid)) > 50.0
                            outgoingSyncs.value = false
                        end
                    end
                end
            end, function()
                for _, pid in players.list(false, true, true) do
                    if players.exists(pid) then
                        local outgoingSyncs = menu.ref_by_rel_path(menu.player_root(pid), "Outgoing Syncs>Block")
                        outgoingSyncs.value = false
                    end
                end
            end)

            local spoof = anti_spectate_root:list("Spoof Spectator Syncs")
            local x = 0.00
            spoof:slider_float("X", {"spoofedx"}, "", 0, 1000000, 1000000, 1, function(x_pos)
                x = x_pos
            end)

            local y = 0.00
            spoof:slider_float("Y", {"spoofedy"}, "", 0, 1000000, 1000000, 1, function(y_pos)
                y = y_pos
            end)

            local z = 0.00
            spoof:slider_float("Z (Altitude)", {"spoofedz"}, "", -20000, 270000, -20000, 1, function(z_pos)
                z = z_pos
            end)

            local spoof_spec_syncs
            local spoofing = menu.ref_by_path("Online>Spoofing>Position Spoofing>Position Spoofing")

            spoof_spec_syncs = spoof:toggle_loop("Spoof Spectator Syncs", {"spoofspectatorsyncs"}, "Spoof your position so people who spectate you see you somewhere else. (Note: Everyone else will also see you at your spoofed position)", function()
                if block_spec_syncs.value == true then
                    util.toast("Please don't enable spoof and block spectator syncs simultaneuosly. ;)")
                    block_spec_syncs.value = false
                    util.stop_thread()
                end
                Commands("spoofedposition " .. x .. "," .. y .. "," .. z)
                for _, pid in players.list(false, true, true) do
                    local ped_dist = v3.distance(players.get_position(players.user()), players.get_position(pid))
                    if v3.distance(players.get_position(players.user()), players.get_cam_pos(pid)) < 25.0 and ped_dist > 30.0 or players.get_spectate_target(pid) == players.user() then
                        local outgoingSyncs = menu.ref_by_rel_path(menu.player_root(pid), "Outgoing Syncs>Block")
                        spoofing.value = true
                        util.yield(500)
                        repeat
                            outgoingSyncs.value = true
                            spoofing.value = false
                            util.yield()
                        until v3.distance(v3(x, y, z), players.get_cam_pos(pid)) > 50.0
                        outgoingSyncs.value = false
                    end

                end
            end, function()
                spoofing.value = false
            end)
            --- FIN ANTI-SPECTATEUR

            ------------------
            --- ANTI CANON ORBITAL
            ------------------
            local anti_orbital_cannon_root = protex_root:list("anti cannon orbital", {}, Translations.protection_anti_orbital_cannon_desc)

                menu.divider(anti_orbital_cannon_root, "GHOST")
                local anti_orbital_cannon_ghost = anti_orbital_cannon_root:toggle_loop("Always", {}, "Automatically ghost players that are using the orbital cannon", function()
                    for _, pid in players.list(false, true, true) do
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local cam_dist = v3.distance(players.get_position(players.user()), players.get_cam_pos(pid))
                        if IsPlayerUsingOrbitalCannon(pid) and TASK.GET_IS_TASK_ACTIVE(ped, 135) and cam_dist < 400 and cam_dist > 340 then
                            notification.stand("%s Is targeting you with the orbital cannon", players.get_name(pid))
                        end
                        if IsPlayerUsingOrbitalCannon(pid) then
                            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                            repeat
                                util.yield()
                            until not IsPlayerUsingOrbitalCannon(pid)
                            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                        end
                    end
                end, function()
                    for _, pid in players.list(false, true, true) do
                        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                    end
                end)

                local anti_orbital_cannon_target
                anti_orbital_cannon_target = anti_orbital_cannon_root:toggle_loop("While Being Targeted", {}, "Automatically ghost players that are targetting you with the orbital cannon.", function()
                    if menu.get_value(anti_orbital_cannon_ghost) then
                        anti_orbital_cannon_target.value = false
                    return end
                    for _, pid in players.list(false, true, true) do
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local cam_dist = v3.distance(players.get_position(players.user()), players.get_cam_pos(pid))
                        if IsPlayerUsingOrbitalCannon(pid) and TASK.GET_IS_TASK_ACTIVE(ped, 135) and cam_dist < 400 and cam_dist > 340 then
                            notification.stand("%s Is targeting you with the orbital cannon", players.get_name(pid))
                            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                        else
                            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                        end
                    end
                end, function()
                    for _, pid in players.list(false, true, true) do
                        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                    end
                end)

                local anti_orbital_cannon_annoy = anti_orbital_cannon_root:list("Annoy", {}, "Rapidly shows and removes your name from the targetable players list.")
                local orb_delay = 1000
                anti_orbital_cannon_annoy:list_select("Delay", {}, "The speed in which your name will flicker at for orbital cannon users.", {"Slow", "Medium", "Fast"}, 1, function(index, value)
                    local cases = {
                        ["Slow"] = function()
                            orb_delay = 1000
                        end,
                        ["Medium"] = function()
                            orb_delay = 500
                        end,
                        ["Fast"] = function()
                            orb_delay = 100
                        end
                    }
                    cases[value]()
                end)

                local anti_orbital_cannon_annoy_tgl
                anti_orbital_cannon_annoy_tgl = anti_orbital_cannon_annoy:toggle_loop("Enable", {}, "", function()
                    if menu.get_value(anti_orbital_cannon_ghost) then
                        anti_orbital_cannon_annoy_tgl.value = false
                        notification.stand("Please don't enable Annoy and Ghost simultaneuosly. ;)")
                    return end

                    for _, pid in players.list(false, true, true) do
                       if IsPlayerUsingOrbitalCannon(pid) then
                            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
                            util.yield(orb_delay)
                            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                            util.yield(orb_delay)
                        else
                            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                        end
                    end
                end, function()
                    for _, pid in players.list(false, true, true) do
                        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
                    end
                end)


            protex_root:toggle(Translations.admin_bail, {}, Translations.admin_bail_desc, function(toggle)
                while toggle do
                    if util.is_session_started() then
                        for _, pid in players.list(false, true, true) do
                            if players.is_marked_as_admin(pid) then
                                notification.stand(Translations.admin_detected)
                                Commands("quickbail")
                            end
                        end
                    end
                    util.yield()
                end
            end, true)

    --===============--
    -- FIN Protections
    --===============--

    --===============--
    --[[ Misc ]] local misc_root = main_root:list("Misc")
    --===============--

        local testnotif_root = misc_root:list("testnotif")
            testnotif_root:action("help",{},"", function()
                notification:help("format0" .. ".\n" .. "format1" .. '.', HudColour.red)
            end)
            testnotif_root:toggle_loop("normal",{},"", function()
                --notification:normal(SCRIPT_NAME.." ~q~est ~u~le ~o~meilleur script!")
                notification:normal("un petit %s du script", HudColour.red, "test")
            end)
            testnotif_root:action("stand",{},"", function()
                notification.stand("un petit %s du script", "test")
            end)

        misc_root:slider("Change seat", {}, "DriverSeat = -1 Passenger = 0 Left Rear = 1 RightRear = 2", -1, 2, -1, 1, function(seatnumber)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
            local vehicle = my_cur_car
            --PED.SET_PED_INTO_VEHICLE(ped, vehicle, seatnumber)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
        end)

        misc_root:toggle_loop("Unlock Vehicle that you try to get into", {"unlockvehget"}, "Unlocks a vehicle that you try to get into. This will work on locked player cars.", function()
            ::start::
            local localPed = players.user_ped()
            --obtenir le véhicule où le ped essaie d'entrer
            local veh = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(localPed)
            --Obtient une valeur indiquant si le ped spécifié se trouve dans un véhicule. Si le 2ème argument est faux, la fonction ne retournera pas vrai jusqu'à ce que le ped soit assis dans le véhicule et soit sur le point de fermer la porte.
            if PED.IS_PED_IN_ANY_VEHICLE(localPed, false) then
                --Obtient le véhicule dans lequel se trouve le piéton spécifié. Renvoie 0 si le piéton est/n'était pas dans un véhicule. True recupère le dernier vehicle.
                local v = PED.GET_VEHICLE_PED_IS_IN(localPed, false)
                --VERROUILLER LES PORTES DU VÉHICULE {VEHICLELOCK_NONE, VEHICLELOCK_UNLOCKED, VEHICLELOCK_LOCKED, VEHICLELOCK_LOCKOUT_PLAYER_ONLY, VEHICLELOCK_LOCKED_PLAYER_INSIDE, VEHICLELOCK_LOCKED_INITIALLY, VEHICLELOCK_FORCE_SHUT_DOORS, VEHICLELOCK_LOCKED_BUT_CAN_BE_DAMAGED, VEHICLELOCK_LOCKED_BUT_BOOT_UNLOCKED, VEHICLELOCK_LOCKED_NO_PASSENGERS, VEHICLELOCK_CANNOT_ENTER}
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(v, 0)
                --DÉFINIR LES PORTES DU VÉHICULE VERROUILLÉES POUR TOUS LES JOUEURS
                --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(v, false)
                --DÉFINIR LES PORTES DU VÉHICULE VERROUILLÉES POUR LE JOUEUR
                --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(v, players.user(), false)
                --VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
                util.yield()
            else
                if veh ~= 0 then
                    --RÉSEAU DEMANDE DE CONTRÔLE DE L'ENTITÉ
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                    --LE RÉSEAU A PAS LE CONTRÔLE DE L'ENTITÉ
                    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                        for i = 1, 20 do
                            --RÉSEAU DEMANDE DE CONTRÔLE DE L'ENTITÉ
                            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                            util.yield(100)
                        end
                    end
                    --LE RÉSEAU A PAS LE CONTRÔLE DE L'ENTITÉ
                    if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) then
                        notification.stand("Waited 2 secs, couldn't get control!")
                        goto start
                    else
                        --if SE_Notifications then
                            notification.stand("Has control.")
                        --end
                    end
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 0)
                    --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
                    --VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, players.user(), false)
                    --DÉFINIR LE VÉHICULE APPARTIENT AU JOUEUR
                    --VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
                end
            end
        end)

        local weather_root = misc_root:list("Météo")
        --fun-menu
        weather_root:slider("WIND_SPEED", {"nywindspeed"}, "WIND_SPEED_DESC", -1, 12, -1, 1, function(s)
        	MISC.SET_WIND_SPEED(s)
        end)
        weather_root:slider("WIND_DIRECTION", {"nywinddir"}, "WIND_DIRECTION_DESC", -1, 360, -1, 1, function(s)
        	MISC.SET_WIND_DIRECTION(s)
        end)
        weather_root:action("FORCE_FLASH", {}, "", function()
        	MISC.FORCE_LIGHTNING_FLASH()
        end)
        weather_root:slider("RAIN_LEVEL", {"nyrainlvl"}, "RAIN_LEVEL_DESC", -1, 10, -1, 1, function(s)
        	MISC.SET_RAIN(s/10)
        end)
        weather_root:slider("SNOW_LEVEL", {"nysnowlvl"}, "SNOW_LEVEL_DESC", -1, 10, -1, 1, function(s)
        	MISC.SET_SNOW(s/10)
        end)

        misc_root:action("Stop Sounds", {}, "Stop all sounds incase they are going off constantly", function ()
            for i=-1,100 do
	        	AUDIO.STOP_SOUND(i)
	        	AUDIO.RELEASE_SOUND_ID(i)
	        end
        end)


        --AndyScript
        --consistent freeze clock
        --[[local function read_time(file_path)
            local filehandle = io.open(file_path, "r")
            if filehandle then
                local time = filehandle:read()
                filehandle:close()
                return tostring(time)
            else
                return false
            end
        end

        local function save_current_time(file_path, time)
            filehandle = io.open(file_path, "w")
            filehandle:write(time)
            filehandle:flush()
            filehandle:close()
        end

        local function get_clock()
            return tostring(CLOCK.GET_CLOCK_HOURS() .. ":" .. CLOCK.GET_CLOCK_MINUTES() .. ":".. CLOCK.GET_CLOCK_SECONDS())
        end

        local time_path = filesystem.store_dir() .. "AndyScript\\time.txt"
        local is_freeze_clock_on = false
        misc_root:toggle("Consistent Freeze Clock", {}, "Freezes the clock using Stand's function, then saves the time for next execution. Change the current time using the \"time\" command, or in \"World > Atmosphere > Clock > Time\".",
        function(state)
            is_freeze_clock_on = state
            if state then
                if filesystem.exists(time_path) then
                    local time = read_time(time_path)
                    menu.trigger_command(menu.ref_by_path("World>Atmosphere>Clock>Time", Tree_V), time)
                else
                    save_current_time(time_path, get_clock())
                end
            else
                menu.trigger_command(menu.ref_by_path("World>Atmosphere>Clock>Lock Time", Tree_V), "false")
            end
            while is_freeze_clock_on do
                menu.trigger_command(menu.ref_by_path("World>Atmosphere>Clock>Lock Time", Tree_V), "true")
                save_current_time(time_path, get_clock())
                util.yield(1000)
            end
        end)
        -- end of freeze clock
        ]]--
    --===============--
    -- FIN Misc
    --===============--

    --===============--
    --[[ PARAMETRES ]] local settings_root = main_root:list("Paramètres")
    --===============--

        settings_root:list_action("Langue", {}, "", just_language_files, function(index, value, click_type)
            local file = io.open(selected_lang_path, 'w')
            if file then
                file:write(value)
                file:close()
            end
            util.restart_script()
        end, selected_language)
    --[[ 
        settings_root:toggle("debug", "debug", {}, "", function(toggle)
            ls_debug = toggle
        end)

        -- check online version
        local online_v = tonumber(NETWORK.GET_ONLINE_VERSION())
        if online_v > ocoded_for and outdated_notif then
            notify(translations.outdated_script_1 .. online_v .. translations.outdated_script_2 .. ocoded_for .. translations.outdated_script_3)
        end
    ]]--

    --LanceScript by lance#8213
    --WiriScript by Nowiry#2663
    --fun_menu esay_enter :Arrêtez le véhicule dans lequel vous essayez de monter
    --fun_menu Anti carjacking
        -- CREDITS
        local settings_credits_root = settings_root:list("Credits", {}, "")

            settings_credits_root:readonly("LanceScript", "Aimbot")
            settings_credits_root:readonly("LanceScript", "Translation")
            settings_credits_root:readonly("WiriScript", "Anti-mugger")
            settings_credits_root:readonly("WiriScript", "Notification")
            settings_credits_root:readonly("Hexarobi", "Auto-Update")
            settings_credits_root:readonly("AndyScript", "Auto-flip")
            settings_credits_root:readonly("AndyScript", "Freeze clock")
            settings_credits_root:readonly("AcJocker", "Auto taxi")
            settings_credits_root:readonly("AcJocker", "Kosatka")
            settings_credits_root:readonly("fun_menu", "Easy Enter")
            settings_credits_root:readonly("fun_menu", "Anti Carjacking")
            --settings_credits_root:action("Ayim#7708", {}, "", function() end)

--===============--
-- FIN Main
--===============--

-----------------------------------
-- Script tick loop
-----------------------------------
util.create_tick_handler(function()
    --CAR SETTINGS
        if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 2) then --when exiting a car
            setCarOptions(false)
        elseif TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 160) then --when entering a vehicle
            setCarOptions(true)
        end

        local carCheck = entities.get_user_vehicle_as_handle()
        if my_cur_car != carCheck then
            my_cur_car = carCheck
            setCarOptions(true)
        end

end)

---@param pId Player
NetworkPlayerOpts = function(pId)
    menu.divider(menu.player_root(pId), SCRIPT_NAME)
    -------------------------------------
	-- SEND MUGGER
	-------------------------------------

	menu.action(menu.player_root(pId), "Send Mugger", {}, "", function()
		if NETWORK.NETWORK_IS_SESSION_STARTED() and IsPlayerActive(pId, true, true) and IsPlayerInInterior(pId) ~= 0 then
			if not NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
				local bits_addr = memory.script_global(1853910 + (players.user() * 862 + 1) + 140)
				memory.write_int(bits_addr, SetBit(memory.read_int(bits_addr), 0))
				Write_global.int(1853910 + (players.user() * 862 + 1) + 141, pId)
                notification:help("mugger ok", HudColour.green)
			else
				notification:help("A mugger is already active", HudColour.red)
			end
		end
	end)

    --[[menu.action(trolling, "Kill passive-mode player", {}, "", function()
        local coords = players.get_position(pid)
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords.z = coords.z + 5
        local playerCar = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
        if playerCar > 0 then
            entities.delete_by_handle(playerCar)
        end
        local carHash = util.joaat("dukes2")
        loadModel(carHash)
        local car = entities.create_vehicle(carHash, coords, 0)
        ENTITY.SET_ENTITY_VISIBLE(car, false, 0)
        ENTITY.APPLY_FORCE_TO_ENTITY(car, 1, 0.0, 0.0, -65, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
    end)]]
end
players.on_join(NetworkPlayerOpts)
players.dispatch_on_join()


util.log(SCRIPT_NAME.." loaded in %d millis", util.current_time_millis() - scriptStartTime)