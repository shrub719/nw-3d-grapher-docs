## 3.3 Complex programming techniques

### Matrices

`grapher/mat.rs` contains definitions for many vector and matrix calculation-related objects.
In Rust, these take the form of structures with implementations of methods and overloaded operators
from `core::ops`.

The matrices used in my program are 4-dimensional affine matrices, which allow for the inclusion
of 3-dimensional translations by exploiting the 4th dimension. These special matrices always
have a 1 in row 4, column 4.

```rs
impl MulAssign for Matrix4 {
    fn mul_assign(&mut self, other: Matrix4) {
        let self_copy = *self;
        for i in 0..4 {
            for j in 0..4 {
                let mut sum: f32 = 0.0;
                for k in 0..4 {
                    // OTHER * SELF so that other transformation applies after self
                    sum += other.0[k][j] * self_copy.0[i][k];
                }
                self.0[i][j] = sum;
            }
        }
    }
}
```

Some fundamental matrix operations are included in the definitions of `mat.rs`.
This is a basic four dimensional matrix operation which overloads the multiplication
operator, used for composing multiple transformations into one.

```rs
#[derive(Clone, Copy)]
pub struct Triangle3(pub [Vector3; 3]);
impl Mul<Matrix4> for Triangle3 {
    type Output = RTriangle3;
    // ...
```

Similar multiplication operations exist for aggregate polygon/triangle structs. The reason
these are abstracted is to appease the type-checking system; projecting a triangle from
domain coordinates to screen coordinates results in a different `RTriangle3` type (renderable
triangle in 3 dimensions).

```rs
#[derive(Debug, Clone, Copy)]
pub struct Matrix4(pub [[f32; 4]; 4]);
impl Matrix4 {
    pub fn inverse(&mut self) -> Matrix4 {
        let m = &self.0;
        let mut inv: [[f32; 4]; 4] = [[0.0; 4]; 4];

        inv[0][0] =  m[1][1]*m[2][2]*m[3][3] - m[1][1]*m[2][3]*m[3][2] -
                     m[2][1]*m[1][2]*m[3][3] + m[2][1]*m[1][3]*m[3][2] +
                     m[3][1]*m[1][2]*m[2][3] - m[3][1]*m[1][3]*m[2][2];

        inv[0][1] = -m[0][1]*m[2][2]*m[3][3] + m[0][1]*m[2][3]*m[3][2] +
                     m[2][1]*m[0][2]*m[3][3] - m[2][1]*m[0][3]*m[3][2] -
                     m[3][1]*m[0][2]*m[2][3] + m[3][1]*m[0][3]*m[2][2];

        // 50 lines of code omitted

        let mut det = m[0][0]*inv[0][0] + m[0][1]*inv[1][0] + m[0][2]*inv[2][0] + m[0][3]*inv[3][0];

        det = 1.0 / det;

        for i in 0..4 {
            for j in 0..4 {
                inv[i][j] *= det;
            }
        }

        Matrix4(inv)
    }
}
```

The above algorithm
carries out a matrix inverse operation. The process follows the traditional algorithm of finding
the transpose of the matrix of cofactors $C^T$, then dividing it by the determinant, except that
in order to optimise the process (this method is called thousands of times per action), the loop
is unrolled to manually calculate each element of the resulting matrix.

This is used in the raymarching algorithm in order to invert the camera projection matrix into an inverse
"screen space to domain coordinates" matrix, which is detailed later.

```rs
impl Mul<Matrix4> for RVector3 {
    type Output = Vector3;

    fn mul(self, matrix: Matrix4) -> Vector3 {
        let self_4 = [self.x as f32, self.y as f32, self.z as f32, 1.0];
        let mut result = [0.0; 4];
        for i in 0..4 {
            let mut sum: f32 = 0.0;
            for j in 0..4 {
                sum += matrix.0[i][j] * self_4[j];
            }
            result[i] = sum;
        }
        Vector3 {
            x: result[0],
            y: result[1],
            z: result[2]
        }
    }
}
```

