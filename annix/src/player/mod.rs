pub mod player;
pub mod playlist;

pub enum PlayerStateEvent {
    /// Started playing
    Play,
    /// Paused
    Pause,
    /// Stopped playing
    Stop,
}
