function div(name::String, plot::Any, mime::String = "text/html")
    plot_div::Component{:div} = divider(name)
    io::IOBuffer = IOBuffer();
    show(io, mime, plot)
    data::String = String(io.data)
    data = replace(data,
     """<?xml version=\"1.0\" encoding=\"utf-8\"?>\n""" => "")
    plot_div[:text] = data
    plot_div::Component{:div}
end

function textdiv(name::String, p::Pair{String, String} ...; args ...)
    box = div(name, contenteditable = true, rawtext = "", selection = "", x = 0,
    y = 0, p ..., args ...)
    boxupdater = script("$name-updater", text = """
    function getCaretCoordinates() {
  let x = 0,
    y = 0;
  const isSupported = typeof window.getSelection !== "undefined";
  if (isSupported) {
    const selection = window.getSelection();
    if (selection.rangeCount !== 0) {
      const range = selection.getRangeAt(0).cloneRange();
      range.collapse(true);
      const rect = range.getClientRects()[0];
      if (rect) {
        x = rect.left;
        y = rect.top;
      }
    }
  }
  return { x, y };
}
    function updatecursor(event) {
        document.getElementById("$name").setAttribute("selection", window.getSelection());
        var coords = getCaretCoordinates();
        document.getElementById("$name").setAttribute("x", coords[0]);
        document.getElementById("$name").setAttribute("y", coords[1]);
    }
    document.getElementById("$name").addEventListener("drag", updatecursor);
    """)
    push!(box.extras, boxupdater)
    box::Component{:div}
end

tab(name::String, p::Pair{String, Any}; args ...) = Component(name,
    "tab", p ..., args ...)::Component{:tab}

function tabbedview(c::AbstractConnection, name::String, contents::Vector{Servable})
    tabwindow = div("$name-tabwindow", selected = contents[1])
    content = div("$name-contents")
    tabs = Vector{Servable}()
    for child in contents
        childtab = tab("$(child.name)-tab", text = child.name)
        on(c, childtab, "click", ["$name-contents"]) do cm::ComponentModifier
            set_children!(cm, "$name-contents", [child])
            cm[tabwindow] = "selected" => child.name
        end
        push!(tabwindow, tab)
    end
    tabwindow[:children] = tabs
    push!(tabwindow, content)
    tabwindow::Component{:div}
end

function cursor(name::String, args ...)
    cursor_updater = script(name, args ...)
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
    Component(name,"progress", ps..., args ...)
end

function colorinput()

end

function tabbedview()

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
    checkscript = script(text = """
    """)
    push!(cursor.extras, checkscript)
end
