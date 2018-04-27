package com.example.naveedshah.mimicme3;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import android.util.Log;

public class ChatRoomContent {

    public static List<ChatRoom> ITEMS = new ArrayList<ChatRoom>();

    public static final Map<String, ChatRoom> ITEM_MAP = new HashMap<String, ChatRoom>();

    private static final int COUNT = 25;

    private static void addItem(ChatRoom item) {
        ITEMS.add(item);
        ITEM_MAP.put(item.id, item);
    }

    public static void insertDummyData() {
        Log.d("checkpoint","2");
        for (int i = 1; i <= COUNT; i++) {
            addItem(createChatRoom(i));
            Log.d("checkpoint","yaay");
        }
    }

    private static ChatRoom createChatRoom(int position) {
        return new ChatRoom(String.valueOf(position), "Item " + position, makeDetails(position));
    }

    private static String makeDetails(int position) {
        StringBuilder builder = new StringBuilder();
        builder.append("Details about Item: ").append(position);
        for (int i = 0; i < position; i++) {
            builder.append("\nMore details information here.");
        }
        return builder.toString();
    }

    public static class ChatRoom {
        public final String id;
        public final String content;
        public final String details;

        public ChatRoom(String id, String content, String details) {
            this.id = id;
            this.content = content;
            this.details = details;
        }

        @Override
        public String toString() {
            return content;
        }
    }
}
