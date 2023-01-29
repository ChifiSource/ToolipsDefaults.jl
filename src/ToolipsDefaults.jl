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
import Toolips: script, style!
import Base: push!
using ToolipsSession
import ToolipsSession: bind!, AbstractInputMap, AbstractComponentModifier

include("Styles.jl")
include("Components.jl")

"""
"""
mutable struct SwipeMap <: AbstractInputMap
    bindings::Vector{Pair{String, Function}}
end

function bind!(f::Function, c::Connection, sm::SwipeMap, swipe::String)
    swipes = ["left", "right", "up", "down"]
    if ~(swipe in swipes)
        throw(
        "Swipe is not a proper direction, please use up, down, left, or right!")
    end
    sm.bindings[swipe] = f
end

function bind!(c::Connection, cm::ComponentModifier, sm::SwipeMap,
    readonly::Vector{String} = Vector{String}())
    swipes = keys
    sc = script("swipemap", text = """
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
            /* right swipe */
        } else {
            /* left swipe */
        }
    } else {
        if ( yDiff > 0 ) {
            /* down swipe */
        } else {
            /* up swipe */
        }
    }
    /* reset values */
    xDown = null;
    yDown = null;
};

""")
end



export option, ColorScheme, dropdown, rangeslider, numberinput, containertextbox
export textbox, pane, anypane, stylesheet, cursor, static_observer, numberinput
export update!, audio, video, option, progress
end # module
