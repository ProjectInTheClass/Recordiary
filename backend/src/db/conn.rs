use std::time::Duration;

use sqlx::postgres::{PgConnectOptions, PgPoolOptions};

pub async fn initialize_conn_pool() {
    let db_connection_str = std::env::var("DB_CONNECTION_URI")
        .unwrap_or_else(|_| "postgres://postgres:password@localhost".to_string());

    // setup connection pool
    PgPoolOptions::new()
        .max_connections(5)
        .acquire_timeout(Duration::from_secs(3))
        .connect(&db_connection_str)
        .await
        .expect("can't connect to database");
}
