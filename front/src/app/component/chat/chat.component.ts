import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import ChatService from '../../service/Chat.service';
import Message from '../../type/Message.type';
import { FormsModule } from '@angular/forms';

/**
 * ChatComponent
 * 
 * This component provides a user interface for a chat application. 
 * It allows users to join a chat room, send messages, and view messages from other users in real-time.
 * The component uses the ChatService to manage WebSocket connections and message handling.
 */
@Component({
  selector: 'chat-component',
  imports: [CommonModule, FormsModule],
  templateUrl: './chat.component.html',
  styleUrl: './chat.component.scss'
})
class ChatComponent {
  isConnected = false;
  chatService: ChatService;

  roomName = '';
  senderName = '';
  messageContent = '';

  messages: Message[] = [];

  /**
   * Constructor for ChatComponent. 
   * It initializes the ChatService and 
   * sets up subscriptions to connection status and incoming messages.
   * 
   * @param chatService 
   */
  constructor(chatService: ChatService) {
    this.chatService = chatService;
    this.chatService.isConnected().subscribe(connected => {
      this.isConnected = connected;
    });
    this.chatService.getMessages().subscribe(message => {
      this.messages.push(message);
    });
  }

  /**
   * This method is called when the user clicks the "Join Room" button.
   * It validates the room name and sender name, and if valid, 
   * it calls the ChatService to connect to the WebSocket server for the specified room.
   */
  joinRoom() {    
    console.log('Room:', this.roomName);
    console.log('Sender:', this.senderName);

    if(this.roomName.trim() === '' || this.senderName.trim() === '') {
      alert('Room name and sender name are required');
      return;
    }

    this.chatService.connect(this.roomName);
  }

  /**
   * This method is called when the user clicks the "Leave Room" button.
   * It calls the ChatService to disconnect from the WebSocket server and 
   * clears the message list.
   */
  leaveRoom() {
    this.chatService.disconnect();
    this.messages = [];
  }

  /**
   * This method is called when the user clicks the "Send Message" button.
   * It validates the message content, and if valid, 
   * it creates a Message object and sends it via the ChatService.
   */
  sendMessage() {
    console.log('Message content:', this.messageContent);
    if(this.messageContent.trim() === '') {
      alert('Message content cannot be empty');
      return;
    }

    const message: Message = {
      room: this.roomName,
      sender: this.senderName,
      content: this.messageContent
    };

    this.chatService.sendMessage(message);  
    this.messageContent = '';
  }
}

export default ChatComponent;