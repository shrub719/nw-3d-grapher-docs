## Marching cubes
- how many polygons can n0120 store in memory?
    - **256 KB** static RAM
    - 1 point is 3 `floats`, 4 B * 3 = **12 B**
    - 1 polygon is 3 vertices, 12 B * 3 = **36 B**
    - 256 KB / 36 B  = **7000 polygons**
    - but polygons will usually be touching
        - touching vertices can be stored as `usize` pointers
        - [nw processor](https://www.mouser.co.uk/c/semiconductors/embedded-processors-controllers/microcontrollers-mcu/arm-microcontrollers-mcu/?core=ARM%20Cortex%20M7&data%20bus%20width=32%20bit&maximum%20clock%20frequency=216%20MHz&package%20%2F%20case=LQFP-208) is 32 bit, so a pointer is **4 B**
        - on average a polygon will be 1 vertex and 2 pointers, which is **20 B**
        - 256 KB / 20 B = **12 800 polygons**

## Makefile
- line ~21: -stc=c99
    - should it be no-std?
    - is this needed for storage.c
    - recode storage.c?

## GH
- could use the same protocol nw uses to load to calc? just as a fun extra thing