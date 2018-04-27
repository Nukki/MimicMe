package com.example.naveedshah.mimicme3;

// Libraries and files to import
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import java.net.HttpURLConnection;
import java.io.*;
import android.util.*;
import java.net.*;
import android.content.Intent;
import org.json.*;
import android.support.design.widget.Snackbar;


public class LoginActivity extends AppCompatActivity {

    // UI references.
    private AutoCompleteTextView mEmailView;
    private AutoCompleteTextView mNameView;
    private EditText mPasswordView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login); // Connect to activity_login.xml

        // Set up the login form.
        mEmailView = (AutoCompleteTextView) findViewById(R.id.email);
        mPasswordView = (EditText) findViewById(R.id.password);
        mPasswordView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_ACTION_DONE || id == EditorInfo.IME_NULL) {
                    attemptLogin();
                    return true;
                }
                return false;
            }
        });

        mNameView = (AutoCompleteTextView) findViewById(R.id.name);

        Button mEmailSignInButton = (Button) findViewById(R.id.email_sign_in_button);
        mEmailSignInButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptLogin();
            }
        });
    }


    private void attemptLogin() {

        // Reset errors.
        mEmailView.setError(null);
        mPasswordView.setError(null);
        mNameView.setError(null);

        // Store values at the time of the login attempt.
        final String email = mEmailView.getText().toString();
        final String password = mPasswordView.getText().toString();
        final String name = mNameView.getText().toString();

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            mPasswordView.setError(getString(R.string.error_invalid_password));
            focusView = mPasswordView;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(email)) {
            mEmailView.setError(getString(R.string.error_field_required));
            focusView = mEmailView;
            cancel = true;
        } else if (!isEmailValid(email)) {
            mEmailView.setError(getString(R.string.error_invalid_email));
            focusView = mEmailView;
            cancel = true;
        }

        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            // There was no error with front-end validations. Attempt to login with
            // the backend
            new Thread() {

               public void run() {

                   HttpURLConnection conn = null;
                    try {

                        // port to connect to Django server
                        URL url = new URL("http://10.0.2.2:8000/login");

                        conn = (HttpURLConnection) url.openConnection();
                        conn.setRequestMethod("POST");

                        // Send information user entered as a JSON object to the backend
                        JSONObject jsonObject = new JSONObject();
                        try {
                            jsonObject.put("email", email);
                            jsonObject.put("password", password);
                            jsonObject.put("name", name);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                        // http://10.0.2.2:8000/user/login
                        // http://10.0.2.2:8000/user/register

                        DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
                        wr.writeBytes(jsonObject.toString());
                        wr.flush();
                        wr.close();


                        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));

                        StringBuilder sb = new StringBuilder();
                        String line;

                        // Obtain and record response from back-end server
                        while ((line = br.readLine()) != null) {
                            sb.append(line + "\n");
                        }
                        br.close();

                        // If the server returns a login-success response, launch the RecyclerActivity which contains the list of chatrooms
                        if (sb.toString().contains("Login success!")) {

                            Intent myIntent = new Intent(LoginActivity.this, RecyclerActivity.class);
                            startActivity(myIntent);

                        // If the server returns that the password is wrong, show a Snackbar message to alert the user
                        }  else if (sb.toString().contains("Wrong password")) {

                            Snackbar mySnackbar;
                            mySnackbar = Snackbar.make(findViewById(R.id.login_view),"Incorrect Password",3000);
                            mySnackbar.show();

                         // If the server returns that the account is not registered, alert user and send them SignUpActivity
                        } else if (sb.toString().contains("Account not found. User does not exist")) {

                            Snackbar mySnackbar;
                            mySnackbar = Snackbar.make(findViewById(R.id.login_view),"This email is not registered",3000);
                            mySnackbar.show();
                            // see if I can put a delay here.
                            Intent myIntent = new Intent(LoginActivity.this, SignUpActivity.class);
                            startActivity(myIntent);
                        }

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
    }

    // Checks if the inputted email contains a "@" symbol
    private boolean isEmailValid(String email) {
        return email.contains("@");
    }

    // Checks to ensure that password is atleast 6 characters long
    private boolean isPasswordValid(String password) {
        // Password must be atleast 6 characters
        return password.length() >= 6;
    }


}

