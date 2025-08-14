#Requires -Version 5.1

# reddit_api_sub.ps1

<#
.SYNOPSIS
    Uses Reddit API to get up to 25 posts from a Reddit sub.

.DESCRIPTION
    A dedicated tool for old.reddit.com. It uses Reddit API to extract 
    the title and URL for each post and formats them as Markdown
    link list for the Chatty McClient application.

.PARAMETER
    The unique sub name, with optional sorting (eg: /new)


.EXAMPLE
    .\reddit_api_sub.ps1 LocalLlama/new

#>



param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$subredditPath   # e.g. "localllama/new"
)

# ---- Configuration ----------------------------------------------------
$baseUrl   = "https://old.reddit.com/r/"
$limit     = 25
$userAgent = "RedditReadDemo (by /u/Your-Reddit-Username-Here)"

# ---- Build request -----------------------------------------------------
$fullUrl = "$baseUrl$subredditPath/.json?limit=$limit"

# ---- Helper function to output JSON ----------------------------------
function Write-Json {
    param([hashtable]$obj)
    $obj | ConvertTo-Json -Depth 10 -Compress
}

# ---- Execute request ---------------------------------------------------
try {
    $response = Invoke-RestMethod -Uri $fullUrl `
                                  -Headers @{ 'User-Agent' = $userAgent } `
                                  -Method Get `
                                  -ErrorAction Stop
}
catch {
    $errMsg = $_.Exception.Message
    Write-Json @{ status = "error"; error_message = $errMsg } | Out-String
    exit 1
}

# ---- Validate response ------------------------------------------------
if (-not $response -or -not $response.data -or -not $response.data.children) {
    Write-Json @{ status = "error"; error_message = "Empty or malformed response from Reddit." } | Out-String
    exit 1
}

# ---- Build content string ---------------------------------------------
$lines = @()
foreach ($post in $response.data.children) {
    $d = $post.data
    $title   = $d.title
    $link    = "https://reddit.com" + $d.permalink
    $lines += "- [$title]($link)"
}

# Join with newlines
$allText = $lines -join "`n"

# ---- Success output ---------------------------------------------------
Write-Json @{ status = "success"; content = $allText } | Out-String