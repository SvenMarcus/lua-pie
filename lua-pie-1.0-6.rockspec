package = "lua-pie"
version = "1.0-6"
source = {
   url = "git://github.com/SvenMarcus/lua-pie",
   tag = "v1.06"
}
description = {
   summary = "A class library with encapsulation, inheritance and polymorphism.",
   detailed = [[
      lua-pie (polymorphism, ineritance and encapsulation) is a class library for Lua.
      Currently lua-pie supports interfaces with abstract methods and classes with private, public and static methods as well as inheritance with polymorphism via the respective keywords.
      Private member variables can be declared with the `self` keyword in the constructor. Classes may also contain metamethods using the operator keyword.
   ]],
   homepage = "https://github.com/SvenMarcus/lua-pie",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}
build = {
   type = "builtin",
   modules = {
      ["lua-pie"] = "src/lua-pie/init.lua",
      ["lua-pie.class"] = "src/lua-pie/class.lua",
      ["lua-pie.interface"] = "src/lua-pie/interface.lua",
      ["lua-pie.util"] = "src/lua-pie/util.lua"
   },
   copy_directories = {
      "doc"
   }
}
