use std::collections::HashMap;

use serde::Deserialize;

#[derive(Deserialize, Debug)]
pub struct PostgresTestResult {
    pub initialize: InitializeResult,
    #[serde(rename = "read-write")]
    pub read_write: HashMap<String, PgbenchResult>,
    #[serde(rename = "read-only")]
    pub read_only: HashMap<String, PgbenchResult>,
}
#[derive(Deserialize, Debug)]
pub struct InitializeResult {
    pub done_in: f64,
    pub drop_tables: f64,
    pub create_tables: f64,
    pub client_side_generate: f64,
    pub vacuum: f64,
    pub primary_keys: f64,
}
#[derive(Deserialize, Debug)]
pub struct PgbenchResult {
    pub scaling_factor: u32,
    pub number_of_clients: u32,
    pub number_of_threads: u32,
    pub number_of_transactions_per_client: u32,
    pub latency_average: f64,
    pub initial_connection_time: f64,
    pub tps: f64,
    pub time: f64,
}

#[derive(Debug, Deserialize)]
pub struct KafkaTestResult {
    pub measurements: u64,
    pub mean_latency: f64,
    pub p50_latency: u64,
    pub p90_latency: u64,
    pub p99_latency: u64,
}
