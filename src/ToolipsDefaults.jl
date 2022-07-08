module ToolipsDefaults
using Toolips
using ToolipsSession

mutable struct ColorScheme
    background::String
    foreground::String
    faces::String
    faces_hover::String
    text::String
    heading1::String
    heading2::String
    heading3::String
    heading4::String
    heading5::String
    function ColorScheme(;
        foreground::String = "#FDF8FF",
        background::String = "#8384DF",
        faces::String = "#F9AFEC",
        faces_hover::String = "#A2DEBD",
        text::String = "#FFFFFF",
        heading1::String = "#00147e",
        heading2::String = "#01A7EC",
        heading3::String = "#FFC94B",
        heading4::String = "#FE8F5D",
        heading5::String = "#80DA65"
        )
        new(background, foreground, faces, faces_hover, text, heading1,
                heading2, heading3, heading4, heading5)
    end
end

function stylesheet(cs::ColorScheme = ColorScheme();
                    textsize::Integer = 14, face_textsize::Integer = 12,
                    padding::Integer = 7, face_padding::Integer = 5)
        bodys = Style("body")
        bodys["background-color"] = cs.background
        divs = Style("div", padding = padding)
        divs["border-radius"] = "15px"
        divs["background-color"] = cs.foreground
        buttons = Style("button", padding = face_padding, color = cs.text,
        transition = ".5s")
        buttons["background-color"] = cs.faces
        buttons["border-style"] = "none"
        buttons:"hover":["background-color" => cs.faces_hover,
        "transform" => "scale(1.1)"]
        buttons["border-radius"] = "5px"
        as = Style("a", color = cs.text)
        ps = Style("p", color = cs.text)
        h1s = Style("h1", color = cs.heading1)
        h2s = Style("h2", color = cs.heading2)
        h3s = Style("h3", color = cs.heading3)
        h4s = Style("h4", color = cs.heading4)
        h5s = Style("h5", color = cs.heading5)
        components(bodys, divs, buttons, as, ps, h1s, h2s, h3s,
                h4s, h5s)
end


function anydiv(name::String, plot::Any, mime::String = "text/html")
    plot_div::Component = divider(name)
    io::IOBuffer = IOBuffer();
    show(io, mime, plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    plot_div[:text] = data
    plot_div
end

function anypane(name::String, plot::Any, mime::String = "text/html"; args ...)
    plot_div::Component = divider(name, args)
    style!(plot_div, dissplay => "inline-block")
    io::IOBuffer = IOBuffer();
    show(io, mime, plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    plot_div[:text] = data
    plot_div
end

function pane(name::String; args ...)
    pane_div::Component = divider(name)
    style!(pane_div, "display" => "inline-block")
    pane_div
end

function cursor(name::String, args ...)
    cursor_updater = script(name, args)
    cursor_updater["x"] = "1"
    cursor_updater["y"] = "1"
    cursor_updater[:text] = """setTimeOut(function () {
        document.getElementById("$name").x = event.clientX;
        document.getElementById("$name").y = event.clienty;
    }, 1000);
   """
   cursor_updater
end


"""
**Toolips Defaults**
### textbox(name::String, range::UnitRange = 1:10; text::String = "", size::Integer = 10) -> ::Component
------------------
Creates a textbox component.
#### example
```

```
"""
function textbox(name::String, range::UnitRange = 1:10;
                text::String = "", size::Integer = 10)
        input(name, type = "text", minlength = range[1], maxlength = range[2],
        value = text, size = size,
        oninput = "\"this.setAttribute('value',this.value);\"")
end

"""
**Toolips Defaults**
### textbox(name::String, containername::String; text::String = "text") -> ::Component
------------------
Creates a containertextbox component.
#### example
```

```
"""
function containertextbox(name::String, containername::String; text::String = "text")
    container = divider(containername, contenteditable = "true")
    txtbox = a(name, text = text)
    push!(container, txtbox)
    container
end

"""
**Toolips Defaults**
### numberinput(name::String, range::UnitRange = 1:10; value::Integer = 5) -> ::Component
------------------
Creates a number input component.
#### example
```

```
"""
function numberinput(name::String, range::UnitRange = 1:10; value::Integer = 5)
    input(name, type = "number", min = range[1], max = range[2],
    selected = value, oninput = "\"this.setAttribute('value',this.value);\"")
end

"""
**Toolips Defaults**
### rangeslider(name::String, range::UnitRange = 1:100; value::Integer = 50, step::Integer = 5) -> ::Component
------------------
Creates a range slider component.
#### example
```

```
"""
function rangeslider(name::String, range::UnitRange = 1:100;
                    value::Integer = 50, step::Integer = 5)
    input(name, type = "range", min = string(minimum(range)),
     max = string(maximum(range)), value = value, step = step,
            oninput = "\"this.setAttribute('value',this.value);\"")
end

function dropdown(name::String, options::Vector{Servable})
    thedrop = Component(name, "select")
    thedrop["oninput"] = "\"this.setAttribute('value',this.value);\""
    thedrop[:children] = options
    thedrop
end

function update!(cm::ComponentModifier, ppane::Component, plot)
    io::IOBuffer = IOBuffer();
    show(io, "text/html", plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    set_text!(cm, ppane.name, data)
end

function audio(name::String; args ...)
    component(name, "audio controls", args)
end

function video(name::String; args ...)
    Component(name, "video", args)
end

option(name::String, args ...) = Component(name, "option", args)
export option, ColorScheme, dropdown, rangeslider, numberinput, containertextbox
export textbox, pane, anypane, stylesheet
end # module