This algorithm implements multiplication of a 3-dimensional vector (a point) by a 4-dimension matrix
(a linear transformation with a translation). The translation works by extending the vector into
4 dimensions with a $w$-coordinate of 1.
Regular matrix multiplication is then performed using two embededded for loops.

```rs
#[derive(Clone, Copy, Debug)]
pub struct Quaternion {
    pub w: f32,
    pub x: f32,
    pub y: f32,
    pub z: f32
}
impl Default for Quaternion {
    fn default() -> Self {
        Quaternion {
            w: 0.5713734,
            x: 0.77361715,
            y: 0.2203645,
            z: -0.16275544
        }
    }
}
```

Quaternions play a significant role in the user interaction with the graph in my program.
They are a special type of number (often regarded as an extension of the complex numbers)
which help represent rotations in 3 dimensions. Unlike Euler angles or other methods of 
storing rotational states, they completely avoid gimbal locking.

The `Quaternion` struct in my code is simply a collection of the coefficients of each
unit dimension in quaternion mathematics. The default quaternion represents a rotation of
which orients the graph in an isometric-like view.

```rs
impl Quaternion {
    pub fn new(w: f32, x: f32, y: f32, z: f32) -> Self {
        Quaternion { w, x, y, z }
    }

    pub fn from_angles(x: f32, y: f32, z: f32) -> Self {
        let (cx, sx) = (cos(x/2.0), sin(x/2.0));
        let (cy, sy) = (cos(y/2.0), sin(y/2.0));
        let (cz, sz) = (cos(z/2.0), sin(z/2.0));

        Quaternion::new(
            cx*cy*cz + sx*sy*sz, 
            sx*cy*cz + cx*sy*sz, 
            cx*sy*cz + sx*cy*sz, 
            cx*cy*sz + sx*sy*cz
        )
    }
```

In my code, quaternions handle all rotational mathematics abstractly, and are
converted from angles when needed. The formula to do so is displayed above.

```rs
    pub fn get_rotation_matrix(&self) -> Matrix4 {
        let (w, x, y, z) = (self.w, self.x, self.y, self.z);
        let x2 = self.x * self.x;
        let y2 = self.y * self.y;
        let z2 = self.z * self.z;
        Matrix4 ([
            [1.0 - 2.0*y2 - 2.0*z2, 2.0*x*y - 2.0*w*z    , 2.0*x*z + 2.0*w*y    , 0.0],
            [2.0*x*y + 2.0*w*z    , 1.0 - 2.0*x2 - 2.0*z2, 2.0*y*z - 2.0*w*x    , 0.0],
            [2.0*x*z - 2.0*w*y    , 2.0*y*z + 2.0*w*x    , 1.0 - 2.0*x2 - 2.0*y2, 0.0],
            [0.0                  , 0.0                  , 0.0                  , 1.0]
        ])
    }
}
```

Quaternions are used to store angles of rotation; to perform useful operations,
they must be converted to the special `Matrix4` struct that implements methods
related to points and polygons. This is again done with a formula derived outside of
this document. <!--show in research?-->

```rs
impl Mul<Quaternion> for Quaternion {
    type Output = Quaternion;

    fn mul(self, o: Quaternion) -> Quaternion {
        let s = self;
        Quaternion {
            w: s.w * o.w - s.x * o.x - s.y * o.y - s.z * o.z,
            x: s.w * o.x + s.x * o.w + s.y * o.z - s.z * o.y,
            y: s.w * o.y - s.x * o.z + s.y * o.w + s.z * o.x,
            z: s.w * o.z + s.x * o.y - s.y * o.x + s.z * o.w
        }
    }
}
```

The key part that distinguishes quaternions from other representations of rotation is
the ability to multiply two of them together to compound rotations.


### Rendering and rasterisation

Hey.
