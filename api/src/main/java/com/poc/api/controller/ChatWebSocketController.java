package com.poc.api.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.poc.api.dto.MessageDTO;
import com.poc.api.service.ChatService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final SimpMessagingTemplate messagingTemplate;

    private final ChatService chatService;

    /**
     * Handles incoming chat messages sent to the "/app/chat.send" destination.
     * It logs the received message and
     * then broadcasts it to all subscribers of the "/topic/room.{room}" topic,
     * where {room} is the room name from the message. *
     * 
     * @param message
     * @return
     */
    @MessageMapping("/chat.send")
    public void sendMessage(MessageDTO message) {
        // Log the received message for debugging purposes
        System.out.println("Received message: " + message);

        messagingTemplate.convertAndSend("/topic/room." + message.room(), message);
        // Save the message to the database using the ChatService
        chatService.saveMessage(message);
    }
}
