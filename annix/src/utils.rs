#[macro_export]
macro_rules! dummy {
    ($name: ident) => {
        use std::ops::{Deref, DerefMut};

        pub struct $name<T>(T);

        impl<T> Deref for $name<T> {
            type Target = T;

            fn deref(&self) -> &Self::Target {
                &self.0
            }
        }

        impl<T> DerefMut for $name<T> {
            fn deref_mut(&mut self) -> &mut Self::Target {
                &mut self.0
            }
        }
    };
}
