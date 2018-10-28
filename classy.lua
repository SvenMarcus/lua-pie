local classes = {
    currentDef = nil,
    nextName = nil,
    environments = {}
}

local function import(name)

    return setmetatable(
        {},
        {__call = function(t, ...)
            local obj = {}

            local env = {self = {}}
            classes.environments[obj] = env

            setmetatable(env, {__index = _G})


            local self_mt = {
                __index = function(t, key)
                    local class = classes[name]
                    local publicDefs = class.publicDefs
                    local privateDefs = class.privateDefs
                    local func = publicDefs[key] or privateDefs[key]
                    if func and type(func) == "function" then
                        return setfenv(func, env)
                    end

                    if env.super then
                        return super[key]
                    end

                    error("attempt to call field ".."'"..key.."'".." (a nil value)--")
                end
            }

            if classes[name].extends then
                local super = import(classes[name].extends)()
                env.super = super
            end

            setmetatable(env.self, self_mt)
            setmetatable(obj, classes[name].class)

            if classes[name].publicDefs.constructor then
                obj.constructor(unpack({...}))
            end

            return obj
        end}
    )
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

        local obj_mt = {
            env = {self = {}},
            __index = function(t, key)
                local class = classes[name]
                local objPublic = class.publicDefs
                local func = objPublic[key]
                local objEnvironment = classes.environments[t]

                if func and type(func) == "function" then
                    return setfenv(func, objEnvironment)
                end



                if classes[name].extends then
                    local super = classes[classes[name].extends]
                    local superPublic = super.publicDefs

                    func = superPublic[key]
                    if func and type(func) == "function" then
                        return setfenv(func, classes.environments[objEnvironment.super])
                    end
                end

                error("Trying to access non existing or private member "..tostring(key))
            end
        }

        classes[name].class = obj_mt

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