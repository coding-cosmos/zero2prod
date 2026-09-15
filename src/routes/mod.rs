//! src/routes/mod.rs
pub(crate) mod health_check;
mod newsletter;
pub(crate) mod subscriptions;
mod subscriptions_confirm;
mod home;
mod login;

pub use health_check::*;
pub use newsletter::*;
pub use subscriptions::*;
pub use subscriptions_confirm::*;
pub use home::*;
pub use login::*;