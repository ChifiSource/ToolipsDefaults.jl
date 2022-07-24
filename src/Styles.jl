mutable struct ColorScheme
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
        color5::String = "#80DA65"
        )
        new(background, foreground, faces, faces_hover, text, text_faces, color1,
                color2, color3, color4, color5)::ColorScheme
    end
end

function default_divstyle(cs::ColorScheme; padding::Integer = 7, radius1::Integer = 15)
    Style("div", padding = padding, "background-color" => cs.background,
    "border-radius" => "$(radius1)px")
end

function default_buttonstyle(cs::ColorScheme; face_padding::Integer = 5,
    radius2::Integer = 8)
    s = Style("button", padding = face_padding, color = cs.text_faces,
    "background-color" => cs.faces, "border-style" => "none",
    "border-radius" => "$(radius2)px")
    s:"hover":["background-color" => "cs.faces_hover", "transform" => "scale(1.1)"]
    s
end

function stylesheet(name::String, cs::ColorScheme = ColorScheme();
                    textsize::Integer = 14, face_textsize::Integer = 12,
                    padding::Integer = 7, face_padding::Integer = 5,
                    radius1::Integer = 15, radius2::Integer = 8,
                    transition::Float64 = 0.5)
        sheet = Component(name, "sheet")
        appname = title("appname", text = name)
        description = meta("description", content = "default description")
        divs = default_divstyle(cs)
        buttons = default_buttonstyle(cs)
        as = Style("a", color = cs.text)
        ps = Style("p", color = cs.text)
        ps["font-size"] = "14pt"
        sectionst = Style("section", padding = "30px")
        sectionst["border-color"] = cs.color3
        sectionst["border-width"] = "2px"
        sectionst["border-radius"] = "10px"
        sectionst["border-style"] = "solid"
        sectionst["background-color"] = "white"
        sectionst["transition"] = "1s"
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
        push!(sheet, appname, description, divs, buttons, sectionst, as, ps, h1s,
         h2s, h3s,
                h4s, h5s, scrollbars)
                sheet
end
