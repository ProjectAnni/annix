pub use flutter_rust_bridge::{RustOpaque, SyncReturn};
pub use rusqlite::Connection;
pub use std::{path::PathBuf, sync::Mutex};

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
