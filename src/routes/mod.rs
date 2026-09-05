//! src/routes/mod.rs
pub(crate) mod health_check;
mod newsletter;
pub(crate) mod subscriptions;
mod subscriptions_confirm;

pub use health_check::*;
pub use newsletter::*;
pub use subscriptions::*;
pub use subscriptions_confirm::*;
