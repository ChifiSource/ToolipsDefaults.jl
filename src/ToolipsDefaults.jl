"""
Created in July, 2022 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[toolips](https://github.com/orgs/ChifiSource/teams/toolips)
This software is MIT-licensed.
### ToolipsDefaults
The ToolipsDefaults extension provides various default Styles and Components for
    full-stack applications.
##### Module Composition
- [**ToolipsDefaults**](https://github.com/ChifiSource/Toolips.jl)
"""
module ToolipsDefaults
using Toolips
import Toolips: SpoofConnection, AbstractComponent, div, AbstractConnection, get
import Toolips: style!, write!
import Base: push!, getindex, setindex!
using ToolipsSession
import ToolipsSession: bind!, InputMap

include("Styles.jl")
include("Components.jl")

"""
### ServerData <: Toolips.ServerExtension
- type::Symbol
- data::Dict{String, Any}

A simple extension to hold any server data inside a simple `Dict`.
------------------
##### constructors
- ConnectionData()
"""
mutable struct ServerData <: Toolips.ServerExtension
    type::Symbol
    data::Dict{String, Any}
    ServerData() = new(:connection, Dict{String, Any}())
end

 getindex(sd::ServerData, s::String) = ServerData.data[s]

 setindex!(sd::ServerData, a::Any, s::String) = ServerData.data[s] = a

"""
### SwipeMap <: ToolipsSession.InputMap
- bindings**::Dict{String, Function}**

The `SwipeMap` is an input map for swipe controls. Use the
`bind!(::Function, ::Connection, ::SwipeMap, ::String)` method to make
bindings to the map, then use `bind!(::Connection, ::SwipeMap, ::VectorString)`
to bind it to the `Connection`. The possible bindings include `left`, `right`,
`up`, and `down` -- all as `Strings`.
##### example
```
swipe = route("/swipe") do c::Connection
    sm = ToolipsDefaults.SwipeMap()
    swipe_identifier = h("swipeid", 1, text = "none", align = "center")
    style!(swipe_identifier, "margin-top" => 40percent, "font-size" => 25pt)
    bod = body("mybody")
    bind!(c, sm, "right") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "right")
        style!(cm, bod, "background-color" => "black")
    end
    bind!(c, sm, "left") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "left")
        style!(cm, bod, "background-color" => "orange")
    end
    bind!(c, sm, "up") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "up")
        style!(cm, bod, "background-color" => "blue")
    end
    bind!(c, sm, "down") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "down")
        style!(cm, bod, "background-color" => "pink")
    end
    bind!(c, sm)
    push!(bod, swipe_identifier)
    style!(bod, "transition" => 5seconds)
    write!(c, bod)
end
```
------------------
##### constructors
- SwipeMap()
"""
mutable struct SwipeMap <: InputMap
    bindings::Dict{String, Function}
    SwipeMap() = new(Dict{String, Function}())
end

"""
**Defaults**
### bind!(f::Function, c::Connection, sm::SwipeMap, swipe::String)
------------------
Binds a swipe to an event, swipes can be "left", "right", "up", or "down".
#### example
```
swipe = route("/swipe") do c::Connection
    sm = ToolipsDefaults.SwipeMap()
    swipe_identifier = h("swipeid", 1, text = "none", align = "center")
    style!(swipe_identifier, "margin-top" => 40percent, "font-size" => 25pt)
    bod = body("mybody")
    bind!(c, sm, "right") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "right")
        style!(cm, bod, "background-color" => "black")
    end
    bind!(c, sm, "left") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "left")
        style!(cm, bod, "background-color" => "orange")
    end
    bind!(c, sm, "up") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "up")
        style!(cm, bod, "background-color" => "blue")
    end
    bind!(c, sm, "down") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "down")
        style!(cm, bod, "background-color" => "pink")
    end
    bind!(c, sm)
    push!(bod, swipe_identifier)
    style!(bod, "transition" => 5seconds)
    write!(c, bod)
end
```
"""
function bind!(f::Function, c::Connection, sm::SwipeMap, swipe::String)
    swipes = ["left", "right", "up", "down"]
    if ~(swipe in swipes)
        throw(
        "Swipe is not a proper direction, please use up, down, left, or right!")
    end
    sm.bindings[swipe] = f
end

"""
**Defaults**
### bind!(c::Connection, sm::SwipeMap, readonly::Vector{String} = Vector{String})
------------------
Binds a `SwipeMap` to a `Connection`.
#### example
```
swipe = route("/swipe") do c::Connection
    sm = ToolipsDefaults.SwipeMap()
    swipe_identifier = h("swipeid", 1, text = "none", align = "center")
    style!(swipe_identifier, "margin-top" => 40percent, "font-size" => 25pt)
    bod = body("mybody")
    bind!(c, sm, "right") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "right")
        style!(cm, bod, "background-color" => "black")
    end
    bind!(c, sm, "left") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "left")
        style!(cm, bod, "background-color" => "orange")
    end
    bind!(c, sm, "up") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "up")
        style!(cm, bod, "background-color" => "blue")
    end
    bind!(c, sm, "down") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "down")
        style!(cm, bod, "background-color" => "pink")
    end
    bind!(c, sm)
    push!(bod, swipe_identifier)
    style!(bod, "transition" => 5seconds)
    write!(c, bod)
end
```
"""
function bind!(c::Connection, sm::SwipeMap,
    readonly::Vector{String} = Vector{String}())
    swipes = keys
    swipes = ["left", "right", "up", "down"]
    newswipes = Dict([begin
        if swipe in keys(sm.bindings)
            ref = ToolipsSession.gen_ref()
            if getip(c) in keys(c[:Session].iptable)
                push!(c[:Session][getip(c)], "$ref" => sm.bindings[swipe])
            else
                c[:Session][getip(c)] = Dict("$ref" => sm.bindings[swipe])
            end
            if length(readonly) > 0
                c[:Session].readonly["$ip$ref"] = readonly
            end
            swipe => "sendpage('$ref');"
        else
            swipe => ""
        end
    end for swipe in swipes])
    sc::Component{:script} = script("swipemap", text = """
    document.addEventListener('touchstart', handleTouchStart, false);
document.addEventListener('touchmove', handleTouchMove, false);

var xDown = null;
var yDown = null;

function getTouches(evt) {
  return evt.touches ||             // browser API
         evt.originalEvent.touches; // jQuery
}

function handleTouchStart(evt) {
    const firstTouch = getTouches(evt)[0];
    xDown = firstTouch.clientX;
    yDown = firstTouch.clientY;
};

function handleTouchMove(evt) {
    if ( ! xDown || ! yDown ) {
        return;
    }

    var xUp = evt.touches[0].clientX;
    var yUp = evt.touches[0].clientY;

    var xDiff = xDown - xUp;
    var yDiff = yDown - yUp;

    if ( Math.abs( xDiff ) > Math.abs( yDiff ) ) {/*most significant*/
        if ( xDiff > 0 ) {
            $(newswipes["left"])
        } else {

            $(newswipes["right"])
        }
    } else {
        if ( yDiff > 0 ) {
            $(newswipes["up"])
        } else {
            $(newswipes["down"])
        }
    }
    /* reset values */
    xDown = null;
    yDown = null;
};

""")
    write!(c, sc)
end

export ColorScheme, cursor, SwipeMap, set_textdiv_caret!

end # module
