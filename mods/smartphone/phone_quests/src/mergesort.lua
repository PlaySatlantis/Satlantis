local function mergesort(table, compare_func)
	if #table <= 1 then return table end

	local middle = math.floor(#table / 2)
	local left = mergesort({unpack(table, 1, middle)}, compare_func)
	local right = mergesort({unpack(table, middle + 1, #table)}, compare_func)

	local i = 1
	local j = 1
	local k = 1

	local sorted = {}

	while i <= #left and j <= #right do
		if compare_func(left[i], right[j]) then
			sorted[k] = left[i]
			i = i + 1
		else
			sorted[k] = right[j]
			j = j + 1
		end
		k = k + 1
	end

	while i <= #left do
		sorted[k] = left[i]
		i = i + 1
		k = k + 1
	end

	while j <= #right do
		sorted[k] = right[j]
		j = j + 1
		k = k + 1
	end

	return sorted
end

table.mergesort = mergesort