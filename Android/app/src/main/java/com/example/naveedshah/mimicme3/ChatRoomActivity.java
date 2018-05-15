package com.example.naveedshah.mimicme3;
import android.app.Activity;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.ListView;
import android.widget.Button;
import android.content.Intent;
import android.widget.EditText;
import android.os.Bundle;
import android.view.View;
import android.widget.AbsListView;
import android.database.DataSetObserver;
import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONException;
import org.json.JSONObject;
import java.net.URI;
import java.net.URISyntaxException;


public class ChatRoomActivity extends Activity {
    private static final String TAG = "ChatActivity";
    WebSocketClient mWebSocketClient;
    private ChatArrayAdapter adp;
    private ListView list;
    private EditText chatText;
    private Button send;
    private String roomNumber = null;
    private Integer userId = null;
    private String username = null;
    private boolean side = false;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent i = getIntent();
        connectWebSocket();
        setContentView(R.layout.chat_room_activity);

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        userId = preferences.getInt("uid",0);
        username = preferences.getString("username",null);
        roomNumber = preferences.getString("room",null);

        Log.d("userId",userId.toString());
        Log.d("username",username);
        Log.d("roomNumber",roomNumber);

        send = (Button) findViewById(R.id.btn);
        list = (ListView) findViewById(R.id.listview);
        adp = new ChatArrayAdapter(getApplicationContext(), R.layout.chat_room_activity);
        list.setAdapter(adp);
        chatText = (EditText) findViewById(R.id.chat_text);
        send.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View arg0) {
                sendChatMessage();
            }
        });
        list.setTranscriptMode(AbsListView.TRANSCRIPT_MODE_ALWAYS_SCROLL);
        list.setAdapter(adp);
        adp.registerDataSetObserver(new DataSetObserver() {
            public void OnChanged(){
                super.onChanged();
                list.setSelection(adp.getCount() -1);
            }
        });
    }

    private boolean sendChatMessage() {
        side = false;
        runOnUiThread(new Runnable() {

            @Override
            public void run() {

                adp.add(new ChatMessage(side, chatText.getText().toString()));

            }
        });


        if (mWebSocketClient.isClosed()) {

            mWebSocketClient.reconnect();
        }

        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("command", "send");
            jsonObject.put("room", roomNumber);
            jsonObject.put("message", chatText.getText().toString());
            jsonObject.put("username", username);
            jsonObject.put("uid", userId);

        } catch (JSONException e) {
            e.printStackTrace();
        }

        mWebSocketClient.send(jsonObject.toString());

        chatText.setText("");
        return true;
    }

    private void connectWebSocket() {

        new Thread() {

            public void run() {

                URI uri;
                try {
                    uri = new URI("ws://159.65.38.56:8000/socket");
                } catch (URISyntaxException e) {
                    e.printStackTrace();
                    return;
                }

                mWebSocketClient = new WebSocketClient(uri) {
                    @Override
                    public void onOpen(ServerHandshake serverHandshake) {
                        Log.i("Websocket", "Opened");

                        JSONObject jsonObject2 = new JSONObject();
                        try {
                            jsonObject2.put("command", "join");
                            jsonObject2.put("room", roomNumber);
                            jsonObject2.put("username", username);
                            jsonObject2.put("uid", userId);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        mWebSocketClient.send(jsonObject2.toString());

                    }

                    @Override
                    public void onMessage(final String s) {
                        side = true;

                        Long tsLong = System.currentTimeMillis()/1000;
                        String ts = tsLong.toString();

                        Log.d("timestamp",ts);
                        Log.d("from server:",s.toString());

                        runOnUiThread(new Runnable() {

                            @Override
                            public void run() {

                                try {
                                    JSONObject json_obj=new JSONObject(s.toString());
                                    String value1=json_obj.getString("username");
                                    if (!value1.equals(username)) {
                                        String value2=json_obj.getString("message");
                                        adp.add(new ChatMessage(side,value2));
                                    }

                                } catch (JSONException e) {
                                    Log.d("JSON Exception: ", e.toString());
                                }

                            }
                        });

                    }

                    @Override
                    public void onClose(int i, String s, boolean b) {
                        Log.i("Websocket", "Closed " + s);
                    }

                    @Override
                    public void onError(Exception e) {
                        Log.i("Websocket", "Error " + e.getMessage());
                    }
                };
                mWebSocketClient.connect();

            }
        }.start();
    }
}