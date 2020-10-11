-- The Thing Info Mod
--[[
    This file is part of Thing Info.

    Thing Info is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    Thing Info is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
]]

tinfo = {}
function tinfo.get_block_info(pos) -- Process block info
	local node = minetest.get_node_or_nil(pos)
	if not node then
		return false, "Pointing node unloaded!"
	end
	local node_def = minetest.registered_nodes[node.name]
	if not node_def then
		return false, "Unknown Node!"
	end
	local name = node_def.short_description or node_def.description or node.name
	local groups = ""
	local groups_t = node_def.groups or {}
	for k,v in pairs(groups_t) do
		groups = groups.."\n    "..tostring(k)..": "..tostring(v)
	end
	return true, "--------\nNode Info:\nName: "..node.name.."\nPOS: "..minetest.pos_to_string(pos).."\nDescription: "..name.."\nparam2: "..tostring(node.param2).."\nGroups: "..groups.."\n--------"
end

function tinfo.get_object_info(ref) -- Process object Info
	local player_info = "Is player: "..(ref:is_player() and "true" or "false")
	if ref:is_player() then
		player_info = player_info.."\nPlayer name: "..ref:get_player_name()
	end
	local hp = tostring(ref:get_hp())
	local yaw = tostring(ref:get_yaw() or ref:get_look_horizontal() or "nil")
	local wielded = ((ref:get_luaentity() and ItemStack(ref:get_luaentity().itemstring)) or ref:get_wielded_item() or ItemStack()):to_string()
	local agroups_t = ref:get_armor_groups()
	local agroups = ""
	for k,v in pairs(agroups_t) do
		agroups = agroups.."\n    "..tostring(k)..": "..tostring(v)
	end
	local add_info = "\n"
	if ref:get_luaentity() then -- If the object is luaentity
		local lename = ref:get_luaentity().name
		add_info = add_info.."LuaEntity Info:\n    Name: "..lename.."\n"
	end
	if ref:is_player() then -- If the object is player
		local breath = tostring(ref:get_breath())
		add_info = add_info.."Player Info:\n    Breath: "..breath.."\n"
	end
	return true, "--------\nObject Info:\n"..player_info.."\nHP: "..hp.."\nyaw: "..yaw.."\narmor groups: "..agroups.."\nWielded item: "..wielded..add_info.."--------"
end

local function tool_handle(itemstack, placer, pointed_thing)
	if placer:is_player() then
		if pointed_thing.type == "node" then
			local stat, back = tinfo.get_block_info(minetest.get_pointed_thing_position(pointed_thing))
			minetest.chat_send_player(placer:get_player_name(), back)
		elseif pointed_thing.type == "object" then
			local stat, back = tinfo.get_object_info(pointed_thing.ref)
			minetest.chat_send_player(placer:get_player_name(), back)
		elseif pointed_thing.type == "nothing" then
			minetest.chat_send_player(placer:get_player_name(), "Don't check what is nothing!")
		end
	end
end

minetest.register_craftitem("tinfo:tool",{
	description = "Info Tool",
	inventory_image = "menu_bg.png^zoom.png",
	on_place = tool_handle,
	on_use = tool_handle,
	on_secondary_use = tool_handle,
	liquids_pointable = false,
})

minetest.register_craftitem("tinfo:tool_w",{
	description = "Info Tool (Liquids Pointable)",
	inventory_image = "menu_bg.png^bubble.png^zoom.png",
	on_place = tool_handle,
	on_use = tool_handle,
	on_secondary_use = tool_handle,
	liquids_pointable = true,
})
