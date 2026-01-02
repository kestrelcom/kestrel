# Kestrel

A Tauri v2 application with React/TypeScript frontend, Rust backend, and Python ML integration.

## Project Structure

```
kestrel/
├── frontend/          # React + TypeScript + Vite
├── src-tauri/         # Rust backend (Tauri commands, macOS filesystem ops)
└── ai-layer/          # Python ML/processing module
```

## Setup

### Prerequisites

- Node.js (v18+)
- Rust (latest stable)
- Python (3.8+)
- macOS (for macOS-specific features)

### Installation

1. **Install frontend dependencies:**
   ```bash
   cd frontend
   npm install
   ```

2. **Install Python module:**
   ```bash
   cd ai-layer
   pip install -e .
   ```

3. **Run the app:**
   ```bash
   npm run dev
   ```

## Development

- `npm run dev` - Run Tauri app in development mode
- `npm run build` - Build production app
- `npm run frontend:dev` - Run frontend only
- `npm run frontend:build` - Build frontend only

## Architecture

- **Frontend**: React/TypeScript UI with Vite bundler
- **Rust Backend**: Tauri commands for macOS filesystem operations
- **AI Layer**: Python ML/processing layer (can be called from Rust via subprocess or FFI)



The Open Source AI Notetaker
