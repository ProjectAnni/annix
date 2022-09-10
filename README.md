# Annix

Desktop / Mobile client for Project Anni.

## Features

- Cross-platform player designed for Project Anni
    - Tested on Linux(Manjaro KDE), macOS, Windows and Android
- Control through MPRIS on Linux
- Portable mode (create a file named `portable.enable`)

## Build

```bash
# Build models & ffi
flutter pub run build_runner build --delete-conflicting-outputs

# Build apk
flutter build apk --release --split-per-abi --split-debug-info debug --obfuscate
```

### Known issues

- Windows users should
  download [`sqlite3.dll`](https://github.com/tekartik/sqflite/raw/master/sqflite_common_ffi/lib/src/windows/sqlite3.dll)
  manually and put it in the directory which includes `annix.exe`.
- At this moment, annix does not work as
  expected. [#1221](https://github.com/bluefireteam/audioplayers/pull/1221) has been merged, but no
  update has been released yet.
- Locale on linux desktop may fallback to `en_US` because
  of [an issue of flutter engine](https://github.com/flutter/flutter/issues/111341) which makes
  slang [failed to parse locale string](https://github.com/Tienisto/slang/issues/102).

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

## Thanks

- [WeSlide - MIT License](https://github.com/luciano-work/we_slide): We're using a modified version
  of this package to implement the main player UI on mobile.