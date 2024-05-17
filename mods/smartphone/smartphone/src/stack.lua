stack = {}
stack.__index = stack

function stack.new()
	local self = setmetatable({}, stack)
	self.items = {}
	return self
end

function stack:push(item)
	table.insert(self.items, item)
end

function stack:pop()
	return table.remove(self.items)
end

function stack:peek()
	return self.items[#self.items]
end

function stack:is_empty()
	return #self.items == 0
end