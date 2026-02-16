package com.poc.api.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.poc.api.model.MessageEntity;

public interface MessageRepository extends JpaRepository<MessageEntity, Long> {
    List<MessageEntity> findByRoomOrderByCreatedAtAsc(String room);
}
