#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_MutexDummy1Connection {
  const void *ptr;
} wire_MutexDummy1Connection;

typedef struct wire_NativePreferenceStore {
  struct wire_MutexDummy1Connection conn;
} wire_NativePreferenceStore;

typedef struct wire_MutexRepoDatabaseRead {
  const void *ptr;
} wire_MutexRepoDatabaseRead;

typedef struct wire_LocalDb {
  struct wire_MutexRepoDatabaseRead repo;
} wire_LocalDb;

typedef struct DartCObject *WireSyncReturn;

typedef struct wire_MutexConnection {
  const void *ptr;
} wire_MutexConnection;

typedef struct wire_LocalStore {
  struct wire_MutexConnection conn;
} wire_LocalStore;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_update_network_status(int64_t port_, bool is_online);

void wire_is_online__method__NetworkStatus(int64_t port_, int32_t that);

struct wire_NativePreferenceStore *new_box_autoadd_native_preference_store_1(void);

struct wire_LocalDb *new_box_autoadd_local_db_0(void);

void free_WireSyncReturn(WireSyncReturn ptr);

struct wire_LocalStore *new_box_autoadd_local_store_2(void);

static int64_t dummy_method_to_enforce_bundling_ApiNetwork(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_update_network_status);
    dummy_var ^= ((int64_t) (void*) wire_is_online__method__NetworkStatus);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
