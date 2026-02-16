/**
 * ChatMessage.ts
 * 
 * This file defines the ChatMessage type, which represents a message sent in a chat room.
 * It includes the room name, sender's name, and the content of the message.
 * 
 * @param {string} room - The name of the chat room where the message was sent.
 * @param {string} sender - The name of the sender of the message.
 * @param {string} content - The content of the message.
 */
type Message = {
  room: string;
  sender: string;
  content: string;
};

export default Message;