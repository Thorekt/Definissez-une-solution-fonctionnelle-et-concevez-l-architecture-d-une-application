package com.poc.api.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.poc.api.dto.ChatMessage;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ChatWsController {

    private final SimpMessagingTemplate messagingTemplate;

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
    public void sendMessage(ChatMessage message) {
        // Log the received message for debugging purposes
        System.out.println("Received message: " + message);

        messagingTemplate.convertAndSend("/topic/room." + message.room(), message);
    }
}
