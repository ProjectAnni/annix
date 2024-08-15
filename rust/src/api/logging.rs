use flutter_rust_bridge::frb;
use rusqlite::Connection;
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
