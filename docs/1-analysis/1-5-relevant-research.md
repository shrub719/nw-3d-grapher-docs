## 1.5 Relevant research

<!-- 
- desmos is used a lot
    - https://www.desmos.com/about##:~:text=Our%20free%20suite%20of%20math,the%20world.
- calculators are bought a lot
    - https://www.amazon.co.uk/Casio-FX-CG50-CASIO-Graphic-Calculator/dp/B071S1HRM7?th=1
    - https://www.amazon.co.uk/NumWorks-Graphic-calculator-numworks/dp/B0747RQGF5
    - https://www.amazon.co.uk/gp/bestsellers/officeproduct/201036031
- calculators are bought a lot - by STUDENTS in SCHOOLS
    - https://www.numworks.com/educators/offers/
    - https://education.casio.co.uk/teachers-and-schools/
- 3d graphs are used a lot - in a level further mathematics
    - ummmmm
use numbers!!
-->

### Target Market

Graphing calculators are [very popular](https://www.amazon.co.uk/gp/bestsellers/officeproduct/201036031)
with students of secondary and sixth form ages especially - manufacturers like [Casio](https://education.casio.co.uk/teachers-and-schools/) 
and [NumWorks](https://www.numworks.com/educators/offers/) have bulk offers aimed at educators,
purely because graphing calculators have such high educational value. Graphing programs - like
built-in calculator applications, or websites like [Desmos](https://www.desmos.com/about##:~:text=Our%20free%20suite%20of%20math,the%20world) 
are often desired by teachers for visually demonstrating various parts of the syllabus.

The [A Level Further Mathematics specification](https://qualifications.pearson.com/content/dam/pdf/A%20Level/Mathematics/2017/specification-and-sample-assesment/a-level-l3-further-mathematics-specification.pdf) 
has many areas in which graphs in 3 dimensions are relevant to course content, 
such as vectors & geomtetry, multivariable calculus, and modelling. As a result, 
current solutions do exist to attempt to give educators the tools they need, yet 
fail to be integrated in the classroom.

### Algorithms

Several solutions exist for producing a mesh of points from an implicit surface -
this will be necessary for rasterising implicit graphs (see [1.7 Objectives](1.7%20Objectives.md)). 
I've chosen to use an algorithm called marching cubes because of its ease of integration 
with [creating tris](https://graphics.stanford.edu/~mdfisher/MarchingCubes.html) from its 
geometric mesh for rendering. With appropriately chosen interpolation methods, the mesh 
produced can show an [accurate image of 3D implicit graphs](https://graphics.stanford.edu/~mdfisher/MarchingCubes.html) 
to the user.
