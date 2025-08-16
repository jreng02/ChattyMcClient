# GoogleNewsRSS.ps1
<#
.SYNOPSIS
    Returns a Markdown table of the first 10 Google‑News stories.
.DESCRIPTION
    • No argument or argument = "" → top‑stories feed.
    • One non‑empty argument → keyword search (`search?q=…`).
    • Output JSON {status,content} – content is a single‑line Markdown string.
    • Handles quoted strings automatically (PowerShell passes the raw string).
#>

param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

# -------- 1️⃣ Resolve target URL ----------
$base   = 'https://news.google.com/rss'
$search = if ($Args.Count -eq 0 -or ($Args.Count -eq 1 -and $Args[0] -eq '')) {
              $base + '?hl=en-US&gl=US&ceid=US:en'
          }
          else {
              #$q = [System.Web.HttpUtility]::UrlEncode($Args[0])

		# Join all supplied words into one search string
		$searchTerm = ($Args -join ' ')

		# URL‑encode the whole phrase
		$q = [System.Net.WebUtility]::UrlEncode($searchTerm)


	      # $q = [System.Net.WebUtility]::UrlEncode($Args[0])
              "$base/search?q=$q"
          }

# -------- 2️⃣ Fetch RSS ----------
try {
    $resp = Invoke-WebRequest -Uri $search -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
    $xml  = [xml]$resp.Content
} catch {
    $msg = "Failed to fetch RSS: $_"
    Write-Output (@{status='error'; error_message=$msg} | ConvertTo-Json -Depth 10 -Compress)
    exit 1
}

# -------- 3️⃣ Guard against empty feed ----------
$items = $xml.rss.channel.item
if (-not $items) {
    Write-Output (@{status='error'; error_message='No items found in feed.'} |
                  ConvertTo-Json -Depth 10 -Compress)
    exit 1
}

# -------- 4️⃣ Build Markdown table (first 10) ----------
$tbl = @()

$index = 0    # number counter

foreach ($item in $items[0..([math]::Min(9,$items.Count-1))]) {
    $index++
    $t = $item.title          # headline (plain text)
    $u = $item.link           # article URL

    # One‑liner: number – plain headline as a Markdown link
    $row = "$index. [$t]($u)"
    $tbl += $row
}

$md = $tbl -join "`n---`n"   # separate rows by a horizontal rule


# -------- 5️⃣ Output JSON ----------
$result = @{
    status  = 'success'
    content = $md
}
Write-Output ($result | ConvertTo-Json -Depth 10 -Compress)