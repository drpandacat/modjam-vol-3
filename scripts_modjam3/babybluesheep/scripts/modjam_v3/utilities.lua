---Creates a shallow copy of a table.
---The table must be in the form of a list (with integer keys and no gaps). 
---@param inputTable table
---@return table
function ModJamV3.CopyListShallow(inputTable)
    if type(inputTable) ~= "table" then
		return inputTable
	end

    local tableCopy = {}
    for i = 1, #inputTable do
        tableCopy[i] = inputTable[i]
    end
    return tableCopy
end

---Shuffles items in a list around.<br>
---Creates a copy of the list and returns it.<br>
---https://gist.github.com/Uradamus/10323382
---@generic T
---@param list T[]
---@param rng RNG
---@return table
function ModJamV3.ShuffleList(list, rng)
    local listCopy = ModJamV3.CopyListShallow(list)
    for i = #listCopy, 2, -1 do
        local j = rng:RandomInt(i) + 1
        listCopy[i], listCopy[j] = listCopy[j], listCopy[i]
    end
    return listCopy
end

---Shuffles items in a list around.<br>
---Modifies the table inputted as the argument.<br>
---https://gist.github.com/Uradamus/10323382
---@generic T
---@param list T[]
---@param rng RNG
function ModJamV3.ShuffleListInPlace(list, rng)
    for i = #list, 2, -1 do
        local j = rng:RandomInt(i) + 1
        list[i], list[j] = list[j], list[i]
    end
end

---@param min number
---@param max number
function ModJamV3.RandomFloat(min, max)
    return ModJamV3.Lerp(min, max, math.random())
end

---@param a number
---@param b number
---@param t number
function ModJamV3.Lerp(a, b, t)
    return a + (b - a) * t
end

---@param a number
---@param b number
---@param t number
---@param clamp boolean?
function ModJamV3.InverseLerp(a, b, t, clamp)
    local result = (t - a) / (b - a)
    if clamp == true or clamp == nil then
        return math.max(0, math.min(result, 1))
    end
    return result
end