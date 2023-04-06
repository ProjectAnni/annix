use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_update_network_status(port_: i64, is_online: bool) {
    wire_update_network_status_impl(port_, is_online)
}

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

#[no_mangle]
pub extern "C" fn wire_new__static_method__LocalDb(port_: i64, path: *mut wire_uint_8_list) {
    wire_new__static_method__LocalDb_impl(port_, path)
}

#[no_mangle]
pub extern "C" fn wire_get_album__method__LocalDb(
    port_: i64,
    that: *mut wire_LocalDb,
    album_id: *mut wire_uint_8_list,
) {
    wire_get_album__method__LocalDb_impl(port_, that, album_id)
}

#[no_mangle]
pub extern "C" fn wire_get_albums_by_tag__method__LocalDb(
    port_: i64,
    that: *mut wire_LocalDb,
    tag: *mut wire_uint_8_list,
    recursive: bool,
) {
    wire_get_albums_by_tag__method__LocalDb_impl(port_, that, tag, recursive)
}

#[no_mangle]
pub extern "C" fn wire_get_tags__method__LocalDb(port_: i64, that: *mut wire_LocalDb) {
    wire_get_tags__method__LocalDb_impl(port_, that)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_MutexConnection() -> wire_MutexConnection {
    wire_MutexConnection::new_with_null_ptr()
}

#[no_mangle]
pub extern "C" fn new_MutexRepoDatabaseRead() -> wire_MutexRepoDatabaseRead {
    wire_MutexRepoDatabaseRead::new_with_null_ptr()
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_local_db_0() -> *mut wire_LocalDb {
    support::new_leak_box_ptr(wire_LocalDb::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_local_store_0() -> *mut wire_LocalStore {
    support::new_leak_box_ptr(wire_LocalStore::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_native_preference_store_0() -> *mut wire_NativePreferenceStore {
    support::new_leak_box_ptr(wire_NativePreferenceStore::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
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

#[no_mangle]
pub extern "C" fn drop_opaque_MutexRepoDatabaseRead(ptr: *const c_void) {
    unsafe {
        Arc::<Mutex<RepoDatabaseRead>>::decrement_strong_count(ptr as _);
    }
}

#[no_mangle]
pub extern "C" fn share_opaque_MutexRepoDatabaseRead(ptr: *const c_void) -> *const c_void {
    unsafe {
        Arc::<Mutex<RepoDatabaseRead>>::increment_strong_count(ptr as _);
        ptr
    }
}

// Section: impl Wire2Api

impl Wire2Api<RustOpaque<Mutex<Connection>>> for wire_MutexConnection {
    fn wire2api(self) -> RustOpaque<Mutex<Connection>> {
        unsafe { support::opaque_from_dart(self.ptr as _) }
    }
}
impl Wire2Api<RustOpaque<Mutex<RepoDatabaseRead>>> for wire_MutexRepoDatabaseRead {
    fn wire2api(self) -> RustOpaque<Mutex<RepoDatabaseRead>> {
        unsafe { support::opaque_from_dart(self.ptr as _) }
    }
}
impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<uuid::Uuid> for *mut wire_uint_8_list {
    fn wire2api(self) -> uuid::Uuid {
        let single: Vec<u8> = self.wire2api();
        wire2api_uuid_ref(single.as_slice())
    }
}

impl Wire2Api<LocalDb> for *mut wire_LocalDb {
    fn wire2api(self) -> LocalDb {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<LocalDb>::wire2api(*wrap).into()
    }
}
impl Wire2Api<LocalStore> for *mut wire_LocalStore {
    fn wire2api(self) -> LocalStore {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<LocalStore>::wire2api(*wrap).into()
    }
}
impl Wire2Api<NativePreferenceStore> for *mut wire_NativePreferenceStore {
    fn wire2api(self) -> NativePreferenceStore {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<NativePreferenceStore>::wire2api(*wrap).into()
    }
}
impl Wire2Api<LocalDb> for wire_LocalDb {
    fn wire2api(self) -> LocalDb {
        LocalDb {
            repo: self.repo.wire2api(),
        }
    }
}
impl Wire2Api<LocalStore> for wire_LocalStore {
    fn wire2api(self) -> LocalStore {
        LocalStore {
            conn: self.conn.wire2api(),
        }
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
pub struct wire_MutexConnection {
    ptr: *const core::ffi::c_void,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_MutexRepoDatabaseRead {
    ptr: *const core::ffi::c_void,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_LocalDb {
    repo: wire_MutexRepoDatabaseRead,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_LocalStore {
    conn: wire_MutexConnection,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_NativePreferenceStore {
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
impl NewWithNullPtr for wire_MutexRepoDatabaseRead {
    fn new_with_null_ptr() -> Self {
        Self {
            ptr: core::ptr::null(),
        }
    }
}

impl NewWithNullPtr for wire_LocalDb {
    fn new_with_null_ptr() -> Self {
        Self {
            repo: wire_MutexRepoDatabaseRead::new_with_null_ptr(),
        }
    }
}

impl Default for wire_LocalDb {
    fn default() -> Self {
        Self::new_with_null_ptr()
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

impl NewWithNullPtr for wire_NativePreferenceStore {
    fn new_with_null_ptr() -> Self {
        Self {
            conn: wire_MutexConnection::new_with_null_ptr(),
        }
    }
}

impl Default for wire_NativePreferenceStore {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
