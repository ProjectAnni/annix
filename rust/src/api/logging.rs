use std::collections::HashMap;

use flutter_rust_bridge::frb;
use once_cell::sync::OnceCell;
use rusqlite::Connection;
use tracing::level_filters::LevelFilter;
pub use tracing_subscriber_sqlite::LogEntry;
use tracing_subscriber_sqlite::LogHandle;

static LOGGER: OnceCell<LogHandle> = OnceCell::new();

#[frb(sync)]
pub fn init_logger(path: String) {
    LOGGER.get_or_init(|| {
        let conn = Connection::open(path).unwrap();

        let subscriber = tracing_subscriber_sqlite::SubscriberBuilder::new()
            .with_max_level(LevelFilter::DEBUG)
            .with_black_list(["h2"])
            .build_prepared(conn)
            .unwrap();

        let logger = subscriber.log_handle();
        tracing::subscriber::set_global_default(subscriber).unwrap();

        tracing_log::LogTracer::init().unwrap();

        logger
    });
}

#[derive(Debug)]
#[frb(mirror(LogEntry))]
pub struct _LogEntry {
    pub time: String,
    pub level: String,
    pub module: Option<String>,
    pub file: Option<String>,
    pub line: Option<i32>,
    pub message: String,
    pub structured: String,
}

pub fn read_logs() -> anyhow::Result<Vec<LogEntry>> {
    let handle = LOGGER
        .get()
        .ok_or_else(|| anyhow::anyhow!("Logger not initialized"))?;
    let logs = handle.read_logs_v0()?;
    Ok(logs)
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

    logger.log_v0(
        &level,
        module.as_deref(),
        file.as_deref(),
        line,
        &message,
        kvs,
    );
    Ok(())
}
