use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_new__static_method__NativePreferenceStore(
    root: *mut wire_uint_8_list,
) -> support::WireSyncReturn {
    wire_new__static_method__NativePreferenceStore_impl(root)
}

#[no_mangle]
pub extern "C" fn wire_get__method__NativePreferenceStore(
    that: *mut wire_NativePreferenceStore,
    key: *mut wire_uint_8_list,
) -> support::WireSyncReturn {
    wire_get__method__NativePreferenceStore_impl(that, key)
}

#[no_mangle]
pub extern "C" fn wire_set__method__NativePreferenceStore(
    that: *mut wire_NativePreferenceStore,
    key: *mut wire_uint_8_list,
    value: *mut wire_uint_8_list,
) -> support::WireSyncReturn {
    wire_set__method__NativePreferenceStore_impl(that, key, value)
}

#[no_mangle]
pub extern "C" fn wire_remove__method__NativePreferenceStore(
    that: *mut wire_NativePreferenceStore,
    key: *mut wire_uint_8_list,
) -> support::WireSyncReturn {
    wire_remove__method__NativePreferenceStore_impl(that, key)
}

#[no_mangle]
pub extern "C" fn wire_remove_prefix__method__NativePreferenceStore(
    that: *mut wire_NativePreferenceStore,
    prefix: *mut wire_uint_8_list,
) -> support::WireSyncReturn {
    wire_remove_prefix__method__NativePreferenceStore_impl(that, prefix)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_MutexDummy1Connection() -> wire_MutexDummy1Connection {
    wire_MutexDummy1Connection::new_with_null_ptr()
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_native_preference_store_1() -> *mut wire_NativePreferenceStore {
    support::new_leak_box_ptr(wire_NativePreferenceStore::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_1(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

#[no_mangle]
pub extern "C" fn drop_opaque_MutexDummy1Connection(ptr: *const c_void) {
    unsafe {
        Arc::<Mutex<Dummy1<Connection>>>::decrement_strong_count(ptr as _);
    }
}

#[no_mangle]
pub extern "C" fn share_opaque_MutexDummy1Connection(ptr: *const c_void) -> *const c_void {
    unsafe {
        Arc::<Mutex<Dummy1<Connection>>>::increment_strong_count(ptr as _);
        ptr
    }
}

// Section: impl Wire2Api

impl Wire2Api<RustOpaque<Mutex<Dummy1<Connection>>>> for wire_MutexDummy1Connection {
    fn wire2api(self) -> RustOpaque<Mutex<Dummy1<Connection>>> {
        unsafe { support::opaque_from_dart(self.ptr as _) }
    }
}
impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<NativePreferenceStore> for *mut wire_NativePreferenceStore {
    fn wire2api(self) -> NativePreferenceStore {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<NativePreferenceStore>::wire2api(*wrap).into()
    }
}
impl Wire2Api<NativePreferenceStore> for wire_NativePreferenceStore {
    fn wire2api(self) -> NativePreferenceStore {
        NativePreferenceStore {
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
pub struct wire_MutexDummy1Connection {
    ptr: *const core::ffi::c_void,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_NativePreferenceStore {
    conn: wire_MutexDummy1Connection,
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

impl NewWithNullPtr for wire_MutexDummy1Connection {
    fn new_with_null_ptr() -> Self {
        Self {
            ptr: core::ptr::null(),
        }
    }
}

impl NewWithNullPtr for wire_NativePreferenceStore {
    fn new_with_null_ptr() -> Self {
        Self {
            conn: wire_MutexDummy1Connection::new_with_null_ptr(),
        }
    }
}

impl Default for wire_NativePreferenceStore {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}
