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
        text::String = "#5B4679",
        color1::String = "#00147e",
        color2::String = "#754679",
        color3::String = "#795B46",
        color4::String = "#4B7946",
        color5::String = "#80DA65"
        )
        new(background, foreground, faces, faces_hover, text, heading1,
                heading2, heading3, heading4, heading5)
    end
end
#==
TODO: Methodize all of these styles, with multiple revisions available and
colorschemes passed as arguments.
==#

function stylesheet(title::String, cs::ColorScheme = ColorScheme();
                    textsize::Integer = 14, face_textsize::Integer = 12,
                    padding::Integer = 7, face_padding::Integer = 5,
                    radius1::Integer = 15, radius2::Integer = 10)
        title = title("title", text = title)
        description = meta("description", content = "default description")
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
        ps["font-size"] = "14pt"
        sectionst = Style("section", padding = "30px")
        sectionst["border-color"] = cs.color3
        sectionst["border-width"] = "2px"
        sectionst["border-radius"] = "10px"
        sectionst["border-style"] = "solid"
        sectionst["background-color"] = "white"
        sectionst["transition"] = "1s"
        push!(styles, sectionst)
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
        components(bodys, divs, buttons, sectionst, as, ps, h1s, h2s, h3s,
                h4s, h5s, scrollbars)::Vector{Servable}
end
