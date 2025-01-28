--- @class str_table

--- @within str_table
--- @function str_table
--- @param str string
--- @return {string}
local function str_table(str: string): { string }
	local t = string.split(str, "")

	return t
end

return str_table
