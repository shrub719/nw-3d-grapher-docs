## 3.5 Coding style

### Modules

Three dimensional arithmetic is used throughout my code frequently, so I found it 
important that complex operations are abstracted well into the `mat.rs`  submodule.
Multiple operators are overloaded using Rust `impl`s which makes code outside of the
module making use of matrix/vector arithmetic clear to read.

Other mathematical functions (namely the Taylor approximations of trigonometric functions
used throughout the program) are defined in `trig.rs`. The decision to implement these functions
myself instead of using the `libm` library is due to the constraints of a `no-std` environment,
as well as the larger object size and lower efficiency that `libm` provides compared to my
own code as a result of being less specialised.

The rest of the code is split into three modules based on purpose;

- `grapher` contains all code related to the 3D graph display, and handles communication
  with the mesh generators and user interface.
- `generator` is a collection of the various possible algorithms used for creating
  a mesh or rasterisation based on a graph expression.
- `expr` is the interface and logic for turning user input into a parseable
  RPN expression for use in the mesh generators.

More detailed relationships between the modules are described in my Design section.

### Local variables

The only global variables in my program are:

- The stack allocator (provided by the `embedded_alloc` library).
- The required ELF header `.rodata` for a `.nwa` application file.
- A collection of constants aggregated into the `constants.rs` submodule.
  This is a necessary tradeoff for avoiding the use of magic numbers within the code.
- Marching cubes lookup tables. [See above](#mesh-generation) for why.

### Exceptions

The only possibility of user-generated exceptions occur within the parsing
logic of the RPN expression that defines the graph. The `parser.rs` module
implements custom error types in order to utilise Rust's `Result<T, E>` meta type.

```rs
#[derive(Debug)]
pub enum ParserError {
    InvalidCharacter,
    Overflow
}

#[derive(Debug)]
pub enum EvalError {
    Underflow,
    Overflow,
    ZeroDiv
}
```

This allows for clean, idiomatic error handling expressions, including methods like
`map_err` or `ok_or`, and operators like `?`. 

```rs
_ => Token::Const(
    split.parse()
        .map_err(|_| ParserError::InvalidCharacter)?
)
```

Stack errors are also anticipated using
"test evaluations" of an RPN expression, and panics or `unwrap`s never occur within the code
as a result of these errors, and are instead handled with UI feedback.

Otherwise, the program ensures that errors such as zero division math errors
and memory overflow do not occur unchecked.

