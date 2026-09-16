//! src/routes/mod.rs
mod admin;
pub(crate) mod health_check;
mod home;
mod login;
mod newsletter;
pub(crate) mod subscriptions;
mod subscriptions_confirm;

pub use admin::*;
pub use health_check::*;
pub use home::*;
pub use login::*;
pub use newsletter::*;
pub use subscriptions::*;
pub use subscriptions_confirm::*;
