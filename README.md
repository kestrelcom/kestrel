# Kestrel

**Local-first AI meeting notes with evidence-backed summaries.**

Kestrel records meetings locally, generates timestamped transcripts, and produces summaries where every point links back to the source. No meeting bots. No black box memory.

---

## What this project is (MVP)

Kestrel is an **open-source desktop app** that helps you trust AI meeting notes by always showing *why* something was summarized.

The MVP focuses on **three core features only**:

1. Transcription
2. Evidence-backed summarization
3. Manual bookmarks

Anything beyond that is explicitly out of scope for now.

---

## Core Features (MVP)

### 1. Transcription

**Summary**
Record meetings locally and produce a clean, timestamped transcript without joining the call.

**Behavior**

* User starts the app before the meeting
* App records audio from the device
* Generates a timestamped transcript
* No speaker detection in MVP

**Why it matters**

* Acts as the source of truth
* Enables evidence-backed summaries
* Keeps everything local and private

---

### 2. Evidence-Backed Summarization

**Summary**
AI summaries that show their work.

**Behavior**

* Generate a short summary after the meeting
* Every summary line links to one or more transcript timestamps
* No speculation or invented facts
* If confidence is low, summarize less

**Why it matters**

* Reduces hallucinations
* Builds trust in AI output
* Makes summaries usable for real work

---

### 3. Manual Bookmarks

**Summary**
A lightweight way for users to mark important moments during a meeting.

**Behavior**

* Global hotkey to bookmark the current timestamp
* Optional short note
* Bookmarks appear in the transcript and summary view

**Why it matters**

* Captures user intent the AI might miss
* Prevents interrupting the meeting
* Improves post-meeting review

---

## Explicit Non-Goals (for MVP)

* No speaker diarization
* No cross-meeting memory
* No profiles or role-based context
* No real-time suggestions
* No cloud sync or accounts

These are future ideas and intentionally not part of the MVP.

---

## Tech Stack

**App / UI**

* Tauri v2
* React + TypeScript
* Tailwind (or simple CSS)

**Core / OS Layer**

* Rust

  * audio capture (mic; system audio later)
  * global hotkeys
  * file I/O
  * recording state

**ML / AI Layer**

* Python

  * transcription (Whisper / faster-whisper)
  * summarization
* Called from Rust via subprocess or local service

**Storage**

* Local file-based (no database)

  * `audio.wav`
  * `transcript.md`
  * `summary.json`
  * `bookmarks.json`

---

## Project Structure

```
kestrel/
├── frontend/      # React + TypeScript + Vite
├── src-tauri/     # Rust backend (Tauri commands, OS integration)
└── ai-layer/      # Python ML layer
```

---

## Setup

### Prerequisites

* Node.js (v18+)
* Rust (latest stable)
* Python (3.8+)
* macOS (for macOS-specific features)

### Installation

**1. Install frontend dependencies:**

```bash
cd frontend
npm install
cd ..
```

**2. Set up Python virtual environment:**

```bash
cd ai-layer
python3 -m venv .venv
source .venv/bin/activate  # On macOS/Linux
# On Windows: .venv\Scripts\activate
pip install --upgrade pip setuptools wheel
pip install -e .
cd ..
```

**3. Run the app:**

```bash
npm run dev
```

**Note:** For Rust, Cargo automatically manages dependencies per project (no virtual environment needed). The `target/` directory is like `node_modules` for Rust and is already ignored in `.gitignore`.

---

## Open Source

* MIT or Apache-2.0 license
* Early-stage project
* Contributions welcome after MVP stabilizes
