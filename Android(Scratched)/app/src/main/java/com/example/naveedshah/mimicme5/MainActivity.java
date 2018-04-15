package com.example.naveedshah.mimicme5;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.text.format.DateFormat;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;


public class MainActivity extends AppCompatActivity {

    // Integer to indiciate a sign-in request
    private static int SIGN_IN_REQUEST_CODE = 1;

    // Keep track of user signed-in
    boolean userSignedIn = false;
    RelativeLayout activity_main;

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if(item.getItemId() == R.id.menu_sign_out)
        {
            AuthUI.getInstance().signOut(this).addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    Snackbar.make(activity_main,"You have been signed out.", Snackbar.LENGTH_SHORT).show();
                    finish();
                }
            });
        }
        return true;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu,menu);
        return true;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == SIGN_IN_REQUEST_CODE)
        {
            if(resultCode == RESULT_OK)
            {
                userSignedIn = true;
                Snackbar.make(activity_main,"Successfully signed in.Welcome!", Snackbar.LENGTH_SHORT).show();
                displayMessage();
            }
            else{
                Snackbar.make(activity_main,"We couldn't sign you in.Please try again later", Snackbar.LENGTH_SHORT).show();
                finish();
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        activity_main = (RelativeLayout)findViewById(R.id.activity_main);


        // If there is no user signed-in, prompt them to sign in

        if(userSignedIn == false)
        {

            // implement Django Sign-in here
            new Thread() {
                HttpURLConnection conn = null;

                public void run() {
                    try {

                        URL url = new URL("http://10.0.2.2:8000/login");
                        conn = (HttpURLConnection) url.openConnection();
                        conn.setRequestMethod("POST");

                        conn.setRequestProperty("email", "test@gmail.com");
                        conn.setRequestProperty("password", "abcabc");
                        conn.setRequestProperty("name", "testing123");


                        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));

                        StringBuilder sb = new StringBuilder();
                        String line;

                        while ((line = br.readLine()) != null) {
                            sb.append(line + "\n");
                        }

                        br.close();
                        Log.d("INCOMING ", sb.toString());


                    } catch (IOException e) {
                        Log.e("MYAPP", "exception for connection:", e);
                    } finally {
                        if (conn != null) {
                            conn.disconnect();
                        }
                    }
                }
            }.start();

        }
        else
        {
            Snackbar.make(activity_main,"Welcome",Snackbar.LENGTH_SHORT).show();
            //Load content
            displayMessage();
        }


    }



    private void displayMessage() {

        // OLD FIREBASE CODE TO BE REPLACED WITH NEW CODE FOR DJANGO SERVER

//        ListView listOfMessage = (ListView)findViewById(R.id.list_of_message);
//        adapter = new FirebaseListAdapter<Message>(this,Message.class,R.layout.list_item,FirebaseDatabase.getInstance().getReference())
//        {
//            @Override
//            protected void populateView(View v, Message model, int position) {
//
//                //Get references to the views of list_item.xml
//                TextView messageText, messageUser, messageTime;
//                messageText = (TextView) v.findViewById(R.id.message_text);
//                messageUser = (TextView) v.findViewById(R.id.message_user);
//                messageTime = (TextView) v.findViewById(R.id.message_time);
//
//                messageText.setText(model.getMessageText());
//                messageUser.setText(model.getMessageUser());
//                messageTime.setText(DateFormat.format("dd-MM-yyyy (HH:mm:ss)", model.getMessageTime()));
//
//            }
//        };
//        listOfMessage.setAdapter(adapter);
    }
}

