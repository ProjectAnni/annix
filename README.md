# Annix

Desktop / Mobile client for Project Anni.

## Build

```bash
# For player
# http://cjycode.com/flutter_rust_bridge/integrate/deps.html
cargo install flutter_rust_bridge_codegen
dart pub global activate ffigen

# For Android
cargo install cargo-ndk
rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android

# Build models & ffi
flutter pub run build_runner build --delete-conflicting-outputs
flutter_rust_bridge_codegen \
    -r player/src/api.rs \
    -d lib/bridge_generated.dart \
    -c ios/Runner/bridge_generated.h \
    -c macos/Runner/bridge_generated.h

# Build apk
export CPATH="$(clang -v 2>&1 | grep "Selected GCC installation" | rev | cut -d' ' -f1 | rev)/include"
flutter build apk --release --split-per-abi --split-debug-info debug --obfuscate
```

## TODOs

- [x] Audio Playback
- [ ] Annil
  - [ ] Server info
  - [x] Album list
  - [x] Cover
    - [x] Cover cache
  - [x] Audio
    - [x] Audio cache
  - [x] Annil selection based on priority
- [ ] Metadata Sources
  - [x] Anniv
  - [x] Local sqlite file
  - [x] Remote sqlite file
  - [ ] Metadata repository
- [ ] Anniv
  - [x] Server Info
  - [ ] User system
    - [x] Login
      - [ ] 2FA
    - [ ] Register
    - [x] Logout
    - [ ] ~~Revoke account~~ (Would not be implemented in Annix)
  - [ ] Playlist
    - [x] List playlist
    - [ ] Create playlist
    - [ ] Remove playlist
    - [ ] Edit playlist
      - [ ] Append
      - [ ] Remove
      - [ ] Reorder
      - [ ] Replace
  - [ ] Favorite
    - [x] Add favorite
    - [x] Remove favorite
    - [x] Favorite list
  - [ ] Credentials
    - [x] Get credentials
    - [ ] Add credential
    - [ ] Edit credential
    - [ ] Delete credential
  - [x] Lyric
  - [x] Search
