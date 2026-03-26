## 5.1 Objectives

1. **Grapher input**
    1. Parse mathematical text input
    1. Use the EADK Ion interface to take input from the user
        1. Accept alphanumeric key presses as text input
        1. Handle all special keys on the calculator as shortcuts for specific functions
    1. Graph configuration
        1. Toggle graph type (see **4. Graph generation**) ($z =$ and $0 =$)

The program interfaces with the EADK Events API to support input just like native applications,
displaying the result in a text field on the screen.
Graph type can also be toggled using the Toolbox key.

2. **Poincaré/Pompeiu**
    1. Convert parsed mathematical text input into a tree of evaluatable functions
    1. Implement function evaluation/calculation

Pompeiu (the name given to 3D Grapher's mathematical engine) successfully achieved these
goals, with a minimal. Expression "trees" were not stored as AST references
in memory but rather as an array of
elements to be folded using postfix rules, which achieves the same result for the end user
with faster function evaluation.

3. **Interface & controls**
    1. Allow for switching between multiple input modes (VIEW, DOMAIN)
    1. Handle D-pad input for graph manipulation by accepting directional input and handling correctly relative to viewing direction
    1. Display relevant information using a UI bar

3D Grapher's interface met the need of being intuitive to use by strictly adhering to 
the above objectives;
mode switching was implemented and communicated clearly to the user, with different modes handling
D-pad input in their own way and the HUD displaying information decided to be relevant during the
designing of the program.

4. **Graph generation**
    1. $z = f(x, y)$ (explicit functions) — Systematically generate a grid of 
    points by evaluating a parsed function
    1. $f(x, y, z) = 0$ (implicit functions) — Generate a triangular mesh from 
    a parsed implicit function using a marching cubes algorithm

Both mesh generation engines used by the program (explicit and implicit) are performant
and precise enough to display graphs of the complexity required by my target audience.
The marching cubes algorithhm effectively uses computational approximations to discover
solutions to implicit equations, and both the implicit and explicit graphs are produced
with sufficient detail while adhering to memory constraints.

5. **Graph manipulation**
    1. Implement different manipulation modes, with separate controls for 
    each axis (**3. Interface & controls**)
        1. VIEW - rotation and scaling of 3D domain relative to the camera
        1. DOMAIN - adjustment of domain start/end
    1. Interpret manipulations as a single (inverse) transformation matrix

Graph manipulation algorithms were implemented using 4D matrix operations, successfully
encompassing both goals of linear (VIEW-related) transformations and (DOMAIN) translations.
The modularity of individual transformations equired of objective 5.2 was also achieved,
allowing multiple transformations to occur simultaneously without interfering with each other.

6. **Graph display**
    1. Interface with Ion to draw to 320x240 screen
    1. Frame buffers
    1. Grid (explicit) graph formats
    1. Mesh (implicit) graph formats
    1. Implicit graph rasterisation with raytracer
    1. Handle the effect of input on graph display

Graph display was challenging on the hardware of the calculator, but in the end was achieved
with split frame buffers that optimise both memory usage and screen refresh time. Minimal 
Ion calls were used. Effective and time-efficient rasterisation algorithms for different polygons
were implemented, supporting thousands of vertices without noticeable lag or stutter.

The raytracer/raymarcher was also added, completing the goal of having a higher detail rasterisation
method for implicit graphs, in accordance with the needs of my end user.

The frame redraw logic described in objective 6.6 was successfully drafted using robust communication
of graph updates between modules, which reduces unnecessary redraws and is compatible with the HUD and
help menu overlays.

