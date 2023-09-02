pub use anni_repo::{db::RepoDatabaseRead, prelude::JsonAlbum};
pub use flutter_rust_bridge::{RustOpaque, SyncReturn};
pub use once_cell::sync::Lazy;
pub use rusqlite::Connection;
pub use uuid::Uuid;

pub use std::sync::Arc;
pub use std::sync::{OnceLock, RwLock};
use std::thread;
pub use std::{path::PathBuf, sync::Mutex};

pub enum NetworkStatus {
    Online,
    Offline,
}

impl NetworkStatus {
    pub fn is_online(&self) -> bool {
        match self {
            NetworkStatus::Online => true,
            NetworkStatus::Offline => false,
        }
    }
}

pub static NETWORK: Lazy<RwLock<NetworkStatus>> = Lazy::new(|| RwLock::new(NetworkStatus::Offline));

pub fn update_network_status(is_online: bool) {
    let mut network = NETWORK.write().unwrap();
    *network = if is_online {
        NetworkStatus::Online
    } else {
        NetworkStatus::Offline
    };
}

/// Preferences
pub struct NativePreferenceStore {
    pub conn: RustOpaque<Mutex<Connection>>,
}

impl NativePreferenceStore {
    pub fn new(root: String) -> SyncReturn<NativePreferenceStore> {
        let db_path = PathBuf::from(&root).join("preference.db");
        std::fs::create_dir_all(&root).unwrap();
        let conn = Connection::open(db_path).unwrap();
        conn.execute(
            r#"
CREATE TABLE IF NOT EXISTS preferences(
    key    TEXT PRIMARY KEY ON CONFLICT REPLACE,
    value  TEXT NOT NULL
);
"#,
            (),
        )
        .unwrap();

        let conn = RustOpaque::new(Mutex::new(conn));
        SyncReturn(Self { conn })
    }

    pub fn get(&self, key: String) -> SyncReturn<Option<String>> {
        let conn = self.conn.lock().unwrap();
        let mut stmt = conn
            .prepare("SELECT value FROM preferences WHERE key = ?")
            .unwrap();
        let mut rows = stmt.query(rusqlite::params![key]).unwrap();
        let result = rows
            .next()
            .ok()
            .and_then(|r| r)
            .and_then(|row| row.get(0).ok());

        SyncReturn(result)
    }

    pub fn set(&self, key: String, value: String) -> SyncReturn<()> {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "INSERT INTO preferences (key, value) VALUES (?, ?)",
                rusqlite::params![key, value],
            )
            .unwrap();

        SyncReturn(())
    }

    pub fn remove(&self, key: String) -> SyncReturn<()> {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "DELETE FROM preferences WHERE key = ?",
                rusqlite::params![key],
            )
            .unwrap();

        SyncReturn(())
    }

    pub fn remove_prefix(&self, prefix: String) -> SyncReturn<()> {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "DELETE FROM preferences WHERE key LIKE ?",
                rusqlite::params![format!("{}%", prefix)],
            )
            .unwrap();

        SyncReturn(())
    }
}

/// Repo

pub struct LocalDb {
    pub repo: RustOpaque<Mutex<RepoDatabaseRead>>,
}

pub struct TagItem {
    pub name: String,
    pub children: Vec<String>,
}

impl LocalDb {
    pub fn new(path: String) -> LocalDb {
        let repo = RepoDatabaseRead::new(path).unwrap();
        let repo = RustOpaque::new(Mutex::new(repo));
        Self { repo }
    }

    pub fn get_album(&self, album_id: uuid::Uuid) -> Option<String> {
        let album = self.repo.lock().unwrap().read_album(album_id).unwrap();
        album.map(|album| JsonAlbum::from(album).to_string())
    }

    pub fn get_albums_by_tag(&self, tag: String, recursive: bool) -> Vec<Uuid> {
        let albums = self
            .repo
            .lock()
            .unwrap()
            .get_albums_by_tag(&tag, recursive)
            .unwrap();
        albums.into_iter().map(|album| album.album_id.0).collect()
    }

    pub fn get_tags(&self) -> Vec<TagItem> {
        let albums = self.repo.lock().unwrap().get_tags_relationship().unwrap();
        albums
            .into_iter()
            .map(|(_, tag)| TagItem {
                name: tag.tag.to_string(),
                children: tag
                    .children
                    .into_iter()
                    .map(|tag| tag.to_string())
                    .collect(),
            })
            .collect()
    }
}

/// API
pub type LocalStoreConnection = Mutex<Connection>;

pub struct LocalStore {
    pub conn: RustOpaque<LocalStoreConnection>,
}

