--- @class str_table

--- @within str_table
--- @function str_table
--- @param str string
--- @return {string}
local function str_table(str: string): { string }
	local t = {}

	for i = 1, #str do
		table.insert(t, string.sub(str, i, i))
	end

	return t
end

return str_table
