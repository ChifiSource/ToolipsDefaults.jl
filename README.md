## dead repo
`ToolipsDefaults` is now a part of `ToolipsServables` in `Toolips` `0.3`. [Toolips](https://github.com/ChifiSource/Toolips.jl) [ToolipsServables](https://github.com/ChifiSource/ToolipsServables.jl)
--
- ( **This project can still be used with `Toolips` `0.2`.** )

</br>
<div align="center"><img src = "https://github.com/ChifiSource/image_dump/blob/main/toolips/toolipsdefaults.png" href = "https://toolips.app"></img></div>
</br>

- [Documentation](doc.toolips.app/extensions/toolips_base64)
- [Toolips](https://github.com/ChifiSource/Toolips.jl)
- [Extension Gallery](https://toolips.app/?page=gallery&selected=defaults)
### what's inside?
ToolipsDefaults contains default styles, stylesheets, Components, functions, and tools which can be easily integrated with your [toolips](https://github.com/ChifiSource/Toolips.jl) project. This can be a quick way to start and organize a project with some basics. This includes new input types, new prebuilt Components, and some other things...

#### styles
- The `ColorScheme` structure provides an easy format for changing colors of a `sheet`
- The `sheet` method can be provided a `ColorScheme` and creates
- You may use `style!(::Component{:sheet}, ::String, Pair{String, String} ...)` to style children of the sheet more quickly.
##### example
```julia
using Toolips
using ToolipsDefaults

home = route("/") do c::Connection
  cs = ColorScheme(foreground = "black", background = "orange")
  mysheet = ToolipsDefaults.sheet("My Styles")
  style!(mysheet, "div", "background-color" => "blue")
end
```
#### components
- textdiv
- tabbedview
- cursor
- textbox
- numberinput
- rangeslider
- dropdown
- audio
- video
- progress
- colorinput
##### example
```julia

```
#### other
- Extra `write!` binding that allows for writing of most Julia types.
- SwipeMap
##### example
```julia
swipe = route("/swipe") do c::Connection
    sm = ToolipsDefaults.SwipeMap()
    swipe_identifier = h("swipeid", 1, text = "none", align = "center")
    style!(swipe_identifier, "margin-top" => 40percent, "font-size" => 25pt)
    bod = body("mybody")
    bind!(c, sm, "right") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "right")
        style!(cm, bod, "background-color" => "black")
    end
    bind!(c, sm, "left") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "left")
        style!(cm, bod, "background-color" => "orange")
    end
    bind!(c, sm, "up") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "up")
        style!(cm, bod, "background-color" => "blue")
    end
    bind!(c, sm, "down") do cm::ComponentModifier
        set_text!(cm, swipe_identifier, "down")
        style!(cm, bod, "background-color" => "pink")
    end
    bind!(c, sm)
    push!(bod, swipe_identifier)
    style!(bod, "transition" => 5seconds)
    write!(c, bod)
end
```
