### Chatty McClient 

**User Guide**:

---

**Main Screen**

<img width="1000" height="700" alt="ChattyMcClient-MainScreen" src="https://github.com/user-attachments/assets/4a0a22b7-55ce-4709-83a4-83ca482b9d6e" />

<br>
<br>

**A**- Chat Sessions. This is an index of your locally saved chat sessions. They are stored in a "Chats" subfolder from where you started the app.

**B**- Server URI and Model name. These will be stored in your session file. When you click on a chat and write something into it, 
        the corresponding model will be loaded by the server (if you set it up this way)

**C**- Messages window. Both yours and your model's interactions are displayed here. This is a stripped down version of Chromium so it can display rich-text, images, etc.

**D**- Turn up/down. This will let you quickly scroll up to the start of next/prev turn.

**M**- Just kidding.

**E**- User input window. Type away here. You can also issue tool calls using the "@/" command.

**F**- Context stats. Input stats are estimated (4 char = 1 token), the rest are taken from the server, if they are provided. 
       They could be off from actual as we only get server stats when there's an interaction with the server.

**G**- Controls. Clear chat, Settings, Tools, System Prompt, and Attachments.

**H**- Send/Stop button. Stop works in mysterious ways. The app will *attempt* and send a stop signal to the server in hopes it does that. 
        Once a stop command is issued, the button is grayed out so you're not tempted to spam it. Not Send, Send is nice and well behaved. 

<br>

---

**Settings:**

<img width="500" height="590" alt="ChattyMcClient-Settings" src="https://github.com/user-attachments/assets/b274fe6e-68e6-4b87-b339-2cc1413fbfd0" />

<br>
<br>

**A**- Settings Scope:
        - **Global**: applies settings, tools, and prompts to *all* models in every chat session.
        - **Chat Specific**: applies settings, tools, and prompts to *per chat session*. 
            - This option lets you customize settings for each model you use, and quickly switch between them.
                      
**B**- Model parameters. Beware some of these settings (context length, in particular) require re-loading the model on the server, and this app doesn't do that. 

**C**- Optional settings

1. Enable server usage stats: receive context stats from server.

2. Add Timestamp to User turn: Prints date/time stats in the context. This is both useful for you to track *when* you sent a message, and for the model to hvae *some* sense of current date and passage of time.
    - Hey, I'm nice to my model so I don't get exterminated when they take over.

3. Model Thoughts: Some "thinking" models output their thoughts into the context. We have three ways of handling it:
   
    - Off: show all their thoughts in the message window.
    - API: if thoughts are sent by the server, we wrap them in a message section and clear them afterwards if you select to do so.
    - Client: If the server is not sending model thoughts in a \<reasoning_content> object, the app tags the thoughts so they can be managed.

5. Auto-Collapse. Each model message is tagged with an "Exclude" button. If you click that button, the message will be excluded from context.
    When this option is enabled, tool and thoughts output are cleared automatically to keep the context clean and small. 

<br>

---

**Tools:**

<br>

<img width="700" height="450" alt="ChattyMcClient-Tools" src="https://github.com/user-attachments/assets/862103c8-3430-40b5-a60c-4a5bc34d4130" />


**A**- Tool Alias. This is the name you and your model will use to call the tool. 

-Not depicted because I forgot: tool path. I recommend a dedicated "Tools" folder under you app install (drop) directory to keep tools organized

**B**- Tool Description. This is the description your model will use to understand tool usage.
- Don't just "*yo, check out my tool I made to do stuff*" because your model (and most everyone else) won't understand that.
- Give it a good description in natural language that the tool can use, like: 
      
              Gets weather using the format "-Location -Units -Forecast". 
              Forecast: 0=current, 5=5 days. Examples: "-Paris,TX,US -F -0", "-Miami", "-Berlin,DE -C, -5"

**C**- Model Enabled (on/off). You can always use any of these tools from the input window but only those enabled here can be used by the model.


---
<br>

Not shown is the System Prompt window. Standard stuff, if you've ever interacted with models before. 
If not, the app includes a starter prompt message that has (mostly) worked for me. 
Remember, if you have per-session option enabled, each model gets their own system prompt, too.

For either System Prompt and tool description, be a concise as possible with something that is useful to your model but don't overly use your context space. 

Finally, Global APP Settings, Tool definition, and the like are stored in a "settings.json" file on the root of your app folder.

<br>

**ENJOY!**

/JR







