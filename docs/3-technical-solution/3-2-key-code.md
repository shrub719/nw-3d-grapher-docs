## 3.2 Key code

```rs
==> src/constants.rs <==
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

    // 2 is possible with margins and very few triangles... i kinda wanna try stretch it further
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
    // pub const MAX_LINES: usize = 20;  // TODO: add lines
}

#[cfg(not(target_os = "none"))]
pub mod limits {
    pub const MAX_TRIS: usize = 15000;
    pub const EXPLICIT_N: usize = 30;
    pub const IMPLICIT_N: usize = 30;
    pub const MARCH_N: usize = 500; // TODO: what should the limits be?
    pub const MAX_ROW_TIME: u64 = 50;
    // pub const MAX_LINES: usize = 20;  // TODO: add lines
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
        "WIP",
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

==> src/eadk.rs <==
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

==> src/generator <==

==> src/generator.rs <==
pub mod explicit;
pub mod implicit;
pub mod raymarcher;
mod tables;


==> src/grapher <==

==> src/grapher.rs <==
use crate::{
    grapher::{
        renderer::*,
        mesh::Mesh,
        input::*,
        hud::*,
        timer::*
    },
    eadk::*,
    constants::{ graphics::*, palette::* }
};
#[cfg(target_os = "none")]
use alloc::format;

pub mod mat;
mod renderer;
pub mod mesh;
mod input;
mod hud;
mod timer;

pub type Graph = fn(f32, f32, f32) -> f32;

pub struct Grapher {
    renderer: Renderer,
    pub mesh: Mesh,
    input: InputHandler,
    timer: Timer,
    pub graph: Graph
}
impl Grapher {
    pub fn new(graph: Graph) -> Self {
        Grapher {
            renderer: Renderer::new(),
            mesh: Mesh::new(),
            input: InputHandler::new(),
            timer: Timer::new(),
            graph
        }
    }

    fn setup_ui() {
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
                self.generate_mesh_imp();
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

            if self.input.upd.enhance {
                self.mesh.generate_screen(self.graph);
            }

            self.input.update();
            self.timer.update();
            
            if self.timer.fps < 800.0 {   // temp fix
                header_info(&format!("fps: {:.1}   ", self.timer.fps));
            }
        }
    }
}

==> src/main.rs <==
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
mod menu;
use menu::Menu;

#[unsafe(no_mangle)]
pub fn main() -> isize {
    #[cfg(target_os = "none")]
    {
        let heap_size: usize = 100_000;
        unsafe { HEAP.init(eadk::HEAP_START as usize, heap_size) }
    }

    let mut menu = Menu::new();
    menu.main_loop();

    0
}

==> src/menu <==

==> src/menu.rs <==
use crate::{
    grapher::Grapher
};

pub mod parser;
pub mod ui;

pub enum MenuState {
    Input,
    Settings
}

pub struct Menu {
    state: MenuState
}
impl Menu {
    pub fn new() -> Self {
        Menu {
            state: MenuState::Input
        }
    }
    
    pub fn main_loop(&self) {
        loop {
            let graph = ui::get_graph();
            let mut grapher = Grapher::new(graph);
            grapher.main_loop();
        }
    }
}

==> src/trig.rs <==
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
```
