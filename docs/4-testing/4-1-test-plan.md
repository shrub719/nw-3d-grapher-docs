## 4.1 Test plan

Test # | Purpose | Test data | Expected outcome | Actual outcome
:----- | :------ | :-------- | :--------------- | :-------------
1.1.a | Tokenise constants | 3 | Expr: Const | Passed
1.1.b | Tokenise operators | 1 1 + | Expr: Const, Const, Add | Passed
1.1.c | Tokenise variables | x | Expr: X | Passed
1.1.d | Tokenise functions | 0 \sin | Expr: Const, Sin | Passed <!--skip a few-->
2.2.a | Evaluate arithmetic operators | 1 1 + | `2.0` | Passed
2.2.b | Evaluate trigonometric functions | \pi sin | `0.0` | Passed <!--C: TODO-->
2.2.d.i | Evaluate whole indices | 2 3 \^ | `8.0` | Passed
2.2.d.ii | Evaluate negative indices | 2 (-1) \^ | `0.5` | Passed



