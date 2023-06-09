#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

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

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_MutexConnection {
  const void *ptr;
} wire_MutexConnection;

typedef struct wire_LocalStore {
  struct wire_MutexConnection conn;
} wire_LocalStore;

struct wire_NativePreferenceStore *new_box_autoadd_native_preference_store_1(void);

struct wire_LocalDb *new_box_autoadd_local_db_0(void);

void free_WireSyncReturn(WireSyncReturn ptr);

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

WireSyncReturn wire_new__static_method__LocalStore(struct wire_uint_8_list *root);

void wire_insert__method__LocalStore(int64_t port_,
                                     struct wire_LocalStore *that,
                                     struct wire_uint_8_list *category,
                                     struct wire_uint_8_list *key,
                                     struct wire_uint_8_list *value);

void wire_get__method__LocalStore(int64_t port_,
                                  struct wire_LocalStore *that,
                                  struct wire_uint_8_list *category,
                                  struct wire_uint_8_list *key);

void wire_clear__method__LocalStore(int64_t port_,
                                    struct wire_LocalStore *that,
                                    struct wire_uint_8_list *category);

struct wire_MutexConnection new_MutexConnection(void);

struct wire_LocalStore *new_box_autoadd_local_store_2(void);

struct wire_uint_8_list *new_uint_8_list_2(int32_t len);

void drop_opaque_MutexConnection(const void *ptr);

const void *share_opaque_MutexConnection(const void *ptr);

static int64_t dummy_method_to_enforce_bundling_ApiStore(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_new__static_method__LocalStore);
    dummy_var ^= ((int64_t) (void*) wire_insert__method__LocalStore);
    dummy_var ^= ((int64_t) (void*) wire_get__method__LocalStore);
    dummy_var ^= ((int64_t) (void*) wire_clear__method__LocalStore);
    dummy_var ^= ((int64_t) (void*) new_MutexConnection);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_local_store_2);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_2);
    dummy_var ^= ((int64_t) (void*) drop_opaque_MutexConnection);
    dummy_var ^= ((int64_t) (void*) share_opaque_MutexConnection);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
