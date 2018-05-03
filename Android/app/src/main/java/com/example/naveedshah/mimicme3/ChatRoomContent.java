package com.example.naveedshah.mimicme3;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.*;
import java.util.Iterator;

public class ChatRoomContent {

    public static List<ChatRoom> ITEMS = new ArrayList<ChatRoom>();

    public static final Map<String, ChatRoom> ITEM_MAP = new HashMap<String, ChatRoom>();

    private static void addItem(ChatRoom item) {
        ITEMS.add(item);
        ITEM_MAP.put(item.id, item);
    }

    public static void getData() {
        // make json call here

        new Thread() {
            public void run() {
                HttpURLConnection conn = null;
                try {

                    URL url = new URL("http://10.0.2.2:8000/chatrooms");

                    conn = (HttpURLConnection) url.openConnection();

                    int counter = 1;

                    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));

                    StringBuilder sb = new StringBuilder();
                    String line;

                    // Obtain and record response from back-end server
                    while ((line = br.readLine()) != null) {
                        sb.append(line);
                    }
                    br.close();

                    try {

                        JSONObject json = new JSONObject(sb.toString());

                        Iterator<String> iter = json.keys();

                        while (iter.hasNext()) {

                            String key = iter.next();

                            addItem(createChatRoom(counter, json.getString(key)));

                            counter++;

                        }

                    } catch (JSONException e) {

                    }

                } catch (IOException e) {

            } finally {
                if (conn != null) {
                    conn.disconnect();
                }
            }
            }
        }.start();

    }

    private static ChatRoom createChatRoom(int position, String description) {
        return new ChatRoom(String.valueOf(position), description, makeDetails(position));
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
