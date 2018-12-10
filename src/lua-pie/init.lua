--- Classes in Lua with lua-pie (polymorphism, inheritance, encapsulation)
-- @module lua-pie

local classes = {}

local class_definitions = require "lua-pie.class" (classes)

--- Imports a class.
-- @function import
-- @tparam string name The name of the class to import
-- @usage
-- local MyClass = import("MyClass")
-- local instance = MyClass()
local import = class_definitions.import

--- Extends a class with another class.
-- @function extends
-- @tparam string name The name of the class to extend with
local extends = class_definitions.extends

--- Defines static methods in a class definition.
-- @function static
-- @tparam table tab A table containing static function definitions or variables
-- @usage
-- static {
--    my_var = 5;
--    my_func = function(self, args)
--    end
-- }
local static = class_definitions.static

--- Defines public methods in a class definition.
-- @function public
-- @tparam table tab A table containing public function definitions
-- @usage
-- public {
--    my_func = function(self, args)
--    end
-- }
local public = class_definitions.public

--- Defines private methods in a class definition.
-- @function private
-- @tparam table tab A table containing private function definitions
-- @usage
-- private {
--    my_func = function(self, args)
--    end
-- }
local private = class_definitions.private

--- Allows adding metamethods for operators.
-- The first parameter of the metamethod is the object (self) and allows access to private members.
-- __index and __newindex are currently not allowed.
-- @function operators
-- @tparam table tab A table containing operator function definitions.
-- @usage
-- operators {
--     __add = function(self, other)
--     end
-- }
local operators = class_definitions.operators

--- Creates a new class.
-- @function class
-- @tparam string name The class name
-- @return A function that accepts a table with private, public, static and operator definitions
-- @usage
-- class "MyClass" {
--    implements {
--        "IMyInterface",
--        "IAnotherInterface"
--    };
--    extends "Parent";
--    static { ... };
--    private { ... };
--    public { ... };
--    operators { ... };
-- }
-- @see implements
-- @see extends
-- @see static
-- @see private
-- @see public
-- @see operators
local class = class_definitions.class

--- Anonymous function returned by class() that accepts a table as a class body.
-- Private, public, static and operator members must be declared in the input table.
-- @function class_body
-- @tparam table tab
-- @return the created class table that can be instantiated by calling it (same as import("ClassName")).
-- @see class
-- @see import

local interface_definitions = require "lua-pie.interface" (classes)

--- Defines an interface.
-- @function interface
-- @tparam string name The name of the interface
-- @usage
-- interface "IMyInterface" {
--     my_func = abstract_function("arg1", "arg2")
-- }
-- @see abstract_function
local interface = interface_definitions.interface

--- Defines an abstract function in an interface.
-- @function abstract_function
-- @param ... Varargs with variable names
-- @see interface
local abstract_function = interface_definitions.abstract_function

--- Implements an interface.
-- @function implements
-- @param interfaces A single string with an interface name or a table of interface names
local implements = interface_definitions.implements

local util = require "lua-pie.util" (classes)

--- Check if an object is an instance of a class.
-- An object is also considered an instance of its super class, any of its implemented interfaces
-- as well as any interface implemented by the super class.
-- @function is
-- @param object The object to compare
-- @tparam string className the name of the class
local is = util.is

--- Toggle displaying of warnings.
-- @function show_warnings
-- @tparam boolean bool Whether or not to show warnings
local show_warnings = util.show_warnings

--- Toggle writing to objects.
-- @function allow_writing_to_objects
-- @tparam boolean bool Whether or not objects may be written to
local allow_writing_to_objects = util.allow_writing_to_objects


return {
    show_warnings = show_warnings,
    allow_writing_to_objects = allow_writing_to_objects,
    static = static,
    private = private,
    public = public,
    operators = operators,
    extends = extends,
    class = class,
    interface = interface,
    abstract_function = abstract_function,
    implements = implements,
    is = is,
    import = import
}
