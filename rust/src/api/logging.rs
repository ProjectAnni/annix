use std::{collections::HashMap, str::FromStr};

use flutter_rust_bridge::frb;
use once_cell::sync::OnceCell;
use rusqlite::Connection;
use time::OffsetDateTime;
use tracing::{level_filters::LevelFilter, Level};
use tracing_subscriber_sqlite::{prepare_database, LogHandle};
pub use tracing_subscriber_sqlite::{Connect, LogEntry as TracingLogEntry};

static LOGGER: OnceCell<LogHandle> = OnceCell::new();

#[frb(sync)]
pub fn init_logger(path: String) {
    LOGGER.get_or_init(|| {
        let conn = Connection::open(path).unwrap();
        prepare_database(&conn).unwrap();

        let logger = LogHandle::new(conn);
        let subscriber = tracing_subscriber_sqlite::SubscriberBuilder::new()
            .with_max_level(LevelFilter::DEBUG)
            .with_black_list(["h2"])
            .build_layer(logger.clone())
            .to_subscriber();

        tracing::subscriber::set_global_default(subscriber).unwrap();

        tracing_log::LogTracer::init().unwrap();

        logger
    });
}

#[derive(Debug)]
pub struct LogEntry {
    pub time: String,
    pub level: String,
    pub module: Option<String>,
    pub file: Option<String>,
    pub line: Option<u32>,
    pub message: String,
    pub structured: HashMap<String, String>,
}

pub fn read_logs() -> anyhow::Result<Vec<LogEntry>> {
    let handle = LOGGER
        .get()
        .ok_or_else(|| anyhow::anyhow!("Logger not initialized"))?;
    let logs = handle.read_logs()?;
    Ok(logs
        .into_iter()
        .map(|l| LogEntry {
            time: l.time.to_string(),
            level: l.level.to_string(),
            module: l.module,
            file: l.file,
            line: l.line,
            message: l.message,
            structured: l.structured,
        })
        .collect())
}

#[frb(sync)]
pub fn log_native(
    level: String,
    module: Option<String>,
    file: Option<String>,
    line: Option<u32>,
    message: String,
    exception: Option<String>,
    stacktace: Option<String>,
) -> anyhow::Result<()> {
    let logger = LOGGER
        .get()
        .ok_or_else(|| anyhow::anyhow!("Logger not initialized"))?;

    let mut kvs = HashMap::new();
    if let Some(exception) = exception {
        kvs.insert("exception", exception);
    }
    if let Some(stacktace) = stacktace {
        kvs.insert("stacktace", stacktace);
    }

    logger.log(TracingLogEntry {
        time: OffsetDateTime::now_utc(),
        level: Level::from_str(&level).unwrap(),
        module: module.as_deref(),
        file: file.as_deref(),
        line,
        message,
        structured: kvs,
    });
    Ok(())
}
