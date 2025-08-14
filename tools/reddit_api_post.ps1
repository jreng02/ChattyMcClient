#Requires -Version 5.1

# reddit_api_post.ps1

<#
.SYNOPSIS
    Uses Reddit API to get top x number of subreddit posts from an old.reddit.com page.

.DESCRIPTION
    A dedicated tool for old.reddit.com. It uses Reddit API to extract 
    the title and URL for each post and formats them as Markdown
    link list for the Chatty McClient application.

.PARAMETER URL
    The unique post identification, followed by an optional "-commentLimit x"; 
    where x= number of comments retreived (e.g., "1jabmwz -commentLimit 20").

.EXAMPLE
    .\reddit_api_post.ps1 1jabmwz -commentLimit 20

#>


param(
    [string]$argsCombined   # The single string the app passes
)

# -------------------------------------------------------------
# 1. Split the combined argument string
# -------------------------------------------------------------
# Split on whitespace, but keep quoted substrings together
$tokens = $argsCombined -split '\s+(?=(?:[^"]*"[^"]*")*[^"]*$)'

# The first token is always the post ID
$postId = $tokens[0]

# Default comment limit
$commentLimit = 10

# Look for '-commentLimit' flag if it exists
for ($i = 1; $i -lt $tokens.Count; $i++) {
    if ($tokens[$i] -eq '-commentLimit' -and ($i + 1) -lt $tokens.Count) {
        $commentLimit = [int]$tokens[$i + 1]
        break
    }
}

# -------------------------------------------------------------
# 2. Helper for JSON output
# -------------------------------------------------------------
function Write-Json {
    param([hashtable]$obj)
    $obj | ConvertTo-Json -Depth 10 -Compress
}

# -------------------------------------------------------------
# 3. Resolve subreddit from the post ID
# -------------------------------------------------------------
$infoUrl = "https://www.reddit.com/api/info.json?id=t3_$postId"
$userAgent = "RedditReadDemo (by /u/Your-Reddit-Username-Here)"

try {
    $info = Invoke-RestMethod -Uri $infoUrl `
                              -Headers @{ 'User-Agent' = $userAgent } `
                              -Method Get `
                              -ErrorAction Stop
    $subreddit = $info.data.children[0].data.subreddit
}
catch {
    Write-Json @{ status='error'; error_message='Could not resolve post ID.' } | Out-String
    exit 1
}

# -------------------------------------------------------------
# 4. Build request URL for comments (top N)
# -------------------------------------------------------------
$commentsUrl = "https://old.reddit.com/r/$subreddit/comments/$postId/.json?limit=1&depth=1&sort=top&limit=$commentLimit"

try {
    $raw = Invoke-RestMethod -Uri $commentsUrl `
                             -Headers @{ 'User-Agent' = $userAgent } `
                             -Method Get `
                             -ErrorAction Stop
}
catch {
    Write-Json @{ status='error'; error_message="HTTP error: $($_.Exception.Message)" } | Out-String
    exit 1
}

# Sanity check – expect two elements: post + comments
if (-not $raw -or $raw.Count -ne 2) {
    Write-Json @{ status='error'; error_message='Unexpected response structure from Reddit.' } | Out-String
    exit 1
}

# -------------------------------------------------------------
# 5. Extract post data
# -------------------------------------------------------------
$postData = $raw[0].data.children[0].data
$title   = $postData.title
$excerpt = ($postData.selftext -split '\s+' | Select-Object -First 100) -join ' '
$excerpt = if ($excerpt) { "$excerpt..." } else { "" }

# -------------------------------------------------------------
# 6. Extract comments
# -------------------------------------------------------------
$comments = @()
foreach ($c in $raw[1].data.children) {
    if ($c.kind -ne 't1') { continue }
    if ($c.data.author -eq "[deleted]" -or $c.data.body -eq "") { continue }

    $body = ($c.data.body -split '\s+' | Select-Object -First 30) -join ' '
    $body = "$body..."
    $comments += "- *$($c.data.author)*: $body"
    if ($comments.Count -ge $commentLimit) { break }
}

# -------------------------------------------------------------
# 7. Build output string
# -------------------------------------------------------------
$lines = @()
$lines += "## $title"
$lines += ""
if ($excerpt) { $lines += $excerpt; $lines += "" }

if ($comments.Count -gt 0) {
    $lines += "### Top $commentLimit comments"
    $lines += $comments
}

$content = $lines -join "`n"

# -------------------------------------------------------------
# 8. Return JSON
# -------------------------------------------------------------
Write-Json @{ status='success'; content=$content } | Out-String