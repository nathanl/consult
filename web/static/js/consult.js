window.EnableConsult = function(socketModule) {
  let cookie = {
    read: function(name) {
      var nameEQ = name + "=";
      var ca = document.cookie.split(';');
      for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
      }
      return null;
    },

    write: function(name,value,days) {
      if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
      }
      else var expires = "";
      document.cookie = name+"="+value+expires+"; path=/";
    },

    erase: function(name) { this.write(name,"",-1); }
  }

  if (document.getElementById("chatbox") !== null) {
    let Chat = exports.Chat = function Chat() {
      this.socket                = null
      this.channel_name          = null
      this.user_name             = null
      this.user_id_token         = null
      this.conversation_id_token = null
      this.chatStarted           = false

      this.startChatButton       = document.getElementById("chatbox-startchat")
      this.chatBox               = document.getElementById("chatbox")
      this.chatInput             = document.getElementById("chatbox-input")
      let chatMessages           = document.getElementById("chatbox-messages")
      this.closeChatButton       = document.getElementById("chatbox-close-chat")

      this.userIsCsRep   = !!this.chatBox.className.match("cs-support")

      this.checkAndMaybeStart = function(){
        let inChatSession = !!cookie.read("conversationId")

        if (inChatSession || this.userIsCsRep) {
          this.startChat()
        }
      }

      this.startChatButton.addEventListener("click", event => {
        event.preventDefault()
        this.startChat()
      })

      this.startChat = function(){
        if (this.chatStarted) { return false }
        chat.chatStarted = true
        chat.swapClass(this.chatBox, "inactive", "loading")
        chat.requestChatSession(
          function(chatSessionInfo){
            if (chatSessionInfo.error) {
              chat.displayError(chatSessionInfo.error)
              return false
            }
            chat.swapClass(chat.chatBox, "loading", "active")

            chat.channel_name          = chatSessionInfo.channel_name
            chat.user_name             = chatSessionInfo.user_name
            // TODO - ask the user for a name if none found
            chat.user_id_token         = chatSessionInfo.user_id_token
            chat.conversation_id_token = chatSessionInfo.conversation_id_token

            if (!chat.userIsCsRep) {
              cookie.write("conversationId", chat.conversation_id_token)
            }

            chat.closeChatButton.addEventListener("click", event => {
              chat.closeChat()
            })

            chat.socket = new socketModule("/consult_socket", {})
            chat.socket.connect()
            chat.channel = chat.socket.channel(chatSessionInfo.channel_name, {conversation_id_token: chatSessionInfo.conversation_id_token})
            chat.channel.on("new_msg", payload => chat.addMessage(payload.timestamp, payload.from, payload.body))
            chat.channel.on("conversation_closed", _response => { chat.disable() })

            chat.channel.join()
            .receive("ok", resp => console.log("Joined successfully", resp))
            .receive("error", resp => console.log("Unable to join", resp))

            chat.onSubmit( (body, user_name, user_id_token) => {
              chat.channel.push("new_msg", {
                body: body,
                user_name: user_name,
                user_id_token: user_id_token,
              })
              .receive("ok", response => {
                // TODO - uh, this is useless, right? handled above?
                response.messages.forEach(body => chat.addMessage(response.from, body))
              })
            })
          }
        )
      }

      this.requestChatSession = function(handleSessionInfo) {
        let url = null
        if (this.userIsCsRep) {
          url = `/consult/api/give_help/${this.chatBox.dataset.conversationId}`
        } else {
          let conversation_id = cookie.read("conversationId")
          url = `/consult/api/get_help?conversation_id_token=${conversation_id}`
        }
        this.onAjaxSuccess("GET", url, handleSessionInfo)
      }

      this.onSubmit = function(submitHandler) {
        let enterKeyCode = 13
        this.chatInput.addEventListener("keypress", event => {
          if(event.keyCode === enterKeyCode && !event.shiftKey) {
            let message = this.chatInput.value.trim()
            if (!this.isBlank(message)) {

              submitHandler(message, this.user_name, this.user_id_token)
              this.chatInput.value = ""
            }
            event.preventDefault() // don't insert a new line
          }
        })
      }

      this.addMessage = function(timestamp, from, message) {
        let newMessage = document.createElement("div")
        newMessage.innerHTML = `<span class="chatterbox-message-sender">${from}</span> <span class="chatterbox-message-timestamp">${timestamp}</span> <span class="chatterbox-message-contents">${message}</span>`
        newMessage.className = "chatbox-message"
        chatMessages.appendChild(newMessage)
        chatMessages.scrollTop = chatMessages.scrollHeight // scroll to bottom
      }

      this.onAjaxSuccess = function(verb, url, callback) {
        let httpRequest = new XMLHttpRequest();

        if (!httpRequest) {
          console.log('Giving up :( Cannot create an XMLHTTP instance');
          return false;
        }
        httpRequest.onreadystatechange = function() {
          if (httpRequest.readyState === XMLHttpRequest.DONE) {
            if (httpRequest.status === 200) {
              callback(
                JSON.parse(httpRequest.responseText)
              )
            } else {
              console.log('There was a problem with the request.');
            }
          }
        }
        httpRequest.open(verb, url);
        httpRequest.send();
      }

      this.displayError = function(message) {
        let errorDiv = document.createElement("div")
        errorDiv.setAttribute("class", "chatbox-error")
        errorDiv.innerHTML = message
        this.chatBox.appendChild(errorDiv)
      }

      this.closeChat = function() {
        // TODO - don't send this request if we know the conversation is already closed
        this.onAjaxSuccess(
          "PUT",
          `/consult/api/close_conversation/${this.conversation_id_token}`, (chatSessionInfo) => {
            cookie.erase("conversationId")
            this.chatSessionCleared = true
            this.channel.push("conversation_closed", {
              ended_at: chatSessionInfo.ended_at,
              ended_by: this.user_name,
              user_id_token: this.user_id_token,
            })
            if (!this.userIsCsRep) {
              this.reset()
            }
          }
        )
      }

      this.disable = function() {
        // may happen after reset or before,
        // depending on which party hangs up
        this.swapClass(this.chatBox, "active", "ended")
        chat.socket.disconnect()
        if (this.userIsCsRep) {
          this.closeChatButton.parentNode.removeChild(this.closeChatButton)
        }
      }

      this.reset = function() {
        chatMessages.innerHTML = ""
        this.chatBox.className = "inactive"
        this.chatStarted = false
      }

      this.isBlank = function(string) {
        return (!string || /^\s*$/.test(string))
      }

      this.swapClass = function(element, oldClass, newClass) {
        let classes = element.className.trim().split(/\s+/)
        let oldIndex = classes.indexOf(oldClass)
        if (oldIndex !== -1) {
          classes[oldIndex] = newClass
          element.className = classes.join(" ")
        }
      }

    }

    let chat = new Chat()
    chat.checkAndMaybeStart()
  }

  if (document.getElementById("chatterbox-dashboard") !== null) {
    let main = document.getElementById("main")

    let socket = new socketModule("/consult_socket", {})
    socket.connect()
    let channel = socket.channel("cs_panel", {})

    channel.on("update", payload => {
      main.innerHTML = payload.main_contents
    })

    channel.join()
    .receive("ok", resp => console.log("Joined successfully", resp))
    .receive("error", resp => console.log("Unable to join", resp))
  }
}
