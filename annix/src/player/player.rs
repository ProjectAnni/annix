use std::{ops::Deref, sync::mpsc::Receiver, thread};

use anni_playback::{types::PlayerEvent, Controls, Decoder};

pub struct Player {
    controls: Controls,
}

impl Player {
    pub fn new() -> (Player, Receiver<PlayerEvent>) {
        let (sender, receiver) = std::sync::mpsc::channel();
        let controls = Controls::new(sender);
        let thread_killer = crossbeam::channel::unbounded();

        thread::spawn({
            let controls = controls.clone();
            move || {
                let decoder = Decoder::new(controls, thread_killer.1.clone());
                decoder.start();
            }
        });

        (Player { controls }, receiver)
    }
}

impl Deref for Player {
    type Target = Controls;

    fn deref(&self) -> &Self::Target {
        &self.controls
    }
}
