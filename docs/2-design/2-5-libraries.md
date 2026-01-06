## 2.5 Libraries

### `embedded-alloc` with `cortex-m`

The N0120 uses a 216 MHz ARMv7 processor; the NumWorks family of calculators all use ARM Cortex-M CPUs.
In order for Rust to access the dynamic heap memory of the calculator, a feature which I use frequently throughout my code, I need a library which allows me to allocate memory in the calculator's RAM. The Cortex M library itself also requires a critical section implementation which manages concurrent access to memory to maintain program integrity.

Links: [embedded-alloc](https://docs.rs/embedded-alloc/latest/embedded_alloc/), [cortex-m](https://docs.rs/cortex-m/latest/cortex_m/)

### `heapless`

Conversely, sometimes a heapless solution is more optimal - I have discussed the pros and cons of each choice when relevant in my documentation. This crate allows my program to access the heapless version of built-in Rust data structures.

Importing it as a crate with a separate namespace helps me more clearly indicate when I've selected to use the default or heapless data structure, by prefixing heapless builtins with `heapless::`.

[Link](https://docs.rs/heapless/latest/heapless/)

### `eadk.rs`

The EADK is a platform which I've covered earlier in the documentation. `eadk.rs` is a module which provides rust bindings for the C kit.
NumWorks themselves provide one [here](https://github.com/numworks/epsilon-sample-app-rust), but implementation is lacking.

The community have created alternative bindings, keeping the principle of program safety in mind, while extending the functionality of the base EADK. 
My chosen community EADK bindings were provided by Yannis300307 with some expansions and tweaks by myself detailed later.

<!-- TODO: change when switching to yannis' completely original MIT licensed eadk -->
[Link](https://github.com/yannis300307/NumworksAppsRust)

