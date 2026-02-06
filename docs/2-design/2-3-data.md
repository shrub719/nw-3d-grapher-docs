## 2.3 Data

```{.mermaid format=svg}
flowchart TD
    g[Grapher]
    input[InputHandler]
    renderer[Renderer]
    timer[Timer]
    mesh[Mesh]
    mat[[Matrix calculator]]
    hud[[HUD]]
    gen[[Generator]]
    io((Ion))

    io --KeyboardState--> input
    io --millis--> timer
    input --Updates--> g
    timer --Time data--> g
    timer --Time data--> gen
    g --DOMAIN updates--> mesh
    g --VIEW updates--> mesh
    g --Delta time--> mesh
    mesh --Rotation/scale data--> mat
    mat --Transformation matrix --> mesh
    g --Function--> gen
    g --Updates--> hud
    g --Interaction details--> hud
    gen --Generated mesh--> mesh
    mesh --Homogenous clip space--> renderer
```

Rectangles represent classes; lined rectangles represent modules/procedures; circles represent APIs.

Considering the flow of data from module to module in my program is needed to optimise recalculation,
graph generation and rendering to only the necessary updates, passed via the Updates struct from
the input module. Ensuring that recalculation processes only occur when needed is paramount to
making the most of the NumWorks calculator's limited CPU, and making sure the user does not have to
wait unnecessarily long times between interactions.

I plan to handle these within a master algorithm in the Grapher class which manages different
levels of update - renderer (typically caused by rotations/scalings) and mesh generator (triggered
only by domain-level recalculations).

