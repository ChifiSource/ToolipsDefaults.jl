</br>
<div align="center"><img src = "https://github.com/ChifiSource/image_dump/blob/main/toolips/toolipsdefaults.png" href = "https://toolips.app"></img></div>
</br>

- [Documentation](doc.toolips.app/extensions/toolips_base64)
- [Toolips](https://github.com/ChifiSource/Toolips.jl)
- [Extension Gallery](https://toolips.app/?page=gallery&selected=defaults)
### what's inside?
ToolipsDefaults contains default styles, stylesheets, Components, functions, and tools which can be easily integrated with your [toolips](https://github.com/ChifiSource/Toolips.jl) project. This can be a quick way to start and organize a project with some basics. This includes new input types, new prebuilt Components, and some other things...

##### styles
- The `ColorScheme` structure provides an easy format for changing colors of a `sheet`
- The `sheet` method can be provided a `ColorScheme` and creates
- You may use `style!(::Component{:sheet}, ::String, Pair{String, String} ...)` to style children of the sheet more quickly.
- **Style Demonstration**
```julia
using Toolips
using ToolipsDefaults

home = route("/") do c::Connection
  cs = ColorScheme(foreground = "black", background = "orange")
  mysheet = ToolipsDefaults.sheet("My Styles")
  style!(mysheet, "div", "background-color" => "blue")
end
```
##### components
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
- **Components Demonstration**
```julia

```
##### other
- Extra `write!` binding that allows for writing of most Julia types.
- SwipeMap

