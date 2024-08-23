use flutter_rust_bridge::frb;
use rusqlite::Connection;
use rusqlite::Result;
use tracing::level_filters::LevelFilter;

#[frb(sync)]
pub fn init_logger(path: String) {
    let conn = Connection::open(path).unwrap();

    tracing_log::LogTracer::init().unwrap();
    tracing::subscriber::set_global_default(
        tracing_subscriber_sqlite::SubscriberBuilder::new()
            .with_max_level(LevelFilter::DEBUG)
            .with_black_list(["h2"])
            .build_prepared(conn)
            .unwrap(),
    )
    .unwrap();
}

#[derive(Debug)]
pub struct LogEntry {
    pub time: String,
    pub level: String,
    pub module: Option<String>,
    pub file: Option<String>,
    pub line: Option<i32>,
    pub message: String,
    pub structured: String,
}

pub fn read_logs(path: String) -> Result<Vec<LogEntry>> {
    let conn = Connection::open(path)?;

    let mut stmt = conn.prepare("SELECT * FROM logs_v0")?;
    let log_iter = stmt.query_map([], |row| {
        Ok(LogEntry {
            time: row.get(0)?,
            level: row.get(1)?,
            module: row.get(2)?,
            file: row.get(3)?,
            line: row.get(4)?,
            message: row.get(5)?,
            structured: row.get(6)?,
        })
    })?;

    let logs: Result<Vec<LogEntry>> = log_iter.collect();
    logs
}
