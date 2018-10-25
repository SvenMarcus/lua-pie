local classes = {
    currentDef = nil,
    nextName = nil,
    tableLookUp = {}
}

local function private(name)
    classes.nextName = name
    return function(tab)
        classes[classes.currentDef].privateDefs[classes.nextName] = tab[1]
        classes.nextName = nil
    end
end

local function public(name)
    classes.nextName = name
    return function(tab)
        classes[classes.currentDef].publicDefs[classes.nextName] = tab[1]
        classes.nextName = nil
    end
end

local function class(name)
    classes.currentDef = name
    classes[classes.currentDef] = {
        privateDefs = {},
        publicDefs = {},
        class = nil
    }

    return function(tab)
        classes[classes.currentDef].class = tab
        classes.tableLookUp[tab] = classes.currentDef

        function tab:new(...)

            local classdef = classes[classes.tableLookUp[self]]
            local privateObj = {}
            local publicObj = {}

            for funcName, func in pairs(classdef.privateDefs) do
                local clone_func = loadstring(string.dump(func))
                privateObj[funcName] = clone_func
                publicObj[funcName] = function()
                    error("Error. Trying to access private member "..funcName)
                end
            end

            for funcName, func in pairs(classdef.publicDefs) do
                local clone_func = loadstring(string.dump(func))
                privateObj[funcName] = clone_func
                publicObj[funcName] = clone_func
            end

            local env = {self = privateObj}
            setmetatable(env, {__index = _G})
            for _, v in pairs(privateObj) do
                if type(v) == "function" then
                    setfenv(v, env)
                end
            end

            if publicObj.constructor then
                publicObj.constructor(unpack(arg))
                publicObj.constructor = nil
            end

            return publicObj
        end
        classes.currentDef = nil
    end
end

local function import(name)
    return classes[name].class
end

return {
    private = private,
    public = public,
    class = class,
    import = import
}