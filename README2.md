# ChattyMcClient

**Description**  
A lightweight, OpenAI‑API compatible client for Windows (and any .NET 8.0+ platform). Built mostly with help from Gemini 2.5 Pro, it’s a quick way to experiment with chat‑based models without the bloat of larger solutions.

> ⚠️ **Warning** – The project contains many inconsistencies and bugs.  
> Do not use it for critical or medical decisions (e.g., liver transplants).

---

## Features

| Feature | What It Does |
|---------|--------------|
| **Multi‑chat sessions** | Each session is stored as a local JSON file that you can edit manually. Great for debugging what the model actually does. |
| **Global / Per‑session settings** | <ul><li>**Global mode:** one set of tool assignments, system prompt, and settings apply to all chats.</li><li>**Per‑session mode:** each chat has its own independent configuration.</li></ul> |
| **External tools support** | Run arbitrary scripts (Python, C++, C#, PowerShell, etc.) from within the chat. <br>Both the model *and* you can invoke tools. |
| **Context actions** | In the conversation view: **Run**, **Edit**, **Delete**, **Copy**, and **Exclude**.<br>  • **Run** – re‑executes a user turn, overwriting context from that point onward.<br>  • **Edit** – edit a turn; on save it runs and deletes subsequent context.<br>  • **Delete** – removes a message (use with care).<br>  • **Copy** – copies the entry verbatim.<br>  • **Exclude** – hides a message from the prompt sent to the model without deleting it. |
| **File attachments** | Attach text files or images (PDF support pending). |
| **Tool auto‑exclusion** | Optionally exclude tool output automatically; useful for keeping the prompt clean. |

---

## Tool Protocol

### 1️⃣ Input
- The app passes a single command‑line string to your script.
- Example: `@/search "most capable model on a single GPU"` → alias `/search` + argument `"most capable model on a single GPU"`.
- How scripts receive it:
  - **PowerShell** – `$args[0]` or `param([string]$searchTerm)`
  - **Batch** – `%1`, `%2`, …
  - **Python** – `sys.argv[1]`

### 2️⃣ Output
Your script must print a *single* JSON string to stdout.

| Status | JSON Shape |
|--------|------------|
| **Success** | `{ "status": "success", "content": "<tool output>" }` |
| **Error** | `{ "status": "error", "error_message": "<description>" }` |

> The `content` string can contain newlines and other formatting; it will be inserted into the chat as a “Tool Output” message.

---

## Example Tool: Reddit Scraper (PowerShell)

```powershell
# reddit.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$URL
)
try {
    if ($URL -notlike "https://old.reddit.com/*") { throw "Only old.reddit.com URLs are supported." }
    $response = Invoke-WebRequest -Uri $URL -UseBasicParsing -ErrorAction Stop
    $matches = [regex]::Matches($response.Content, '(?si)<div class="entry unvoted.*?">.*?<a class="title.*?href="(.*?)".*?>(.*?)</a>.*?</div>')
    $builder = [System.Text.StringBuilder]::new()
    $i = 1
    foreach ($m in $matches) {
        $url = if ($m.Groups[1].Value -match "^http") { $m.Groups[1].Value } else { "https://old.reddit.com$($m.Groups[1].Value)" }
        $title = [System.Net.WebUtility]::HtmlDecode($m.Groups[2].Value).Trim()
        $builder.AppendLine("$i. [$title]($url)") | Out-Null
        $i++
    }
    $content = if ($builder.Length -gt 0) { $builder.ToString() } else { "No posts found." }

    @{ status = "success"; content = $content } | ConvertTo-Json -Compress
} catch {
    @{ status = "error"; error_message = $_.Exception.Message } | ConvertTo-Json -Compress
}
```

---

## Privacy & Data Collection

* No personal data is collected or sent anywhere.  
* The app is fully local; you can delete, copy, and modify it as you wish.  
* There’s no registration, telemetry, or hidden uploads.

If you want to contribute or see the source code, let me know (GitHub issue). I plan to clean up and publish the repo soon.

---

## Installation

1. **No installer** – just drop the files into any folder.  
2. Create a `Tools` subfolder if you wish to add your own scripts.

---

## FAQ Highlights

| Question | Answer |
|----------|--------|
| Why release this? | Needed a lightweight chat client; existing options were too heavy or required huge dependencies. |
| Is the code safe? | Run it in an isolated VM, scan for malware, and treat it as experimental until the source is released. |

---

Happy chatting! 🚀
