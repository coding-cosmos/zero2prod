use secrecy::ExposeSecret;
use sqlx::{
    PgPool,
    postgres::{PgConnectOptions, PgSslMode},
};
use std::net::TcpListener;
use zero2prod::{
    configuration::get_configuration,
    startup::run,
    telemetry::{get_subscriber, init_subscriber},
};

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let subscriber = get_subscriber("zero2prod".into(), "info".into(), std::io::stdout);
    init_subscriber(subscriber);

    let configuration = get_configuration().expect("Failed to read the configuration");

    let database_options = PgConnectOptions::new()
        .host(&configuration.database.host)
        .port(configuration.database.port)
        .username(&configuration.database.username)
        .password(configuration.database.password.expose_secret())
        .database(&configuration.database.database_name)
        .ssl_mode(PgSslMode::Disable);

    let connection_pool = PgPool::connect_lazy_with(database_options);
    let address = format!(
        "{}:{}",
        configuration.application.host, configuration.application.port
    );
    let listener = TcpListener::bind(address)?;
    run(listener, connection_pool)?.await
}
