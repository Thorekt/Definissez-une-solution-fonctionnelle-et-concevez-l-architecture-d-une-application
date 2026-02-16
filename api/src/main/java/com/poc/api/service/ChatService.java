package com.poc.api.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.poc.api.dto.MessageDTO;
import com.poc.api.model.MessageEntity;
import com.poc.api.repository.MessageRepository;

import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final MessageRepository messageRepository;

    @Transactional
    public void saveMessage(MessageDTO message) {
        MessageEntity messageEntity = MessageEntity.builder()
                .room(message.room())
                .sender(message.sender())
                .content(message.content())
                .build();
        messageRepository.save(messageEntity);
    }

    @Transactional(readOnly = true)
    public List<MessageDTO> getMessagesByRoom(String room) {
        return messageRepository.findByRoomOrderByCreatedAtAsc(room).stream()
                .map(MessageEntity::toDTO)
                .toList();
    }
}
