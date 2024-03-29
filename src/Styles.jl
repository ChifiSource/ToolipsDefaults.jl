"""
### ColorScheme <: Servable
- background::String
- foreground::String
- face::String
- faces_hover::String
- text::String
- text_facess::String
- color1::String
- color2::String
- color3::String
- color4::String
- color5::String

The `ColorScheme` provides an easy way to get a `sheet` of Styles in a particular
color theme.
##### example
```
cs = ColorScheme(background = "#FFFFFF")
mysheet = sheet("styles", cs)
```
------------------
##### constructors
- ColorScheme(;
        foreground::String = "#FDF8FF",
        background::String = "#FFFFFF",
        faces::String = "#F9AFEC",
        faces_hover::String = "#A2DEBD",
        text::String = "#5B4679",
        text_faces::String = "#FFFFFF",
        color1::String = "#00147e",
        color2::String = "#754679",
        color3::String = "#795B46",
        color4::String = "#4B7946",
        color5::String = "#80DA65"
        )
"""
mutable struct ColorScheme <: Servable
    background::String
    foreground::String
    faces::String
    faces_hover::String
    text::String
    text_faces::String
    color1::String
    color2::String
    color3::String
    color4::String
    color5::String
    function ColorScheme(;
        foreground::String = "#FDF8FF",
        background::String = "#FFFFFF",
        faces::String = "#F9AFEC",
        faces_hover::String = "#A2DEBD",
        text::String = "#5B4679",
        text_faces::String = "#FFFFFF",
        color1::String = "#00147e",
        color2::String = "#754679",
        color3::String = "#795B46",
        color4::String = "#4B7946",
        color5::String = "#3D3D3D"
        )
        new(background, foreground, faces, faces_hover, text, text_faces, color1,
                color2, color3, color4, color5)::ColorScheme
    end
end


write!(c::Connection, cs::ColorScheme) = write!(c, sheet("styles", cs))

function default_divstyle(cs::ColorScheme; padding::Integer = 7, radius1::Integer = 15)
    Style("div", padding = padding, "background" => "transparent",
    "border-radius" => "$(radius1)px", "overflow-y" => "scroll")
end

function default_buttonstyle(cs::ColorScheme; face_padding::Integer = 5,
    radius2::Integer = 8)
    s = Style("button", padding = face_padding, color = cs.text_faces,
    "background-color" => cs.faces, "border-style" => "none",
    "border-radius" => "$(radius2)px", transition = 1seconds)
    s:"hover":["background-color" => "cs.faces_hover", "transform" => "scale(1.1)"]
    s
end

function default_tabstyle(cs::ColorScheme; radiustop::Int64 = 5,
    face_padding::Int64 = 5)
    s = Style("tab", padding = face_padding, transition = 1seconds,
    "backgroundcolor" => cs.faces, color = cs.text_faces)
    s::Style
end

default_astyle(cs::ColorScheme) = Style("a", color = cs.color4)

default_pstyle(cs::ColorScheme; textsize = 12pt) = ps = Style("p",
    color = cs.text, "font-size" => "14pt")

function default_sectionstyle(cs::ColorScheme; padding::Any = 30px,
    radius::Any = 10px)
    Style("section", padding = "30px", "border-color" => cs.color3,
    "border-width" => "2px", "border-radius" => 10px, "border-style" => "solid",
    "transition" => 1seconds)::Style
end

"""
**Defaults**
### sheet(name::String, cs::ColorScheme, p::Pair{String, Any} ...; textsize::Integer = 14,
    face_textsize::Integer = 12, padding::Integer = 7, face_padding::Integer = 5,
    radius1::Integer = 15, radius2::Integer = 8, transition::Float64, args ...) -> ::Component{:sheet}
------------------
Creates a new stylesheet from a ColorScheme. This makes stylesheets more easily replacable
and easier to work with.
#### example
```

```
"""
function sheet(name::String, cs::ColorScheme = ColorScheme(), p::Pair{String, Any} ...;
                    textsize::Integer = 14, face_textsize::Integer = 12,
                    padding::Integer = 7, face_padding::Integer = 5,
                    radius1::Integer = 15, radius2::Integer = 8,
                    transition::Float64 = 0.5,
                    args ...)
        sheet = Component(name, "sheet", p ..., args ...)
        divs = default_divstyle(cs)
        buttons = default_buttonstyle(cs)
        as = default_astyle(cs)
        ps = default_pstyle(cs, textsize = textsize)
        sectionst = default_sectionstyle(cs, padding = padding)
        tabs = default_tabstyle(cs)
        h1s = Style("h1", color = cs.color1)
        h2s = Style("h2", color = cs.color2)
        h3s = Style("h3", color = cs.color3)
        h4s = Style("h4", color = cs.color4)
        h5s = Style("h5", color = cs.color5)
        scrollbars = Style("::-webkit-scrollbar", width = "5px")
        scrtrack = Style("::-webkit-scrollbar-track", background = "transparent")
        scrthumb = Style("::-webkit-scrollbar-thumb", background = "#797ef6",
        "border-radius" => "5px")
        push!(scrollbars.extras, scrtrack, scrthumb)
        push!(sheet, divs, buttons, sectionst, as, ps, h1s,
         h2s, h3s,
                h4s, h5s, scrollbars)
                sheet
end

"""
**Defaults**
### style!(::Component{:sheet}, child::String, p::Pair{String, String} ...)
------------------
Styles a child in a sheet by name.
#### example
```

```
"""
style!(c::Component{:sheet}, child::String, p::Pair{String, String} ...) = style!(c[:children][child], p ...)
