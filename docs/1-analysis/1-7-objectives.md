## 1.7 Objectives

1. **Grapher input**
    1. Parse mathematical text input
        a. Tokenise constants
        a. Tokenise operators
        a. Tokenise variables
        a. Tokenise functions
    1. Use the EADK Ion interface to take input from the user
        1. Accept alphanumeric key presses as text input
            a. Input and display numbers and letters
        1. Handle all special keys on the calculator as shortcuts for specific functions
            a. Shift modifiers ($\sin$, $\cos$)
            a. Relevant alpha modifiers (brackets, $\arcsin$)
            a. Ignore irrelevant alpha modifiers ($=$, $\gt$)
    1. Graph configuration
        1. Toggle graph type (see **4. Graph generation**) ($z =$ and $0 =$)
            a. Flip function type in struct
1. **Poincaré/Pompeiu**
    1. Convert parsed mathematical text input into a tree of evaluatable functions
        a. Fold function tokens into function calls
        a. Do not evaluate constants/variables (create leaf nodes)
    1. Implement function evaluation/calculation
        a. Arithmetic operators
        a. Trigonometric approximations
        a. Inverse trigonometric approximations
        a. Indices, including negative and fractional
        a. Exponents and logarithms
1. **Interface & controls**
    1. Allow for switching between multiple input modes (VIEW, DOMAIN)
        a. Press super button to toggle mode
    1. Handle D-pad input for graph manipulation
        a. Accept directional input and handle correctly relative to viewing direction
    1. Display relevant information using a UI bar
        a. VIEW: scale factor
        b. DOMAIN: start and end x, y, and z coordinates of domain
1. **Graph generation**
    1. $z = f(x, y)$ (explicit functions) — Systematically generate a grid of 
    points by evaluating a parsed function
        a. Plot explicit function
    1. $f(x, y, z) = 0$ (implicit functions) — Generate a triangular mesh from 
    a parsed implicit function using a marching cubes algorithm
        a. Create mesh of implicit function
1. **Graph manipulation**
    1. Implement different manipulation modes, with separate controls for 
    each axis (**3. Interface & controls**)
        1. VIEW - rotation and scaling of 3D domain relative to the camera
            a. Use D-pad to rotate graph
            a. Use +/- to scale graph
        1. DOMAIN - adjustment of domain start/end
            a. Use D-pad to translate domain
            a. Use +/- to zoom domain
    1. Interpret manipulations as a single (inverse) transformation matrix
        a. Aggregate transformations into a single matrix
1. **Graph display**
    1. Grid (explicit) graph formats
        a. Display explicit function
    1. Mesh (implicit) graph formats
        a. Display implicit mesh
    1. Implicit graph rasterisation with raytracer
        a. Display raytraced implicit graph screen
