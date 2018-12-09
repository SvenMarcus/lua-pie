-- @module lua-pie
local util = require "util"
local warning = util.warning
local writing_allowed = util.writing_allowed

return function(classes)

	local FORBIDDEN_OPERATORS = {
	    __index = true,
	    __newindex = true
	}

	local function import(name)
	    return classes[name].class
	end

	local function extends(name)
	    classes[classes.currentDef].extends = name
	end

	local function private(tab)
	    local classdef = classes[classes.currentDef]
	    if classdef.isInterface then
	        error("Modifier 'private' not allowed in interfaces", 2)
	    end

	    for key, value in pairs(tab) do
	        if type(value) == "function" then
	            classdef.privateFuncDefs[key] = value
	        elseif type(value) == "table" and value.abstract_function then
	            error("Abstract methods are currently only allowed in interfaces", 2)
	        else
	            error("Currently only functions in private definitions are supported", 2)
	        end
	    end
	end

	local function public(tab)
	    local classdef = classes[classes.currentDef]
	    if classdef.isInterface then
	        error("Modifier 'public' not allowed in interfaces", 2)
	    end

	    for key, value in pairs(tab) do
	        if type(value) == "function" then
	            classdef.publicFuncDefs[key] = value
	        elseif type(value) == "table" and value.abstract_function then
	            error("Abstract methods are currently only allowed in interfaces", 2)
	        else
	            error("Currently only functions in public definitions are supported", 2)
	        end
	    end
	end

	local function static(tab)
	    for key, value in pairs(tab) do
	        classes[classes.currentDef].staticDefs[key] = value
	    end
	end

	local function operators(tab)
	    for key, value in pairs(tab) do
	        if type(value) ~= "function" then
	            error("Operator must be function", 2)
	        elseif FORBIDDEN_OPERATORS[key] then
	            error("Operator "..tostring(key).." is not allowed for classes.", 2)
	        else
	            classes[classes.currentDef].operators[key] = value
	        end
	    end
	end

	--- Returns whether or not a public function is defined in the parent class.
	-- @local in_super
	local function in_super(classdef, key)
	    if classdef.extends then
	        return classes[classdef.extends].publicFuncDefs[key] ~= nil
	    end
	    return false
	end

	local function class(name)
	    classes.currentDef = name
	    classes[classes.currentDef] = {
	        staticDefs = {
				getClass = function()
					return name
				end
	        },
	        privateFuncDefs = {},
	        publicFuncDefs = {},
	        operators = {},
	        extends = nil,
	        class = nil
	    }

	    return function(_)

	        local classdef = classes[name]

	        if classdef.extends then
				if not classes[classdef.extends] then
					error("Unknown parent class "..classdef.extends)
				end
	        end

	        if classdef.implements then
	            local interfaces = classdef.implements
	            if type(classdef.implements) == "string" then
	                interfaces = { classdef.implements }
	            end

	            for _, interfaceName in pairs(interfaces) do
	                local interface = classes[interfaceName]
	                if not interface then
						error("Unknown interface "..interfaceName)
	                end
	                for funcName, funcDef in pairs(interface.publicFuncDefs) do
	                    if not classdef.publicFuncDefs[funcName] then
	                        local varNames = ""

	                        for _, varName in pairs(funcDef.vars) do
	                            varNames = varNames..varName..", "
	                        end

	                        varNames = string.sub( varNames, 0, string.len(varNames) - 2)

	                        error("Class "..name.." does not implement abstract method: function "..funcName.."("..varNames..")", 2)
	                    end
	                end
	            end
	        end

	        classes[name].class = setmetatable( {}, {
	            __index = classdef.staticDefs,

	            __call = function(_, ...)

	                    local privateObj = {}
						local publicObj = {
							privateObj = privateObj
						}

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
	                                error("Trying to access private member "..tostring(k), 2)
	                            elseif in_super(classdef, k) then
	                                return super[k]
	                            else
	                                error("Trying to access non existing member "..tostring(k), 2)
	                            end
	                        end;
	                        __newindex = function(t, k, v)
	                            local static_member = classdef.staticDefs[k]
	                            if static_member then
	                                classdef.staticDefs[k] = v
	                            elseif writing_allowed() then
	                                rawset(t, k, v)
	                                warning("Setting keys for classes from outside is not intended. Objects will not be able to use new keys.")
	                            else
									error([[

									Trying to write new index to object.
									Writing is not permitted by default, because __newindex is required for the library.
									You can enable writing to objects with allow_writing_to_objects(true), e.g. for busted tests.
									Other usages may break the library.
									]])
	                            end
	                        end;
	                    }

	                    for operator, func in pairs(classdef.operators) do
	                        private_mt[operator] = func
	                        public_mt[operator] = function(_, ...)
	                            return private_mt[operator](privateObj, ...)
	                        end
	                    end

	                    setmetatable(publicObj, public_mt)

	                    local constructor = classdef.publicFuncDefs.constructor
	                    if constructor then
	                        constructor(privateObj, ...)
	                    end

	                    return publicObj
	                end
	        })

	        classes.currentDef = nil

	        return classes[name].class
	    end
	end

	return {
		import = import,
	    static = static,
	    private = private,
	    public = public,
	    operators = operators,
	    extends = extends,
	    class = class
	}
end