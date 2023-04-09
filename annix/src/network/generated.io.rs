use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_update_network_status(port_: i64, is_online: bool) {
    wire_update_network_status_impl(port_, is_online)
}

#[no_mangle]
pub extern "C" fn wire_is_online__method__NetworkStatus(port_: i64, that: i32) {
    wire_is_online__method__NetworkStatus_impl(port_, that)
}

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

// Section: wire structs

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}
