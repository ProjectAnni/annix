# Annix

Desktop / Mobile client for Project Anni.

## Build

```bash
flutter pub run build_runner build
flutter build apk --release --split-per-abi --split-debug-info debug --obfuscate
```

## TODOs

- [x] Audio Playback
- [ ] Annil
  - [ ] Server info
  - [x] Album list
  - [x] Cover
  - [x] Audio
  - [ ] Lyric
  - [x] Annil selection based on priority
- [ ] Metadata Sources
  - [x] Anniv
  - [x] Local sqlite file
  - [ ] Remote sqlite file
  - [ ] Metadata repository
- [ ] Anniv
  - [x] Server Info
  - [ ] User system
    - [x] Login
      - [ ] 2FA
    - [ ] Register
    - [ ] Logout
    - [ ] ~~Revoke account~~ (May not be implemented in Annix)
  - [ ] Playlist
    - [ ] List playlist
    - [ ] Create playlist
    - [ ] Remove playlist
    - [ ] Edit playlist
      - [ ] Append
      - [ ] Remove
      - [ ] Reorder
      - [ ] Replace
  - [ ] Credentials
    - [x] Get credentials
    - [ ] Add credential
    - [ ] Edit credential
    - [ ] Delete credential
  - [ ] Search
