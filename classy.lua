local classes = {
    currentDef = nil,
    nextName = nil,
    tableLookUp = {}
}

local function import(name)
    return classes[name].class
end

local function extends(className)
    classes[classes.currentDef].extends = className
end

local function private(tab)
    for funcName, func in pairs(tab) do
        classes[classes.currentDef].privateDefs[funcName] = func
    end
end

local function public(tab)
    for funcName, func in pairs(tab) do
        classes[classes.currentDef].publicDefs[funcName] = func
    end
end

local function class(name)
    classes.currentDef = name
    classes[classes.currentDef] = {
        privateDefs = {},
        publicDefs = {},
        extends = nil,
        class = nil
    }

    return function(tab)
        classes[classes.currentDef].class = tab
        classes.tableLookUp[tab] = classes.currentDef

        function tab:new(...)

            local classdef = classes[classes.tableLookUp[self]]
            local privateObj = {}
            local publicObj = {}

            local args = {...}
            local env = {self = privateObj}
            setmetatable(env, {__index = _G})

            if classdef.extends then
                local superClass = import(classdef.extends)
                local super = superClass:new(unpack(args))

                for funcName, func in pairs(super) do
                    if type(func) == "function" and funcName ~= "constructor" then
                        privateObj[funcName] = func
                        publicObj[funcName] = func
                    end
                end

                env.super = super
            end

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

            for _, v in pairs(privateObj) do
                if type(v) == "function" then
                    setfenv(v, env)
                end
            end

            if publicObj.constructor then
                publicObj.constructor(unpack(args))
                publicObj.constructor = nil
            end

            return publicObj
        end
        classes.currentDef = nil
    end
end

return {
    private = private,
    public = public,
    extends = extends,
    class = class,
    import = import
}