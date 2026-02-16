package com.poc.api.controller;

import org.springframework.web.bind.annotation.*;

import com.poc.api.dto.MessageDTO;
import com.poc.api.service.ChatService;

import java.util.List;

@RestController
@RequestMapping("/api/room")
public class ChatHistoryController {

    private final ChatService chatService;

    public ChatHistoryController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping("/{room}")
    public List<MessageDTO> history(
            @PathVariable String room) {

        return chatService.getMessagesByRoom(room);
    }
}
