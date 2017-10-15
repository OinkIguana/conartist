//! Exposes the v1 (REST) API.

mod auth;

use mount::Mount;

pub fn new() -> Mount {
    let mut mount = Mount::new();
    mount.mount("/auth", auth::new());
    mount
}
