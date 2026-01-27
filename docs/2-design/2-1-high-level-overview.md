## 2.1 High level overview

As I explored in **1. Analysis**, in order to replicate the functionality of
native Epsilon app's I have needed to streamline the nagivation to make menu
flow as straightforward as possible. This means the overall data flow of the program -
at least, that which is apparent to the user - is quite simple.

All key features can be accessed within one or two button presses once the
graph display is entered, making use of a "display mode" system that allows
the user to both translate, rotate and scale graphs in 3 dimensions with the
same inputs.

```{.mermaid format=svg}
flowchart TD
    home[Epsilon home]
    input[Input menu]
    mode[Graph mode switcher]
    mode1[VIEW mode]
    mode2[DOMAIN mode]
    tracer[Render screen]

    home --Open app--> input
    input --HOME button--> home
    input--Enter function--> mode
    mode --Exit graph display--> input
    mode <--Switch mode--> mode1
    mode <--Switch mode--> mode2
    mode --Trigger raytracer--> tracer
    tracer --Exit raytracer --> mode
```
