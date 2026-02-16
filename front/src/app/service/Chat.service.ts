import { Injectable, OnDestroy } from '@angular/core';
import { Client, StompSubscription } from '@stomp/stompjs';
import { BehaviorSubject, Observable, Subject } from 'rxjs';
import Message from '../type/Message.type';
import { HttpClient } from '@angular/common/http';



@Injectable(
    {
        providedIn: 'root'
    }
)
class ChatService implements OnDestroy {
    private readonly API_URL = 'http://localhost:8080/api/room';
    private readonly WS_URL = 'ws://localhost:8080/ws';
    private readonly TOPIC_PREFIX = '/topic/room.';


    private stompClient?: Client;
    
    private subscription?: StompSubscription;

    private connected$ = new BehaviorSubject<boolean>(false);
    private messages$ = new Subject<Message>();

    constructor(private httpClient: HttpClient) {}
    
    isConnected(): Observable<boolean>  {
        return this.connected$.asObservable();
    }

    getMessages(): Observable<Message> {
        return this.messages$.asObservable();
    }

    connect(roomName: string): void {
        if(this.stompClient?.active) {
            console.warn('Already connected to WebSocket');
            return;
        }
        this.retrieveHistory(roomName);        
        this.connectStompClient(roomName);        
    }

    retrieveHistory(roomName: string): void {
        this.httpClient.get<Message[]>(this.API_URL + '/' + roomName )
            .subscribe({
                next: (messages) => {
                    messages.forEach(message => this.messages$.next(message));
                },
                error: (err) => {
                    console.error('Failed to retrieve message history:', err);
                }
            });
    }

    connectStompClient(roomName: string): void {
        this.stompClient = new Client({
            brokerURL: this.WS_URL,
            reconnectDelay: 5000,
            debug: (str) => console.log(str)
        });

        this.stompClient.onConnect = () => this.onConnect(roomName);
        this.stompClient.activate();
    }
    
    
    onConnect(roomName: string): void {
        this.connected$.next(true);
        this.subscription = this.stompClient?.subscribe(this.TOPIC_PREFIX + roomName, (message) => {
            const chatMessage: Message = JSON.parse(message.body);
            this.messages$.next(chatMessage);
        });
    }

    disconnect(): void {
        this.subscription?.unsubscribe();
        this.subscription = undefined;
        this.stompClient?.deactivate();
        this.stompClient = undefined;
        this.connected$.next(false);
    }

    sendMessage(message: Message): void {
        if(!this.stompClient?.active) {
            console.warn('Cannot send message, WebSocket is not connected');
            return;
        }
        this.stompClient.publish({
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