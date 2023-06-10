use lib_flutter_rust_bridge_codegen::{
    config_parse, frb_codegen_multi, get_symbols_if_no_duplicates, init_logger, RawOpts,
};

/// Path of input Rust code
const RUST_INPUT: &str = "src/api.rs";

fn main() {
    // init_logger("./logs/", true).unwrap();
    // println!("cargo:rerun-if-changed={RUST_INPUT}");

    // let raw_opts = RawOpts::try_parse_args_or_yaml().unwrap();
    // let configs = config_parse(raw_opts);
    // let all_symbols = get_symbols_if_no_duplicates(&configs).unwrap();

    // for config_index in 0..configs.len() {
    //     frb_codegen_multi(&configs, config_index, &all_symbols).unwrap();
    // }
}
