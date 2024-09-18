pub use anni_repo::{db::RepoDatabaseRead, prelude::JsonAlbum};
use flutter_rust_bridge::frb;
use material_colors::image::{FilterType, ImageReader};
pub use once_cell::sync::Lazy;
pub use rusqlite::Connection;
pub use uuid::Uuid;

pub use std::sync::Arc;
pub use std::sync::{OnceLock, RwLock};
pub use std::{path::PathBuf, sync::Mutex};

use crate::frb_generated::RustOpaque;

// pub use super::player::{PlayerStateEvent, ProgressState};

/// Preferences
pub struct NativePreferenceStore {
    pub conn: RustOpaque<Mutex<Connection>>,
}

impl NativePreferenceStore {
    #[frb(sync)]
    pub fn new(root: String) -> NativePreferenceStore {
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
        Self { conn }
    }

    #[frb(sync)]
    pub fn get(&self, key: String) -> Option<String> {
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

        result
    }

    #[frb(sync)]
    pub fn set(&self, key: String, value: String) {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "INSERT INTO preferences (key, value) VALUES (?, ?)",
                rusqlite::params![key, value],
            )
            .unwrap();
    }

    #[frb(sync)]
    pub fn remove(&self, key: String) {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "DELETE FROM preferences WHERE key = ?",
                rusqlite::params![key],
            )
            .unwrap();
    }

    #[frb(sync)]
    pub fn remove_prefix(&self, prefix: String) {
        self.conn
            .lock()
            .unwrap()
            .execute(
                "DELETE FROM preferences WHERE key LIKE ?",
                rusqlite::params![format!("{}%", prefix)],
            )
            .unwrap();
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

pub struct LocalStore {
    pub conn: RustOpaque<Mutex<Connection>>,
}

impl LocalStore {
    #[frb(sync)]
    pub fn new(root: String) -> LocalStore {
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
        Self { conn }
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

/// Color
pub fn get_theme_color(path: String) -> u32 {
    let mut data = ImageReader::open(path).expect("failed to read image");
    data.resize(128, 128, FilterType::Lanczos3);
    let color = ImageReader::extract_color(&data);

    // alpha: ((value >> 24) & 0xFF) as u8,
    // red: ((value >> 16) & 0xFF) as u8,
    // green: ((value >> 8) & 0xFF) as u8,
    // blue: ((value) & 0xFF) as u8,
    (color.alpha as u32) << 24
        | (color.red as u32) << 16
        | (color.green as u32) << 8
        | (color.blue as u32)
}
