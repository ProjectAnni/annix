use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_new__static_method__LocalStore(
    root: *mut wire_uint_8_list,
) -> support::WireSyncReturn {
    wire_new__static_method__LocalStore_impl(root)
}

#[no_mangle]
pub extern "C" fn wire_insert__method__LocalStore(
    port_: i64,
    that: *mut wire_LocalStore,
    category: *mut wire_uint_8_list,
    key: *mut wire_uint_8_list,
    value: *mut wire_uint_8_list,
) {
    wire_insert__method__LocalStore_impl(port_, that, category, key, value)
}

#[no_mangle]
pub extern "C" fn wire_get__method__LocalStore(
    port_: i64,
    that: *mut wire_LocalStore,
    category: *mut wire_uint_8_list,
    key: *mut wire_uint_8_list,
) {
    wire_get__method__LocalStore_impl(port_, that, category, key)
}

#[no_mangle]
pub extern "C" fn wire_clear__method__LocalStore(
    port_: i64,
    that: *mut wire_LocalStore,
    category: *mut wire_uint_8_list,
) {
    wire_clear__method__LocalStore_impl(port_, that, category)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_MutexConnection() -> wire_MutexConnection {
    wire_MutexConnection::new_with_null_ptr()
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_local_store_2() -> *mut wire_LocalStore {
    support::new_leak_box_ptr(wire_LocalStore::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_2(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

#[no_mangle]
pub extern "C" fn drop_opaque_MutexConnection(ptr: *const c_void) {
    unsafe {
        Arc::<Mutex<Connection>>::decrement_strong_count(ptr as _);
    }
}

#[no_mangle]
pub extern "C" fn share_opaque_MutexConnection(ptr: *const c_void) -> *const c_void {
    unsafe {
        Arc::<Mutex<Connection>>::increment_strong_count(ptr as _);
        ptr
    }
}

// Section: impl Wire2Api

impl Wire2Api<RustOpaque<Mutex<Connection>>> for wire_MutexConnection {
    fn wire2api(self) -> RustOpaque<Mutex<Connection>> {
        unsafe { support::opaque_from_dart(self.ptr as _) }
    }
}
impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<LocalStore> for *mut wire_LocalStore {
    fn wire2api(self) -> LocalStore {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<LocalStore>::wire2api(*wrap).into()
    }
}
impl Wire2Api<LocalStore> for wire_LocalStore {
    fn wire2api(self) -> LocalStore {
        LocalStore {
            conn: self.conn.wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_MutexConnection {
    ptr: *const core::ffi::c_void,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_LocalStore {
    conn: wire_MutexConnection,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_MutexConnection {
    fn new_with_null_ptr() -> Self {
        Self {
            ptr: core::ptr::null(),
        }
    }
}

impl NewWithNullPtr for wire_LocalStore {
    fn new_with_null_ptr() -> Self {
        Self {
            conn: wire_MutexConnection::new_with_null_ptr(),
        }
    }
}

impl Default for wire_LocalStore {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}
