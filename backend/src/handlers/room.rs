use axum::{
    debug_handler,
    extract::{Query, State},
    response::IntoResponse,
};
use hyper::StatusCode;
use serde::Deserialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::{db::user_deco::UserDeco, utils::sqlx::get_pg_tx, AppState};

#[derive(Deserialize, Clone, Debug)]
pub struct GetRoomParams {
    user_id: Uuid,
    year: i32,
    month: u32,
}

pub struct GetRoomResponse(Vec<UserDeco>);
impl IntoResponse for GetRoomResponse {
    fn into_response(self) -> axum::response::Response {
        let user_decos = self.0;
        let serialized = serde_json::to_string(&user_decos);

        match serialized {
            Ok(serialized) => (StatusCode::OK, serialized).into_response(),
            Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response(),
        }
    }
}

#[debug_handler(state = AppState)]
pub async fn get_room(
    State(pool): State<PgPool>,
    Query(params): Query<GetRoomParams>,
) -> axum::response::Result<GetRoomResponse> {
    let mut tx = get_pg_tx(pool).await?;
    let user_decos = crate::db::user_deco::get_user_deco_of_month(
        &mut tx,
        params.user_id,
        params.year,
        params.month,
    )
    .await;
    match user_decos {
        Ok(user_decos) => Ok(GetRoomResponse(user_decos)),
        Err(e) => Err(e.to_string().into()),
    }
}
