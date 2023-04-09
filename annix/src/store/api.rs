pub use std::{path::PathBuf, sync::Mutex};

pub use flutter_rust_bridge::{RustOpaque, SyncReturn};
pub use rusqlite::Connection;

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
