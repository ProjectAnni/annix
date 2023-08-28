#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::double_parens,
    non_snake_case,
    clippy::too_many_arguments
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.81.0.

use crate::repo::api::*;
use core::panic::UnwindSafe;
use flutter_rust_bridge::rust2dart::IntoIntoDart;
use flutter_rust_bridge::*;
use std::ffi::c_void;
use std::sync::Arc;

// Section: imports

// Section: wire functions

fn wire_new__static_method__LocalDb_impl(
    port_: MessagePort,
    path: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, LocalDb>(
        WrapInfo {
            debug_name: "new__static_method__LocalDb",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_path = path.wire2api();
            move |task_callback| Ok(LocalDb::new(api_path))
        },
    )
}
fn wire_get_album__method__LocalDb_impl(
    port_: MessagePort,
    that: impl Wire2Api<LocalDb> + UnwindSafe,
    album_id: impl Wire2Api<uuid::Uuid> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, Option<String>>(
        WrapInfo {
            debug_name: "get_album__method__LocalDb",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_that = that.wire2api();
            let api_album_id = album_id.wire2api();
            move |task_callback| Ok(LocalDb::get_album(&api_that, api_album_id))
        },
    )
}
fn wire_get_albums_by_tag__method__LocalDb_impl(
    port_: MessagePort,
    that: impl Wire2Api<LocalDb> + UnwindSafe,
    tag: impl Wire2Api<String> + UnwindSafe,
    recursive: impl Wire2Api<bool> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, Vec<uuid::Uuid>>(
        WrapInfo {
            debug_name: "get_albums_by_tag__method__LocalDb",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_that = that.wire2api();
            let api_tag = tag.wire2api();
            let api_recursive = recursive.wire2api();
            move |task_callback| {
                Ok(LocalDb::get_albums_by_tag(
                    &api_that,
                    api_tag,
                    api_recursive,
                ))
            }
        },
    )
}
fn wire_get_tags__method__LocalDb_impl(
    port_: MessagePort,
    that: impl Wire2Api<LocalDb> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, Vec<TagItem>>(
        WrapInfo {
            debug_name: "get_tags__method__LocalDb",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_that = that.wire2api();
            move |task_callback| Ok(LocalDb::get_tags(&api_that))
        },
    )
}
// Section: wrapper structs

// Section: static checks

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        (!self.is_null()).then(|| self.wire2api())
    }
}

impl Wire2Api<bool> for bool {
    fn wire2api(self) -> bool {
        self
    }
}

impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

// Section: impl IntoDart

impl support::IntoDart for LocalDb {
    fn into_dart(self) -> support::DartAbi {
        vec![self.repo.into_dart()].into_dart()
    }
}
impl support::IntoDartExceptPrimitive for LocalDb {}
impl rust2dart::IntoIntoDart<LocalDb> for LocalDb {
    fn into_into_dart(self) -> Self {
        self
    }
}

impl support::IntoDart for TagItem {
    fn into_dart(self) -> support::DartAbi {
        vec![
            self.name.into_into_dart().into_dart(),
            self.children.into_into_dart().into_dart(),
        ]
        .into_dart()
    }
}
impl support::IntoDartExceptPrimitive for TagItem {}
impl rust2dart::IntoIntoDart<TagItem> for TagItem {
    fn into_into_dart(self) -> Self {
        self
    }
}

// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

#[cfg(not(target_family = "wasm"))]
#[path = "generated.io.rs"]
mod io;
#[cfg(not(target_family = "wasm"))]
pub use io::*;
