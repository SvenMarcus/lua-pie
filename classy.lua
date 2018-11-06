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

        local classdef = classes[name]

        local class_mt = {
            __call = function(t, ...)

                local privateObj = {}
                local env = {self = privateObj}
                setmetatable(env, {__index = _G})

                local superDef
                local super
                if classdef.extends then
                    superDef = classes[classdef.extends]
                    local superClass = import(classdef.extends)
                    super = superClass(...)
                    env.super = super
                end

                setmetatable(privateObj, {__index = function(t, k)
                    local func = classdef.privateDefs[k] or classdef.publicDefs[k]

                    if type( func ) == "function" then
                        return setfenv(func, env)
                    end

                    if not func and superDef then
                        return super[k]
                    end

                    return func
                end} )

                local public_mt = {
                    __index = function(t, k)
                        if not classdef.publicDefs[k] then
                            if superDef then
                                if not superDef.publicDefs[k] then
                                    return
                                end
                            else
                                return
                            end
                        end

                        local func = classdef.publicDefs[k]

                        if type(func) == "function" then
                            return setfenv(func, env)
                        end

                        if not func and superDef then
                            return super[k]
                        end

                        return func
                    end;
                }

                local publicObj = setmetatable({}, public_mt)

                local constructor = publicObj.constructor
                if constructor then
                    constructor(...)
                end

                return publicObj
            end
        }

        classes[name].class = setmetatable( {}, class_mt )
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