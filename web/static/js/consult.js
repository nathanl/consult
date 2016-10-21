// usage in app:
// let consult = new Consult(Socket)
// consult.enable()

let Consult = exports.Consult = function Consult(socketModule) {
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

  this.enable = function() {
    if (document.getElementById("consult-chatbox") !== null) {
      let Chat = function Chat() {
        this.chatBox               = document.getElementById("consult-chatbox")
        this.chatInput             = this.chatBox.getElementsByTagName("textarea")[0]
        this.startChatButton       = this.chatBox.getElementsByClassName("start-chat")[0]
        let chatMessages           = this.chatBox.getElementsByClassName("messages")[0]
        this.closeChatButton       = this.chatBox.getElementsByClassName("close-chat")[0]

        this.userIsRep   = !!this.chatBox.className.match("representative")

        this.checkAndMaybeStart = function(){
          let inChatSession = !!cookie.read("conversationIdToken")

          if (inChatSession || this.userIsRep) {
            this.startChat()
          }
        }

        this.startChatButton.addEventListener("click", event => {
          event.preventDefault()
          this.startChat()
        })

        this.closeChatButton.addEventListener("click", event => {
          chat.closeChat()
        })

        this.chatInput.addEventListener("keypress", event => {
          let enterKeyCode = 13
          if(event.keyCode === enterKeyCode && !event.shiftKey) {
            let message = this.chatInput.value.trim()
            if (!this.isBlank(message)) {
              this.channel.push("new_msg", { body: message })
              this.chatInput.value = ""
            }
            event.preventDefault() // don't insert a new line
          }
        })

        this.startChat = function(){
          if (this.connectionIsOpen()) { return false }
          chat.swapClass(this.chatBox, "inactive", "loading")
          chat.requestChatSession(
            function(chatSessionInfo){
              if (chatSessionInfo.error) {
                chat.displayError(chatSessionInfo.error)
                return false
              }
              chat.swapClass(chat.chatBox, "loading", "active")
              chat.user_public_identifier = chatSessionInfo.user_public_identifier

              if (!chat.userIsRep) {
                cookie.write("conversationIdToken", chatSessionInfo.conversation_id_token)
              }

              chat.openConnection(chatSessionInfo)
            }
          )
        }

        this.requestChatSession = function(handleSessionInfo) {
          let url = null
          if (this.userIsRep) {
            url = `/consult/api/give_help/${this.chatBox.dataset.conversationId}`
          } else {
            let conversation_id = cookie.read("conversationIdToken")
            url = `/consult/api/get_help?conversation_id_token=${conversation_id}`
          }
          this.onAjaxSuccess("GET", url, handleSessionInfo)
        }

        this.addMessage = function(timestamp, from, message, userPublicIdentifier) {
          if (!this.socket) { return }
          let newMessage = document.createElement("div")
          newMessage.innerHTML = `<span class="message-sender">${from}</span> <span class="message-timestamp">${timestamp}</span> <span class="message-contents">${message}</span>`
          let isMe = this.trimmedEqual(userPublicIdentifier, chat.user_public_identifier)
          let personTag = isMe ? "mine" : null
          newMessage.className = this.compactedString(["message", personTag])
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
          if (this.connectionIsOpen()) {
            this.channel.push("conversation_closed", {})
          }
          if (this.userIsRep) {
            // Don't disconnect yet. Wait for notification, and in the
            // meantime, display the "conversation closed" message
            // that will bounce back
            this.disableChat()
          } else {
            this.resetChat()
          }
        }

        this.openConnection = function(chatSessionInfo) {
          chat.socket = new socketModule("/consult_socket", {})
          chat.socket.connect()
          chat.channel = chat.socket.channel(
            chatSessionInfo.channel_name,
            {
              conversation_id_token: chatSessionInfo.conversation_id_token,
              user_role_token: chatSessionInfo.user_role_token,
              // TODO - ask the user for a name if none found
              user_name: chatSessionInfo.user_name,
              user_id_token: chatSessionInfo.user_id_token,
            }
          )
          chat.channel.on("new_msg", function(payload) {
            chat.addMessage(
              payload.timestamp,
              payload.from,
              payload.body,
              payload.user_public_identifier
            )
          })
          chat.channel.on("conversation_closed", function(_response) { chat.reactToChatClosing() })

          chat.channel.join()
          .receive("ok", resp => console.log("Joined successfully", resp))
          .receive("error", resp => console.log("Unable to join", resp))
        }

        this.connectionIsOpen = function() {
          return !!(this.socket && this.channel)
        }

        this.closeConnection = function() {
          if (this.socket) { this.socket.disconnect() }
          this.socket = null
          this.channel = null
        }

        this.reactToChatClosing = function() {
          this.closeConnection()
          this.disableChat()
        }

        this.disableChat = function() {
          this.swapClass(this.chatBox, "active", "ended")
        }

        this.resetChat = function() {
          this.closeConnection()
          cookie.erase("conversationIdToken")
          chatMessages.innerHTML = ""
          this.chatBox.className = "inactive"
        }

        this.isBlank = function(string) {
          return (!string || /^\s*$/.test(string))
        }

        this.swapClass = function(element, oldClass, newClass) {
          let classes = element.className.trim().split(/\s+/)
          let oldIndex = classes.indexOf(oldClass)
          if (oldIndex !== -1) {
            classes[oldIndex] = newClass
            element.className = this.compactedString(classes)
          }
        }

        this.compactedString = function(inputArray) {
          let cleaned = []
          for(i = 0; i < inputArray.length; i++ ) {
            if(inputArray[i] !== null) {
              cleaned.push(inputArray[i])
            }
          }
          return cleaned.join(" ")
        }

        this.trimmedEqual = function(stringOne, stringTwo) {
          let oneTrimmed = stringOne.trim()
          let twoTrimmed = stringTwo.trim()
          return oneTrimmed == twoTrimmed
        }
      }

      let chat = new Chat()
      chat.checkAndMaybeStart()
    }

    if (document.getElementById("consult-dashboard") !== null) {
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
}
