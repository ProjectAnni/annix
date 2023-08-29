pub use anni_repo::{db::RepoDatabaseRead, prelude::JsonAlbum};
pub use flutter_rust_bridge::{RustOpaque, SyncReturn};
use once_cell::sync::Lazy;
pub use rusqlite::Connection;
pub use uuid::Uuid;

use std::sync::RwLock;
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
use crate::dummy;

dummy!(Dummy1);

pub struct NativePreferenceStore {
    pub conn: RustOpaque<Mutex<Dummy1<Connection>>>,
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

        let conn = RustOpaque::new(Mutex::new(Dummy1(conn)));
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
