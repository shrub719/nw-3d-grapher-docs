## 3.2 Key code

```rs
==> constants.rs <==
pub mod settings {
    pub const ROTATION_SPEED: f32 = 1.5;
    pub const SCALE_SPEED: f32 = 0.5;
    pub const DOMAIN_SCALE_SPEED: f32 = 0.1;
}

pub mod palette {
    use crate::eadk::Color;

    pub const ORANGE: Color = Color::from_rgb(255, 183, 52);
    pub const WHITE: Color = Color::from_rgb(255, 255, 255);
    pub const GREY: Color = Color::from_rgb(230, 230, 230);
    pub const DARK_GREY: Color = Color::from_rgb(75, 75, 75);
    pub const BLACK: Color = Color::from_rgb(0, 0, 0);

    pub const RED: Color = Color::from_rgb(255, 90, 75);
    pub const GREEN: Color = Color::from_rgb(75, 200, 90);
    pub const BLUE: Color = Color::from_rgb(75, 90, 255);
}

pub mod graphics {
    pub const SCREEN_WIDTH: u16 = 320;
    pub const SCREEN_HEIGHT: u16 = 240;
    pub const SCREEN_WIDTH_SIZE: usize = SCREEN_WIDTH as usize;

    pub const HUD_HEIGHT: u16 = 36;

    pub const MARGIN_TOP: u16 = 18;
    pub const MARGIN_BOTTOM: u16 = HUD_HEIGHT;

    pub const FRAME_HEIGHT: u16 = SCREEN_HEIGHT - (MARGIN_TOP + MARGIN_BOTTOM);

    // 2 is possible with margins and very few triangles...
    pub const FB_TILE: u16 = 3;

    pub const FB_WIDTH: u16 = SCREEN_WIDTH / FB_TILE;
    pub const FB_HEIGHT: u16 = FRAME_HEIGHT / FB_TILE;
    pub const FB_WIDTH_SIZE: usize = FB_WIDTH as usize;
    pub const FB_HEIGHT_SIZE: usize = FB_HEIGHT as usize;

    use crate::eadk::Color;
    use super::palette::*;
    pub const BG: Color = WHITE;
    pub const AXIS_COLORS: [Color; 3] = [RED, GREEN, BLUE];
}

#[cfg(target_os = "none")]
pub mod limits {
    #[cfg(not(debug_assertions))]
    pub const MAX_TRIS: usize = 1500;
    #[cfg(debug_assertions)]
    pub const MAX_TRIS: usize = 1000;

    pub const EXPLICIT_N: usize = 18;
    pub const IMPLICIT_N: usize = 10;
    pub const MARCH_N: usize = 300;

    #[cfg(not(debug_assertions))]
    pub const MAX_ROW_TIME: u64 = 100;
    #[cfg(debug_assertions)]
    pub const MAX_ROW_TIME: u64 = 200;

    pub const MAX_TOKENS: usize = 32;
    pub const PARSE_STACK: usize = 16;
}

#[cfg(not(target_os = "none"))]
pub mod limits {
    pub const MAX_TRIS: usize = 15000;
    pub const EXPLICIT_N: usize = 30;
    pub const IMPLICIT_N: usize = 30;
    pub const MARCH_N: usize = 500; // what should the limits be?
    pub const MAX_ROW_TIME: u64 = 50;
    pub const MAX_TOKENS: usize = 128;
    pub const PARSE_STACK: usize = 32;
}

pub mod strings {
    pub const ROTATE_NAME: &str = "VIEW";
    pub const TRACE_NAME: &str = "TRACE";
    pub const DOMAIN_NAME: &str = "DOMAIN";

    type Help<'a> = [&'a str; 10];
    pub const ROTATE_HELP: Help = [
        "Rotate:",
        "  D-Pad ( )",
        "",
        "Zoom:",
        "  + -",
        "",
        "Reset:",
        "  Bcksp",
        "",
        ""
    ];
    pub const TRACE_HELP: Help = [
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
    ];
    pub const DOMAIN_HELP: Help = [
        "Translate:",
        "  D-Pad ( )",
        "",
        "Scale:",
        "  + -",
        "",
        "Reset:",
        "  Bcksp",
        "",
        ""
    ];
}

pub mod controls {
    use crate::eadk::input::Key;

    pub const D_DOWN: Key =     Key::Down;
    pub const D_UP: Key =       Key::Up;
    pub const D_LEFT: Key =     Key::Left;
    pub const D_RIGHT: Key =    Key::Right;
    pub const D_SP_1: Key =     Key::RightParenthesis;
    pub const D_SP_2: Key =     Key::LeftParenthesis;

    pub const INCREASE: Key =   Key::Plus;
    pub const DECREASE: Key =   Key::Minus;
    pub const MODIFIER: Key =   Key::Multiplication;

    pub const CONFIRM: Key =    Key::OK;
    pub const BACK: Key =       Key::Back;

    pub const HELP: Key =       Key::Toolbox;
    pub const RESET: Key =      Key::Backspace;

    pub const MODE_SWITCH: Key = Key::OK;

    pub const ENHANCE: Key =    Key::EXE;

    pub const EXIT: Key =       Key::Home;
}

==> eadk.rs <==
// thanks to yannis300307 for the extended eadk (most of this file)

use crate::constants::palette::*;

#[repr(C)]
#[derive(Copy, Clone)]
pub struct Color {
    pub rgb565: u16
}
impl Color{
    #[inline]
    pub const fn from_rgb(r: u16, g: u16, b: u16) -> Self {
        Color {
            rgb565: ((r & 0b11111000) << 8) | ((g & 0b11111100) << 3) | (b >> 3),
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct Rect {
    pub x: u16,
    pub y: u16,
    pub width: u16,
    pub height: u16
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct Point {
    pub x: u16,
    pub y: u16,
}

pub mod display {
    use super::Rect;
    use super::Color;
    use super::Point;

    #[cfg(target_os = "none")]
    use alloc::ffi::CString;

    #[cfg(not(target_os = "none"))]
    use std::ffi::CString;

    use core::ffi::c_char;

    pub fn push_rect(rect: Rect, pixels: &[Color]) {
        unsafe {
            eadk_display_push_rect(rect, pixels.as_ptr());
        }
    }

    pub fn push_rect_uniform(rect: Rect, color: Color) {
        unsafe {
            eadk_display_push_rect_uniform(rect, color);
        }
    }

    pub fn wait_for_vblank() {
        unsafe {
            eadk_display_wait_for_vblank();
        }
    }

    pub fn draw_string(
        text: &str,
        point: Point,
        large_font: bool,
        text_color: Color,
        background_color: Color,
    ) {
        unsafe {
            eadk_display_draw_string(
                CString::new(text).unwrap().as_ptr(),
                point,
                large_font,
                text_color,
                background_color,
            )
        }
    }

    unsafe extern "C" {
        fn eadk_display_push_rect_uniform(rect: Rect, color: Color);
        fn eadk_display_push_rect(rect: Rect, color: *const Color);
        fn eadk_display_wait_for_vblank();
        fn eadk_display_draw_string(
            text: *const c_char,
            point: Point,
            large_font: bool,
            text_color: Color,
            background_color: Color,
        );
    }
}

pub mod timing {
    pub fn usleep(us: u32) {
        unsafe {
            eadk_timing_usleep(us);
        }
    }

    pub fn msleep(ms: u32) {
        unsafe {
            eadk_timing_msleep(ms);
        }
    }

    pub fn millis() -> u64 {
        unsafe {
            return eadk_timing_millis();
        }
    }

    unsafe extern "C" {
        fn eadk_timing_usleep(us: u32);
        fn eadk_timing_msleep(us: u32);
        fn eadk_timing_millis() -> u64;
    }
}

pub fn random() -> u32 {
    unsafe {
        return eadk_random()
    }
}

unsafe extern "C" {
    fn eadk_random() -> u32;
}

pub mod input {
    use enum_iterator::Sequence;

    type EADKKeyboardState = u64;

    #[allow(dead_code)]
    #[derive(Clone, Copy, PartialEq, Eq, Sequence, Debug)]
    #[repr(u8)]
    pub enum Key {
        Left = 0,
        Up = 1,
        Down = 2,
        Right = 3,
        OK = 4,
        Back = 5,
        Home = 6,
        OnOff = 8,
        Shift = 12,
        Alpha = 13,
        Xnt = 14,
        Var = 15,
        Toolbox = 16,
        Backspace = 17,
        Exp = 18,
        Ln = 19,
        Log = 20,
        Imaginary = 21,
        Comma = 22,
        Power = 23,
        Sine = 24,
        Cosine = 25,
        Tangent = 26,
        Pi = 27,
        Sqrt = 28,
        Square = 29,
        Seven = 30,
        Eight = 31,
        Nine = 32,
        LeftParenthesis = 33,
        RightParenthesis = 34,
        Four = 36,
        Five = 37,
        Six = 38,
        Multiplication = 39,
        Division = 40,
        One = 42,
        Two = 43,
        Three = 44,
        Plus = 45,
        Minus = 46,
        Zero = 48,
        Dot = 49,
        EE = 50,
        Ans = 51,
        EXE = 52,
    }

    unsafe extern "C" {
        fn eadk_keyboard_scan() -> EADKKeyboardState;
    }

    #[derive(Clone, Copy)]
    pub struct KeyboardState(EADKKeyboardState);
    impl KeyboardState {
        pub fn new() -> Self {
            KeyboardState(0)
        }

        pub fn from_raw(state: EADKKeyboardState) -> Self {
            Self(state)
        }
    
        pub fn scan() -> Self {
            Self::from_raw(unsafe { eadk_keyboard_scan() })
        }

        pub fn key_down(&self, key: Key) -> bool {
            (self.0 >> (key as u8)) & 1 != 0
        }
    }

    #[allow(dead_code)]
    #[derive(Clone, Copy, PartialEq, Eq)]
    #[repr(u16)]
    pub enum Event {
        Left = 0,
        Up = 1,
        Down = 2,
        Right = 3,
        OK = 4,
        Back = 5,
        Shift = 12,
        Alpha = 13,
        Xnt = 14,
        Var = 15,
        Toolbox = 16,
        Backspace = 17,
        Exp = 18,
        Ln = 19,
        Log = 20,
        Imaginary = 21,
        Comma = 22,
        Power = 23,
        Sine = 24,
        Cosine = 25,
        Tangent = 26,
        Pi = 27,
        Sqrt = 28,
        Square = 29,
        Seven = 30,
        Eight = 31,
        Nine = 32,
        LeftParenthesis = 33,
        RightParenthesis = 34,
        Four = 36,
        Five = 37,
        Six = 38,
        Multiplication = 39,
        Division = 40,
        One = 42,
        Two = 43,
        Three = 44,
        Plus = 45,
        Minus = 46,
        Zero = 48,
        Dot = 49,
        EE = 50,
        Ans = 51,
        EXE = 52,
        ShiftLeft = 54,
        ShiftUp = 55,
        ShiftDown = 56,
        ShiftRight = 57,
        AlphaLock = 67,
        Cut = 68,
        Copy = 69,
        Paste = 70,
        Clear = 71,
        LeftBracket = 72,
        RightBracket = 73,
        LeftBrace = 74,
        RightBrace = 75,
        Underscore = 76,
        Sto = 77,
        Arcsine = 78,
        Arccosine = 79,
        Arctangent = 80,
        Equal = 81,
        Lower = 82,
        Greater = 83,
        Colon = 122,
        Semicolon = 123,
        DoubleQuotes = 124,
        Percent = 125,
        LowerA = 126,
        LowerB = 127,
        LowerC = 128,
        LowerD = 129,
        LowerE = 130,
        LowerF = 131,
        LowerG = 132,
        LowerH = 133,
        LowerI = 134,
        LowerJ = 135,
        LowerK = 136,
        LowerL = 137,
        LowerM = 138,
        LowerN = 139,
        LowerO = 140,
        LowerP = 141,
        LowerQ = 142,
        LowerR = 144,
        LowerS = 145,
        LowerT = 146,
        LowerU = 147,
        LowerV = 148,
        LowerW = 150,
        LowerX = 151,
        LowerY = 152,
        LowerZ = 153,
        Space = 154,
        Question = 156,
        Exclamation = 157,
        UpperA = 180,
        UpperB = 181,
        UpperC = 182,
        UpperD = 183,
        UpperE = 184,
        UpperF = 185,
        UpperG = 186,
        UpperH = 187,
        UpperI = 188,
        UpperJ = 189,
        UpperK = 190,
        UpperL = 191,
        UpperM = 192,
        UpperN = 193,
        UpperO = 194,
        UpperP = 195,
        UpperQ = 196,
        UpperR = 198,
        UpperS = 199,
        UpperT = 200,
        UpperU = 201,
        UpperV = 202,
        UpperW = 204,
        UpperX = 205,
        UpperY = 206,
        UpperZ = 207,
    }

    pub fn event_get(timeout: i32) -> Event {
        unsafe { eadk_event_get(&timeout) }
    }

    unsafe extern "C" {
        fn eadk_event_get(timeout: &i32) -> Event;
    }
}

#[cfg(target_os = "none")]
use core::panic::PanicInfo;

#[cfg(target_os = "none")]
use alloc::string::String;

#[cfg(target_os = "none")]
pub fn write_wrapped(text: &str, limit: usize) {
    let mut line_count = 0;

    let mut line = String::new();
    for i in 0..text.len() {
        line.push(text.as_bytes()[i] as char);

        if line.len() >= limit || text.as_bytes()[i] as char == '\n' || i >= text.len() - 1 {
            display::draw_string(
                line.as_str(),
                Point {
                    x: 10,
                    y: (10 + 20 * line_count) as u16,
                },
                false,
                Color { rgb565: 65503 },
                Color { rgb565: 63488 },
            );
            line.clear();
            line_count += 1;
        }
    }
}

#[cfg(target_os = "none")]
#[panic_handler]
fn panic(panic: &PanicInfo<'_>) -> ! {
    use alloc::format;

    display::push_rect_uniform(
        Rect {
            x: 0,
            y: 0,
            width: 320,
            height: 240,
        },
        Color { rgb565: 63488 },
    );

    write_wrapped(format!("{}", panic).as_str(), 42);

    loop {
        
    } 
}

pub fn debug_info(text: &str, wait: usize) {
    display::draw_string(
        text,
        Point { x: 10, y: 30 },
        false,
        BLACK,
        WHITE,
    );
    timing::msleep(wait as u32);
}

pub fn header_info(text: &str) {
    display::draw_string(
        text,
        Point { x: 5, y: 3 },
        false,
        WHITE,
        ORANGE
    );
}

unsafe extern "C" {
    pub static mut _heap_start: u8;
    pub static mut _heap_end: u8;
}

pub static mut HEAP_START: *mut u8 = core::ptr::addr_of_mut!(_heap_start);
pub static mut HEAP_END: *mut u8 = core::ptr::addr_of_mut!(_heap_end);

pub fn heap_size() -> usize {
    (unsafe { HEAP_END.offset_from(HEAP_START) }) as usize
}

==> generator.rs <==
pub mod explicit;
pub mod implicit;
pub mod raymarcher;
mod tables;


==> grapher.rs <==
use crate::{
    grapher::{
        renderer::*,
        mesh::Mesh,
        input::*,
        hud::*,
        timer::*
    },
    eadk::*,
    constants::{ graphics::*, palette::* },
    input::parser::Expr
};
#[cfg(target_os = "none")]
use alloc::format;

pub mod mat;
mod renderer;
pub mod mesh;
mod input;
mod hud;
mod timer;

pub struct Grapher {
    renderer: Renderer,
    pub mesh: Mesh,
    input: InputHandler,
    timer: Timer,
    pub expr: Expr
}
impl Grapher {
    pub fn new(expr: Expr) -> Self {
        Grapher {
            renderer: Renderer::new(),
            mesh: Mesh::new(),
            input: InputHandler::new(),
            timer: Timer::new(),
            expr
        }
    }

    pub fn setup_ui() {
        display::push_rect_uniform(
            Rect {
                x: 0,
                y: MARGIN_TOP,
                width: SCREEN_WIDTH,
                height: SCREEN_HEIGHT - MARGIN_TOP
            },
            WHITE
        );

        display::push_rect_uniform(
            Rect {
                x: 0,
                y: 0,
                width: SCREEN_WIDTH - 20,
                height: MARGIN_TOP
            },
            ORANGE
        );

        display::draw_string(
            "3D GRAPHER",
            Point { x: 122, y: 3 },
            false,
            WHITE,
            ORANGE
        );

        #[cfg(not(target_os = "none"))]
        {
            display::push_rect_uniform(
                Rect {
                    x: SCREEN_WIDTH - 20,
                    y: 0,
                    width: 20,
                    height: MARGIN_TOP
                },
                ORANGE
            );
            display::draw_string(
                "sim",
                Point { x: 295, y: 3 },
                false,
                WHITE,
                ORANGE
            );
        }

        #[cfg(debug_assertions)]
        display::draw_string(
            "(dev)",
            Point { x: 255, y: 3 },
            false,
            WHITE,
            ORANGE
        );
    }

    pub fn main_loop(&mut self) {
        Grapher::setup_ui();

        // main loop - runs every frame
        while !self.input.upd.quit {
            if self.input.upd.domain {
                self.mesh.update_domain(self.input.domain_trans_direction, self.input.domain_scale_direction);
                // temp: check for exp
                self.mesh.tris.clear();

                if self.expr.is_implicit {
                    self.generate_mesh_imp();
                } else {
                    self.generate_mesh_exp();
                }

                self.input.domain_cooldown = 0.0;
            } else {
                self.input.domain_cooldown += self.timer.delta_time;
            }
            
            if self.input.upd.rotation {
                self.mesh.update_rotation(self.input.rotation_direction, self.timer.delta_time);
            }
            if self.input.upd.scale {
                self.mesh.update_scale(self.input.scale_change, self.timer.delta_time);
            }

            if self.input.upd.hud {
                draw_hud(self.input.mode, self.input.upd.mode, self.input.upd.help_on, self.mesh.scale, self.mesh.domain);
            }

            if self.input.upd.redraw {
                self.mesh.transform();
                self.renderer.draw_screen(&self.mesh, self.input.help);
            }

            if self.input.upd.enhance && self.expr.is_implicit {
                self.mesh.generate_screen(&self.expr);
            }

            self.input.update();
            self.timer.update();
            
            if self.timer.fps < 800.0 {   // temp fix
                header_info(&format!("fps: {:.1}   ", self.timer.fps));
            }
        }
    }
}

==> input.rs <==
use crate::{
    grapher::Grapher
};

pub mod parser;
pub mod ui;

pub fn main_loop() {
    loop {
        Grapher::setup_ui();
        let graph = match ui::get_expr() {
            Some(e) => e,
            None => break
        };
        let mut grapher = Grapher::new(graph);
        grapher.main_loop();
    }
}

==> main.rs <==
#![cfg_attr(target_os = "none", no_std)]
#![no_main]
#![feature(f16)]

#[allow(unused_imports)]
#[cfg(target_os = "none")]
use cortex_m;

#[cfg(target_os = "none")]
use eadk::heap_size;

#[cfg(target_os = "none")]
use embedded_alloc::LlffHeap as Heap;

#[global_allocator]
#[cfg(target_os = "none")]
static HEAP: Heap = Heap::empty();

#[cfg(target_os = "none")]
extern crate alloc;

#[used]
#[cfg(target_os = "none")]
#[unsafe(link_section = ".rodata.eadk_app_name")]
pub static EADK_APP_NAME: [u8; 11] = *b"3D Grapher\0";

#[used]
#[cfg(target_os = "none")]
#[unsafe(link_section = ".rodata.eadk_api_level")]
pub static EADK_APP_API_LEVEL: u32 = 0;

#[used]
#[cfg(target_os = "none")]
#[unsafe(link_section = ".rodata.eadk_app_icon")]
pub static EADK_APP_ICON: [u8; 4900] = *include_bytes!("../target/icon.nwi");

pub mod eadk;
mod constants;
mod trig;
mod grapher;
mod generator;
mod input;

#[unsafe(no_mangle)]
pub fn main() -> isize {
    #[cfg(target_os = "none")]
    {
        let heap_size: usize = 100_000;
        unsafe { HEAP.init(eadk::HEAP_START as usize, heap_size) }
    }

    input::main_loop();

    0
}

==> trig.rs <==
const PI: f32 = 3.14159265;
const TWO_PI: f32 = 6.28318531;

fn wrap_pi(mut x: f32) -> f32 {
    while x < 0.0 { x += TWO_PI }
    while x >= TWO_PI { x -= TWO_PI }

    if x >= PI { x -= TWO_PI }

    x
}

pub fn sin(mut x: f32) -> f32 {
    x = wrap_pi(x);
    let x2 = x * x;
    let x3 = x * x2;
    let x5 = x3 * x2;
    let x7 = x5 * x2;
    let x9 = x7 * x2;

    x - x3 / 6.0 + x5 / 120.0 - x7 / 5040.0 + x9 / 362880.0
}

pub fn cos(mut x: f32) -> f32 {
    x = wrap_pi(x);
    let x2 = x * x;
    let x4 = x2 * x2;
    let x6 = x4 * x2;
    let x8 = x6 * x2;
    
    1.0 - x2 / 2.0 + x4 / 24.0 - x6 / 720.0 + x8 / 40320.0
}

==> generator/explicit.rs <==
use crate::{
    grapher::{
        Grapher,
        mat::*,
    },
    constants::limits::*,
    input::parser::EvalError
};

impl Grapher {
    fn add_explicit_tris(&mut self, x0: f32, y0: f32, dx: f32, dy: f32) -> Result<(), EvalError> {
        let mut vertices = [v!(0.0, 0.0, 0.0); 4];

        for i in 0..2 {
            for j in 0..2 {
                let x = x0 + i as f32 * dx;
                let y = y0 + j as f32 * dy;
                let z = self.expr.eval(x, y, 0.0)?;

                vertices[i*2 + j] = v!(x, y, z);
            }
        }

        let _ = self.mesh.tris.push(Triangle3([vertices[1], vertices[2], vertices[0]]));
        let _ = self.mesh.tris.push(Triangle3([vertices[1], vertices[2], vertices[3]]));

        Ok(())
    }

    pub fn generate_mesh_exp(&mut self) { 
        let dx = (self.mesh.domain.x1 - self.mesh.domain.x0) / EXPLICIT_N as f32;
        let dy = (self.mesh.domain.y1 - self.mesh.domain.y0) / EXPLICIT_N as f32;

        for i in 0..EXPLICIT_N {
            for j in 0..EXPLICIT_N {
                let x = self.mesh.domain.x0 + dx * i as f32;
                let y = self.mesh.domain.y0 + dy * j as f32;
                
                let _ = self.add_explicit_tris(x, y, dx, dy);
            }
        }
    }
}

==> generator/implicit.rs <==
use crate::{
    grapher::{
        Grapher,
        mat::*,
    },
    generator::tables::*,
    constants::limits::*,
    input::parser::EvalError
};

// pub fn placeholder_func_3(x: f32, y: f32, z: f32) -> f32 {
//     x*x + y*y + z*z + sin(4.0*x) + sin(4.0*y) + sin(4.0*z) - 1.11
// }
// 
// pub fn placeholder_func_2(x: f32, y: f32, z: f32) -> f32 {
//     let x2 = x * x;
//     let y2 = y * y;
//     let z2 = z * z;
// 
//     let a = 2.92 * (x - 1.0) * x2 * (x + 1.0) + 1.7 * y2;
//     let b = 2.92 * (y - 1.0) * y2 * (y + 1.0) + 1.7 * z2;
//     let c = 2.92 * (z - 1.0) * z2 * (z + 1.0) + 1.7 * x2;
// 
//     let term1 = a * a * (y2 - 0.88) * (y2 - 0.88);
//     let term2 = b * b * (z2 - 0.88) * (z2 - 0.88);
//     let term3 = c * c * (x2 - 0.88) * (x2 - 0.88);
// 
//     term1 + term2 + term3 - 0.02   
// }
// 
// pub fn placeholder_func_1(x: f32, y: f32, z: f32) -> f32 {
//     x*x*x*x + 2.0*x*x*y*y + 2.0*x*x*z*z + y*y*y*y + 2.0*y*y*z*z + z*z*z*z + 8.0*x*y*z - 10.0*x*x - 10.0*y*y - 10.0*z*z + 20.0
//     // 400.0 * (x*x*y*y + y*y*z*z + x*x*z*z) - (1.0-x*x-y*y-z*z)*(1.0-x*x-y*y-z*z)*(1.0-x*x-y*y-z*z)
// }

fn interpolate_vertex(v0: Vector3, v1: Vector3, t0: f32, t1: f32) -> Vector3 {
    let mu = -t0 / (t1 - t0);
    
    v!(
        v0.x + mu * (v1.x - v0.x),
        v0.y + mu * (v1.y - v0.y),
        v0.z + mu * (v1.z - v0.z)
    )
}

impl Grapher {
    fn march_that_cube(
        &mut self,
        v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3,
        v4: Vector3, v5: Vector3, v6: Vector3, v7: Vector3
    ) -> Result<(), EvalError> {
        let t0 = self.expr.eval(v0.x, v0.y, v0.z)?;
        let t1 = self.expr.eval(v1.x, v1.y, v1.z)?;
        let t2 = self.expr.eval(v2.x, v2.y, v2.z)?;
        let t3 = self.expr.eval(v3.x, v3.y, v3.z)?;
        let t4 = self.expr.eval(v4.x, v4.y, v4.z)?;
        let t5 = self.expr.eval(v5.x, v5.y, v5.z)?;
        let t6 = self.expr.eval(v6.x, v6.y, v6.z)?;
        let t7 = self.expr.eval(v7.x, v7.y, v7.z)?;

        let mut cube_index: usize = 0;
        
        if t0 < 0.0 { cube_index |= 1 << 0 };
        if t1 < 0.0 { cube_index |= 1 << 1 };
        if t2 < 0.0 { cube_index |= 1 << 2 };
        if t3 < 0.0 { cube_index |= 1 << 3 };
        if t4 < 0.0 { cube_index |= 1 << 4 };
        if t5 < 0.0 { cube_index |= 1 << 5 };
        if t6 < 0.0 { cube_index |= 1 << 6 };
        if t7 < 0.0 { cube_index |= 1 << 7 };

        let edge = EDGE_TABLE[cube_index];
        let mut vertices: [Vector3; 12] = [v!(5.0, 0.0, 0.0); 12];

        if edge & (1 << 0) != 0 {
            vertices[0] = interpolate_vertex(v0, v1, t0, t1);
        } 
        if edge & (1 << 1) != 0 {
            vertices[1] = interpolate_vertex(v1, v2, t1, t2);
        } 
        if edge & (1 << 2) != 0 {
            vertices[2] = interpolate_vertex(v2, v3, t2, t3);
        } 
        if edge & (1 << 3) != 0 {
            vertices[3] = interpolate_vertex(v3, v0, t3, t0);
        } 
        if edge & (1 << 4) != 0 {
            vertices[4] = interpolate_vertex(v4, v5, t4, t5);
        } 
        if edge & (1 << 5) != 0 {
            vertices[5] = interpolate_vertex(v5, v6, t5, t6);
        } 
        if edge & (1 << 6) != 0 {
            vertices[6] = interpolate_vertex(v6, v7, t6, t7);
        } 
        if edge & (1 << 7) != 0 {
            vertices[7] = interpolate_vertex(v7, v4, t7, t4);
        } 
        if edge & (1 << 8) != 0 {
            vertices[8] = interpolate_vertex(v0, v4, t0, t4);
        } 
        if edge & (1 << 9) != 0 {
            vertices[9] = interpolate_vertex(v1, v5, t1, t5);
        } 
        if edge & (1 << 10) != 0 {
            vertices[10] = interpolate_vertex(v2, v6, t2, t6);
        } 
        if edge & (1 << 11) != 0 {
            vertices[11] = interpolate_vertex(v3, v7, t3, t7);
        }

        let triangle = TRI_TABLE[cube_index];

        let mut i = 0;
        while triangle[i] != 255 {
            let _ = self.mesh.tris.push(Triangle3([
                vertices[triangle[i] as usize],
                vertices[triangle[i+1] as usize],
                vertices[triangle[i+2] as usize]
            ]));
            i += 3;
        }

        Ok(())
    }

    pub fn generate_mesh_imp(&mut self) {
        let dx = (self.mesh.domain.x1 - self.mesh.domain.x0) / IMPLICIT_N as f32;
        let dy = (self.mesh.domain.y1 - self.mesh.domain.y0) / IMPLICIT_N as f32;
        let dz = (self.mesh.domain.z1 - self.mesh.domain.z0) / IMPLICIT_N as f32;

        for i in 0..IMPLICIT_N {
            for j in 0..IMPLICIT_N {
                for k in 0..IMPLICIT_N {
                    let x0 = self.mesh.domain.x0 + dx * i as f32;
                    let y0 = self.mesh.domain.y0 + dy * j as f32;
                    let z0 = self.mesh.domain.z0 + dz * k as f32;
                    let x1 = x0 + dx;
                    let y1 = y0 + dy;
                    let z1 = z0 + dz;
                    
                    let _ = self.march_that_cube(
                        v!(x0, y0, z0),
                        v!(x1, y0, z0),
                        v!(x1, y1, z0),
                        v!(x0, y1, z0),
                        v!(x0, y0, z1),
                        v!(x1, y0, z1),
                        v!(x1, y1, z1),
                        v!(x0, y1, z1)
                    );
                }
            }
        }
    }
}

==> generator/raymarcher.rs <==
use crate::{
    eadk::{
        *,
        input::*
    },
    grapher::{
        mat::*
    },
    constants::{
        limits::*,
        graphics::*,
        controls::*
    },
    input::parser::{ Expr, EvalError }
};
#[cfg(target_os = "none")]
use alloc::format;

fn get_coord(matrix: Matrix4, x: u16, y: u16, z: f32) -> Vector3 {
    let r_vector = RVector3::new(
        x as isize,
        y as isize,
        z as f16
    );

    r_vector * matrix
}

fn march_that_ray(expr: &Expr, matrix: Matrix4, n: usize, x: u16, y: u16) -> Result<Color, EvalError> {
    let z0 = -1.0;
    let z1 = 1.0;
    let dz = (z1 - z0) / n as f32;
    let mut z = z0;
    
    let mut c = get_coord(matrix, x, y, z);
    let mut prev_t = expr.eval(c.x, c.y, c.z)?;
    let mut i = 0;
    while i < n {
        z += dz;
        c = get_coord(matrix, x, y, z);
        if prev_t * expr.eval(c.x, c.y, c.z)? < 0.0 {
            break;
        }
        prev_t = expr.eval(c.x, c.y, c.z)?;
        i += 1;
    }
    
    let mut value = (-z + 1.0) / 2.0 * 255.0;
    if value > 255.0 { value = 255.0 };
    if value < 0.0 { value = 0.0 };

    Ok(
        if i == n { BG } else { Color::from_rgb(0, value as u16, 255) }
    )
}

pub fn generate_screen(expr: &Expr, matrix: Matrix4) {
    let mut row_buffer: [Color; SCREEN_WIDTH_SIZE] = [BG; SCREEN_WIDTH_SIZE];
    let mut keyboard_state: KeyboardState;
    let mut n = MARCH_N;

    let mut prev_time = timing::millis();
    for y in MARGIN_TOP..MARGIN_TOP+FRAME_HEIGHT {
        for x in 0..SCREEN_WIDTH {
            row_buffer[x as usize] = match march_that_ray(expr, matrix, n, x, y) {
                Ok(c) => c,
                Err(_) => BG
            };
        }

        display::push_rect(
            Rect {
                x: 0, 
                y,
                width: SCREEN_WIDTH,
                height: 1
            },
            &row_buffer
        );
        
        let current_time = timing::millis();
        if (current_time - prev_time) > MAX_ROW_TIME {
            n = (n as f32 * 0.9) as usize;
        }
        prev_time = current_time;

        let progress = (y - MARGIN_TOP) as f32 / (FRAME_HEIGHT) as f32;
        header_info(&format!(
            "{:.0}%         ", progress * 100.0
        ));
        #[cfg(debug_assertions)]
        header_info(&format!(
            "{}             ", n
        ));

        keyboard_state = KeyboardState::scan();
        if keyboard_state.key_down(BACK) {
            break;
        }
    }
}


==> generator/tables.rs <==
// from https://paulbourke.net/geometry/polygonise/


pub const EDGE_TABLE: [u16; 256] = [
0x0  , 0x109, 0x203, 0x30a, 0x406, 0x50f, 0x605, 0x70c,
0x80c, 0x905, 0xa0f, 0xb06, 0xc0a, 0xd03, 0xe09, 0xf00,
0x190, 0x99 , 0x393, 0x29a, 0x596, 0x49f, 0x795, 0x69c,
0x99c, 0x895, 0xb9f, 0xa96, 0xd9a, 0xc93, 0xf99, 0xe90,
0x230, 0x339, 0x33 , 0x13a, 0x636, 0x73f, 0x435, 0x53c,
0xa3c, 0xb35, 0x83f, 0x936, 0xe3a, 0xf33, 0xc39, 0xd30,
0x3a0, 0x2a9, 0x1a3, 0xaa , 0x7a6, 0x6af, 0x5a5, 0x4ac,
0xbac, 0xaa5, 0x9af, 0x8a6, 0xfaa, 0xea3, 0xda9, 0xca0,
0x460, 0x569, 0x663, 0x76a, 0x66 , 0x16f, 0x265, 0x36c,
0xc6c, 0xd65, 0xe6f, 0xf66, 0x86a, 0x963, 0xa69, 0xb60,
0x5f0, 0x4f9, 0x7f3, 0x6fa, 0x1f6, 0xff , 0x3f5, 0x2fc,
0xdfc, 0xcf5, 0xfff, 0xef6, 0x9fa, 0x8f3, 0xbf9, 0xaf0,
0x650, 0x759, 0x453, 0x55a, 0x256, 0x35f, 0x55 , 0x15c,
0xe5c, 0xf55, 0xc5f, 0xd56, 0xa5a, 0xb53, 0x859, 0x950,
0x7c0, 0x6c9, 0x5c3, 0x4ca, 0x3c6, 0x2cf, 0x1c5, 0xcc ,
0xfcc, 0xec5, 0xdcf, 0xcc6, 0xbca, 0xac3, 0x9c9, 0x8c0,
0x8c0, 0x9c9, 0xac3, 0xbca, 0xcc6, 0xdcf, 0xec5, 0xfcc,
0xcc , 0x1c5, 0x2cf, 0x3c6, 0x4ca, 0x5c3, 0x6c9, 0x7c0,
0x950, 0x859, 0xb53, 0xa5a, 0xd56, 0xc5f, 0xf55, 0xe5c,
0x15c, 0x55 , 0x35f, 0x256, 0x55a, 0x453, 0x759, 0x650,
0xaf0, 0xbf9, 0x8f3, 0x9fa, 0xef6, 0xfff, 0xcf5, 0xdfc,
0x2fc, 0x3f5, 0xff , 0x1f6, 0x6fa, 0x7f3, 0x4f9, 0x5f0,
0xb60, 0xa69, 0x963, 0x86a, 0xf66, 0xe6f, 0xd65, 0xc6c,
0x36c, 0x265, 0x16f, 0x66 , 0x76a, 0x663, 0x569, 0x460,
0xca0, 0xda9, 0xea3, 0xfaa, 0x8a6, 0x9af, 0xaa5, 0xbac,
0x4ac, 0x5a5, 0x6af, 0x7a6, 0xaa , 0x1a3, 0x2a9, 0x3a0,
0xd30, 0xc39, 0xf33, 0xe3a, 0x936, 0x83f, 0xb35, 0xa3c,
0x53c, 0x435, 0x73f, 0x636, 0x13a, 0x33 , 0x339, 0x230,
0xe90, 0xf99, 0xc93, 0xd9a, 0xa96, 0xb9f, 0x895, 0x99c,
0x69c, 0x795, 0x49f, 0x596, 0x29a, 0x393, 0x99 , 0x190,
0xf00, 0xe09, 0xd03, 0xc0a, 0xb06, 0xa0f, 0x905, 0x80c,
0x70c, 0x605, 0x50f, 0x406, 0x30a, 0x203, 0x109, 0x0   ];

pub const TRI_TABLE: [[u8; 16]; 256] =
[[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 3, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 1, 9, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 8, 3, 9, 8, 1, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 10, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 3, 1, 2, 10, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[9, 2, 10, 0, 2, 9, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[2, 8, 3, 2, 10, 8, 10, 9, 8, 255, 255, 255, 255, 255, 255, 255],
[3, 11, 2, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 11, 2, 8, 11, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 9, 0, 2, 3, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 11, 2, 1, 9, 11, 9, 8, 11, 255, 255, 255, 255, 255, 255, 255],
[3, 10, 1, 11, 10, 3, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 10, 1, 0, 8, 10, 8, 11, 10, 255, 255, 255, 255, 255, 255, 255],
[3, 9, 0, 3, 11, 9, 11, 10, 9, 255, 255, 255, 255, 255, 255, 255],
[9, 8, 10, 10, 8, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 7, 8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 3, 0, 7, 3, 4, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 1, 9, 8, 4, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 1, 9, 4, 7, 1, 7, 3, 1, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 10, 8, 4, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[3, 4, 7, 3, 0, 4, 1, 2, 10, 255, 255, 255, 255, 255, 255, 255],
[9, 2, 10, 9, 0, 2, 8, 4, 7, 255, 255, 255, 255, 255, 255, 255],
[2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4, 255, 255, 255, 255],
[8, 4, 7, 3, 11, 2, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[11, 4, 7, 11, 2, 4, 2, 0, 4, 255, 255, 255, 255, 255, 255, 255],
[9, 0, 1, 8, 4, 7, 2, 3, 11, 255, 255, 255, 255, 255, 255, 255],
[4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1, 255, 255, 255, 255],
[3, 10, 1, 3, 11, 10, 7, 8, 4, 255, 255, 255, 255, 255, 255, 255],
[1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4, 255, 255, 255, 255],
[4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3, 255, 255, 255, 255],
[4, 7, 11, 4, 11, 9, 9, 11, 10, 255, 255, 255, 255, 255, 255, 255],
[9, 5, 4, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[9, 5, 4, 0, 8, 3, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 5, 4, 1, 5, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[8, 5, 4, 8, 3, 5, 3, 1, 5, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 10, 9, 5, 4, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[3, 0, 8, 1, 2, 10, 4, 9, 5, 255, 255, 255, 255, 255, 255, 255],
[5, 2, 10, 5, 4, 2, 4, 0, 2, 255, 255, 255, 255, 255, 255, 255],
[2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8, 255, 255, 255, 255],
[9, 5, 4, 2, 3, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 11, 2, 0, 8, 11, 4, 9, 5, 255, 255, 255, 255, 255, 255, 255],
[0, 5, 4, 0, 1, 5, 2, 3, 11, 255, 255, 255, 255, 255, 255, 255],
[2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5, 255, 255, 255, 255],
[10, 3, 11, 10, 1, 3, 9, 5, 4, 255, 255, 255, 255, 255, 255, 255],
[4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10, 255, 255, 255, 255],
[5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3, 255, 255, 255, 255],
[5, 4, 8, 5, 8, 10, 10, 8, 11, 255, 255, 255, 255, 255, 255, 255],
[9, 7, 8, 5, 7, 9, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[9, 3, 0, 9, 5, 3, 5, 7, 3, 255, 255, 255, 255, 255, 255, 255],
[0, 7, 8, 0, 1, 7, 1, 5, 7, 255, 255, 255, 255, 255, 255, 255],
[1, 5, 3, 3, 5, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[9, 7, 8, 9, 5, 7, 10, 1, 2, 255, 255, 255, 255, 255, 255, 255],
[10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3, 255, 255, 255, 255],
[8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2, 255, 255, 255, 255],
[2, 10, 5, 2, 5, 3, 3, 5, 7, 255, 255, 255, 255, 255, 255, 255],
[7, 9, 5, 7, 8, 9, 3, 11, 2, 255, 255, 255, 255, 255, 255, 255],
[9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11, 255, 255, 255, 255],
[2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7, 255, 255, 255, 255],
[11, 2, 1, 11, 1, 7, 7, 1, 5, 255, 255, 255, 255, 255, 255, 255],
[9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11, 255, 255, 255, 255],
[5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0, 255],
[11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0, 255],
[11, 10, 5, 7, 11, 5, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[10, 6, 5, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 3, 5, 10, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[9, 0, 1, 5, 10, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 8, 3, 1, 9, 8, 5, 10, 6, 255, 255, 255, 255, 255, 255, 255],
[1, 6, 5, 2, 6, 1, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 6, 5, 1, 2, 6, 3, 0, 8, 255, 255, 255, 255, 255, 255, 255],
[9, 6, 5, 9, 0, 6, 0, 2, 6, 255, 255, 255, 255, 255, 255, 255],
[5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8, 255, 255, 255, 255],
[2, 3, 11, 10, 6, 5, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[11, 0, 8, 11, 2, 0, 10, 6, 5, 255, 255, 255, 255, 255, 255, 255],
[0, 1, 9, 2, 3, 11, 5, 10, 6, 255, 255, 255, 255, 255, 255, 255],
[5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11, 255, 255, 255, 255],
[6, 3, 11, 6, 5, 3, 5, 1, 3, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6, 255, 255, 255, 255],
[3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9, 255, 255, 255, 255],
[6, 5, 9, 6, 9, 11, 11, 9, 8, 255, 255, 255, 255, 255, 255, 255],
[5, 10, 6, 4, 7, 8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 3, 0, 4, 7, 3, 6, 5, 10, 255, 255, 255, 255, 255, 255, 255],
[1, 9, 0, 5, 10, 6, 8, 4, 7, 255, 255, 255, 255, 255, 255, 255],
[10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4, 255, 255, 255, 255],
[6, 1, 2, 6, 5, 1, 4, 7, 8, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7, 255, 255, 255, 255],
[8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6, 255, 255, 255, 255],
[7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9, 255],
[3, 11, 2, 7, 8, 4, 10, 6, 5, 255, 255, 255, 255, 255, 255, 255],
[5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11, 255, 255, 255, 255],
[0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6, 255, 255, 255, 255],
[9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6, 255],
[8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6, 255, 255, 255, 255],
[5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11, 255],
[0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7, 255],
[6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9, 255, 255, 255, 255],
[10, 4, 9, 6, 4, 10, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 10, 6, 4, 9, 10, 0, 8, 3, 255, 255, 255, 255, 255, 255, 255],
[10, 0, 1, 10, 6, 0, 6, 4, 0, 255, 255, 255, 255, 255, 255, 255],
[8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10, 255, 255, 255, 255],
[1, 4, 9, 1, 2, 4, 2, 6, 4, 255, 255, 255, 255, 255, 255, 255],
[3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4, 255, 255, 255, 255],
[0, 2, 4, 4, 2, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[8, 3, 2, 8, 2, 4, 4, 2, 6, 255, 255, 255, 255, 255, 255, 255],
[10, 4, 9, 10, 6, 4, 11, 2, 3, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6, 255, 255, 255, 255],
[3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10, 255, 255, 255, 255],
[6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1, 255],
[9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3, 255, 255, 255, 255],
[8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1, 255],
[3, 11, 6, 3, 6, 0, 0, 6, 4, 255, 255, 255, 255, 255, 255, 255],
[6, 4, 8, 11, 6, 8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[7, 10, 6, 7, 8, 10, 8, 9, 10, 255, 255, 255, 255, 255, 255, 255],
[0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10, 255, 255, 255, 255],
[10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0, 255, 255, 255, 255],
[10, 6, 7, 10, 7, 1, 1, 7, 3, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7, 255, 255, 255, 255],
[2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9, 255],
[7, 8, 0, 7, 0, 6, 6, 0, 2, 255, 255, 255, 255, 255, 255, 255],
[7, 3, 2, 6, 7, 2, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7, 255, 255, 255, 255],
[2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7, 255],
[1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11, 255],
[11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1, 255, 255, 255, 255],
[8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6, 255],
[0, 9, 1, 11, 6, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0, 255, 255, 255, 255],
[7, 11, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[7, 6, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[3, 0, 8, 11, 7, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 1, 9, 11, 7, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[8, 1, 9, 8, 3, 1, 11, 7, 6, 255, 255, 255, 255, 255, 255, 255],
[10, 1, 2, 6, 11, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 10, 3, 0, 8, 6, 11, 7, 255, 255, 255, 255, 255, 255, 255],
[2, 9, 0, 2, 10, 9, 6, 11, 7, 255, 255, 255, 255, 255, 255, 255],
[6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8, 255, 255, 255, 255],
[7, 2, 3, 6, 2, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[7, 0, 8, 7, 6, 0, 6, 2, 0, 255, 255, 255, 255, 255, 255, 255],
[2, 7, 6, 2, 3, 7, 0, 1, 9, 255, 255, 255, 255, 255, 255, 255],
[1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6, 255, 255, 255, 255],
[10, 7, 6, 10, 1, 7, 1, 3, 7, 255, 255, 255, 255, 255, 255, 255],
[10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8, 255, 255, 255, 255],
[0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7, 255, 255, 255, 255],
[7, 6, 10, 7, 10, 8, 8, 10, 9, 255, 255, 255, 255, 255, 255, 255],
[6, 8, 4, 11, 8, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[3, 6, 11, 3, 0, 6, 0, 4, 6, 255, 255, 255, 255, 255, 255, 255],
[8, 6, 11, 8, 4, 6, 9, 0, 1, 255, 255, 255, 255, 255, 255, 255],
[9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6, 255, 255, 255, 255],
[6, 8, 4, 6, 11, 8, 2, 10, 1, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6, 255, 255, 255, 255],
[4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9, 255, 255, 255, 255],
[10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3, 255],
[8, 2, 3, 8, 4, 2, 4, 6, 2, 255, 255, 255, 255, 255, 255, 255],
[0, 4, 2, 4, 6, 2, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8, 255, 255, 255, 255],
[1, 9, 4, 1, 4, 2, 2, 4, 6, 255, 255, 255, 255, 255, 255, 255],
[8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1, 255, 255, 255, 255],
[10, 1, 0, 10, 0, 6, 6, 0, 4, 255, 255, 255, 255, 255, 255, 255],
[4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3, 255],
[10, 9, 4, 6, 10, 4, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 9, 5, 7, 6, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 3, 4, 9, 5, 11, 7, 6, 255, 255, 255, 255, 255, 255, 255],
[5, 0, 1, 5, 4, 0, 7, 6, 11, 255, 255, 255, 255, 255, 255, 255],
[11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5, 255, 255, 255, 255],
[9, 5, 4, 10, 1, 2, 7, 6, 11, 255, 255, 255, 255, 255, 255, 255],
[6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5, 255, 255, 255, 255],
[7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2, 255, 255, 255, 255],
[3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6, 255],
[7, 2, 3, 7, 6, 2, 5, 4, 9, 255, 255, 255, 255, 255, 255, 255],
[9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7, 255, 255, 255, 255],
[3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0, 255, 255, 255, 255],
[6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8, 255],
[9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7, 255, 255, 255, 255],
[1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4, 255],
[4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10, 255],
[7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10, 255, 255, 255, 255],
[6, 9, 5, 6, 11, 9, 11, 8, 9, 255, 255, 255, 255, 255, 255, 255],
[3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5, 255, 255, 255, 255],
[0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11, 255, 255, 255, 255],
[6, 11, 3, 6, 3, 5, 5, 3, 1, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6, 255, 255, 255, 255],
[0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10, 255],
[11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5, 255],
[6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3, 255, 255, 255, 255],
[5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2, 255, 255, 255, 255],
[9, 5, 6, 9, 6, 0, 0, 6, 2, 255, 255, 255, 255, 255, 255, 255],
[1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8, 255],
[1, 5, 6, 2, 1, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6, 255],
[10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0, 255, 255, 255, 255],
[0, 3, 8, 5, 6, 10, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[10, 5, 6, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[11, 5, 10, 7, 5, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[11, 5, 10, 11, 7, 5, 8, 3, 0, 255, 255, 255, 255, 255, 255, 255],
[5, 11, 7, 5, 10, 11, 1, 9, 0, 255, 255, 255, 255, 255, 255, 255],
[10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1, 255, 255, 255, 255],
[11, 1, 2, 11, 7, 1, 7, 5, 1, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11, 255, 255, 255, 255],
[9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7, 255, 255, 255, 255],
[7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2, 255],
[2, 5, 10, 2, 3, 5, 3, 7, 5, 255, 255, 255, 255, 255, 255, 255],
[8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5, 255, 255, 255, 255],
[9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2, 255, 255, 255, 255],
[9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2, 255],
[1, 3, 5, 3, 7, 5, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 7, 0, 7, 1, 1, 7, 5, 255, 255, 255, 255, 255, 255, 255],
[9, 0, 3, 9, 3, 5, 5, 3, 7, 255, 255, 255, 255, 255, 255, 255],
[9, 8, 7, 5, 9, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[5, 8, 4, 5, 10, 8, 10, 11, 8, 255, 255, 255, 255, 255, 255, 255],
[5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0, 255, 255, 255, 255],
[0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5, 255, 255, 255, 255],
[10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4, 255],
[2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8, 255, 255, 255, 255],
[0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11, 255],
[0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5, 255],
[9, 4, 5, 2, 11, 3, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4, 255, 255, 255, 255],
[5, 10, 2, 5, 2, 4, 4, 2, 0, 255, 255, 255, 255, 255, 255, 255],
[3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9, 255],
[5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2, 255, 255, 255, 255],
[8, 4, 5, 8, 5, 3, 3, 5, 1, 255, 255, 255, 255, 255, 255, 255],
[0, 4, 5, 1, 0, 5, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5, 255, 255, 255, 255],
[9, 4, 5, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 11, 7, 4, 9, 11, 9, 10, 11, 255, 255, 255, 255, 255, 255, 255],
[0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11, 255, 255, 255, 255],
[1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11, 255, 255, 255, 255],
[3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4, 255],
[4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2, 255, 255, 255, 255],
[9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3, 255],
[11, 7, 4, 11, 4, 2, 2, 4, 0, 255, 255, 255, 255, 255, 255, 255],
[11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4, 255, 255, 255, 255],
[2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9, 255, 255, 255, 255],
[9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7, 255],
[3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10, 255],
[1, 10, 2, 8, 7, 4, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 9, 1, 4, 1, 7, 7, 1, 3, 255, 255, 255, 255, 255, 255, 255],
[4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1, 255, 255, 255, 255],
[4, 0, 3, 7, 4, 3, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[4, 8, 7, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[9, 10, 8, 10, 11, 8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[3, 0, 9, 3, 9, 11, 11, 9, 10, 255, 255, 255, 255, 255, 255, 255],
[0, 1, 10, 0, 10, 8, 8, 10, 11, 255, 255, 255, 255, 255, 255, 255],
[3, 1, 10, 11, 3, 10, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 2, 11, 1, 11, 9, 9, 11, 8, 255, 255, 255, 255, 255, 255, 255],
[3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9, 255, 255, 255, 255],
[0, 2, 11, 8, 0, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[3, 2, 11, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[2, 3, 8, 2, 8, 10, 10, 8, 9, 255, 255, 255, 255, 255, 255, 255],
[9, 10, 2, 0, 9, 2, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8, 255, 255, 255, 255],
[1, 10, 2, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[1, 3, 8, 9, 1, 8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 9, 1, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[0, 3, 8, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255],
[255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]];

==> grapher/hud.rs <==
use crate::{ 
    eadk::*, 
    grapher::{
        input::Mode,
        mesh::Domain
    },
    constants::{ 
        graphics::*, 
        palette::*, 
        strings::* 
    } 
};
#[cfg(target_os = "none")]
use alloc::format;

fn draw_hud_string(text: &str, bg_color: Color) {
    display::draw_string(
        text,
        Point { x: 10, y: SCREEN_HEIGHT - HUD_HEIGHT + 10 },
        true,
        WHITE,
        bg_color
    );
}

fn draw_hud_string_table(text: &str, row: u16, column: u16, bg_color: Color) {
    display::draw_string(
        text,
        Point {
            x: 10 + column * 80,
            y: SCREEN_HEIGHT - HUD_HEIGHT + 5 + 15 * row
        },
        false,
        WHITE,
        bg_color
    );
}

fn draw_help_string(text: &str, offset: u16) {
    display::draw_string(
        text,
        Point {
            x: SCREEN_WIDTH - FB_WIDTH - 2 + 10,
            y: MARGIN_TOP + 10 + 15 * offset
        },
        false,
        DARK_GREY,
        GREY
    );
}

pub fn draw_hud(mode: Mode, mode_update: bool, help_on: bool, scale: f32, domain: Domain) {
    let bg_color = match mode {
        Mode::View => RED,
        Mode::Trace => GREEN,
        Mode::Domain => BLUE
    };
    
    if mode_update {
        display::push_rect_uniform(
            Rect {
                x: 0,
                y: SCREEN_HEIGHT - HUD_HEIGHT,
                width: SCREEN_WIDTH,
                height: HUD_HEIGHT
            },
            bg_color
        );

        let text = match mode {
            Mode::View => ROTATE_NAME,
            Mode::Trace => TRACE_NAME,
            Mode::Domain => DOMAIN_NAME
        };
        let length = text.len() as u16;
        display::draw_string(
            text,
            Point { x: SCREEN_WIDTH - 5 - 7 * length, y: SCREEN_HEIGHT - 15},
            false,
            WHITE,
            bg_color
        );
    }

    if mode == Mode::View {
        draw_hud_string(
            &format!("scale: {:.2}", scale),
            bg_color
        );
    } else if mode == Mode::Trace {
        draw_hud_string(
            "green",
            bg_color
        );
    } else if mode == Mode::Domain {
        draw_hud_string_table(&format!("x: {:.1}  ", domain.x0), 0, 0, bg_color);
        draw_hud_string_table(&format!("   {:.1}  ", domain.x1), 1, 0, bg_color);
        draw_hud_string_table(&format!("y: {:.1}  ", domain.y0), 0, 1, bg_color);
        draw_hud_string_table(&format!("   {:.1}  ", domain.y1), 1, 1, bg_color);
        draw_hud_string_table(&format!("z: {:.1}  ", domain.z0), 0, 2, bg_color);
        draw_hud_string_table(&format!("   {:.1}  ", domain.z1), 1, 2, bg_color);
    }

    if help_on {
        let help_lines = match mode {
            Mode::View => ROTATE_HELP,
            Mode::Trace => TRACE_HELP,
            Mode::Domain => DOMAIN_HELP
        };

        display::push_rect_uniform(
            Rect {
                x: SCREEN_WIDTH - FB_WIDTH - 2,
                y: MARGIN_TOP,
                width: FB_WIDTH,
                height: SCREEN_HEIGHT - MARGIN_TOP - MARGIN_BOTTOM
            },
            GREY
        );
        
        let mut i: u16 = 0;
        for text in help_lines {
            draw_help_string(text, i);
            i += 1;
        }
    }
}

==> grapher/input.rs <==
use crate::{ 
    grapher::mat::*, 
    eadk::input::*,
    constants::controls::*
};

fn bind_keys(keyboard_state: &KeyboardState, pos_key: Key, neg_key: Key, update: &mut bool, value: &mut f32) {
    if keyboard_state.key_down(pos_key) {
        *update = true;
        *value = 1.0;
    }
    else if keyboard_state.key_down(neg_key) {
        *update = true;
        *value = -1.0;
    }
}

fn bind_keys_directional(
    keyboard_state: &KeyboardState, 
    x_pos_key: Key, x_neg_key: Key, 
    y_pos_key: Key, y_neg_key: Key, 
    z_pos_key: Key, z_neg_key: Key, 
    update: &mut bool, 
    vector: &mut Vector3
) {
    bind_keys(keyboard_state, x_pos_key, x_neg_key, update, &mut vector.x);
    bind_keys(keyboard_state, y_pos_key, y_neg_key, update, &mut vector.y);
    bind_keys(keyboard_state, z_pos_key, z_neg_key, update, &mut vector.z);
}

#[derive(Clone, Copy, Eq, PartialEq)]
pub enum Mode {
    View,
    Trace,
    Domain
}
impl Mode {
    fn next(&self) -> Mode {
        use Mode::*;
        match *self {
            View => Domain, // TODO: View => Trace
            Trace => Domain,
            Domain => View
        }
    }
}

#[derive(Default)]
pub struct Updates {
    pub domain: bool,
    pub rotation: bool,
    pub scale: bool,
    pub redraw: bool,
    pub mode: bool,
    pub enhance: bool,
    pub hud: bool,
    pub help_on: bool,
    pub help_off: bool,
    pub quit: bool
}

pub struct InputHandler {
    pub upd: Updates,
    pub keyboard_state: KeyboardState,
    pub rotation_direction: Vector3,
    pub domain_trans_direction: Vector3,
    pub scale_change: f32,
    pub domain_scale_direction: Vector3,
    pub mode: Mode,
    pub help: bool,
    pub domain_cooldown: f32,
}
impl InputHandler {
    pub fn new() -> Self {
        InputHandler {
            upd: Updates {
                domain: true,
                rotation: true,
                scale: true,
                redraw: true,
                mode: true,
                enhance: false,
                hud: true,
                help_on: false,
                help_off: false,
                quit: false
            },
            keyboard_state: KeyboardState::scan(),
            rotation_direction: v!(0.0, 0.0, 0.0),
            domain_trans_direction: v!(0.0, 0.0, 0.0),
            scale_change: 0.0,
            domain_scale_direction: v!(0.0, 0.0, 0.0),
            mode: Mode::View,
            help: false,
            domain_cooldown: 0.1,
        }
    }

    pub fn update(&mut self) {
        let switch_pressed_before = self.keyboard_state.key_down(MODE_SWITCH);
        let ignore_back = self.keyboard_state.key_down(ENHANCE) || self.keyboard_state.key_down(BACK);
        self.keyboard_state = KeyboardState::scan();
        self.rotation_direction = v!(0.0, 0.0, 0.0);
        self.domain_trans_direction = v!(0.0, 0.0, 0.0);
        self.scale_change = 0.0;
        self.domain_scale_direction = v!(0.0, 0.0, 0.0);
        self.upd = Updates::default();

        if self.mode == Mode::View {
            bind_keys_directional(
                &self.keyboard_state,
                D_DOWN, D_UP,
                D_LEFT, D_RIGHT,
                D_SP_1, D_SP_2,
                &mut self.upd.rotation, 
                &mut self.rotation_direction
            );

            bind_keys(&self.keyboard_state, INCREASE, DECREASE, &mut self.upd.scale, &mut self.scale_change);

            if self.keyboard_state.key_down(RESET) {
                self.upd.rotation = true;
                self.rotation_direction.x = f32::NAN;
            }
        } 

        else if self.mode == Mode::Trace {
         
        }
        
        else if self.mode == Mode::Domain {
            if self.domain_cooldown >= 0.1 {
                if self.keyboard_state.key_down(MODIFIER) {
                    bind_keys_directional(
                        &self.keyboard_state,
                        D_RIGHT, D_LEFT,
                        D_UP, D_DOWN,
                        D_SP_1, D_SP_2,
                        &mut self.upd.domain,
                        &mut self.domain_scale_direction
                    );
                } else {
                    bind_keys_directional(
                        &self.keyboard_state,
                        D_RIGHT, D_LEFT,
                        D_UP, D_DOWN,
                        D_SP_1, D_SP_2,
                        &mut self.upd.domain, 
                        &mut self.domain_trans_direction
                    );

                    let mut scale_change = 0.0;
                    bind_keys(&self.keyboard_state, DECREASE, INCREASE, &mut self.upd.domain, &mut scale_change);
                    self.domain_scale_direction = v!(scale_change, scale_change, scale_change);
                }
                if self.keyboard_state.key_down(RESET) {
                    self.upd.domain = true;
                    self.domain_trans_direction.x = f32::NAN;
                }
            }
        }
        
        if self.keyboard_state.key_down(MODE_SWITCH) && !switch_pressed_before {
            // if self.keyboard_state.key_down(MODE_1) { 
            //     self.upd.mode = self.mode != Mode::View;
            //     self.mode = Mode::View; 
            // } else if self.keyboard_state.key_down(MODE_2) { 
            //     self.upd.mode = self.mode != Mode::Trace;
            //     self.mode = Mode::Trace;
            // } else if self.keyboard_state.key_down(MODE_3) { 
            //     self.upd.mode = self.mode != Mode::Domain;
            //     self.mode = Mode::Domain;
            // }
            self.mode = self.mode.next();
            self.upd.mode = true;
        }

        if self.keyboard_state.key_down(ENHANCE) && self.domain_cooldown >= 0.1 {
            self.upd.enhance = true;
        }

        if self.keyboard_state.key_down(HELP) {
            self.upd.help_on = self.help != true || self.upd.mode;
            self.help = true;
        } else {
            self.upd.help_off = self.help != false;
            self.help = false;
        }

        if self.keyboard_state.key_down(BACK) && !ignore_back || self.keyboard_state.key_down(EXIT) {
            self.upd.quit = true;
        }

        self.upd.redraw = self.upd.rotation || self.upd.domain || self.upd.scale || self.upd.help_off;
        self.upd.hud = self.upd.mode || self.upd.redraw || self.upd.help_on;
    }
}


==> grapher/mat.rs <==
use core::ops::{ Sub, SubAssign, Mul, MulAssign };
use crate::trig::*;

#[derive(Clone, Copy, Debug)]
pub struct RVector3 {
    pub x: isize,
    pub y: isize,
    pub z: f16
}
impl RVector3 {
    pub fn new(x: isize, y: isize, z: f16) -> Self {
        Self { x, y, z }
    }

    pub fn from_vector3 (vector3: Vector3) -> Self {
        Self {
           x: vector3.x as isize,
           y: vector3.y as isize,
           z: vector3.z as f16
        }
    }
}
// impl AddAssign for RVector3 {
//     fn add_assign(&mut self, other: Self) {
//         self.x += other.x;
//         self.y += other.y;
//         self.z += other.z;
//     }
// }
impl SubAssign for RVector3 {
    fn sub_assign(&mut self, other: Self) {
        self.x -= other.x;
        self.y -= other.y;
        self.z -= other.z;
    }
}
impl Sub for RVector3 {
    type Output = RVector3;

    fn sub(self, other: Self) -> RVector3 {
        RVector3 {
            x: self.x - other.x,
            y: self.y - other.y,
            z: self.z - other.z
        }
    }
}
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

macro_rules! v {
    ($x:expr, $y:expr, $z:expr) => {
        Vector3::new($x, $y, $z)
    };
}
pub(crate) use v;

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct Vector3 {
    pub x: f32,
    pub y: f32,
    pub z: f32
}
impl Vector3 {
    pub fn new(x: f32, y: f32, z: f32) -> Self {
        Self { x, y, z }
    }
}
// impl Index<usize> for Vector3 {
//     type Output = f32;
//     fn index(&self, i: usize) -> &f32 {
//         match i {
//             0 => &self.x,
//             1 => &self.y,
//             2 => &self.z,
//             _ => panic!("Index out of range for Vector3"),
//         }
//     }
// }
// impl IndexMut<usize> for Vector3 {
//     fn index_mut(&mut self, i: usize) -> &mut f32 {
//         match i {
//             0 => &mut self.x,
//             1 => &mut self.y,
//             2 => &mut self.z,
//             _ => panic!("Index out of range for Vector3"),
//         }
//     }
// }
// technically the wrong order but idc
// impl Mul<&Matrix3> for &Vector3 {
//     type Output = Vector3;

//     fn mul(self, matrix: &Matrix3) -> Vector3 {
//         let mut result = v!(0.0, 0.0, 0.0);
//         for i in 0..3 {
//             let mut sum: f32 = 0.0;
//             for j in 0..3 {
//                 sum += matrix.0[i][j] * self[j];
//             }
//             result[i] = sum;
//         }
//         result
//     }
// }
impl Mul<Matrix4> for Vector3 {
    type Output = Vector3;

    fn mul(self, matrix: Matrix4) -> Vector3 {
        let self_4 = [self.x, self.y, self.z, 1.0];
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

#[derive(Debug, Clone, Copy)]
pub struct Matrix4(pub [[f32; 4]; 4]);
impl Matrix4 {
    pub fn new() -> Self {
        Matrix4 ( [
            [1.0, 0.0, 0.0, 0.0],
            [0.0, 1.0, 0.0, 0.0],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]
        ] )
    }

    pub fn inverse(&mut self) -> Matrix4 {
        let m = &self.0;
        let mut inv: [[f32; 4]; 4] = [[0.0; 4]; 4];

        inv[0][0] =  m[1][1]*m[2][2]*m[3][3] - m[1][1]*m[2][3]*m[3][2] -
                     m[2][1]*m[1][2]*m[3][3] + m[2][1]*m[1][3]*m[3][2] +
                     m[3][1]*m[1][2]*m[2][3] - m[3][1]*m[1][3]*m[2][2];

        inv[0][1] = -m[0][1]*m[2][2]*m[3][3] + m[0][1]*m[2][3]*m[3][2] +
                     m[2][1]*m[0][2]*m[3][3] - m[2][1]*m[0][3]*m[3][2] -
                     m[3][1]*m[0][2]*m[2][3] + m[3][1]*m[0][3]*m[2][2];

        inv[0][2] =  m[0][1]*m[1][2]*m[3][3] - m[0][1]*m[1][3]*m[3][2] -
                     m[1][1]*m[0][2]*m[3][3] + m[1][1]*m[0][3]*m[3][2] +
                     m[3][1]*m[0][2]*m[1][3] - m[3][1]*m[0][3]*m[1][2];

        inv[0][3] = -m[0][1]*m[1][2]*m[2][3] + m[0][1]*m[1][3]*m[2][2] +
                     m[1][1]*m[0][2]*m[2][3] - m[1][1]*m[0][3]*m[2][2] -
                     m[2][1]*m[0][2]*m[1][3] + m[2][1]*m[0][3]*m[1][2];

        inv[1][0] = -m[1][0]*m[2][2]*m[3][3] + m[1][0]*m[2][3]*m[3][2] +
                     m[2][0]*m[1][2]*m[3][3] - m[2][0]*m[1][3]*m[3][2] -
                     m[3][0]*m[1][2]*m[2][3] + m[3][0]*m[1][3]*m[2][2];

        inv[1][1] =  m[0][0]*m[2][2]*m[3][3] - m[0][0]*m[2][3]*m[3][2] -
                     m[2][0]*m[0][2]*m[3][3] + m[2][0]*m[0][3]*m[3][2] +
                     m[3][0]*m[0][2]*m[2][3] - m[3][0]*m[0][3]*m[2][2];

        inv[1][2] = -m[0][0]*m[1][2]*m[3][3] + m[0][0]*m[1][3]*m[3][2] +
                     m[1][0]*m[0][2]*m[3][3] - m[1][0]*m[0][3]*m[3][2] -
                     m[3][0]*m[0][2]*m[1][3] + m[3][0]*m[0][3]*m[1][2];

        inv[1][3] =  m[0][0]*m[1][2]*m[2][3] - m[0][0]*m[1][3]*m[2][2] -
                     m[1][0]*m[0][2]*m[2][3] + m[1][0]*m[0][3]*m[2][2] +
                     m[2][0]*m[0][2]*m[1][3] - m[2][0]*m[0][3]*m[1][2];

        inv[2][0] =  m[1][0]*m[2][1]*m[3][3] - m[1][0]*m[2][3]*m[3][1] -
                     m[2][0]*m[1][1]*m[3][3] + m[2][0]*m[1][3]*m[3][1] +
                     m[3][0]*m[1][1]*m[2][3] - m[3][0]*m[1][3]*m[2][1];

        inv[2][1] = -m[0][0]*m[2][1]*m[3][3] + m[0][0]*m[2][3]*m[3][1] +
                     m[2][0]*m[0][1]*m[3][3] - m[2][0]*m[0][3]*m[3][1] -
                     m[3][0]*m[0][1]*m[2][3] + m[3][0]*m[0][3]*m[2][1];

        inv[2][2] =  m[0][0]*m[1][1]*m[3][3] - m[0][0]*m[1][3]*m[3][1] -
                     m[1][0]*m[0][1]*m[3][3] + m[1][0]*m[0][3]*m[3][1] +
                     m[3][0]*m[0][1]*m[1][3] - m[3][0]*m[0][3]*m[1][1];

        inv[2][3] = -m[0][0]*m[1][1]*m[2][3] + m[0][0]*m[1][3]*m[2][1] +
                     m[1][0]*m[0][1]*m[2][3] - m[1][0]*m[0][3]*m[2][1] -
                     m[2][0]*m[0][1]*m[1][3] + m[2][0]*m[0][3]*m[1][1];

        inv[3][0] = -m[1][0]*m[2][1]*m[3][2] + m[1][0]*m[2][2]*m[3][1] +
                     m[2][0]*m[1][1]*m[3][2] - m[2][0]*m[1][2]*m[3][1] -
                     m[3][0]*m[1][1]*m[2][2] + m[3][0]*m[1][2]*m[2][1];

        inv[3][1] =  m[0][0]*m[2][1]*m[3][2] - m[0][0]*m[2][2]*m[3][1] -
                     m[2][0]*m[0][1]*m[3][2] + m[2][0]*m[0][2]*m[3][1] +
                     m[3][0]*m[0][1]*m[2][2] - m[3][0]*m[0][2]*m[2][1];

        inv[3][2] = -m[0][0]*m[1][1]*m[3][2] + m[0][0]*m[1][2]*m[3][1] +
                     m[1][0]*m[0][1]*m[3][2] - m[1][0]*m[0][2]*m[3][1] -
                     m[3][0]*m[0][1]*m[1][2] + m[3][0]*m[0][2]*m[1][1];

        inv[3][3] =  m[0][0]*m[1][1]*m[2][2] - m[0][0]*m[1][2]*m[2][1] -
                     m[1][0]*m[0][1]*m[2][2] + m[1][0]*m[0][2]*m[2][1] +
                     m[2][0]*m[0][1]*m[1][2] - m[2][0]*m[0][2]*m[1][1];

        let mut det = m[0][0]*inv[0][0] + m[0][1]*inv[1][0] + m[0][2]*inv[2][0] + m[0][3]*inv[3][0];

        // if det == 0.0 {
        //     return None;
        // }

        det = 1.0 / det;

        for i in 0..4 {
            for j in 0..4 {
                inv[i][j] *= det;
            }
        }

        Matrix4(inv)
    }
}
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


// void matrix_mul(float (&multiplier)[3][3], float (&matrix)[3][3]) {
//     float result[3][3];
//     for (int i = 0; i < 3; i++) {
//         for (int j = 0; j < 3; j++) {
//             float sum = 0.0f;
//             for (int k = 0; k < 3; k++) {
//                 sum += multiplier[i][k] * matrix[k][j];
//             }
//             result[i][j] = sum;
//         }
//     }
//
//     for (int i = 0; i < 3; i ++) {
//         for (int j = 0; j < 3; j++) {
//             matrix[i][j] = result[i][j];
//         }
//     }
// }

// again, wrong order... kinda? *= isn't a mathematical operator
// #[derive(Debug, Clone, Copy)]
// pub struct Matrix3(pub [[f32; 3]; 3]);
// impl MulAssign for Matrix3 {
//     fn mul_assign(&mut self, other: Matrix3) {
//         let self_copy = *self;
//         for i in 0..3 {
//             for j in 0..3 {
//                 let mut sum: f32 = 0.0;
//                 for k in 0..3 {
//                     // OTHER * SELF so that other transformation applies after self
//                     sum += other.0[k][j] * self_copy.0[i][k];
//                 }
//                 self.0[i][j] = sum;
//             }
//         }
//     }
// }

// TODO: add normals to triangle struct? for lighting
#[derive(Clone, Copy)]
pub struct Triangle3(pub [Vector3; 3]);
impl Mul<Matrix4> for Triangle3 {
    type Output = RTriangle3;

    fn mul(self, matrix: Matrix4) -> RTriangle3 {
        let mut result = RTriangle3::new();
        let mut index: usize = 0;
        for vertex in self.0 {
            result.v[index] = RVector3::from_vector3(vertex * matrix);
            index += 1;
        }
        result
    }
}

#[derive(Clone, Copy)]
pub struct Line3(pub [Vector3; 2]);
impl Mul<Matrix4> for Line3 {
    type Output = RLine3;

    fn mul(self, matrix: Matrix4) -> RLine3 {
        let mut result = RLine3 ( [RVector3::new(0, 0, 0.0); 2]);
        let mut index: usize = 0;
        for vertex in self.0 {
            result.0[index] = RVector3::from_vector3(vertex * matrix);
            index += 1;
        }
        result
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct RTriangle3 {
    pub v: [RVector3; 3]
}
impl Sub<RVector3> for RTriangle3 {
    type Output = RTriangle3;

    fn sub(self, vector: RVector3) -> RTriangle3 {
        // TODO: map
        let mut tri = RTriangle3::new();
        for i in 0..3 {
            tri.v[i] = self.v[i] - vector;
        }
        tri
    }
}
impl RTriangle3 {
    pub fn new() -> Self {
        RTriangle3{
            v: [RVector3::new(0, 0, 0.0); 3]
        }
    }
}

#[derive(Clone, Copy)]
pub struct RLine3(pub [RVector3; 2]);

#[derive(Clone, Copy, Debug)]
pub struct Quaternion {
    pub w: f32,
    pub x: f32,
    pub y: f32,
    pub z: f32
}
// TODO: default angle is pi/2 rotated on the x-axis. work that out please
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

==> grapher/mesh.rs <==
use crate::{
    grapher::{
        mat::*
    },
    generator,
    constants::*,
    input::parser::Expr
};
use heapless::Vec;

fn get_projection_matrix(scale: f32) -> Matrix4 {
    Matrix4 ([
        [120.0, 0.0  , 0.0      , 160.0],
        [0.0  , 120.0, 0.0      , 110.0],
        [0.0  , 0.0  , 0.6/scale, 0.0  ],
        [0.0  , 0.0  , 0.0      , 1.0  ]
    ])
}

fn get_scale_matrix(scale: f32) -> Matrix4 {
    Matrix4 ([
        [scale, 0.0  , 0.0  , 0.0],
        [0.0  , scale, 0.0  , 0.0],
        [0.0  , 0.0  , scale, 0.0],
        [0.0  , 0.0  , 0.0  , 1.0]
    ])
}

#[derive(Clone, Copy)]
pub struct Domain {
    pub x0: f32,
    pub y0: f32,
    pub z0: f32,
    pub x1: f32,
    pub y1: f32,
    pub z1: f32,
    pub matrix: Matrix4
}
impl Domain {
    pub fn new() -> Self {
        Domain {
            x0: -10.0,
            y0: -10.0,
            z0: -10.0,
            x1: 10.0,
            y1: 10.0,
            z1: 10.0,
            matrix: Matrix4::new()
        }
    }

    pub fn translate(&mut self, trans_direction: Vector3) {
        if trans_direction.x.is_nan() {
            self.x0 = -10.0;
            self.y0 = -10.0;
            self.z0 = -10.0;
            self.x1 = 10.0;
            self.y1 = 10.0;
            self.z1 = 10.0;

            return
        }
        let dx = (self.x1 - self.x0) * 0.1 * trans_direction.x;
        let dy = (self.y1 - self.y0) * 0.1 * trans_direction.y;
        let dz = (self.z1 - self.z0) * 0.1 * trans_direction.z;

        self.x0 += dx;
        self.x1 += dx;
        self.y0 += dy;
        self.y1 += dy;
        self.z0 += dz;
        self.z1 += dz;
    }

    pub fn scale(&mut self, scale_direction: Vector3) {
        let dx = (self.x1 - self.x0) * (1.0 + scale_direction.x * settings::DOMAIN_SCALE_SPEED) / 2.0;
        let dy = (self.y1 - self.y0) * (1.0 + scale_direction.y * settings::DOMAIN_SCALE_SPEED) / 2.0;
        let dz = (self.z1 - self.z0) * (1.0 + scale_direction.z * settings::DOMAIN_SCALE_SPEED) / 2.0;

        let xm = (self.x0 + self.x1) / 2.0;
        let ym = (self.y0 + self.y1) / 2.0;
        let zm = (self.z0 + self.z1) / 2.0;

        self.x0 = xm - dx;
        self.x1 = xm + dx;
        self.y0 = ym - dy;
        self.y1 = ym + dy;
        self.z0 = zm - dz;
        self.z1 = zm + dz;
    }

    pub fn set_axes(&mut self, axes: &mut [Line3; 3]) {
        axes[0] = Line3([
            v!(self.x0, self.y0, self.z0),
            v!(self.x1, self.y0, self.z0)
        ]);
        axes[1] = Line3([
            v!(self.x0, self.y0, self.z0),
            v!(self.x0, self.y1, self.z0)
        ]);
        axes[2] = Line3([
            v!(self.x0, self.y0, self.z0),
            v!(self.x0, self.y0, self.z1)
        ]);
    }

    pub fn update_matrix(&mut self) {
        let dx = self.x1 - self.x0;
        let dy = self.y1 - self.y0;
        let dz = self.z1 - self.z0;

        let x_scale = 2.0 / dx;
        let y_scale = 2.0 / dy;
        let z_scale = 2.0 / dz;

        let x_trans = -self.x0 - dx/2.0;
        let y_trans = -self.y0 - dy/2.0;
        let z_trans = -self.z0 - dz/2.0;

        self.matrix = Matrix4 ( [
            [x_scale, 0.0    , 0.0    , x_trans*x_scale],
            [0.0    , y_scale, 0.0    , y_trans*y_scale],
            [0.0    , 0.0    , z_scale, z_trans*z_scale],
            [0.0    , 0.0    , 0.0    , 1.0            ]
        ] )
    }
}

pub struct Mesh {
    pub tris: Vec<Triangle3, { limits::MAX_TRIS }>,
    pub transformed_tris: Vec<RTriangle3, { limits::MAX_TRIS }>,
    // pub lines: Vec<Line>,
    pub axes: [Line3; 3],  // in order: x, y, z
    pub transformed_axes:  [RLine3; 3],
    pub domain: Domain,
    rotation: Quaternion,
    pub scale: f32
}
impl Mesh {
    pub fn new() -> Self {
        Self {
            tris: Vec::new(), 
            transformed_tris: Vec::new(),
            // lines:  Vec::with_capacity(limits::MAX_LINES), // TODO: transform lines
            axes: [Line3([v!(0.0, 0.0, 0.0); 2]); 3],
            transformed_axes: [RLine3([RVector3::new(0, 0, 0.0); 2]); 3],
            domain: Domain::new(),
            rotation: Quaternion::default(),
            scale: 0.5
        }
    }

    pub fn update_domain(&mut self, trans_direction: Vector3, scale_direction: Vector3) {
        self.domain.translate(trans_direction);
        self.domain.scale(scale_direction);
        self.domain.update_matrix();
        self.domain.set_axes(&mut self.axes);
    }

    pub fn update_rotation(&mut self, rotation_direction: Vector3, delta_time: f32) {
        if rotation_direction.x.is_nan() {
            self.rotation = Quaternion::default();
            return
        }

        let rotation_speed = settings::ROTATION_SPEED * delta_time;
        let x = rotation_direction.x * rotation_speed;
        let y = rotation_direction.y * rotation_speed;
        let z = rotation_direction.z * rotation_speed;
        
        self.rotation = Quaternion::from_angles(x, y, z) * self.rotation;
    }

    pub fn update_scale(&mut self, scale_change: f32, delta_time: f32) {
        self.scale += settings::SCALE_SPEED * scale_change * delta_time;
        if self.scale < 0.0 { self.scale = 0.0 }
    }

    fn get_matrix(&mut self) -> Matrix4 {
        let mut matrix = get_projection_matrix(self.scale);
        matrix *= self.rotation.get_rotation_matrix();
        matrix *= get_scale_matrix(self.scale);
        matrix *= self.domain.matrix;

        matrix
    }

    pub fn transform(&mut self) {
        let matrix = self.get_matrix();

        self.transformed_tris.clear();
        for tri in &self.tris {
            let _ = self.transformed_tris.push(*tri * matrix);
        }
        for i in 0..3 {
            self.transformed_axes[i] = self.axes[i] * matrix;
        }
    }

    pub fn generate_screen(&mut self, expr: &Expr) {
        let mut matrix = self.get_matrix(); 
        matrix = matrix.inverse();

        generator::raymarcher::generate_screen(
            expr,
            matrix
        );
    }
}

==> grapher/renderer.rs <==
use crate::{ 
    eadk::*, 
    constants::graphics::*, 
    grapher::{
        mat::{ 
            RVector3, 
            RTriangle3 
        }, 
        mesh::Mesh 
    }
};

pub struct Renderer {
    buffer: [Color; FB_WIDTH_SIZE * FB_HEIGHT_SIZE],
    depth_buffer: [f16; FB_WIDTH_SIZE * FB_HEIGHT_SIZE],  // TODO: switching to f32 breaks rendering??
}
impl Renderer {
    pub fn new() -> Self {
        Renderer {
            buffer: [BG; FB_WIDTH_SIZE * FB_HEIGHT_SIZE],
            depth_buffer: [5.0; FB_WIDTH_SIZE * FB_HEIGHT_SIZE]
        }
    }

    pub fn clear(&mut self) {
        for px in self.buffer.iter_mut() {
            *px = BG;
        }
        for d in self.depth_buffer.iter_mut() {
            *d = 5.0; // TODO: stop with this nonsense (maybe?)
        }
    }

    pub fn draw_screen(&mut self, mesh: &Mesh, help: bool) {
        for column in 0..FB_TILE {
            for row in 0..FB_TILE {
                self.clear();
                let offset_vector = RVector3::new(
                    (column * FB_WIDTH) as isize, 
                    (MARGIN_TOP + row * FB_HEIGHT) as isize, 
                    0.0
                );

                // draw tris
                for tri in &mesh.transformed_tris {
                    let mut value = (-tri.v[0].z + 1.0) / 2.0 * 255.0;
                    if value > 255.0 { value = 255.0 };
                    if value < 0.0 { value = 0.0 };

                    let color = Color::from_rgb(0, value as u16, 255);
                    self.fill_triangle(
                        *tri - offset_vector,
                        color
                    );
                }

                // draw axes
                let mut i = 0;  // TODO: is there rust enumerate?
                for axis in &mesh.transformed_axes {
                    let color = AXIS_COLORS[i];
                    self.fill_line(
                        axis.0[0],
                        axis.0[1],
                        offset_vector,
                        color
                    );
                    i += 1;
                }

                if !help || column < FB_TILE - 1 {
                    display::push_rect(
                        Rect { 
                            x: offset_vector.x as u16,
                            y: offset_vector.y as u16,
                            width: FB_WIDTH,
                            height: FB_HEIGHT
                        },
                        &self.buffer
                    );
                }
            }
        }
        // display::wait_for_vblank();
    }

    fn fill_triangle(&mut self, tri: RTriangle3, color: Color) {
        let [mut v0, mut v1, mut v2] = tri.v;

        use core::mem::swap;
        if v0.y > v1.y { swap(&mut v0, &mut v1) }
        if v0.y > v2.y { swap(&mut v0, &mut v2) }
        if v1.y > v2.y { swap(&mut v1, &mut v2) }

        let triangle_height = v2.y - v0.y;
        let triangle_heightf = triangle_height as f32;

        'height_iter: for y_scan in 0..triangle_height {
            let is_second_half = y_scan > (v1.y - v0.y) || (v1.y == v0.y);
            let segment_heightf = if is_second_half {
                (v2.y - v1.y) as f32
            } else {
                (v1.y - v0.y) as f32
            };

            let height_progress = y_scan as f32 / triangle_heightf;
            let segment_progress = if is_second_half {
                (y_scan as f32 - (v1.y - v0.y) as f32) / segment_heightf
            } else {
                y_scan as f32 / segment_heightf
            };

            let mut x_left = v0.x as f32 + ((v2.x - v0.x) as f32 * height_progress);
            let mut z_left = v0.z as f32 + ((v2.z - v0.z) as f32 * height_progress);

            let mut x_right;
            let mut z_right;
            if is_second_half {
                x_right = v1.x as f32 + ((v2.x - v1.x) as f32 * segment_progress);
                z_right = v1.z as f32 + ((v2.z - v1.z) as f32 * segment_progress);
            } else {
                x_right = v0.x as f32 + ((v1.x - v0.x) as f32 * segment_progress);
                z_right = v0.z as f32 + ((v1.z - v0.z) as f32 * segment_progress);
            }

            if x_left > x_right {
                swap(&mut x_left, &mut x_right);
                swap(&mut z_left, &mut z_right);
            }

            let y = v0.y + y_scan;
            if y < 0 {
                continue 'height_iter;
            }
            if y >= FB_HEIGHT as isize {
                break 'height_iter;
            }

            if (x_right as usize) < 1 {
                continue 'height_iter;
            }

            let scan_width = x_right - x_left;
            for x_scan in (x_left as usize)..=(x_right as usize) {
                if x_scan >= FB_WIDTH_SIZE {
                    continue 'height_iter;
                }

                let scan_progress = if scan_width != 0.0 {
                    (x_scan as f32 - x_left) / scan_width
                } else {
                    0.0
                };
                let z = (z_left + (z_right - z_left) * scan_progress) as f16;

                let index = y as usize * FB_WIDTH_SIZE + x_scan;
                let curr_depth = self.depth_buffer[index];
                if z < curr_depth {
                    self.buffer[index] = color;
                    self.depth_buffer[index] = z;
                }
            }
        }
    }

    // TEMP version
    fn fill_line(&mut self, v0: RVector3, v1: RVector3, offset_vector: RVector3, color: Color) {
        let v2 = RVector3::new(
            v0.x + 1,
            v0.y + 1,
            v0.z + 0.1
        );
        let v3 = RVector3::new(
            v1.x + 1,
            v1.y + 1,
            v1.z + 0.1
        );
        let tri1 = RTriangle3 {
            v: [v0, v1, v2]
        };
        let tri2 = RTriangle3 {
            v: [v1, v3, v2]
        };

        self.fill_triangle(tri1 - offset_vector, color);
        self.fill_triangle(tri2 - offset_vector, color);
    }
}

==> grapher/timer.rs <==
use crate::eadk::timing::millis;

pub struct Timer {
    pub delta_time: f32,
    pub fps: f32,
    prev_time: u64
}
impl Timer {
    pub fn new() -> Self {
        Timer {
            delta_time: 0.1,
            fps: 0.0,
            prev_time: millis()
        }
    }

    pub fn update(&mut self) {
        let now = millis();
        self.delta_time = (now - self.prev_time) as f32 / 1000.0;
        self.prev_time = now;
        self.fps = 1.0 / self.delta_time;
    }
}
==> input/parser.rs <==
use heapless::Vec;
use crate::{
    constants::limits::*,
    trig::*
};

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

#[derive(Debug)]
enum Token {
    X, Y, Z,
    Const(f32),
    Add, Sub,
    Mul, Div,
    Pow,
    Sin, Cos, Tan
}

pub struct Expr {
    pub is_implicit: bool,
    rpn: Vec<Token, MAX_TOKENS>
}
impl Expr {
    pub fn new(expr: &str, is_implicit: bool) -> Result<Self, ParserError> {
        let mut tokens = Vec::new();

        for split in expr.split_whitespace() {
            let token = match split {
                "x" => Token::X, "y" => Token::Y, "z" => Token::Z,
                "+" => Token::Add, "-" => Token::Sub,
                "*" => Token::Mul, "/" => Token::Div,
                "^" => Token::Pow,
                "sin" => Token::Sin, "cos" => Token::Cos, "tan" => Token::Tan,
                _ => Token::Const(
                    split.parse()
                        .map_err(|_| ParserError::InvalidCharacter)?
                )
            };

            tokens.push(token).map_err(|_| ParserError::Overflow)?
        }
        
        Ok(Self { 
            is_implicit,
            rpn: tokens
        })
    }

    pub fn eval(&self, x: f32, y: f32, z: f32) -> Result<f32, EvalError> {
        let mut stack: Vec<f32, PARSE_STACK> = Vec::new();

        for token in self.rpn.iter() {
            let mut result: f32;

            match *token {
                Token::X => result = x, Token::Y => result = y, Token::Z => result = z,
                Token::Const(n) => result = n,

                Token::Add => {
                    let b = stack.pop().ok_or(EvalError::Underflow)?;
                    let a = stack.pop().ok_or(EvalError::Underflow)?;
                    result = a + b;
                },
                Token::Sub => {
                    let b = stack.pop().ok_or(EvalError::Underflow)?;
                    let a = stack.pop().ok_or(EvalError::Underflow)?;
                    result = a - b;
                },
                Token::Mul => {
                    let b = stack.pop().ok_or(EvalError::Underflow)?;
                    let a = stack.pop().ok_or(EvalError::Underflow)?;
                    result = a * b;
                },
                Token::Div => {
                    let b = stack.pop().ok_or(EvalError::Underflow)?;
                    let a = stack.pop().ok_or(EvalError::Underflow)?;
                    if b == 0.0 { return Err(EvalError::ZeroDiv) };
                    result = a / b;
                },

                Token::Pow => {
                    let b = stack.pop().ok_or(EvalError::Underflow)?;
                    let i = b as i32;   // power only works with integers
                    // TODO: use e/ln method?
                    let a = stack.pop().ok_or(EvalError::Underflow)?;
                    result = 1.0;
                    
                    if i > 0 {
                        for _ in 0..i {
                            result *= a;
                        }
                    } else {
                        for _ in 0..-i {
                            result /= a;
                        }
                    }
                }

                Token::Sin => {
                    let x = stack.pop().ok_or(EvalError::Underflow)?;
                    result = sin(x);
                },
                Token::Cos => {
                    let x = stack.pop().ok_or(EvalError::Underflow)?;
                    result = cos(x);
                },
                Token::Tan => {
                    let x = stack.pop().ok_or(EvalError::Underflow)?;
                    result = sin(x) / cos(x);
                }
            };
            
            let _ = stack.push(result)
                .map_err(|_| EvalError::Overflow);
        }

        Ok(stack.pop().ok_or(EvalError::Underflow)?)
    }
}


==> input/ui.rs <==
use crate::{
    input::parser::Expr,
    eadk::{
        display::*,
        Point,
        Color,
        Rect,
        input::*
    },
    constants::{
        controls::*,
        graphics::*,
        palette::*
    }
};
#[cfg(target_os = "none")]
use alloc::string::String;

fn write(text: &str) {
    push_rect_uniform(
        Rect {
            x: 0,
            y: MARGIN_TOP,
            width: SCREEN_WIDTH,
            height: SCREEN_HEIGHT - MARGIN_TOP
        },
        WHITE
    );

    let limit = 30;
    let mut line_count = 0;

    let mut line = String::new();
    for i in 0..text.len() {
        line.push(text.as_bytes()[i] as char);

        if line.len() >= limit || i >= text.len() - 1 {
            draw_string(
                line.as_str(),
                Point {
                    x: 10,
                    y: (25 + 20 * line_count) as u16
                },
                true,
                Color::from_rgb(0, 0, 0),
                Color::from_rgb(255, 255, 255)
            );
            line.clear();
            line_count += 1;
        }
    }
}

pub fn get_expr() -> Option<Expr> {
    let mut expr = String::new();
    
    let mut keyboard_state = KeyboardState::scan();
    while !keyboard_state.key_down(CONFIRM) {
        keyboard_state = KeyboardState::scan();

        use Event::*;
        let event = event_get(200);
        
        if event == Backspace {
            expr.pop();
            write(&expr);
        } else {
            let c: &str = match event {
                Shift => "z ", Alpha => "y ", Xnt => "x ",
                Zero => "0", One => "1", Two => "2", Three => "3", Four => "4", 
                Five => "5", Six => "6", Seven => "7", Eight => "8", Nine => "9",
                Plus => "+ ", Minus => "- ", Multiplication => "* ", Division => "/ ",
                Power => "^ ",
                Sine => "sin ", Cosine => "cos ", Tangent => "tan ",
                EXE => " ",
                _ => ""
            };

            if c != "" {
                expr.push_str(c);
                write(&expr);
            }
        }

        if keyboard_state.key_down(EXIT) { return None }
    }

    Some(Expr::new(&expr, true).unwrap())
}
```
