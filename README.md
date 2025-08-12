# ChattyMcClient

**Description**: 

A lame attempt at an OpenAI API-compatible client for Windows - and possibly other .Net 8.0+ platforms.

You will be shocked to learn I'm not a developer, I'm an AI jockey. This project was ~90% coded by awesomeness that is Google's Gemini 2.5 Pro (no affiliation) under my direction and constant nagging. 

All I wanted was a pony, and for LM Studio to release a client of their own. While we all wait for that, I built this to use it.

**Fair warning**: This project is packed with inconsistencies and bugs throughout. Do not put it in charge of liver transplants or anything serious. 

**Some features I found useful**

- Multi-chat sessions that are written to a local JSON file you can edit and mess with. These are great for debugging what your model is *actually* doing.

- Global or per-session settings. 
    - I run a variety of models but I wouldn't want my 80Mb, 2048 token context one to get a huge system prompt or a bunch of tools description     
      - In Global mode, a single Settings, tool assignments, and system prompt is applied to all chat/model sessions.     
      - In Per-Session mode, each chat session gets their own settings. 

- External tools support.      
  - Pick your language poison (Python, C++, C#, PowerShell (if you're brave), Esperanto, whatever. There's a protocol for input/output at the end.
  	- Both you and your model can run tools.
   	- **Model** uses this pattern. If your model is stubborn about tool use, putting this in System Prompt might help it.
      
    ```json
    	<tool_code>
    		[
    			{
    				"type": "function",
    					"function": {
    						"name": "getweather",
    						"arguments": "{\"input\": \"-Paris -C -0\"}"
    						}
    			}
    		]
        </tool_code>
	```    
     - **You** use this pattern in the input field:  \"@/<tool> <argument>" to send to tool>; eg: @/search "how can I delete a certain chat app I accidentally downloaded?"
  
- Run, Edit, Delete, Copy, Exclude actions in context window.
  - Run: re-runs that user turn, and in the process overwriting/deleting the context from that point on. Useful for when you can't make your darn model run your tool just right.
  
  - Edit: Like above, you can edit your turn, and when you save it, it will run + delete the context after that point     

  - Delete: Does what it says, but use with caution. If you delete any but the last chat turn in the history, you might end up with an out of sequence user/model history and make a mess of it.
   
  - Copy: Copies the entry, markdown and all. 
     
  - Exclude: Magical button that "excludes" the content from the context that gets sent to the model, without removing it from the messages window.
          
  - This feature aims to reduce chatter and raw content created by tools.                  
      1. You ask your model to use the "webscrape" tool on a website and create a summary.                 
      2. The tool imports a chunk of raw HTML and your model creates a summary.                 
      3. Why do you need an incomprehensible blob of HTML there anymore?
         - There's an option in settings to exclude tool output automatically.
         - Why would you **not** want to use this always? Well your model might get the summary wrong and you ask it again to look closer.

- Attach files to talk to.            
  - This is WIP (like the rest of the app isn't, lol), but also limited by what the server and model supports.                  
  - Text files and images work, PDFs do not (yet)

**Project size**: ~3.20Mb, assuming you already have .Net 8.0 runtime installed. I have included a couple of "tools" for testing out of the box.

---

**Privacy, and data collection**

Ha! Why would I want *any* of your data? That is yours to keep. I don't get to know who you are, thank you very much, collect anything from you, have the app secretly send me your files, etc. NONE. I instantly hate any app that even asks for "registration" so I wouldn't do that in my own. 

This is a one-way street: you download this app, copy it, delete it, chop it to pieces, whatever. I don't care. 

If you *want* to reach me to tell me how I should *really* pick a different profession as I suck at this one, file a Github issue - I'll see if I can fix that.

So GDPR hawks and people with nothing better to do: :stuck_out_tongue: Nothing to see here.

---

**Source code**:

Q: Why haven't you released the source code?!? How do I know any of this is true!? 

A. Yeah, you're right. I wouldn't trust a Github app I can't scrutinize under the hood. I plan to release the sources but first need to clean it up, remove incriminating evidence, and ask a helpful AI to comment/document it so it's useful. 

Again: **I** would not download this app if I can't see the sources. If you do, take full precautions. Run it in a VM-like setup, full gas mask on, isolated, scan it for viruses, and generally keep it constrained until you're comfortable with it, and/or I've found the time to pretty up the sources and release them.  

---

**Installation**

1. **LOL, none**. 
	Drop files onto a folder you like, and create a "Tools" folder under it to hold your tools (if you want)


---

**A well thought out and organized list of FAQ:**

Q: Why would you release this abomination onto an unsuspecting world??

A: I needed to appear busy. If I don't look busy, my wife sends me to the mall. I'll do anything to escape the ravages of a mall. So, sorry.

And really, I looked for an OpenAI API-compatible chat app for Windows and most of what I found were giant "containers" or ones with several gigabytes-worth of requirements.  

---

**Tools protocol**:

**Part 1**: Tool Input
     **How Chatty McClient passes tool argument**:
 		- The app passes a single string of command-line arguments.
   		- When you type a command like "@/search *The most capable model you can run on a single GPU* in the chat, the application does the following:
	 		1.  It identifies the tool by the alias (`/search`).
			2.  It takes everything that comes *after* the alias and treats it as a single string of arguments.
   			3.  It launches the tool's process and passes that string as an argument.

   **How Your Script Receives It:**
   		- **PowerShell (`.ps1`):** The arguments are available in the `$args` array. Our current scripts use `param([string]$searchTerm)` which automatically assigns the first argument to the `$searchTerm` variable.
	 	- **Batch File (`.bat`):** The arguments are available as `%1`, `%2`, etc., or `%*` for all of them.
   		- **Python (`.py`):** The arguments are available in the `sys.argv` list (e.g., `sys.argv[1]`).


**Part 2**: Tool Output
	**How Chatty McClient receives payload from the tool**:
 		- Your tool must still print a single, valid JSON string to Standard Output.
   			```json
	  		- On Success: {"status": "success",
                 "content": "All of your scraped text, including newlines, goes directly in this string."
                }
         *Where*:   
               "status": "success": Mandatory.
			   "content": "...": A single string containing the complete text output of your tool. This is what will be placed into the "Tool Output" message in the chat.
	  		```

       	- On Failure:{"status": "error",
  			"error_message": "A clear description of what went wrong."
			}

---

**Tool Example**: scrape Reddit sub for new posts:

   **NOTE**: None of my business but please use with care. Reddit servers run on two tired hamsters and really don't need the extra load of AI scraping their website on a loop.

*******

```powershell
#Requires -Version 5.1

<#
.SYNOPSIS
    Scrapes post titles and links from an old.reddit.com page.

.DESCRIPTION
    A dedicated tool for old.reddit.com. It uses a simple, fast web request
    and regular expressions to parse the raw HTML. It extracts the
    title and URL for each post and formats them as a numbered Markdown
    link list for the Chatty McClient application.

.PARAMETER URL
    The full old.reddit.com URL to scrape (e.g., "https://old.reddit.com/r/LocalLlama/new/").

.EXAMPLE
    .\reddit.ps1 -URL "https://old.reddit.com/r/PowerShell/"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$URL
)

# --- Main Execution ---
try {
    # Ensure the URL is a valid old.reddit.com URL
    if ($URL -notlike "https://old.reddit.com/*") {
        throw "This script is designed for old.reddit.com URLs only."
    }

    # Use simple web request method.
    $response = Invoke-WebRequest -Uri $URL -UseBasicParsing -ErrorAction Stop

    # Regex to find all post containers directly from the raw HTML content.
    # This specifically looks for the div that contains the title link.
    $postMatches = [regex]::Matches($response.Content, '(?si)<div class="entry unvoted.*?">.*?<a class="title.*?href="(.*?)".*?>(.*?)</a>.*?</div>')

    $outputBuilder = [System.Text.StringBuilder]::new()
    $postCounter = 1

    # Loop through each post container to extract its details.
    foreach ($match in $postMatches) {
        if ($match.Success) {
            $relativeUrl = $match.Groups[1].Value
            $title = $match.Groups[2].Value

            # Clean up the title by decoding any HTML entities (e.g., &amp; -> &)
            $cleanedTitle = [System.Net.WebUtility]::HtmlDecode($title).Trim()

            # Create absolute URL from the relative path.
            if ($relativeUrl -notlike "http*") {
                $absoluteUrl = "https://old.reddit.com$relativeUrl"
            }
            else {
                $absoluteUrl = $relativeUrl
            }

            # Append the formatted line to our output string.
            $null = $outputBuilder.AppendLine("$postCounter. [$cleanedTitle]($absoluteUrl)")
            $postCounter++
        }
    }

    $finalText = $outputBuilder.ToString()

    if ([string]::IsNullOrWhiteSpace($finalText)) {
        $finalText = "Scraping completed, but no posts were found on the page."
    }

    # Format the final output as a JSON object for success.
    $output = @{
        status = "success"
        content = $finalText
	}
}

catch {
    # If a critical error occurs, format as an error JSON.
    $errorMessage = "A critical error occurred. $($_.Exception.Message)"
    $output = @{
        status        = "error"
        error_message = $errorMessage
    }
}

# Convert the final result object to a compact JSON string and print to stdout.
$output | ConvertTo-Json -Compress | Write-Output        
```
---

### The end

> You read this whole ReadMe?? Geez.

---


