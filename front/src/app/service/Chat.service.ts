import { Injectable, OnDestroy } from '@angular/core';
import { Client, StompSubscription } from '@stomp/stompjs';
import { BehaviorSubject, Observable, Subject } from 'rxjs';
import Message from '../type/Message.type';



@Injectable(
    {
        providedIn: 'root'
    }
)
class ChatService implements OnDestroy {
    private readonly WS_URL = 'ws://localhost:8080/ws';
    private readonly TOPIC_PREFIX = '/topic/room.';

    private client?: Client;
    private subscription?: StompSubscription;

    private connected$ = new BehaviorSubject<boolean>(false);
    private messages$ = new Subject<Message>();

    
    isConnected(): Observable<boolean>  {
        return this.connected$.asObservable();
    }

    getMessages(): Observable<Message> {
        return this.messages$.asObservable();
    }

    connect(roomName: string): void {
        if(this.client?.active) {
            console.warn('Already connected to WebSocket');
            return;
        }

        this.client = new Client({
            brokerURL: this.WS_URL,
            reconnectDelay: 5000,
            debug: (str) => console.log(str)
        });

        this.client.onConnect = () => this.onConnect(roomName);
        this.client.activate();
    }
    
    onConnect(roomName: string): void {
        this.connected$.next(true);
        this.subscription = this.client?.subscribe(this.TOPIC_PREFIX + roomName, (message) => {
            const chatMessage: Message = JSON.parse(message.body);
            this.messages$.next(chatMessage);
        });
    }

    disconnect(): void {
        this.subscription?.unsubscribe();
        this.subscription = undefined;
        this.client?.deactivate();
        this.client = undefined;
        this.connected$.next(false);
    }

    sendMessage(message: Message): void {
        if(!this.client?.active) {
            console.warn('Cannot send message, WebSocket is not connected');
            return;
        }
        this.client.publish({
            destination: '/app/chat.send',
            body: JSON.stringify(message)
        });
    }

    ngOnDestroy(): void {
        this.disconnect();        
        this.connected$.complete();
        this.messages$.complete();
    }
}

export default ChatService;