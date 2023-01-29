"""
**Defaults**
### write!(ac::Component{<:Any}, plot::Any, mime::MIME<:Any)
------------------
A catchall for `write!` on `Components` to display julia types.
#### example
```
using Plots
plt = plot(1:5, 1:5)
write!(pltdiv, plot, MIME"text/html")
```
"""
function write!(ac::Component{<:Any}, plot::Any, mime::MIME{<:Any} = MIME"text/html"())
    plot_div::Component{<:Any}
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    plot_div[:text] = data
end

#==
- containers
- inputs
- textboxes
- audiovideo
- misc ui
- actions
==#
"""
**Defaults**
### tabbedview(c::AbstractConnection, name::String, contents::Vector{Servable}) -> ::Component{:div}
------------------
Creates a tabbed view from the Components in `contents`. `contents` will be
a `Vector{"Servable"}` of each page. The pages content is stored within a `Component{:div}`
with the name `(\$name)-contents`.
#### example
```
div1 = div("first-div", text = "div1")
div2 = div("second-div", text = "div2")
mytab_view = tabbedview(c, "mytab", [div1, div2])
```
"""
function tabbedview(c::AbstractConnection, name::String, contents::Vector{Servable})
    tabwindow = div(name, selected = contents[1].name)
    content = div("$name-contents")
    [begin
        childtab = Toolips.ul("$(child.name)-tab", text = child.name)
        style!(childtab, "display" => "inline-block", "cursor" => "pointer")
        on(c, childtab, "click", [name]) do cm::ComponentModifier
            set_children!(cm, "$name-contents", [child])
            cm[tabwindow] = "selected" => child.name
        end
        push!(tabwindow, childtab)
    end for child in contents]
    push!(tabwindow, content)
    push!(content, first(contents))
    tabwindow::Component{:div}
end

"""
**Defaults**
### dialog(c::Connection, name::String, p::Pair{String, Any} ...; x::String = 35percent,
y::String = 20percentt, label::String = "popup", args ...)
------------------
Creates a new dialog box translated to `x` and `y` with `label` at the top. The
topbar is named `bar(\$name)` and the content div is named `(\$name)-contents`.
#### example
```
div1 = div("first-div", text = "div1")
div2 = div("second-div", text = "div2")
mytab_view = tabbedview(c, "mytab", [div1, div2])
```
"""
function dialog(c::Connection,
    name::String, p::Pair{String, Any} ...; x::String = 35percent,
    y::String = 20percent, label::String = "popup", args ...)
    maindia::Component{:dialog} = Component(name, name, p ..., args ...)
    style!(maindia, "margin-left" => x, "margin-top" => y, "width" => 30percent,
    "position" => "fixed", "display" => "block", "background" => "transparent", "border-width" => 0px)
    # top bar
    topbar::Component{:div} = div("bar$name")
    topblabel::Component{:b} = Toolips.b(text = label, align = "center")
    style!(topblabel, "color" => "white", "display" => "inline-block", "margin-left" => 5px)
    xbutton::Component{:button} = button("topx$name", text = "X", align = "right")
    on(c, xbutton, "click") do cm::ComponentModifier
        remove!(cm, maindia)
    end
    style!(xbutton, "color" => "white", "background-color" => "red", "display" => "inline-block", "float" => "right",
    "border-radius" => 4px, "border-width" => 0px)
    style!(topbar,
    "background-color" => "blue", "border-radius" => 4px, "padding" => 1px, "border-width" => 0px)
    push!(topbar, topblabel, xbutton)
    # contents
    maindia[:children] = [topbar]
    contentarea::Component{:div} = div("$name-contents")
    style!(contentarea, "background-color" => "white", "border-radius" => "3px",
    "border-top" => "0px", "border-width" => 5px, "border-color" => "gray")
    push!(maindia[:children], contentarea)
    maindia
end

"""
**Defaults**
### textdiv(name::String; text::String = "example")
------------------
A textdiv is a considerably advanced textbox. This includes an additional
property -- to be read by a ComponentModifier -- called `rawtext`.
#### example
```
route("/") do c::Connection
    mytxtdiv = ToolipsDefaults.textdiv("mydiv")
    on(c, mytxtdiv, "click") do cm::ComponentModifier
        txtdiv_rawtxt = cm[mytxtdiv]["rawtext"]
    end
    write!(c, mytxtdiv)
end
```
"""
function textdiv(name::String; text::String = "example")
    raw = element("raw$name")
    style!(raw, "display" => "none")
    box = div(name, contenteditable = true, text = text, rawtext = "`text`", selection = "none", x = "0",
    y = "0", oninput="document.getElementById('raw$name').innerHTML=document.getElementById('$name').textContent;")
    push!(box.extras, raw)
    return(box)::Component{:div}
