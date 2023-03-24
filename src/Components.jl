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
function tabbedview(c::AbstractConnection, name::String, contents::Vector{Servable},
    p::Pair{String, Any} ...; args ...)
    tabwindow = div(name, selected = contents[1].name, p ..., args ...)
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
    name::String, p::Pair{String, Any} ...; x::String = 20percent,
    y::String = 10percent, label::String = "popup", args ...)
    maindia::Component{:dialog} = Component(name, "dialog", p ..., args ...)
    style!(maindia, "left" => x, "top" => y, "width" => 30percent,
    "position" => "absolute", "display" => "block", "background" => "transparent", "border-width" => 0px)
    # top bar
    topbar::Component{:div} = div("bar$name")
    topblabel::Component{:p} = Toolips.p("label$name", text = label, align = "center")
    style!(topblabel, "color" => "white", "display" => "inline-block",
    "margin-left" => 5px, "font-weight" => "bold")
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
### textdiv(name::String, p::Pair{String, Any} ...; text::String = "example", args ...)
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
function textdiv(name::String, p::Pair{String, <:Any} ...; text::String = "example",
    args ...)
    raw = element("raw$name")
    caretpos = script("caretposition", text = """
    function getCaretIndex$(name)(element) {
  let position = 0;
  const isSupported = typeof window.getSelection !== "undefined";
  if (isSupported) {
    const selection = window.getSelection();
    if (selection.rangeCount !== 0) {
      const range = window.getSelection().getRangeAt(0);
      const preCaretRange = range.cloneRange();
      preCaretRange.selectNodeContents(element);
      preCaretRange.setEnd(range.endContainer, range.endOffset);
      position = preCaretRange.toString().length;
    }
  }
  document.getElementById('$name').setAttribute('caret',position);
}
function createRange(node, chars, range) {
    if (!range) {
        range = document.createRange()
        range.selectNode(node);
        range.setStart(node, 0);
    }

    if (chars.count === 0) {
        range.setEnd(node, chars.count);
    } else if (node && chars.count >0) {
        if (node.nodeType === Node.TEXT_NODE) {
            if (node.textContent.length < chars.count) {
                chars.count -= node.textContent.length;
            } else {
                 range.setEnd(node, chars.count);
                 chars.count = 0;
            }
        } else {
            for (var lp = 0; lp < node.childNodes.length; lp++) {
                range = createRange(node.childNodes[lp], chars, range);

                if (chars.count === 0) {
                   break;
                }
            }
        }
   }

   return range;
};

function setCurrentCursorPosition$(name)(chars) {
    chars = chars + 3;
    if (chars >= 0) {
        var selection = window.getSelection();

        range = createRange(document.getElementById("$(name)").parentNode, { count: chars });

        if (range) {
            range.collapse(false);
            selection.removeAllRanges();
            selection.addRange(range);
        }
    }
};""")
    style!(raw, "display" => "none")
    box = div(name, p ..., contenteditable = true, text = text, rawtext = "`text`",
    caret = "0",
    oninput="document.getElementById('raw$name').innerHTML=document.getElementById('$name').textContent;getCaretIndex$(name)(this);",
    args ...)
    push!(box.extras, raw, caretpos)
    return(box)::Component{:div}
end

function set_textdiv_caret!(cm::ToolipsSession.AbstractComponentModifier,
    txtd::Component{:div},
    char::Int64)
    push!(cm.changes, "setCurrentCursorPosition$(txtd.name)($char);")
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
        txtdiv_rawtxt = cm[mytxt]["value"]
    end
    write!(c, mytxtdiv)
