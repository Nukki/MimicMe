package com.example.naveedshah.mimicme5;

import java.util.Date;

/**
 * Created by NaveedShah on 4/7/18.
 */

public class Message {
    private String messageText;
    private String messageUser;
    private long messageTime;

    public Message(String messageText, String messageUser) {
        this.messageText = messageText;
        this.messageUser = messageUser;

        messageTime = new Date().getTime();
    }

    public Message() {

    }

    public String getMessageText() {
        return messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public String getMessageUser() {
        return this.messageUser;
    }

    public void setMessageUser(String messageUser) {
        this.messageUser = messageUser;
    }

    public long getMessageTime() {
        return messageTime;
    }

    public void setMessageTime(long messagetime) {
        this.messageTime = messagetime;
    }
}



