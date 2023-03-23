#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_MutexRepoDatabaseRead {
  const void *ptr;
} wire_MutexRepoDatabaseRead;

typedef struct wire_LocalDb {
  struct wire_MutexRepoDatabaseRead repo;
} wire_LocalDb;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_new__static_method__LocalDb(int64_t port_, struct wire_uint_8_list *path);

void wire_get_album__method__LocalDb(int64_t port_,
                                     struct wire_LocalDb *that,
                                     struct wire_uint_8_list *album_id);

void wire_get_albums_by_tag__method__LocalDb(int64_t port_,
                                             struct wire_LocalDb *that,
                                             struct wire_uint_8_list *tag,
                                             bool recursive);

void wire_get_tags__method__LocalDb(int64_t port_, struct wire_LocalDb *that);

struct wire_MutexRepoDatabaseRead new_MutexRepoDatabaseRead(void);

struct wire_LocalDb *new_box_autoadd_local_db_0(void);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

void drop_opaque_MutexRepoDatabaseRead(const void *ptr);

const void *share_opaque_MutexRepoDatabaseRead(const void *ptr);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_new__static_method__LocalDb);
    dummy_var ^= ((int64_t) (void*) wire_get_album__method__LocalDb);
    dummy_var ^= ((int64_t) (void*) wire_get_albums_by_tag__method__LocalDb);
    dummy_var ^= ((int64_t) (void*) wire_get_tags__method__LocalDb);
    dummy_var ^= ((int64_t) (void*) new_MutexRepoDatabaseRead);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_local_db_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) drop_opaque_MutexRepoDatabaseRead);
    dummy_var ^= ((int64_t) (void*) share_opaque_MutexRepoDatabaseRead);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
