---
name: antwork-clip
description: Use when the user wants to turn one long video (an episode, stream, podcast, webinar or their own footage) into several short vertical clips with burned-in captions and post each one to YouTube Shorts, TikTok, Instagram Reels and Facebook through Antwork. Trigger on "/antwork clip", "clip this video", "cut this into Shorts", "make Reels/TikToks from this episode", "find the best moments in this stream", "turn my podcast into shorts", or a long video file plus a request to post pieces of it. Runs locally with ffmpeg and, if installed, a local Whisper transcriber; plans the clips for approval before cutting, then drafts one post per clip with a version per network.
---

# Clip: one long video into captioned vertical Shorts

The cutting runs on the user's machine. The judgment is the job: finding the few moments that stand on their own and grab in the first two seconds, then writing each network's copy in that account's voice. Run the steps in order and stop where they say stop.

This needs a shell with the video file in reach (Claude Code, Codex, Cursor). Without one (claude.ai, ChatGPT), say this workflow needs a local coding agent; the user can still cut clips themselves and add each one at a draft's `mediaUrl`.

## Arguments

`/antwork clip <file or URL> [--clips N] [--length 15-60] [--accounts youtube,tiktok,...]`

- **No `--clips`:** propose 3 to 5, fewer if the video doesn't have them.
- **`--length`:** the range in seconds. Default 15 to 60.
- **`--accounts`:** limit the networks. Without it, the connected YouTube, TikTok, Instagram and Facebook accounts, confirmed in step 6.

## 1. Check the tools

Run these once and tell the user what you found:

- **ffmpeg (required):** `ffmpeg -version`. Missing: ask the user to install it (`brew install ffmpeg`, `sudo apt install ffmpeg`, `winget install ffmpeg`) and stop.
- **Caption burning:** `ffmpeg -hide_banner -filters | grep -w subtitles`. No match means this ffmpeg was built without libass, as Homebrew's default `ffmpeg` is. On macOS, `brew install ffmpeg-full` adds one beside it (keg-only: call it as `"$(brew --prefix ffmpeg-full)/bin/ffmpeg"`). Otherwise offer to cut without captions.
- **A local transcriber (optional), whichever is installed:**
  - whisper.cpp: `command -v whisper-cli` (Homebrew `whisper-cpp`). Needs a model file such as `ggml-small.bin`.
  - faster-whisper: `python3 -c "import faster_whisper"`.
  - openai-whisper: `command -v whisper`.
  - Another local Whisper build is fine if it gives word timestamps.

  None installed: offer to install one (`brew install whisper-cpp`, `pip install faster-whisper` or `pip install openai-whisper`), or to go on without captions, with the user naming the moments by timestamp. A model's first run downloads its weights; ask before a large download.

**The video never leaves the machine** until the user's own finished clips go to Antwork in step 7. No cloud transcription, no upload to any other service.

## 2. Get the source

- **A local file:** use it in place; never modify it.
- **A URL:** only video the user owns or has the rights to repost. If `yt-dlp` is installed, `yt-dlp -f "bv*+ba/b" --merge-output-format mp4 -o source.mp4 <url>`; say once that the rights are the user's responsibility. Without yt-dlp, ask for the file.

Work in `./antwork-clips/<source name>/` and tell the user the path. Read the source once: `ffprobe -v error -show_entries stream=codec_type,width,height,r_frame_rate:format=duration -of compact <source>`.

## 3. Transcribe, with word timestamps

Extract the audio: `ffmpeg -i <source> -vn -ac 1 -ar 16000 -c:a pcm_s16le audio.wav`. Then, with the tool you found, keeping the video's spoken language:

- **whisper.cpp:** `whisper-cli -m <model.bin> -f audio.wav -ml 1 -sow -oj -of words` (one word per segment; `offsets` in milliseconds).
- **faster-whisper:** `WhisperModel("small", compute_type="int8").transcribe("audio.wav", word_timestamps=True, vad_filter=True)`, then each segment's `words`.
- **openai-whisper:** `whisper audio.wav --model small --word_timestamps True --output_format json --output_dir .`, then `segments[].words`.

Normalize to one file, `words.json`: `[{"start": 12.34, "end": 12.61, "word": "Nobody"}, ...]` in seconds of the source. Read the transcript as sentences (join words, break on punctuation) with their start times.

