## 3.4 Defensive programming

### Assertions

<!--TODO-->

### Type checking

Rust is a strongly, strictly and statically typed language, meaning the whole of my code
is type-safe, and checked as such by the Rust compiler.
Every single variable has a defined type, whether explicitly or implicitly.

A good example of this is the `Renderer` struct.

```rs
#[repr(C)]
#[derive(Copy, Clone)]
pub struct Color {
    pub rgb565: u16
}

pub struct Renderer {
    buffer: [Color; FB_WIDTH_SIZE * FB_HEIGHT_SIZE],
    depth_buffer: [f16; FB_WIDTH_SIZE * FB_HEIGHT_SIZE],
}
```

As well as defining its own type, its fields consist of static array types with a set defined
length, with 16-bit unsigned integer or signed float types.

Type checking is also used to my advantage in ensuring compatible inputs and outputs
when multiple complex functions are called one after the other. However, often
I have relied on the compiler inferring the types of these interim values.

### Try/except

Interfaces with external programs/commands that may result in exceptions, such as file systems,
do not occur within my program. When possible errors do occur, they are managed using the
Rust `Result` type and idiomatic error handling, as described [below](#coding-style).

