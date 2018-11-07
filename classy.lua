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

local function isPrivate(classdef, key)
    return classdef.privateDefs[key] ~= nil
end

local function isPublic(classdef, key)
    return classdef.publicDefs[key] ~= nil
end

local function inSuper(classdef, key)
    if classdef.extends then
        return classes[classdef.extends].publicDefs[key] ~= nil
    end
    return false
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

                local super
                if classdef.extends then
                    local superClass = import(classdef.extends)
                    super = superClass(...)
                    privateObj.super = super
                end

                local private_mt = {}

                local function wrapperFunction(_, ...)
                    return private_mt.func(privateObj, ...)
                end

                private_mt.__index = function(t, k)
                    local func = classdef.privateDefs[k] or classdef.publicDefs[k]
                    if type(func) == "function" then
                        private_mt.func = func
                        return wrapperFunction
                    end

                    return rawget(t, k)
                end

                setmetatable(privateObj, private_mt)

                local public_mt = {
                    __index = function(t, k)
                        if isPublic(classdef, k) and not isPrivate(classdef, k) then
                            return privateObj[k]
                        elseif isPrivate(classdef, k) then
                            error("Trying to access private member "..tostring(k))
                        elseif inSuper(classdef, k) then
                            return rawget(privateObj, "super")[k]
                        else
                            error("Trying to access non existing member "..tostring(k))
                        end
                    end;
                    __newindex = function(t, k)
                        error("Adding new indices for classes is not allowed")
                    end;
                }

                local publicObj = setmetatable({}, public_mt)

                local constructor = classdef.publicDefs.constructor
                if constructor then
                    constructor(privateObj, ...)
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