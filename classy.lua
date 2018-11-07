local classes = {
    currentDef = nil
}

local function import(name)
    return classes[name].class
end

local function extends(className)
    classes[classes.currentDef].extends = className
end

local function private(tab)
    for key, value in pairs(tab) do
        if type(value) == "function" then
            classes[classes.currentDef].privateFuncDefs[key] = value
        else
            error("Currently only functions in private definitions are supported")
        end
    end
end

local function public(tab)
    for key, value in pairs(tab) do
        if type(value) == "function" then
            classes[classes.currentDef].publicFuncDefs[key] = value
        else
            error("Currently only functions in public definitions are supported")
        end
    end
end

local function static(tab)
    for key, value in pairs(tab) do
        classes[classes.currentDef].staticDefs[key] = value
    end
end

local function inSuper(classdef, key)
    if classdef.extends then
        return classes[classdef.extends].publicFuncDefs[key] ~= nil
    end
    return false
end

local function class(name)
    classes.currentDef = name
    classes[classes.currentDef] = {
        staticDefs = {},
        privateFuncDefs = {},
        publicFuncDefs = {},
        extends = nil,
        class = nil
    }

    return function(_)

        local classdef = classes[name]

        classes[name].class = setmetatable( {}, {
            __index = classdef.staticDefs,

            __call = function(_, ...)

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
                        local member = classdef.privateFuncDefs[k] or classdef.publicFuncDefs[k]
                        if member then
                            if type(member) == "function" then
                                private_mt.func = member
                                return wrapperFunction
                            end
                        else
                            member = classdef.staticDefs[k]
                            if member then
                                return member
                            end
                        end

                        return rawget(t, k)
                    end

                    private_mt.__newindex = function(t, k, v)
                        if classdef.staticDefs[k] then
                            classdef.staticDefs[k] = v
                            return
                        end
                        rawset(t, k, v)
                    end

                    setmetatable(privateObj, private_mt)

                    local public_mt = {
                        __index = function(_, k)
                            local static_member = classdef.staticDefs[k]
                            local isPublic = classdef.publicFuncDefs[k] ~= nil
                            local isPrivate = classdef.privateFuncDefs[k] ~= nil

                            if (isPublic or static_member) and not isPrivate then
                                return privateObj[k]
                            elseif isPrivate then
                                error("Trying to access private member "..tostring(k))
                            elseif inSuper(classdef, k) then
                                return rawget(privateObj, "super")[k]
                            else
                                error("Trying to access non existing member "..tostring(k))
                            end
                        end;
                        __newindex = function(_, k, v)
                            local static_member = classdef.staticDefs[k]
                            if static_member then
                                classdef.staticDefs[k] = v
                                return
                            end
                            error("Adding new indices for classes is not allowed")
                        end;
                    }

                    local publicObj = setmetatable({}, public_mt)

                    local constructor = classdef.publicFuncDefs.constructor
                    if constructor then
                        constructor(privateObj, ...)
                    end

                    return publicObj
                end
        })

        classes.currentDef = nil
    end
end

return {
    static = static,
    private = private,
    public = public,
    extends = extends,
    class = class,
    import = import
}