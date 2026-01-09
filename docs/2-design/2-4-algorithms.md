## 2.4 Algorithms

<!-- 
there are SO MANY algorithms for me to do.

generator: mc, raymarcher, explicit
renderer: triangle fill, linear interpolate
mat: matrix mul, matrix inv, quaternions
mesh: projection/scale matrices
grapher: input handling (i remember seeing somewhere to write input flow diagrams)
    ==> DATA SECTION !!
-->

### Marching cubes

Marching cubes is an algorithm used for numerically creating triangular meshes from implicit equations
in order to produce graphs.
Variations of this algorithm are used in graphing applications like Mathematica and Desmos 2D/3D.

Improvements upon this algorithm, which use real analysis to dynamically adjust cube density
based on local function complexity, are available, but were out of scope of my solution.

**Cube splitter**
```py
dx = (x_range / n_divisions)
dy = (y_range / n_divisions)
dz = (z_range / n_divisions)

for x_iter in range(n_divisions):
    for y_iter in range(n_divisions):
        for z_iter in range(n_divisions):
            # left-top-front vertex coordinates
            x0 = x_start + dx * x_iter
            y0 = y_start + dy * y_iter
            z0 = z_start + dz * z_iter
            
            # right-bottom-back vertex coordinates (opposite corner)
            x1 = x0 + dx
            y1 = y0 + dx
            z1 = z0 + dx

            # can now list all vertices of the cube (...)
            # pass them in to a cube testing function
            test_cube(...)
```

The main cube splitter function passes in an ordered set of vertices of the cube,
`vertices`.
The cube tester function also has access to a function `test`,
which tests the implicit equation to be graphed with the values of the vertex.  
If the result is 0, the point lies on the graph.

This is the primary operating principle for marching cubes; it attempts to find pairs of
vertices where the test function passes from positive to negative, and linearly interpolates
between their edges to estimate solutions.  
From these estimated points, there is always a triangular mesh that can be produced within the
cube that approximates the shape of the graph.

In this pseudocode, the methods by which these "solution edges" are determined and how a triangle
mesh is produced from them are ommitted, and
discussed later in the technical solution. <!-- TODO: link -->

**Cube tester** (function `test_cube`)
```py
test_values = []
for vertex in vertices:
    test_values.append(test(vertex))

solution_edges = find_edges(test_values)
mesh_vertices = []
for edge in solution_edges:
    # edge contains indices of vertices; extract them here
    p0 = edge[0]
    p1 = edge[1]
    
    mesh_vertices.append(interpolate(
        vertices[p0], vertices[p1],
        test_values[p0], test_values[p1]
    ))

triangles = get_triangles(mesh_vertices)
# add them to the mesh to be rendered
mesh.append(triangles)
```

### Raymarcher

Sometimes a higher resolution render of an implicit graph is needed than what marching cubes
permits us, given memory constraints.
Raymarching allows us to produce a single, high-quality frame of a graph from a specific
viewpoint by calculating the appropriate colour of each pixel on the screen.  
This is a sufficient level of detail for a great proportion of graphs even with the
NumWorks calculators' screen resolutions of 320x240.

The raymarcher makes use of a special 4 dimensional affine transformation matrix; specifically,
the inverse of the matrix used by the camera to generate pixels from domain coordinates. This lets
us "march" virtually through the imaginary z-axis of each pixel and use the inverse matrix to
calculate the corresponding coordinates at that point. 
The algorithm then tests that point to find, similar to marching cubes, the value at which
the test function passes from positive to negative or vice-versa.  
The current depth is then used to colour the pixel, if a solution is found.

```py
for pixel in pixels:
    # extract pixel coords
    x = pixel.x
    y = pixel.y

    # camera matrix shunts points between -1 (closest) and 1 (furthest) on the z-axis
    z0 = -1
    z1 = 1
    dz = (z1 - z0) / n_divisions

    z = z0
    prev_test = test(x, y, z)
    i = 0
    while i < n_divisions:
        z += dz
        c = matrix * (x, y, z)

        # if last two results are opposite signs
        if prev_test * test(x, y, z) < 0.0:
            break;

        prev_test = test(x, y, z)
        i += 1

    # calculate colour value from z coord
    value = (-z + 1) / 2 * 255
    if value > 255: value = 255
    if value < 0L value = 0
    
    # colour pixel
    if i == n:
        # out of range
        pixel.colour = rgb(255, 255, 255)
    else:
        # nice blue colour
        pixel.colour = rgb(0, value, 255)
```

### Grid generator

Explicit graphs given as $z = f(x, y)$ are significantly easier to generate graphs for.
The following pseudocode systematically generates tris for an explicit graph in a given
domain.

```py
dx = (x_range / n_divisions)
dy = (y_range / n_divisions)
dz = (z_range / n_divisions)

for x_iter in range(n_divisions):
    for y_iter in range(n_divions):
        x0 = x_start + dx * x_iter
        y0 = y_start + dy * y_iter

        vertices = []

        # cycle through vertices in a specific order
        for i in range(2):
            for j in range(2):
                x = x0 + dx * i
                y = y0 + dx * j
                z = f(x, y)

                # indexes specially to ensure proper order of vertices
                vertices[i*2 + j] = (x, y, z)

        # indexes are again chosen so that the triangles properly cover the graph
        mesh.append(triangle(
            vertices[1], vertices[2], vertices[0]
        ))
        mesh.append(triangle(
            vertices[1], vertices[2], vertices[3]
        ))
```

