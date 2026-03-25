## 4.1 Test plan

Test # | Purpose | Test data | Expected outcome | Result
:----- | :------ | :-------- | :--------------- | :-------------
1.1.a | Tokenise constants | 3 | Const | Passed
1.1.b | Tokenise operators | 1 1 + | Const, Const, Add | Passed
1.1.c | Tokenise variables | x | X | Passed
1.1.d | Tokenise functions | 0 \sin | Const, Sin | Passed
1.2.1.a | Accept alphanumeric characters | `x y 1 2 3` | z = x y 123 | Passed
1.2.2.a | Accept shift modifiers | `SHIFT+sin` | z = sin | Passed
1.2.2.b | Ignore alpha modifiers | `ALPHA+a` | z = | Passed
1.3.1.a | Toggle graph type | `TOOLBOX` | 0 = | Passed
2.1.a | Fold function calls | X, Sin | $\sin x$ | Passed
2.1.b | Do not evaluate constants | Const(2) | 2 | Passed
2.2.a | Evaluate arithmetic operators | 1 1 + | `2.0` | Passed
2.2.b | Evaluate trigonometric functions | $\pi$ sin | `0.0` | Passed
2.2.c.i | Evaluate whole indices | 2 3 \^ | `8.0` | Passed
2.2.c.ii | Evaluate negative indices | 2 (-1) \^ | `0.5` | Passed
3.1.a | Toggle mode | `OK` | VIEW => DOMAIN | Passed
3.2.a | Handle D-pad input in VIEW | `LEFT` | Rotation left | Passed
3.2.b | Handle D-pad input in DOMAIN | `LEFT` | Translation left | Passed
3.3.a | Display scale factor in VIEW | Default state | 1.0 | Passed
3.3.b | Display domain in DOMAIN | Default state | -10.0 // 10.0 | Passed
4.1.a | Plot explicit function | $z = x + y$ | Plane perpendicular to $(1 \ 1 \ -1)$ | Passed
4.2.a | Plot implicit function | $0 = xy + yz$ | Intersecting planes | Passed
5.1.1.a | Rotate graph | `LEFT+UP` | Rotate diagonally left/up 360 degrees | Passed
5.1.1.b | Scale graph | `PLUS` | Zoom view of graph, including axes | Passed
5.1.2.a | Translate domain | `LEFT+UP` | Shift graph +y/-x | Passed
5.1.2.b | Zoom domain | `PLUS` | Zoom domain into centre of graph | Passed
5.2.a | Aggregate multiple transformations | `LEFT+UP+PLUS` | Rotate while scaling together | Passed
6.2.a | Split screen into frame buffers | Plane mesh | Plane drawn on screen | Passed
6.2.b | Use depth buffers to draw overlapping objects | Intersecting plane mesh | Proper intersection + hiding | Passed
6.2.c | Rasterise triangles, lines and polygons | Plane mesh + axes | Plane + axes drawn on screen | Passed
6.3.a | Display explicit functions | $z = x + y$ | Graph displayed | Passed
6.4.a | Display implicit function | $0 = xy + yz$ | Graph displayed | Passed
6.5.a | Rasterise implicit mesh with raytracer | $\sin x \ \sin y = \sin z$ | Render graph screen in higher detail | Passed
6.6.a | Redraw display on input | `LEFT` | Graph redrawn in new position | Passed
6.6.b | Draw help menu over graph display | `TOOLBOX+LEFT` | Drawing handled while help menu opened without overlap | Passed

