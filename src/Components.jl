"""
**Defaults**
### write!(ac::Component{<:Any}, plot::Any, mime::MIME<:Any)
------------------
A catchall for `write!` on `Components` to display julia types.
#### example
```
using Plots
plt = plot(1:5, 1:5)
pltdiv = div("pltdiv")
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

"""
**Defaults**
### textdiv(name::String; text::String = "example")
------------------
A textdiv is a considerably advanced textbox.
#### example
```
route("/") do c::Connection
    mytxtdiv = textdiv("mydiv")
    on(c, mytxtdiv, "click") do cm::ComponentModifier
        txtdiv_rawtxt = cm[mytxtdiv]["rawtext"]
    end
    write!(c, mytxtdiv)
end
```
"""
function textdiv(name::String; text::String = "example")
    box = div(name, contenteditable = true, text = text, rawtext = "```text```", selection = "none", x = 0,
    y = 0)
    boxupdater = script("$name-updater", text = """
    function updateme(event) {
        document.getElementById("$name").setAttribute("rawtext", document.getElementById("$name").textContent);
    }
        document.getElementById("$name").addEventListener("input", updateme);
        """)
        push!(box.extras, boxupdater)
        return(box)::Component{:div}
end

"""
**Defaults**
### tabbedview(c::AbstractConnection, name::String, contents::Vector{Servable}) -> ::Component{:div}
------------------
Creates a tabbed view from the Components in `contents`.
#### example
```
div1 = div("first-div", text = "div1")
div2 = div("second-div", text = "div2")
mytab_view = tabbedview(c, "mytab", [div1, div2])
```
"""
function tabbedview(c::AbstractConnection, name::String, contents::Vector{Servable})
    tabwindow = div("$name", selected = contents[1].name)
    content = div("$name-contents")
    tabs = Vector{Servable}()
    [begin
        childtab = Toolips.ul("$(child.name)-tab", text = child.name)
        on(c, childtab, "click", ["$name-contents"]) do cm::ComponentModifier
            set_children!(cm, "$name-contents", [child])
            cm[tabwindow] = "selected" => child.name
        end
        push!(tabwindow, childtab)
    end for child in contents]
    tabwindow[:children] = tabs
    push!(tabwindow, content)
    push!(content, first(contents))
    tabwindow::Component{:div}
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

"""
**Defaults**
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
        oninput = "\"this.setAttribute('value',this.value);\"")::Component{:input}
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
    selected = value, oninput = "\"this.setAttribute('value',this.value);\"")::Component{:input}
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

function audio(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "audio controls", ps..., args ...)
end

function video(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "video", ps ..., args ...)
end

option(name::String, ps::Pair{String, String} ...; args ...) = Component(name, "option", args)

function progress(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "progress", ps..., args ...)
end

function colorinput()

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
    spoof = SpoofConnection()
    write!(spoof, comp)
    set_text!(cm, ppane.name, spoof.http.text)
end

function on_swipe(c::Connection, cursor::Component{script}, dir::String)
    throw("Not implemented!: This feature has not been implemented (yet)!")
    checkscript = script(text = """
    """)
    push!(cursor.extras, checkscript)
end
