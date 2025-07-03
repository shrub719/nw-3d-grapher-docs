## Rendering
- how many polygons can n0120 store in memory?
    - **256 KB** static RAM
    - to account for other program stuff and play it safe, say there's **100 KB**
    - 1 point is 3 `floats`, 4 B * 3 = **12 B**
    - 1 polygon is 3 vertices, 12 B * 3 = **36 B**
    - 100 KB / 36 B  = **3000 polygons**
    - but polygons will usually be touching
        - touching vertices can be stored as `usize` pointers
            - this sounds actually a bit weird to do, maybe not possible
        - [nw processor](https://www.mouser.co.uk/c/semiconductors/embedded-processors-controllers/microcontrollers-mcu/arm-microcontrollers-mcu/?core=ARM%20Cortex%20M7&data%20bus%20width=32%20bit&maximum%20clock%20frequency=216%20MHz&package%20%2F%20case=LQFP-208) is 32 bit, so a pointer is **4 B**
        - on average a polygon will be 1 vertex and 2 pointers, which is **20 B**
        - 256 KB / 20 B = **5000 polygons**
    - this is good news right !!
    - research data structures!!
        - octree
        - reference table thing
        - The Data Structure
    - how the other one generates the wireframe
        - starts from a corner, expands diagonally then closes back in
        - not THAT many corners to store
- algorithm
    - marching cubes
        - how do i store/generate polygons?
    - raymarching
        - implicit functions aren't always sdf's...
            - does this not affect marching cubes too??
- how many pixels can you store in a buffer to push at once? 
    - avoids super long eadk screen stuff
    - one pixel/`Color` is `uint32_t` which is **4 B**
    - 100 KB / 4 B = **25 000 pixels** in a buffer, theoretically
    - 320 * 240 = **76 800 pixels** on the screen in total
        - 1/2 screen: 320 * 240 * 1/4 = **19 200 pixels** (< 25 000)
        - 3/4 screen: 240 * 180 = **43 200 pixels** (fits in 200 KB...)
        - can't scale; has to be 1/2 of screen
        - could tile 4 times ! 4 rects is not that much
            - Python doesn't have support for pushing rects like that... so hopefully i'm faster
- speed
    - the other programs are REALLY slow
    - especially when drawing lines (with that one algorithm?) because they push pixel per pixel

## Makefile
- line ~21: -stc=c99
    - should it be no-std?
    - is this needed for storage.c
    - recode storage.c?

## Nwlink
- could use the same protocol nw uses to load to calc? just as a fun extra thing
- how to run in emulator