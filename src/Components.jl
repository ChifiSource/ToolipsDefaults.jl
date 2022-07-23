function anydiv(name::String, plot::Any, mime::String = "text/html")
    plot_div::Component{:div} = divider(name)
    io::IOBuffer = IOBuffer();
    show(io, mime, plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    plot_div[:text] = data
    plot_div
end

function anypane(name::String, plot::Any, mime::String = "text/html"; args ...)
    plot_div::Component{:div} = divider(name, args)
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

function audio(name::String, style::Style = audio_style(); args ...)
    component(name, "audio controls", args)
end

function video(name::String; args ...)
    Component(name, "video", args)
end

option(name::String, args ...) = Component(name, "option", args)

function loadbar(f::Function, c::Connection)
    internalprogress = divider()
    progressbar = divider()
    push!(progressbar, internalprogress)
    progressbarobs = observer(c)
end

function update!(cm::ComponentModifier, ppane::AbstractComponent, plot::Any)
    io::IOBuffer = IOBuffer();
    show(io, "text/html", plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    set_text!(cm, ppane.name, data)
end

function update!(cm::ComponentModifier, ppane::AbstractComponent,
    comp::AbstractComponent)
    spoof = Toolips.SpoofStream()
    write!(spoof, comp)
    set_text!(cm, ppane.name, spoof.http.text)
end
