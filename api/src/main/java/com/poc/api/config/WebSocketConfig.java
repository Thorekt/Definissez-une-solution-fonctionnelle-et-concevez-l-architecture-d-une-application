package com.poc.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    /**
     * Registers the WebSocket endpoint for STOMP messaging.
     * 
     * @param registry the registry to which the endpoint will be added
     */
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Register the WebSocket endpoint at "/ws"
        registry.addEndpoint("/ws")
                // All origins are allowed to connect to the WebSocket endpoint
                .setAllowedOriginPatterns("*");
    }

    /**
     * Configures the message broker for routing messages to message-handling
     * methods and enabling a simple in-memory message broker.
     * 
     * @param registry the registry to which the message broker will be configured
     */
    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Set the prefix for messages that will be routed to message-handling methods
        registry.setApplicationDestinationPrefixes("/app");

        // Enable a simple in-memory message broker and set the destination prefixes for
        // topics and queues
        registry.enableSimpleBroker("/topic", "/queue");
    }

}
