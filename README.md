<div align><img src = "https://github.com/ChifiSource/image_dump/blob/main/toolips/toolipsdefaults.png" href = "https://toolips.app"></img></div>

- [Documentation](doc.toolips.app/extensions/toolips_base64)
- [Toolips](https://github.com/ChifiSource/Toolips.jl)
- [Extension Gallery](https://toolips.app/?page=gallery&selected=defaults)
### what's inside?
ToolipsDefaults contains default styles, stylesheets, Components, functions, tools, and compositions which can be easily integrated with your [toolips](https://github.com/ChifiSource/Toolips.jl) project. This can be a quick way to start and organize a project with some basics. 
##### styles
- The `ColorScheme` structure provides an easy format for interpretation by the stylesheet method, `sheet`.
- `sheet`, along with the `update!` function make it possible to change an entire stylesheet.
- individual style methods.
- **Style Demonstration**
```julia
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
- mobile touch gesture bindings
- **Components Demonstration**
```julia
```
##### other
- RequestModiifer - modify incoming requests and scrape data with the `Toolips.get` method.
- **RequestModifier Demonstration**
```julia
```
- The `update!` method allows us to replace any `AbstractComponent` out instantly.
- **update! Demonstration**
```julia
```
- Extra `write!` bindings that allow for writing of different MIMES automatically.

##### more UI packages
There are more options coming that will also provide similar UI elements to this package. Whenever I get through the other things I am doing, and get around to building many of them, I will put them here :)
