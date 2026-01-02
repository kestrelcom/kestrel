# AI Notetaker (macOS) — 4-Week MVP Sprint Plan

Target: MVP in 4 weeks (1 month)  
Stack: Tauri v2 + React + TypeScript + Rust  
AI: OpenAI Realtime (transcription) + post-meeting API calls (summary/action)

## MVP Scope (must ship)

By end of Week 4, the app can:

- Run in the background on macOS
- Capture **system loopback audio**
- Produce **sentence-level transcript segments** with timestamps
- Support **Start/End meeting**
- Support **multi-profile selection per meeting**
- Support **include_in_memory** toggle (binary)
- Global hotkey opens a **note panel** for a **bookmark note**
- Bookmarks are anchored to time and appear inline in transcript
- Post-meeting **summary + action items**
- Every summary/action item includes **timestamp citations** that jump to transcript
- All data saved **locally**
- Local embeddings stored for memories (only if include_in_memory = true)

## Explicitly Out of Scope (MVP)

- Speaker diarization
- Live summaries during meeting
- Cloud sync / accounts / team sharing
- Full-text or vector search UI (store embeddings only)
- Heavy UI polish

## Key Technical Decisions (Week 1, Day 1)

1. Loopback strategy (macOS):
   - Option A: ScreenCaptureKit-based audio capture (preferred if feasible)
   - Option B: Virtual audio device (more setup, harder UX)
2. Timestamp approach:
   - Monotonic clock for internal timing; store relative `start_ms` per meeting
3. Storage:
   - SQLite for structured data (recommended)
   - Optional raw transcript JSONL for debugging only

## Repo Structure (suggested)

- `src/` (React/TS UI)
- `src-tauri/` (Rust)
- `src-tauri/migrations/` (SQLite schema)
- `docs/` (prompts, API contracts)

## Data Model (MVP)

### Tables (SQLite)
- `meetings(id, started_at, ended_at, include_in_memory)`
- `profiles(id, name)`
- `meeting_profiles(meeting_id, profile_id)` (many-to-many)
- `transcript_segments(
    id,
    meeting_id,
    start_ms,
    end_ms,
    text
  )`
- `bookmarks(
    id,
    meeting_id,
    timestamp_ms,
    note_text,
    nearest_segment_id
  )`
- `summary_items(
    id,
    meeting_id,
    type,            -- "summary" | "action_item"
    text
  )`
- `summary_citations(
    summary_item_id,
    segment_id,
    start_ms
  )`
- `embeddings(
    id,
    profile_id,
    meeting_id,
    source_type,     -- "summary" | "action_item" | "bookmark"
    source_id,
    vector_blob
  )`

## IPC/Event Contracts (Rust -> UI)

Events:
- `meeting_started { meeting_id }`
- `meeting_ended { meeting_id }`
- `transcript_segment {
    meeting_id,
    segment_id,
    start_ms,
    end_ms,
    text
  }`
- `bookmark_created {
    meeting_id,
    bookmark_id,
    timestamp_ms,
    note_text,
    nearest_segment_id
  }`

Commands (UI -> Rust):
- `start_meeting { profile_ids[], include_in_memory } -> meeting_id`
- `end_meeting { meeting_id }`
- `create_bookmark { meeting_id, timestamp_ms, note_text } -> bookmark_id`
- `request_post_meeting_summary { meeting_id }`

## Definition of Done (applies to every sprint)

- Works on macOS reliably for >= 30 minutes
- No data loss on app restart
- Errors are handled (no silent failure)
- Minimal logs exist for debugging

---

# Sprint Plan (4 Weeks)

## Week 1 — Foundations (Audio + Infra)

### Sprint 1.1 (Days 1–2): App Skeleton + IPC
Deliverables:
- Tauri v2 app boots
- Rust backend wired to UI (IPC test event)

Work:
- [ ] Create Tauri v2 + React + TS project
- [ ] Add a basic main window + tray/background mode behavior
- [ ] Implement IPC “ping” command and event bus
- [ ] Add basic logging (Rust + TS)

Acceptance Criteria:
- App launches, can send/receive a test event reliably
- Can run “headless” with UI minimized/closed (as planned)

Dependencies:
- Tauri v2 setup
- Decide minimal background behavior for MVP

---

### Sprint 1.2 (Days 3–5): System Loopback Audio Capture
Deliverables:
- System audio capture working (loopback)
- Audio chunking + timestamps

Work:
- [ ] Implement loopback capture (ScreenCaptureKit or selected approach)
- [ ] Normalize audio to 16kHz mono PCM
- [ ] Emit audio chunk events with timestamps
- [ ] Save a short raw audio file for verification (debug build)

Acceptance Criteria:
- Play system audio (e.g., YouTube) and confirm captured waveform exists
- Timestamps monotonic and consistent

Risk Notes:
- This is the hardest part. If loopback blocks you, MVP slips.

---

### Sprint 1.3 (Days 6–7): SQLite Storage + Meeting State
Deliverables:
- SQLite initialized with schema
- Meeting start/end writes
- Transcript segment writes (even if mocked)

Work:
- [ ] Create migrations
- [ ] Implement atomic insert paths
- [ ] Implement meeting state machine in Rust
- [ ] Add recovery behavior on restart

Acceptance Criteria:
- Start meeting creates row
- End meeting updates row
- Restart app: DB remains valid, no corruption

---

## Week 2 — Realtime Transcription + Basic UI

