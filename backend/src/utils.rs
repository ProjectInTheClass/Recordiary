use uuid::Uuid;

pub mod coordinates;
pub mod internal_error;
pub mod parse_multipart;
pub mod sqlx;

pub fn get_diary_filename(user_id: Uuid, diary_id: i64) -> String {
    // TODO: check file extension?
    user_id.to_string() + "_" + &diary_id.to_string() + ".mp3"
}