end
```
"""
function textbox(name::String, range::UnitRange = 1:10, p::Pair{String, <:Any} ...;
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
        txt = cm[mytxt]["value"]
    end
    write!(c, mytxt)
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
route("/") do c::Connection
    mytxt = ToolipsDefaults.textbox("mydiv")
    on(c, mytxt, "click") do cm::ComponentModifier
        txtdiv_rawtxt = cm[mytxt]["text"]
    end
    write!(c, mytxt)
end
```
"""
function numberinput(name::String, range::UnitRange = 1:10, p::Pair{String, Any} ...
    ; value::Integer = 5, args ...)
    input(name, type = "number", min = range[1], max = range[2],
    selected = value, oninput = "\"this.setAttribute('value',this.value);\"", p ...,
    args ...)::Component{:input}
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
            oninput = "\"this.setAttribute('value',this.value);\"", p ..., args ...)
end

"""
**Toolips Defaults**
### dropdown(name::String, options::Vector{Servable}) -> ::Component{:input}
------------------
Creates a dropdown Component. Value is stored in the `value` attribute. `options`
is a `Vector` of `ToolipsDefaults.option`
#### example
```

```
"""
function dropdown(name::String, options::Vector{Servable}, p::Pair{String, <:Any} ...; args ...)
    thedrop = Component(name, "select", p ..., args ...)
    thedrop["oninput"] = "\"this.setAttribute('value',this.value);\""
    thedrop[:children] = options
    thedrop
end

"""
**Toolips Defaults**
### checkbox(name::String, p::Pair{String, <:Any} ...; value::Bool = false, args ...) -> ::Component{:input}
------------------
Creates a checkbox Component. Value is stored in the `value` attribute.
#### example
```

```
"""
function checkbox(name::String, p::Pair{String, <:Any} ...; value::Bool = false,
    args ...)
    ch = input(name, p  ..., type = "checkbox", value = value,
    oninput = "this.setAttribute('value',this.checked);", args ...)
    if value
        ch["checked"] = value
    end
    ch::Component{:input}
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
 "option", ps ..., args ...)

 """
 **Toolips Defaults**
 ### colorinput(name::String, p::Pair{String, Any} ...; value = "#ffffff", args ...) -> ::Component{:input}
 ------------------
Creates a color input Component.
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
### progress(name::String, ps::Pair{String, String}; args ...) -> ::Component{:progress}
------------------
Creates a progress Component.
#### example
```

```
"""
function progress(name::String, ps::Pair{String, String} ...; args ...)
    Component(name, "progress", ps..., args ...)
end

"""
**Defaults**
### cursor(name::String, p::Pair{String, Any} ,,,; args ...) -> ::Component{:script}
------------------
Creates a trackable cursor with x and y values that can be used by Modifiers. Use
the `x` and `y` attributes to retrieve the cursor position.
#### example
```
route("/") do c::Connection
    mycurs = cursor("mycurs")
    write!(c, mycurs)
    on(c, "click") do cm::ComponentModifier
        println(cm[mycurs]["x"], cm[mycurs]["y"])
    end
end
```
"""
function cursor(name::String, p::Pair{String, Any} ...; args ...)
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
**Toolips Defaults**
### context_menu!(menu::Component{<:Any})
------------------
Turns any Component into a context (right-click) menu.
#### example
```

```
"""
function context_menu!(menu::Component{<:Any})
    name = menu.name
    scr = script("$name-script", text = """
const scope = document.querySelector("body");
    scope.addEventListener("contextmenu", (event) => {
    event.preventDefault();
    const { clientX: mouseX, clientY: mouseY } = event;
    document.getElementById("$name").style.top = `\${mouseY}px`;
    document.getElementById("$name").style.left = `\${mouseX}px`;
    document.getElementById("$name").style["opacity"] = 100;
    });""")
    push!(menu.extras, scr)
    style!(menu, "opacity" => 0percent, "position" => "absolute")
    menu::Component{<:Any}
end

"""
**Toolips Defaults**
```julia
button_select(c::Connection, name::String, buttons::Vector{<:Servable},
unselected::Vector{Pair{String, String}}, selected::Vector{Pair{String, String}} -> ::Component{:div}
```
------------------
Creates a button select div. Selected button can be accessed with the `value`
attribute. Default is first button.
#### example
```

```
"""
function button_select(c::Connection, name::String, buttons::Vector{<:Servable},
    unselected::Vector{Pair{String, String}} = ["background-color" => "blue",
     "border-width" => 0px],
    selected::Vector{Pair{String, String}} = ["background-color" => "green",
     "border-width" => 2px])
    selector_window = div(name, value = first(buttons)[:text])
    [begin
    style!(butt, unselected)
    on(c, butt, "click") do cm
        [style!(cm, but, unselected) for but in buttons]
        cm[selector_window] = "value" => butt[:text]
        style!(cm, butt, selected)
    end
    end for butt in buttons]
    selector_window[:children] = Vector{Servable}(buttons)
    selector_window::Component{:div}
end

"""
**Toolips Defaults**
```julia
keyinput(name::String, p::Pair{String, <:Any} ...; text::String = "w",
args ...) -> ::Component{:button}
```
------------------
Creates a key input button. Selected value is stored in the `value` attribute.
#### example
```

```
"""
function keyinput(name::String, p::Pair{String, <:Any} ...; text = "w", args ...)
    button(name, p ..., text = text,
    onkeypress = "this.innerHTML=event.key;this.setAttribute('value',event.key);",
    onclick = "this.focus();", value = "W",  args ...)
end
