## 5.4 Areas for future development

Although the current mesh generation engine supports all functions that can be defined as $z = f(x, y)$ or $0 = f(x, y, z)$,
allowing all types of surfaces to be generated, the program does not support lines or curves in 3D space
defined as $f(x) = g(y) = h(z)$ or similar. This would require new algorithms for polygon generation,
but would fit into the current workflow of the program.

Pompeiu, the mathematical expression parser and evaluator, still has some room to expand.
It fails to be as comprehensive as NumWorks' own native engine, which could be improved by
adding support for fractional indices, as well as exponents, natural logarithms, and logarithms
with real bases. 

Complex number support could also be considered, although this expands the purpose of
the grapher from 3 dimensional functions (working in $\mathbb R^3$) to 
functions that map $\mathbb C \rightarrow \mathbb R$ and more.

Perhaps most useful to an end user would be the ability to enter expressions in infix notation,
as natural mathematical expressions. This would expand the accessibility of the program, but
was difficult to implement on limited hardware at high speeds. Future development would
consider special algorithms for the efficient evaluation of recursive Abstract Syntax Trees produced
by infix expression parsing in order to make it a viable solution.

