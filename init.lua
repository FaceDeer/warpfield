warpfield = {}

local S = minetest.get_translator()

local warpfield_trigger_breaks_sound = "default_tool_breaks"
local warpfield_trigger_uses = tonumber(minetest.settings:get("warpfield_trigger_uses")) or 0
local warpfield_trigger_cooldown = tonumber(minetest.settings:get("warpfield_cooldown")) or 10

local default_x = {
	octaves = 1,
	scale = "500",
	lacunarity = "2",
	flags = "",
	spread = {
		y = "800",
		x = "800",
		z = "800"
	},
	seed = 33356,
	offset = "1",
	persistence = "0.5"
}

local default_y = {
	octaves = 1,
	scale = "100",
	lacunarity = "2",
	flags = "",
	spread = {
		y = "200",
		x = "200",
		z = "200"
	},
	seed = 33357,
	offset = "1",
	persistence = "0.5"
}

local default_z = {
	octaves = 1,
	scale = "500",
	lacunarity = "2",
	flags = "",
	spread = {
		y = "800",
		x = "800",
		z = "800"
	},
	seed = 33358,
	offset = "1",
	persistence = "0.5"
}

local warpfield_x = minetest.settings:get_np_group("warpfield_x_params") or default_x
local warpfield_y = minetest.settings:get_np_group("warpfield_y_params") or default_y
local warpfield_z = minetest.settings:get_np_group("warpfield_z_params") or default_z

-- For some reason, these numbers are returned as strings by get_np_group.
local tonumberize_params = function(params)
	params.scale = tonumber(params.scale)
	params.lacunarity = tonumber(params.lacunarity)
	params.spread.x = tonumber(params.spread.x)
	params.spread.y = tonumber(params.spread.y)
	params.spread.z = tonumber(params.spread.z)
	params.offset = tonumber(params.offset)
	params.persistence = tonumber(params.persistence)
end
tonumberize_params(warpfield_x)
tonumberize_params(warpfield_y)
tonumberize_params(warpfield_z)

local trigger_stack_size = 99
local trigger_wear_amount = 0
local trigger_tool_capabilities = nil
if warpfield_trigger_uses ~= 0 then
	trigger_stack_size = 1
	trigger_wear_amount = math.ceil(65535 / warpfield_trigger_uses)
	trigger_tool_capabilities = {
        full_punch_interval=1.5,
        max_drop_level=1,
        groupcaps={},
        damage_groups = {},
    }
end

local particle_node_pos_spread = vector.new(0.5,0.5,0.5)
local particle_user_pos_spread = vector.new(0.5,1.5,0.5)
local particle_speed_spread = vector.new(0.1,0.1,0.1)
local min_spark_delay = 30
local max_spark_delay = 120

local trigger_help_addendum = ""
if warpfield_trigger_uses > 0 then
	trigger_help_addendum = S(" This tool can be used @1 times before breaking.", warpfield_trigger_uses)
end

local warp_x
local warp_y
local warp_z

-- An external API to allow use of warp field by other mods
local get_warp_at = function(pos)
	if not warp_x then
		warp_x = minetest.get_perlin(warpfield_x)
		warp_y = minetest.get_perlin(warpfield_y)
		warp_z = minetest.get_perlin(warpfield_z)
	end

	return {x = warp_x:get_3d(pos), y = warp_y:get_3d(pos), z = warp_z:get_3d(pos)}
end
warpfield.get_warp_at = get_warp_at

local player_cooldown = {}

