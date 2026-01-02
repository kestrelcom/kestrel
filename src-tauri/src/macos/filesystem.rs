use std::fs;
use std::path::Path;

pub fn create_directory(path: &str) -> Result<(), std::io::Error> {
    fs::create_dir_all(path)
}

pub fn create_file(path: &str) -> Result<(), std::io::Error> {
    let path = Path::new(path);
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::File::create(path)?;
    Ok(())
}

