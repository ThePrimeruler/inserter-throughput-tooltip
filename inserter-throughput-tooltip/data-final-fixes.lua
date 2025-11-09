-- Code Borrowing From "More descriptive tooltips" mod
local mod_name = 'inserter-throughput-tooltip'

local setting_add_base_tp_tt = settings.startup[mod_name.."-add-base-max-throughput"].value
local setting_add_per_hs_tt = settings.startup[mod_name.."-add-per-hand-size"].value

---@param input integer
local function fmt_float(input)
    return tostring(math.floor(input * 1000 + 0.5) / 1000)
end

local function jsonSerializeTable(val, name, depth)
    local indent = '    '
    depth = depth or 0

    local tmp = string.rep(indent, depth)

    if name then tmp = tmp .. '"' .. name .. '": ' end

    if type(val) == "table" then
        tmp = tmp .. "{" .. "\n"
        local add_comma = false
        for k, v in pairs(val) do
            if add_comma then
                tmp = tmp .. "," .. (not skipnewlines and "\n" or "")
            else
                add_comma = true
            end
            tmp =  tmp .. jsonSerializeTable(v, k, depth + 1)
        end
        tmp = tmp .. (not skipnewlines and "\n" or "")

        tmp = tmp .. string.rep(indent, depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[unserializable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

local function basic_order(a)
	return 100 + a
end

local function generic_order(a)
	return 150 + a
end

local function specific_order(a)
	return 200 + a
end

---@param proto data.Prototype
---@param tooltip_field data.CustomTooltipField
local function generic_add_description(proto, tooltip_field)
	if not proto.custom_tooltip_fields
	then
		proto.custom_tooltip_fields = {}
	end
	table.insert(proto.custom_tooltip_fields, tooltip_field)
end

---@param inserter data.InserterPrototype
---@param stack_size integer
---@param quality? data.QualityPrototype not required
local function calc_inserter_speed(inserter, stack_size, quality)
    local rot_speed = inserter.rotation_speed * 60
    local qual_mult = 1.0
    if quality then
        qual_mult = quality.inserter_speed_multiplier or quality.default_multiplier or (1 + 0.3 * quality.level)
    end
    return fmt_float(stack_size*rot_speed*qual_mult)
end



local qualities = nil
if mods['quality'] then
    qualities = data.raw["quality"]
end

---@param tooltip data.CustomTooltipField
---@param inserter data.InserterPrototype
---@param qualities {[string]: data.QualityPrototype}
local function add_max_base_tp_quality_tooltips(tooltip, inserter, qualities)
    local stack_size = (inserter.stack_size_bonus or 0) + 1
	tooltip['quality_header'] = "quality-tooltip.increases"
	tooltip['quality_values'] = {}
    for quality_name, proto in pairs(qualities) do
        tooltip['quality_values'][quality_name] = {mod_name..".base-max-throughput-value",calc_inserter_speed(inserter,stack_size,proto),fmt_float(stack_size)}
    end
end

---@param inserter data.InserterPrototype
local function add_max_base_throughput_tooltip(inserter)
    local stack_size = (inserter.stack_size_bonus or 0) + 1
    local tooltip = {
        name = {mod_name..".base-max-throughput"},
        value = {mod_name..".base-max-throughput-value",calc_inserter_speed(inserter,stack_size),fmt_float(stack_size)},
        order = specific_order(0),
        show_in_factoriopedia = true,
        show_in_tooltip = true,
    }
    if qualities then
        add_max_base_tp_quality_tooltips(tooltip,inserter,qualities,stack_size)
    end
    generic_add_description(inserter, tooltip)
end

---@param tooltip data.CustomTooltipField
---@param inserter data.InserterPrototype
---@param qualities {[string]: data.QualityPrototype}
local function add_per_hand_size_quality_tooltips(tooltip, inserter, qualities)
    local stack_size = 1
	tooltip['quality_header'] = "quality-tooltip.increases"
	tooltip['quality_values'] = {}
    for quality_name, proto in pairs(qualities) do
        tooltip['quality_values'][quality_name] = {mod_name..".per-hand-size-value",calc_inserter_speed(inserter,stack_size,proto),fmt_float(stack_size)}
    end
end

---@param inserter data.InserterPrototype
local function add_per_hand_size_tooltip(inserter)
    local stack_size = 1
    local tooltip = {
        name = {mod_name..".per-hand-size"},
        value = {mod_name..".per-hand-size-value",calc_inserter_speed(inserter,stack_size)},
        order = specific_order(0),
        show_in_factoriopedia = true,
        show_in_tooltip = true,
    }
    if qualities then
        add_per_hand_size_quality_tooltips(tooltip,inserter,qualities,stack_size)
    end
    generic_add_description(inserter, tooltip)
end

local inserters = data.raw["inserter"]
for name, inserter in pairs(inserters) do
    if setting_add_base_tp_tt then
        add_max_base_throughput_tooltip(inserter)
    end
    if setting_add_per_hs_tt then
        add_per_hand_size_tooltip(inserter)
    end
end