local trigger_def = {
	description = S("Warpfield Trigger"),
	_doc_items_longdesc = S("A triggering device that allows teleportation via warpfield."),
	_doc_items_usagehelp = S("When triggered, this tool and its user will be displaced in accordance with the local warp field's displacement. Simply holding it makes it act as a compass of sorts, showing the current strength of the warp field.") .. trigger_help_addendum,
	inventory_image = "warpfield_spark.png^warpfield_tool_base.png",
	stack_max = trigger_stack_size,
	tool_capabilites = trigger_tool_capabilities,
	sound = {
		breaks = warpfield_trigger_breaks_sound,
	},
	on_use = function(itemstack, user, pointed_thing)
	
		local player_name = user:get_player_name()
		if (player_cooldown[player_name] or 0) > 0 then
			return itemstack
		end
	
		local old_pos = user:get_pos()
		local warp = get_warp_at(old_pos)
		local new_pos = vector.add(old_pos, warp)
		
		old_pos.y = old_pos.y + 0.5

		local speed = vector.multiply(vector.direction(old_pos, new_pos), 5/0.5)
		minetest.add_particlespawner({
			amount = 100,
			time = 0.1,
			minpos = vector.subtract(old_pos, particle_node_pos_spread),
			maxpos = vector.add(old_pos, particle_user_pos_spread),
			minvel = vector.subtract(speed, particle_speed_spread),
			maxvel = vector.add(speed, particle_speed_spread),
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.1,
			maxexptime = 0.5,
			minsize = 1,
			maxsize = 1,
			collisiondetection = false,
			vertical = false,
			texture = "warpfield_spark.png",
		})		
		minetest.sound_play({name="warpfield_teleport_from"}, {pos = old_pos}, true)
	
		user:set_pos({x=new_pos.x, y=new_pos.y-0.5, z=new_pos.z})
		
		new_pos = vector.subtract(new_pos, speed)
		minetest.add_particlespawner({
			amount = 100,
			time = 0.1,
			minpos = vector.subtract(new_pos, particle_node_pos_spread),
			maxpos = vector.add(new_pos, particle_user_pos_spread),
			minvel = vector.subtract(speed, particle_speed_spread),
			maxvel = vector.add(speed, particle_speed_spread),
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 0.5,
			maxexptime = 0.5,
			minsize = 1,
			maxsize = 1,
			collisiondetection = false,
			vertical = false,
			texture = "warpfield_spark.png",
		})
		minetest.sound_play({name="warpfield_teleport_to"}, {pos = new_pos}, true)
		
		if trigger_wear_amount > 0 and not minetest.is_creative_enabled(player_name) then
			itemstack:add_wear(trigger_wear_amount)
		end
		player_cooldown[player_name] = warpfield_trigger_cooldown
		
		return itemstack
	end
}

local hud_position = {
	x= tonumber(minetest.settings:get("warpfield_hud_x")) or 0.5,
	y= tonumber(minetest.settings:get("warpfield_hud_y")) or 0.9,
}
local hud_color = tonumber("0x" .. (minetest.settings:get("warpfield_hud_color") or "FFFF00")) or 0xFFFF00
local hud_color_stressed = tonumber("0x" .. (minetest.settings:get("warpfield_hud_color_stressed") or "FF0000")) or 0xFF0000

local player_huds = {}
local function hide_hud(player, player_name)
	local id = player_huds[player_name]
	if id then
		player:hud_remove(id)
		player_huds[player_name] = nil
	end
end
local function update_hud(player, player_name, player_cooldown_val)
	local player_pos = player:get_pos()
	local local_warp = vector.floor(get_warp_at(player_pos))
	local color
	local description = S("Local warp field: @1", minetest.pos_to_string(local_warp))
	if player_cooldown_val > 0 then
		color = hud_color_stressed
		description = description .. "\n" .. S("Cooldown: @1s", math.ceil(player_cooldown_val))
	else
		color = hud_color
	end
	local id = player_huds[player_name]
	if not id then
		id = player:hud_add({
			hud_elem_type = "text",
			position = hud_position,
			text = description,
			number = color,
			scale = 20,
		})
		player_huds[player_name] = id
	else
		player:hud_change(id, "text", description)
		player:hud_change(id, "number", color)
	end
end

local function warpfield_globalstep(dtime)
	for i, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local player_cooldown_val = math.max((player_cooldown[player_name] or 0) - dtime, 0)
		player_cooldown[player_name] = player_cooldown_val
		local wielded = player:get_wielded_item()
		if wielded:get_name() == "warpfield:trigger" then
			update_hud(player, player_name, player_cooldown_val)
		else
			hide_hud(player, player_name)
		end
	end
end

-- update hud
minetest.register_globalstep(warpfield_globalstep)


if trigger_tool_capabilities then
	minetest.register_tool("warpfield:trigger", trigger_def)
else
	minetest.register_craftitem("warpfield:trigger", trigger_def)
end

--minetest.register_craft({
--	output = "warpfield:trigger",
--	recipe = {
--		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"},
--		{"default:mese_crystal_fragment", warpfield_displaced_name, "default:mese_crystal_fragment"},
--		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"}
--	}
--})