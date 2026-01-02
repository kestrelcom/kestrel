# AI Notetaker (macOS) — MVP Sprint Plan (Adjusted)

Timeline: 4 weeks (1 month)  
Target: Functional MVP  
Platform: macOS (background app)

Stack:
- Tauri v2
- React + TypeScript
- Rust (audio, hotkeys, persistence)
- SQLite (local-first)
- OpenAI Realtime API (transcription)
- OpenAI API (post-meeting summaries)

---

## MVP DEFINITION (LOCKED)

By the end of Week 4, the app must:

- Run in the background on macOS
- Capture **system loopback audio**
- Capture **microphone audio separately**
- Perform **realtime transcription**
- Produce **sentence-level transcript segments** with timestamps
- Support **basic diarization:**
  - Speaker = `you` (microphone)
  - Speaker = `others` (system audio)
- Allow **Start / End meeting**
- Allow **multiple profiles per meeting**
- Respect **include_in_memory** (yes/no)
- Support **global hotkey** to create a **bookmark note**
- Show bookmarks inline in transcript
- Generate **post-meeting summary + action items**
- Every summary/action item includes **timestamp citations**
- Support **keyword search across meetings**
- Store all data **locally**
- Store embeddings locally (write-only MVP)

---

## NOT MVP (POST-MVP)

- True multi-speaker diarization (Speaker A/B/C)
- Speaker naming
- Semantic search UI
- RAG-based Q&A over meetings
- Cloud sync
- Collaboration
- Live summaries

These are planned later.

---

## CORE TECHNICAL DECISIONS

1. Audio Sources
   - System loopback audio
   - Microphone audio captured separately
   - Both streams timestamped and merged logically

2. Diarization Strategy (MVP)
   - Mic audio → speaker = `you`
   - System audio → speaker = `others`
   - No attempt to distinguish multiple remote speakers

3. Storage
   - SQLite for all structured data
   - Optional raw transcript JSONL for debugging

4. Search
   - SQLite FTS5 for keyword search (MVP)
   - Vector embeddings stored but not queried (MVP)

---

## DATABASE SCHEMA (MVP)

### meetings
- id
- started_at
- ended_at
- include_in_memory

### profiles
- id
- name

### meeting_profiles (many-to-many)
- meeting_id
- profile_id

### transcript_segments
- id
- meeting_id
- start_ms
- end_ms
- text
- speaker        -- "you" | "others"
- audio_source   -- "mic" | "system"

### bookmarks
- id
- meeting_id
- timestamp_ms
- note_text
- nearest_segment_id

### summary_items
- id
- meeting_id
- type            -- "summary" | "action_item"
- text

### summary_citations
- summary_item_id
- segment_id
- start_ms

### embeddings
- id
- profile_id
- meeting_id
- source_type     -- "summary" | "action_item" | "bookmark"
- source_id
- vector_blob

### fts_transcript (FTS5 virtual table)
- text
- meeting_id
- segment_id
- bookmark_id (nullable)

---

## IPC EVENTS (RUST → UI)

- meeting_started { meeting_id }
- meeting_ended { meeting_id }
- transcript_segment {
    meeting_id,
    segment_id,
    start_ms,
    end_ms,
    text,
    speaker
  }
- bookmark_created {
    meeting_id,
    bookmark_id,
    timestamp_ms,
    note_text,
    nearest_segment_id
  }

---

## COMMANDS (UI → RUST)

- start_meeting { profile_ids[], include_in_memory } → meeting_id
- end_meeting { meeting_id }
- create_bookmark { meeting_id, timestamp_ms, note_text }
- request_post_meeting_summary { meeting_id }

---

# SPRINT PLAN

## WEEK 1 — AUDIO + INFRASTRUCTURE

### Sprint 1.1 (Days 1–2): App Skeleton + IPC
Deliverables:
- Tauri v2 app boots
- Rust backend runs continuously
- IPC communication working

Tasks:
- Initialize Tauri v2 project
- Create Rust background process
- Add IPC ping command/event
- Basic logging setup

