package com.poc.api.dto;

/**
 * Represents a chat message with a room, sender, and content.
 *
 * @param room    the chat room to which the message belongs
 * @param sender  the name of the sender of the message
 * @param content the content of the chat message
 */
public record MessageDTO(String room, String sender, String content) {

}
