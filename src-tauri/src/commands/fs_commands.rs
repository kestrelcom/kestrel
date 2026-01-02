use tauri::command;

#[command]
pub fn create_folder(path: String) -> Result<String, String> {
    Ok(format!("Folder created: {}", path))
}

#[command]
pub fn create_file(path: String) -> Result<String, String> {
    Ok(format!("File created: {}", path))
}

