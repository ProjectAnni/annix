pub use anni_player::provider::AudioQuality;

use std::{
    sync::{Arc, Once, OnceLock, RwLock},
    thread,
};

use anni_playback::types::PlayerEvent;
use anni_player::{AnniPlayer, TypedPriorityProvider};
use flutter_rust_bridge::frb;

use crate::frb_generated::StreamSink;

pub enum PlayerStateEvent {
    /// Started playing
    Play,
    /// Paused
    Pause,
    /// Stopped playing
    Stop,
}

pub struct ProgressState {
    pub position: u32,
    pub duration: u32,
}

fn update_progress_stream(progress: &StreamWrapper<ProgressState>, state: ProgressState) {
    if let Some(stream) = progress.get() {
        let _ = stream.add(state);
    }
}

fn update_player_state_stream(
    player_state: &StreamWrapper<PlayerStateEvent>,
    state: PlayerStateEvent,
) {
    if let Some(stream) = player_state.get() {
        let _ = stream.add(state);
    }
}

pub type StreamWrapper<T> = Arc<OnceLock<StreamSink<T>>>;

#[frb(mirror(AudioQuality))]
pub enum _AudioQuality {
    Low,
    Medium,
    High,
    Lossless,
}

#[frb(opaque)]
pub struct AnnixPlayer {
    player: AnniPlayer,
    _state: StreamWrapper<PlayerStateEvent>,
    _progress: StreamWrapper<ProgressState>,
}

impl AnnixPlayer {
    #[frb(sync)]
    pub fn new(cache_path: String) -> AnnixPlayer {
        static LOGGER: Once = Once::new();

        LOGGER.call_once(|| env_logger::init());

        let (player, receiver) = AnniPlayer::new(TypedPriorityProvider::new(vec![]), cache_path.into());
        let progress = Arc::new(OnceLock::new());
        let player_state = Arc::new(OnceLock::new());

        thread::spawn({
            let player_state = (player_state.clone());
            let progress = (progress.clone());
            move || loop {
                if let Ok(event) = receiver.recv() {
                    match event {
                        PlayerEvent::Play => {
                            update_player_state_stream(&player_state, PlayerStateEvent::Play)
                        }
                        PlayerEvent::Pause => {
                            update_player_state_stream(&player_state, PlayerStateEvent::Pause)
                        }
                        PlayerEvent::Stop => {
                            update_player_state_stream(&player_state, PlayerStateEvent::Stop)
                        }
                        PlayerEvent::PreloadPlayed => {
                            // update_player_state_stream(&player_state, PlayerStateEvent::Stop)
                        }
                        PlayerEvent::Progress(state) => update_progress_stream(
                            &progress,
                            ProgressState {
                                position: state.position as u32,
                                duration: state.duration as u32,
                            },
                        ),
                    }
                }
            }
        });

        Self {
            player,
            _state: player_state,
            _progress: progress,
        }
    }

    pub fn play(&self) {
        self.player.play();
    }

    pub fn pause(&self) {
        self.player.pause();
    }

    pub fn open_file(&self, path: String) -> anyhow::Result<()> {
        self.player.open_file(path)
    }

    pub fn open(&self, identifier: String, quality: AudioQuality) -> anyhow::Result<()> {
        self.player.open(identifier.parse()?, quality)
    }

    pub fn set_track(&self, identifier: String, quality: AudioQuality) -> anyhow::Result<()> {
        self.player.load(identifier.parse()?, quality)
    }

    pub fn set_volume(&self, volume: f32) {
        self.player.set_volume(volume);
    }

    pub fn stop(&self) {
        self.player.stop();
    }

    pub fn seek(&self, position: u32) {
        self.player.seek(position as u64);
    }

    #[frb(sync)]
    pub fn is_playing(&self) -> bool {
        self.player.player.is_playing()
    }

    pub fn add_provider(&self, url: String, auth: String, priority: i32) {
        self.player.add_provider(url, auth, priority);
    }

    pub fn clear_provider(&self) {
        self.player.clear_provider();
    }

    pub fn player_state_stream(&self, stream: StreamSink<PlayerStateEvent>) {
        self._state.get_or_init(move || stream);
    }

    pub fn progress_stream(&self, stream: StreamSink<ProgressState>) {
        self._progress.get_or_init(move || stream);
    }
}
