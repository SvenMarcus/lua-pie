# classy

Classy is class library prototype for Lua.

## Overview

Classy was intended to be used in modifications for Star Wars Empire at War - Forces of Corruption. Since game produces corrupt save games when using multiple meta tables or upvalues, their usage was avoided wherever possible. In the end the library still cannot be used for the game in its current form due to engine limitations with `setfenv()`.

Currently classy supports private and public methods via the respective keyword as well as private member variables declared with the `self` keyword in the constructor.

## Usage

### Writing classes
```
local classy = require "classy"
local class = classy.class
local public = classy.public
local private = classy.private


class "Person" {
    public "constructor" { function(name)
        self.name = name
    end };

    public "introduce" { function()
        self.privatePrint()
    end };

    private "privatePrint" { function()
        print("Hi! My name is "..self.name)
    end };
}
```

### Instantiating objects
```
local classy = require "classy"
local import = classy.import
local Person = import("Person")

local slim = Person:new("Slim Shady")
slim.introduce()

--error trying to access private member
slim.privatePrint()
```

### Issues with Empire at War

When passing game objects (userdata) as arguments to member functions the game seems to "forget" about all functionality the game object has.

Example:
```
class "MyClass" {
  public "constructor" { function(planet)
    self.planetOwner = planet.Get_Owner() -- will throw an error, saying that Get_Owner() is a nil value
  end }
}
```

Moreover after saving and then loading a save game the function environment for the class methods is lost, resulting in `self` being nil.

Both errors seem to be connected to `setfenv()`, therefore a solution that doesn't rely on that function must be found.

### Other issues

The provided example works fine with the regular lua 5.1 compiler, but fails with luajit.