## 4. Pick the moments, then stop for approval

Look for moments that work for someone who never saw the rest of the video:

- **Self-contained:** a full thought, story, answer or reaction. No "as I said earlier", no setup that lives outside the clip.
- **A hook in the first 2 seconds:** start on the strongest line (a claim, a number, a question, a reaction, the punchline's setup), not on "so" or "um" or a greeting. Cut the warm-up.
- **A payoff at the end:** end on the line that lands, not mid-sentence. Let the last word finish (about 0.3 s after it).
- **Inside the length range** (default 15 to 60 s; a Short is at most 3 minutes, and nothing here gets close).
- Snap both ends to word boundaries from `words.json`, with about 0.15 s of air before the first word.

Prefer moments with energy (laughter, a strong opinion, a surprise) and spread them across the video rather than taking three from one stretch. Skip anything that looks private: names, addresses, screens with data.

**Show the plan and wait.** One row per clip:

| # | Start - end (length) | Hook (first words) | Why it stands alone | Framing |
|---|---|---|---|---|

Framing is where the 9:16 crop sits (step 5): centre by default. Say which networks each clip goes to and that captions will be burned in. No cutting before the user approves, edits or drops rows.

## 5. Cut each clip to 9:16

**Framing.** Pull a frame from the middle of each approved clip, `ffmpeg -ss <mid> -i <source> -frames:v 1 -vf scale=640:-2 frame-01.jpg`, and look at it. Default is a centre crop; if the speaker or the action is off-centre, move the crop (`X` below, 0 = left edge, 0.5 = centre, 1 = right edge) and say so. The user can choose instead:

- **crop** (default): fills the phone, cuts the sides. Right for one speaker or one subject.
- **pad**: the whole frame on black bars, only when the user asks for it (two people far apart, a screen recording). Never a blurred copy of the video behind it: a landscape video shrunk onto a vertical frame reads as a repost.
- An already vertical source just scales to 1080x1920.

**Captions.** For each clip, write `clip-NN.ass` from `words.json`, times relative to the clip's start, 2 to 4 words per line, above the bottom of the frame where the apps put their own buttons and caption:

```python
import json, sys
words = json.load(open("words.json"))
start, end, out = float(sys.argv[1]), float(sys.argv[2]), sys.argv[3]
def ts(t):
    t = max(t, 0); return f"{int(t // 3600)}:{int(t % 3600 // 60):02d}:{t % 60:05.2f}"
head = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
WrapStyle: 2

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Cap,Arial,84,&H00FFFFFF,&H00FFFFFF,&H00000000,&H64000000,1,0,0,0,100,100,0,0,1,6,0,2,90,90,620,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
inside = [w for w in words if w["end"] > start and w["start"] < end]
lines, chunk = [], []
for w in inside:
    chunk.append(w)
    text = " ".join(x["word"].strip() for x in chunk)
    if len(chunk) >= 4 or len(text) > 18 or w["word"].strip()[-1:] in ".?!,":
        lines.append(chunk); chunk = []
if chunk:
    lines.append(chunk)
with open(out, "w") as f:
    f.write(head)
    for i, c in enumerate(lines):
        a = c[0]["start"] - start
        b = lines[i + 1][0]["start"] - start if i + 1 < len(lines) else c[-1]["end"] - start
        b = min(b, c[-1]["end"] - start + 0.5, end - start)
        text = " ".join(x["word"].strip() for x in c).replace("{", "(").replace("}", ")")
        f.write(f"Dialogue: 0,{ts(a)},{ts(b)},Cap,,0,0,0,,{text}\n")
```

Run it as `python3 captions.py <start> <end> clip-01.ass`. Check a line or two against the audio; fix misheard names by hand in the `.ass` file.

**Render** (crop shown; for pad, replace the first two filters with `scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black`; without captions, drop `subtitles=...`):

```sh
ffmpeg -hide_banner -y -ss <start> -t <length> -i <source> \
  -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920:(iw-1080)*X:(ih-1920)/2,setsar=1,subtitles=clip-01.ass" \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p \
  -c:a aac -b:a 160k -ar 48000 -af loudnorm=I=-14:TP=-1.5:LRA=11 \
  -movflags +faststart clip-01.mp4
```

Check each output: `ffprobe -v error -show_entries stream=codec_name,width,height:format=duration -of compact clip-01.mp4` must say h264 and aac, 1080x1920, and the planned length. A source under 1080p will look soft once cropped; say so rather than hiding it. Show the user one frame of the first finished clip (captions and framing) before rendering the rest.

## 6. Accounts and voice

1. `list_social_accounts` for the connected accounts. If none, `get_connection_urls` and stop. Confirm one account per network (with several on one network, the user picks).
2. `get_post_context(account_ids=[...])` once for all of them. Each account's `recentPosts` are its voice (caption length, hashtags, emoji, calls to action); `performance.topPosts`, when present, show which hooks worked there. Never reuse one account's voice for another. No history means the user gives a tone or a sample.

Write per clip, per network, each within its limit:

- **YouTube:** a title in `platform_options.title` (at most 100 characters; without it YouTube gets the first 100 characters of the text), a short description as `text`, and `hashtags`, which on YouTube become the video's tags. A vertical clip of 3 minutes or less is a Short on its own. Set `privacyStatus` only if the user names one.
- **TikTok:** a short caption (limit 2,200) that adds to the hook rather than repeating the captions, hashtags as the account uses them.
- **Instagram:** a Reel caption (limit 2,200) with the hook up front. A video post is a Reel; `postToGrid` puts it on the profile grid too, only if the user wants it.
- **Facebook:** a Page post in that account's voice; a short vertical Page video is shown as a Reel.

Credit the source when it isn't the user's own show. Show all the copy with the clips before anything is created; editing text in chat is cheaper than editing drafts.

## 7. Draft each clip and attach it

For each approved clip, in order:

1. `create_post(posts=[{account_id, text, hashtags?, platform_options?}, ...])`, one entry per network, each with its own copy. The versions are one post and return `postIds`. A draft for TikTok or YouTube says `mediaRequired` until step 2 runs; that is expected.
2. `add_media(upload={"mime_type": "video/mp4", "byte_size": <bytes>}, attach_to_post_ids=[<that clip's postIds>])`. One ticket per file, asked for right before its upload: the `uploadUrl` lasts 10 minutes.
3. `curl -sS -X PUT --data-binary @clip-01.mp4 '<uploadUrl>'`. Its response is the result: `attached`, `notAttached` with reasons, and `publishBlockers`. Anything in `notAttached` or `publishBlockers` goes to the user as is.

Never attach one clip's file to another clip's posts. Nothing is scheduled or live yet.

## 8. Publish, schedule or keep as drafts

Offer the three choices once for the whole set, then do what the user picked:

- **TikTok settings are the user's.** A TikTok post carries `settingsRequired.tiktokChoices` (privacy, comments, duet, stitch, commercial content). Ask each one with no defaults; never pick them. The user may say the same answers apply to every clip. Send them as `tiktok_settings` with `userConsented: true`, keyed by post id for several posts. If the result offers `lastUsed`, ask once whether to reuse it: a yes is `{"useLast": true, "userConsented": true}`.
- **Schedule:** a clip series reads best spread out, one clip per slot. `schedule_post(post_ids=[...], scheduled_for="next_slot")` gives each post its account's next free slot in turn, or `schedule_post(schedules=[{post_id, scheduled_for}, ...])` sets each time (up to 25). Each account has a daily cap (`dailyPostCap` in `get_post_context`); plan under it.
- **Publish now:** `publish_post(post_ids=[...])`, at most 10 per call. A `pending` answer means one `get_post` after `checkAfterSeconds`, not polling.
- **Keep as drafts:** give each post's `editUrl`.

Report what actually happened, one line per clip and network, with live URLs when published. Never say "posted" when only drafts exist. Leave the clips in the work folder and say where.

## Guardrails

- **Plan before cutting.** No clip is rendered, uploaded or drafted before the user approves the plan in step 4.
- **Local only.** The source and its audio stay on the machine; only the user's approved clips go to Antwork.
- **Rights are the user's.** Clip only what they own or may repost, and credit sources they don't own.
- **No invented quotes.** Copy and titles describe what is said in the clip; a title never promises what the clip doesn't show.
