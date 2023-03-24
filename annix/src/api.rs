pub use anni_repo::{db::RepoDatabaseRead, prelude::JsonAlbum};
pub use flutter_rust_bridge::RustOpaque;
pub use rusqlite::Connection;
pub use std::sync::Mutex;
pub use uuid::Uuid;

use std::path::PathBuf;

pub struct LocalStore {
    pub conn: RustOpaque<Mutex<Connection>>,
}

impl LocalStore {
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
)"#,
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
