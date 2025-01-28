--- @class chain

--- @within chain
--- @function chain
--- @param ...: any
--- @return {any}
local function chain(...: any): { any }
	local cache = {}
	for i, list in ... do
		local vType = type(list)

		if vType == "table" then
			cache[i] = list
		elseif vType == "function" then
			cache[i] = list()
		end
	end

	local added = false
	local chain = {}

	for i = 1, math.huge do
		for _, list in cache do
			local value = list[i]

			if value then
				table.insert(chain, value)
				added = true
			end
		end

		if added == false then
			break
		end
	end

	table.clear(cache)
	return chain
end

return chain