end

"""
**Defaults**
### textbox(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...;
text::String = "", size::Integer = 10, args ...) -> ::Component
------------------
Creates a textbox component. Value is stored in the `value` attribute.
#### example
```
route("/") do c::Connection
    mytxt = ToolipsDefaults.textbox("mydiv")
    on(c, mytxt, "click") do cm::ComponentModifier
        txtdiv_rawtxt = cm[mytxt]["text"]
    end
    write!(c, mytxtdiv)
end
```
"""
function textbox(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...;
                text::String = "", size::Integer = 10, args ...)
        input(name, type = "text", minlength = range[1], maxlength = range[2],
        value = text, size = size,
        oninput = "\"this.setAttribute('value',this.value);\"", p ...,
         args ...)::Component{:input}
end

"""
**Defaults**
### password(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...;
text::String = "", size::Integer = 10, args ...) -> ::Component{:input}
------------------
Creates a textbox component. Value is stored in the `value` attribute.
#### example
```
route("/") do c::Connection
    mytxt = ToolipsDefaults.textbox("mydiv")
    on(c, mytxt, "click") do cm::ComponentModifier
        txtdiv_rawtxt = cm[mytxt]["text"]
    end
    write!(c, mytxtdiv)
end
```
"""
function password(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...;
                text::String = "", size::Integer = 10, args ...)
        input(name, type = "password", minlength = range[1], maxlength = range[2],
        value = text, size = size,
        oninput = "\"this.setAttribute('value',this.value);\"", p ...,
        args ...)::Component{:input}
end

"""
**Toolips Defaults**
### numberinput(name::String, range::UnitRange = 1:10; value::Integer = 5) -> ::Component
------------------
Creates a number input component. Value is stored in the `value` attribute.
#### example
```

```
"""
function numberinput(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...
    ; value::Integer = 5, args ...)
    input(name, type = "number", min = range[1], max = range[2],
    selected = value, oninput = "\"this.setAttribute('value',this.value);\"")::Component{:input}
end

"""
**Toolips Defaults**
### rangeslider(name::String, range::UnitRange = 1:100; value::Integer = 50, step::Integer = 5) -> ::Component
------------------
Creates a range slider component. Value is stored in the `value` attribute.
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

"""
**Toolips Defaults**
### dropdown(name::String, options::Vector{Servable}) -> ::Component{:input}
------------------
Creates a dropdown Component. Value is stored in the `value` attribute.
#### example
```

```
"""
function dropdown(name::String, options::Vector{Servable})
    thedrop = Component(name, "select")
    thedrop["oninput"] = "\"this.setAttribute('value',this.value);\""
    thedrop[:children] = options
    thedrop
end

"""
**Toolips Defaults**
### option(name::String, ps::Pair{String, String} ...; args ...) -> ::Component
------------------
Creates an Option Component..
#### example
```

```
"""
option(name::String, ps::Pair{String, String} ...; args ...) = Component(name,
 "option", args)

 """
 **Toolips Defaults**
 ### colorinput
 ------------------
 Creates a range slider component.
 #### example
 ```

 ```
 """
function colorinput(name::String, p::Pair{String, Any} ...;
    value::String = "#ffffff", args ...)
    input(name, type = "color", value = value,
    oninput = "\"this.setAttribute('value',this.value);\"", p ...,
    args ...)::Component{:input}
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
function audio(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "audio controls", ps..., args ...)
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
function video(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "video", ps ..., args ...)
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
function progress(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "progress", ps..., args ...)
end

"""
**Defaults**
### cursor(name::String, p::Pair{String, Any}; args ...) -> ::Component{:script}
------------------
Creates a trackable cursor with x and y values that can be used by Modifiers.
#### example
```
mycurs = cursor("mycurs")
```
"""
function cursor(name::String, p::Pair{String, Any}; args ...)
    cursor_updater = script(name, p ..., args ...)
    cursor_updater["x"] = "1"
    cursor_updater["y"] = "1"
    cursor_updater[:text] = """
    function updatecursor(event) {
        document.getElementById("$name").setAttribute("x", event.clientX);
        document.getElementById("$name").setAttribute("y", event.clientY);
    }
    document.getElementsByTagName("body")[0].addEventListener("mousemove", updatecursor);
   """
   cursor_updater::Component{:script}
end
