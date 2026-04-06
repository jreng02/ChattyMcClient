param (
    [Parameter(Mandatory=$true)][string]$Query
)

# ==========================================
# SET YOUR TAVILY API KEY HERE
# ==========================================
$TavilyApiKey = "tvly-YOUR_API_KEY_HERE"

[Console]::OutputEncoding =[System.Text.Encoding]::UTF8

if ([string]::IsNullOrWhiteSpace($TavilyApiKey) -or $TavilyApiKey -match "YOUR_API_KEY_HERE") {
    $errorResponse = @{
        status = "error"
        error_message = "Tavily API key is missing. Please edit the script to add your API key."
    }
    $errorResponse | ConvertTo-Json -Depth 3 -Compress | Write-Output
    exit
}

$uri = "https://api.tavily.com/search"

# Build the request body
$requestBody = @{
    api_key = $TavilyApiKey
    query = $Query
    search_depth = "basic"
    max_results = 5
    # include_answer = $true # >>> true to have Tavily 'pre-process' the result
    include_answer = $false #  >>> false for no filtering
} | ConvertTo-Json -Depth 3

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $requestBody -ContentType "application/json"

    if (-not $response.results -or $response.results.Count -eq 0) {
        $successResponse = @{
            status = "success"
            content = "No search results found for query: $Query"
        }
        $successResponse | ConvertTo-Json -Depth 3 -Compress | Write-Output
        exit
    }

    $formattedResults = "Search Results for `"$Query`":`n`n"
    
    # Add the AI summary if Tavily generated one
    if (-not [string]::IsNullOrWhiteSpace($response.answer)) {
        $formattedResults += "**Tavily Summary:** $($response.answer)`n`n---`n`n"
    }
    
    $i = 1
    foreach ($result in $response.results) {
        $cleanContent = $result.content.Trim()
        
        # Clamp massive text chunks
        $maxLength = 600
        if ($cleanContent.Length -gt $maxLength) {
            $cleanContent = $cleanContent.Substring(0, $maxLength) + "... [truncated]"
        }
        
        # Format as a numbered list with a Markdown link, just like the Google News script
        $formattedResults += "$i. [$($result.title)]($($result.url))`n`n"
        
        # Provide the snippet below it. 
        $formattedResults += "$cleanContent`n`n"
        
        # IMPORTANT: The double newline (`n`n) above ensures this is a divider line (<hr>), NOT a header
        $formattedResults += "---`n`n"
        
        $i++
    }

    $successResponse = @{
        status = "success"
        content = $formattedResults.Trim()
    }

    $successResponse | ConvertTo-Json -Depth 3 -Compress | Write-Output
}
catch {
    $errorMsg = $_.Exception.Message
    if ($_.ErrorDetails.Message) { $errorMsg += " - " + $_.ErrorDetails.Message }

    $errorResponse = @{
        status = "error"
        error_message = "Tavily API Request failed: $errorMsg"
    }
    $errorResponse | ConvertTo-Json -Depth 3 -Compress | Write-Output
}