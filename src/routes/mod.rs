//! src/routes/mod.rs
pub(crate) mod health_check;
pub(crate) mod subscriptions;
mod subscriptions_confirm;
mod newsletter;

pub use health_check::*;
pub use subscriptions::*;
pub use subscriptions_confirm::*;
pub use newsletter::*;
