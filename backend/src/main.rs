use axum::{routing::get, Router};
use recordiary::handlers::health::healthcheck;

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(healthcheck))
        .route("/calendar", get(|| async { "Calendar" }));

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
