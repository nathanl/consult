- Make updating the tag an AJAX request, not a page reload
- All conversations page
  - show rep name who last helped?
  - show last message for context (not first?)
- Clean up query stuff for conversations
- Let user download the chat history
- Let CS rep add notes to a conversation
- Label each message with some kind of per-user id so that we can style each speaker's differently - styles for 'me' and 'not me' is probably enough.
- Add "is typing" indicators for users who are not self, maybe 'multiple users are typing' if more than 2.
- Populate only the most recent N messages in a conversation when backfilling history, and load more as the user scrolls up
  - With this, we can then have some infinite conversations (don't allow closing) for back-channel talk between cs reps ("I need some help here", etc)
  - *Maybe* use "who is in the lounge channel" to decide whether any cs reps are available to chat? We need a conditional for that in the views to show the chat feature...
- Use gettext to let app customize the text?
- Let app customize the way timestamps are displayed?
- Clean up path references
- In setup:
  - Prompt user for name if not logged in (currently using "Anonymous")
  - Set up chat window, using given chat room name and username
- Given that we're setting a cookie on every request, if a user loads a page and we already know that they're in a chat session, they should have all the info they need to connect to the socket without having to do another setup request.
- Start using Presence so we can know when reps are available to chat.

## Ideas for Later
- Support file uploads?
- Give conversation tags fields for "background-color" and "text-color" so that CS reps can create and style tags, like on Github issues
- Support callbacks: when a user starts a conversation, when one is tagged or untagged, when one is closed, ... ? This would allow people to add lots of features without supporting them directly (eg, "email me when", Growl notifications, "blink a light in the office when", record info for later reporting, etc)
- Add a way for CS reps to chat with each other: "do you know X?" or "can you join us in conversation 123?"
- CS reps will keep each chat in its own browser tab. Put helpful info/indicators in the `<title>` of each tab. Ideas: user name, exclamation point or some emoji if any unread messages...

# Notes on Zopim:
- Asks for name, email and topic at start of chat
- Messages appear in little speech bubbles from self and agent, self on right, agent on left. Speaker name is bolded at top of bubble, and speaker profile image is where speech bubble appears to come from.
- Basic integration is just "add this JS snippet to your page"
- Ties chat to a session
- If reload the page, all messages from conversation repopulate
- Can open chat in a separate tab and also use widget. The two are synced.
- Can attach files to the chat
- Can rate the chat
- Can get a transcript emailed to self
- Agents can come and go from the chat
- There's an "End this Chat" button - presumably if I did that, and opened the chat window again, it would be a new conversation?