---

### Sprint 1.2 (Days 3–5): Dual Audio Capture
Deliverables:
- System loopback audio capture
- Microphone audio capture
- Timestamped audio chunks

Tasks:
- Implement system loopback capture
- Implement mic capture
- Normalize both to 16kHz mono PCM
- Tag audio source per chunk
- Save debug audio output

Acceptance:
- You can hear yourself labeled as mic
- Remote audio labeled as system

---

### Sprint 1.3 (Days 6–7): SQLite + Meeting State
Deliverables:
- SQLite schema migrated
- Meeting lifecycle implemented

Tasks:
- Create tables
- Implement meeting start/end
- Persist meeting metadata
- Recovery on app restart

---

## WEEK 2 — REALTIME TRANSCRIPTION + DIARIZATION

### Sprint 2.1 (Days 8–10): Realtime Transcription (Dual Stream)
Deliverables:
- Audio streamed to Realtime API
- Sentence-level transcript segments saved

Tasks:
- Stream mic + system audio
- Receive transcript segments
- Assign speaker:
  - mic → `you`
  - system → `others`
- Persist transcript segments
- Emit transcript events to UI

---

### Sprint 2.2 (Days 11–12): Transcript UI
Deliverables:
- Transcript rendered in real time
- Speaker labels visible

Tasks:
- Transcript list UI
- Speaker badges ("You", "Others")
- Auto-scroll toggle
- Timestamp jump

---

### Sprint 2.3 (Days 13–14): Meeting Setup UI
Deliverables:
- Pre-meeting configuration

Tasks:
- Profile multi-select
- include_in_memory toggle
- Start / End meeting UX

---

## WEEK 3 — BOOKMARKS + SEARCH

### Sprint 3.1 (Days 15–17): Global Hotkey + Bookmark Notes
Deliverables:
- Global hotkey works system-wide
- Floating note input panel

Tasks:
- Register global shortcut
- Capture meeting-relative timestamp
- Create bookmark with note text
- Persist bookmark

---

### Sprint 3.2 (Days 18–19): Bookmark Linking
Deliverables:
- Bookmarks inline in transcript

Tasks:
- Link bookmark to nearest transcript segment
- Render bookmark markers
- Click → jump to transcript context

---

### Sprint 3.3 (Days 20–21): Keyword Search (MVP)
Deliverables:
- Search across meetings by keyword

Tasks:
- Create FTS5 virtual table
- Index transcript text + bookmark notes
- Search UI (simple input + list)
- Result click jumps to transcript

---

## WEEK 4 — SUMMARIES + MEMORY

### Sprint 4.1 (Days 22–24): Grounded Summaries
Deliverables:
- Post-meeting summary + action items
- Timestamp citations

Tasks:
- Build transcript payload
- Prompt enforces citation requirement
- Parse structured output
- Render summary UI
- Click citation → transcript jump

---

### Sprint 4.2 (Days 25–26): Local Embeddings (Write-Only)
Deliverables:
- Embeddings stored per profile

Tasks:
- Generate embeddings for:
  - Summary items
  - Action items
  - Bookmark notes
- Store only if include_in_memory = true
- Associate embeddings with profiles

---

### Sprint 4.3 (Days 27–30): MVP Hardening
Deliverables:
- Demo-ready build

Tasks:
- Error handling
- API key input
- Status indicators (recording, error)
- Packaging and basic docs
- Bug fixes only

---

## POST-MVP ROADMAP (HIGH LEVEL)

1. True diarization (Speaker A/B/C)
   - Post-meeting processing
   - Speaker turn clustering
   - Speaker rename UX

2. Semantic search
   - Chunk-level embeddings
   - Vector similarity search
   - Hybrid FTS + vector reranking

3. RAG: Ask Your Meetings
   - Query → retrieve chunks
   - Answer with citations only
   - Profile-scoped context

---

## OPERATING RULES

- Audio stability > features
- No new features after Week 3
- If diarization causes instability, degrade gracefully to no speaker labels
- Always keep an end-to-end path working
