use reqwest::{Client, Error as ReqwestError};

#[derive(Debug, Clone)]
pub struct SupabaseClient {
    supabase_url: String,
    api_key: String,
    client: Client,
    audio_bucket: String,
}

impl SupabaseClient {
    pub fn new(supabase_url: String, api_key: String, audio_bucket: String) -> Self {
        // TODO: proper auth initialization
        Self {
            supabase_url,
            api_key,
            client: Client::new(),
            audio_bucket,
        }
    }

    pub async fn download(
        &self,
        bucket: String,
        filename: String,
    ) -> Result<Vec<u8>, ReqwestError> {
        let url: String = format!(
            "{}/storage/v1/object/public/{}/{}",
            self.supabase_url, bucket, filename
        );
        let resp = self.client.get(&url).send().await?;

        Ok(resp.bytes().await?.to_vec())
    }

    pub async fn upload_diary(
        &self,
        audio: Vec<u8>,
        filename: String,
    ) -> Result<String, ReqwestError> {
        self.upload(self.audio_bucket.clone(), filename.clone(), audio)
            .await?;
        self.get_presigned_download_url(self.audio_bucket.clone(), filename)
            .await
    }

    pub async fn upload(
        &self,
        bucket: String,
        filename: String,
        file: Vec<u8>,
    ) -> Result<(), ReqwestError> {
        let url: String = format!(
            "{}/storage/v1/object/{}/{}",
            self.supabase_url, bucket, filename
        );

        let resp = self
            .client
            .post(&url)
            .header("apikey", &self.api_key)
            .header("authorization", &format!("Bearer {}", &self.api_key))
            .body(file)
            .send()
            .await?;

        match resp {
            r if r.status().is_success() => Ok(()),
            r => {
                tracing::error!("Error uploading file: {:?}", r);
                Err(r.error_for_status().unwrap_err())
            }
        }
    }
    pub async fn get_presigned_download_url(
        &self,
        bucket: String,
        filename: String,
    ) -> Result<String, ReqwestError> {
        let url = format!(
            "{}/storage/v1/object/sign/{}/{}",
            self.supabase_url, bucket, filename
        );

        let resp = self
            .client
            .post(&url)
            .header("apikey", &self.api_key)
            .header("authorization", &format!("Bearer {}", &self.api_key))
            .body(
                "{
        \"expiresIn\": 7776000        
    }",
            ) // 90 days
            .send()
            .await?;

        let json = resp.json::<serde_json::Value>().await?;
        Ok(json["signedURL"].as_str().unwrap().to_string())
    }
}