### Sprint 2.1 (Days 8–10): Realtime Transcription Wiring
Deliverables:
- Audio streamed to OpenAI Realtime API
- Sentence-level transcript segments received and stored

Work:
- [ ] Create Realtime session + stream audio chunks
- [ ] Parse transcript segment events
- [ ] Store `transcript_segments` with `start_ms/end_ms/text`
- [ ] Emit `transcript_segment` events to UI

Acceptance Criteria:
- Speak/play audio and see segments appear within seconds
- Segments persist in DB and reload correctly

Dependencies:
- Stable loopback capture from Week 1

---

### Sprint 2.2 (Days 11–12): Transcript UI (Functional)
Deliverables:
- Transcript view renders segments
- Timestamp display and jump-to-segment

Work:
- [ ] Transcript list component
- [ ] Auto-scroll toggle (on/off)
- [ ] Click timestamp -> scroll to segment

Acceptance Criteria:
- During meeting, text visibly streams in
- Clicking a timestamp moves focus to the correct segment

---

### Sprint 2.3 (Days 13–14): Meeting Setup (Profiles + Memory Toggle)
Deliverables:
- Pre-meeting modal:
  - Multi-select profiles
  - include_in_memory toggle
- Start/End meeting buttons

Work:
- [ ] Profiles CRUD minimal (seed profiles for MVP if needed)
- [ ] Meeting creation flow persists selected profiles
- [ ] Include/exclude flag stored per meeting

Acceptance Criteria:
- Meeting can be started with multiple profiles
- Meeting row links to profiles via join table
- include_in_memory stored correctly

---

## Week 3 — Bookmarks + Reliability

### Sprint 3.1 (Days 15–17): Global Hotkey + Bookmark Note Panel
Deliverables:
- Global hotkey works while app unfocused
- Lightweight panel appears to type note
- Bookmark saved with timestamp

Work:
- [ ] Register global hotkey in Rust/Tauri plugin
- [ ] Capture current meeting-relative timestamp on press
- [ ] Open small always-on-top Tauri window for input
- [ ] Create bookmark record in DB

Acceptance Criteria:
- Hotkey works while in other apps
- Note is saved and visible immediately

---

### Sprint 3.2 (Days 18–19): Bookmark ↔ Transcript Linking
Deliverables:
- Bookmark displays inline
- Bookmark anchored to nearest transcript segment

Work:
- [ ] Find nearest segment by `timestamp_ms`
- [ ] Store `nearest_segment_id`
- [ ] Render bookmark markers inline in transcript UI
- [ ] Click bookmark -> jump to transcript around it

Acceptance Criteria:
- Bookmark appears at roughly correct location in transcript
- Clicking bookmark jumps to the intended context

---

### Sprint 3.3 (Days 20–21): Reliability + Data Integrity Pass
Deliverables:
- Long meeting stability
- Restart recovery

Work:
- [ ] Handle API disconnect/reconnect
- [ ] Ensure transcript writes are append-safe
- [ ] Ensure meeting end closes resources cleanly
- [ ] Add error surfaces in UI (not silent logs only)

Acceptance Criteria:
- 30–60 min run without crash
- Restart app: previous meeting transcript intact

---

## Week 4 — Post-Meeting Summaries + Local Memory

### Sprint 4.1 (Days 22–24): Grounded Summary + Action Items
Deliverables:
- Generate post-meeting summary + action items
- Every bullet has citation(s) to transcript segments

Work:
- [ ] Build transcript payload (segment IDs + text + timestamps)
- [ ] Prompt template that enforces citations
- [ ] Parse structured output into DB tables
- [ ] UI: show summary + action items with clickable citations

Acceptance Criteria:
- Clicking a citation jumps to the correct transcript segment
- If model can’t cite, it omits rather than invents

---

### Sprint 4.2 (Days 25–26): Local Embeddings (Write-Only MVP)
Deliverables:
- Embeddings stored locally per profile
- Only created if include_in_memory = true

Work:
- [ ] Choose local embedding model/runtime
- [ ] Embed:
  - Summary items
  - Action items
  - Bookmark notes
- [ ] Store vectors in `embeddings` table keyed by profile_id

Acceptance Criteria:
- Meetings with include_in_memory=false create no embeddings
- Meetings with include_in_memory=true store embeddings for each selected profile

Note:
- No search UI required for MVP, only storage.

---

### Sprint 4.3 (Days 27–30): Polish for Demo + Release Build
Deliverables:
- Demo-ready MVP build
- Minimal onboarding and UX cleanup

Work:
- [ ] Settings: API key input and validation
- [ ] Basic status indicators (recording, connected, error)
- [ ] Packaging + signing considerations (as needed)
- [ ] Minimal docs: hotkey, start/end meeting, where files live
- [ ] Bug fixes only (no new features)

Acceptance Criteria:
- A fresh install can run and complete a meeting end-to-end
- No obvious “dead ends” in UX

---

# Daily Operating Rules (to hit 1-month MVP)

- Do not add features mid-sprint.
- If loopback capture is unstable by Day 5, pivot immediately to a fallback.
- Always keep an end-to-end “happy path” working.
- Track time: audio + hotkeys + stability are your real risks.

# Checklist: What You Need Before You Start

- [ ] Decision: loopback capture approach (ScreenCaptureKit vs virtual device)
- [ ] OpenAI API key + chosen Realtime endpoint details
- [ ] Basic UX flow (start -> run -> bookmark -> end -> summary)
- [ ] SQLite schema migrated and tested
- [ ] Global hotkey chosen (avoid collisions)
