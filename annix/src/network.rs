use std::sync::RwLock;

use once_cell::sync::Lazy;

pub enum NetworkStatus {
    Online,
    Offline,
}

impl NetworkStatus {
    pub fn is_online(&self) -> bool {
        match self {
            NetworkStatus::Online => true,
            NetworkStatus::Offline => false,
        }
    }
}

pub static NETWORK: Lazy<RwLock<NetworkStatus>> = Lazy::new(|| RwLock::new(NetworkStatus::Offline));
