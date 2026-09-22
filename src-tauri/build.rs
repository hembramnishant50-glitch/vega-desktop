use std::fs;
use std::path::PathBuf;

fn main() {
    tauri_build::build();

    let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap_or_default();

    // Omarchy Linux only: copy libmpv-wrapper.so next to binary, system provides libmpv.so
    if target_os == "linux" {
        let out_dir = PathBuf::from(std::env::var("OUT_DIR").unwrap_or_default());
        // OUT_DIR is deep in target/debug/build/..., walk up to target/debug/
        if let Some(target_debug) = out_dir.ancestors().find(|p| {
            p.file_name()
                .map(|n| n == "debug" || n == "release")
                .unwrap_or(false)
        }) {
            let lib_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("lib");

            let libs = vec!["libmpv-wrapper.so"];

            for lib_name in libs {
                let src = lib_dir.join(lib_name);
                let dst = target_debug.join(lib_name);
                if src.exists()
                    && (!dst.exists()
                        || fs::metadata(&src).ok().map(|m| m.len())
                            != fs::metadata(&dst).ok().map(|m| m.len()))
                {
                    let _ = fs::copy(&src, &dst);
                    println!(
                        "cargo:warning=Copied {} to {}",
                        lib_name,
                        target_debug.display()
                    );
                }
            }
        }
    }
}
