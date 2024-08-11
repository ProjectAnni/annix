# Annix

Desktop / Mobile client for Project Anni.

## Features

- Cross-platform player designed for Project Anni
    - Tested on Linux(Manjaro KDE), macOS, Windows, Android and iOS.
- Control through MPRIS on Linux
- Portable mode (create a file named `portable.enable`)

## Build

```bash
# https://github.com/dart-lang/ffigen/issues/257#issuecomment-1061788936
export CPATH="$(clang -v 2>&1 | grep "Selected GCC installation" | rev | cut -d' ' -f1 | rev)/include"

# [Optional] Build models
dart run build_runner build --delete-conflicting-outputs

# Build apk
flutter build apk --release --split-per-abi --split-debug-info debug --obfuscate

# Build for iOS
flutter build ios --profile
```

## Distribution

For `desktop` or `Android` users, please visit [Release](https://github.com/ProjectAnni/annix/releases) and  choose which asset to download accourding to your platform.

For `Android` users, you can also get an official release to join our public beta test on [Play Store](https://play.google.com/store/apps/details?id=rs.anni.annix).

For `iOS` users, only [Testflight](https://testflight.apple.com/join/ZWXnvupI) is available for now.

### Release branches

There are two release branches: `canary` and `nightly`.

`Canary` builds are binaries built from `master` branch. There might be some some unknown bugs.

`Nightly` builds are triggered daily or manually so most severe issues would be resolved. The daily cron job might be disabled in the future to makes `nightly` more stable.

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
        - [ ] Revoke account
    - [ ] Playlist
        - [x] List playlist
        - [x] Create playlist
        - [ ] Remove playlist
        - [ ] Edit playlist
            - [x] Append
            - [x] Remove
            - [x] Reorder
            - [ ] Replace
    - [ ] Favorite
        - [x] Add favorite
        - [x] Remove favorite
        - [x] Favorite list
        - [x] Add favorite album
        - [x] Remove favorite album
        - [ ] Favorite album list
    - [ ] Credentials
        - [x] Get credentials
        - [ ] Add credential
        - [ ] Edit credential
        - [ ] Delete credential
        - [x] Reorder credential priority
    - [ ] Play history
      - [ ] Report history
      - [ ] Query history
    - [x] Lyric
      - [x] Get lyric
      - [x] Lyric sources
        - [x] Netease Music
        - [x] PetitLyrics
      - [ ] Edit lyric
      - [ ] Upload lyric to Anniv
    - [x] Search
      - [ ] Search with tags