impl LocalStore {
    pub fn new(root: String) -> SyncReturn<LocalStore> {
        let db_path = PathBuf::from(root).join("cache.db");
        let conn = Connection::open(db_path).unwrap();
        conn.execute(
            r#"
CREATE TABLE IF NOT EXISTS store(
  id       INTEGER PRIMARY KEY,
  category TEXT NOT NULL,
  key      TEXT NOT NULL,
  value    TEXT NOT NULL,
  UNIQUE("category", "key", "value") ON CONFLICT REPLACE
);"#,
            (),
        )
        .unwrap();

        let conn = RustOpaque::new(Mutex::new(conn));
        SyncReturn(Self { conn })
    }

    pub fn insert(&self, category: String, key: String, value: String) {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "INSERT INTO store (category, key, value) VALUES (?, ?, ?)",
                rusqlite::params![category, key, value],
            )
            .unwrap();
    }

    pub fn get(&self, category: String, key: String) -> Option<String> {
        let conn = self.conn.lock().unwrap();
        let mut stmt = conn
            .prepare("SELECT value FROM store WHERE category = ? AND key = ?")
            .unwrap();
        let mut rows = stmt.query(rusqlite::params![category, key]).unwrap();
        rows.next()
            .ok()
            .and_then(|r| r)
            .and_then(|row| row.get(0).ok())
    }

    pub fn clear(&self, category: Option<String>) {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "DELETE FROM store WHERE category = ?",
                rusqlite::params![category],
            )
            .unwrap();
    }
}

// Audio
pub use anni_playback::types::*;
use flutter_rust_bridge::frb;
use flutter_rust_bridge::StreamSink;

pub use crate::player::player::Player;
pub use crate::player::PlayerStateEvent;

#[frb(mirror(ProgressState))]
pub struct _ProgressState {
    pub position: u64,
    pub duration: u64,
}

fn update_progress_stream(progress: &StreamWrapper<ProgressState>, state: ProgressState) {
    if let Some(lock) = progress.get() {
        if let Some(stream) = &*lock.read().unwrap() {
            stream.add(state);
        }
    }
}

fn update_player_state_stream(
    player_state: &StreamWrapper<PlayerStateEvent>,
    state: PlayerStateEvent,
) {
    if let Some(lock) = player_state.get() {
        if let Some(stream) = &*lock.read().unwrap() {
            stream.add(state);
        }
    }
}

pub type StreamWrapper<T> = Arc<OnceLock<RwLock<Option<StreamSink<T>>>>>;

pub struct AnnixPlayer {
    pub player: RustOpaque<Player>,
    pub _state: RustOpaque<StreamWrapper<PlayerStateEvent>>,
    pub _progress: RustOpaque<StreamWrapper<ProgressState>>,
}

impl AnnixPlayer {
    pub fn new() -> SyncReturn<AnnixPlayer> {
        let (player, receiver) = Player::new();
        let progress = Arc::new(OnceLock::new());
        let player_state = Arc::new(OnceLock::new());

        thread::spawn({
            let player_state = player_state.clone();
            let progress = progress.clone();
            move || loop {
                if let Ok(event) = receiver.recv() {
                    match event {
                        PlayerEvent::Play => {
                            update_player_state_stream(&player_state, PlayerStateEvent::Play)
                        }
                        PlayerEvent::Pause => {
                            update_player_state_stream(&player_state, PlayerStateEvent::Pause)
                        }
                        PlayerEvent::Stop => {
                            update_player_state_stream(&player_state, PlayerStateEvent::Stop)
                        }
                        PlayerEvent::PreloadPlayed => {
                            // update_player_state_stream(&player_state, PlayerStateEvent::Stop)
                        }
                        PlayerEvent::Progress(state) => update_progress_stream(&progress, state),
                    }
                }
            }
        });

        SyncReturn(Self {
            player: RustOpaque::new(player),
            _state: RustOpaque::new(player_state),
            _progress: RustOpaque::new(progress),
        })
    }

    pub fn play(&self) {
        self.player.play();
    }

    pub fn pause(&self) {
        self.player.pause();
    }

    pub fn open_file(&self, path: String) -> anyhow::Result<()> {
        self.player.open_file(path, false)
    }

    pub fn set_volume(&self, volume: f32) {
        self.player.set_volume(volume);
    }

    pub fn stop(&self) {
        self.player.stop();
    }

    pub fn seek(&self, position: u64) {
        self.player.seek(position);
    }

    pub fn is_playing(&self) -> SyncReturn<bool> {
        SyncReturn(self.player.is_playing())
    }

    pub fn player_state_stream(&self, stream: StreamSink<PlayerStateEvent>) {
        *self
            ._state
            .get_or_init(|| RwLock::new(None))
            .write()
            .unwrap() = Some(stream);
    }

    pub fn progress_stream(&self, stream: StreamSink<ProgressState>) {
        *self
            ._progress
            .get_or_init(|| RwLock::new(None))
            .write()
            .unwrap() = Some(stream);
    }
}
