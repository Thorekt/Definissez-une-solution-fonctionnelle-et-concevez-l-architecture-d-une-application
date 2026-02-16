import { Component } from '@angular/core';
import ChatComponent from './component/chat/chat.component';

@Component({
  selector: 'app-root',
  imports: [ ChatComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'front';
}
