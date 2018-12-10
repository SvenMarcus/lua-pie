-- @module lua-pie
local util = require "util"
local warning = util.warning

return function(classes)

	local function implements(interfaces)
	    classes[classes.currentDef].implements = interfaces
	end

	local function abstract_function(...)
	    return {
	        abstract_function = true,
	        vars = {...}
	    }
	end

	local function interface(name)
	    classes.currentDef = name
	    classes[classes.currentDef] = {
	        isInterface = true,
	        publicFuncDefs = {}
	    }

	    return function(tab)
	        local classdef = classes[name]

	        for k, v in pairs(tab) do
	            if type(v) == "table" and v.abstract_function then
	                if type(k) == "string" then
	                    classdef.publicFuncDefs[k] = v
	                else
	                    error("Unexpected index of type "..tostring(type(v).." in interface definition"), 2)
	                end
	            else
	                error("Unexpected value of type "..tostring(type(v)).." in interface definition", 2)
	            end
	        end

	        classdef.currentDef = nil
	    end
	end

	return {
		interface = interface,
		abstract_function = abstract_function,
		implements = implements
	}
end