package com.cueaudio.engine_consumer;

import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.Editable;
import android.text.Selection;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.cueaudio.engine.CUEEngine;
import com.cueaudio.engine.CUEReceiverCallbackInterface;
import com.google.gson.Gson;

public class MainActivity extends AppCompatActivity {
    private static final int REQUEST_RECORD_AUDIO = 13;
    private static final String API_KEY = "H7v7NMMNh6im735w331iLHtqnduxGCTL";

    private EditText sndArea;
    private Button sendButton;
    private TextView outputView;

    /**
     * Used to parse engine callback.
     */
    private final Gson gson = new Gson();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        checkPermission();

        sndArea = findViewById(R.id.sndArea);
        sendButton = findViewById(R.id.sendButton);
        outputView = findViewById(R.id.outputView);

        outputView.setMovementMethod(new ScrollingMovementMethod());

        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
               //rcvArea.setText("");
               String sndString = sndArea.getText().toString();
               CUEEngine.getInstance().transmitMessage(sndString);
               for (char c : sndString.toCharArray()) {
                   CUEEngine.getInstance().sendChar(c);
               }
            }
        });

        findViewById(R.id.startButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CUEEngine.getInstance().startListening();
            }
        });
        findViewById(R.id.stopButton).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CUEEngine.getInstance().stopListening();
            }
        });
    }

    private void checkPermission() {
        ActivityCompat.requestPermissions(
                this,
                new String[] { android.Manifest.permission.RECORD_AUDIO },
                REQUEST_RECORD_AUDIO
        );
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        //check if permission was granted, and confirm that permission was mic access
        boolean permCondition = requestCode == REQUEST_RECORD_AUDIO &&
                                grantResults.length == 1 &&
                                grantResults[0] == PackageManager.PERMISSION_GRANTED;
        // permission is not granted yet
        if (!permCondition) {
            checkPermission();
            return;
        }

        CUEEngine.getInstance().setupWithAPIKey(this, API_KEY);

        CUEEngine.getInstance().setReceiverCallback(new OutputListener());
        CUEEngine.getInstance().startListening();

        String s = CUEEngine.getInstance().getConfig();
        Log.v("AndroidConsumer", s);
    }

    /**
     * Used to parse engine callback json.
     * @param json JSON string to be parsed
     * @return callback model
     */
    private CUETrigger parse(@NonNull String json) {
        final long initTime = System.currentTimeMillis();
        final CUETrigger model = gson.fromJson(json, CUETrigger.class);
        final long parsingDelay = System.currentTimeMillis() - initTime;
        return model.withParseLatency(parsingDelay);
    }

    private class OutputListener implements CUEReceiverCallbackInterface {
        @Override
        public void run(String json) {
            final CUETrigger model = parse(json);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    outputView.append(model.toString());
                    outputView.append("\n");
                    outputView.append("\n");

                    // scroll to end
                    // https://stackoverflow.com/a/43290961
                    Editable editable = (Editable) outputView.getText();
                    Selection.setSelection(editable, editable.length());
                }
            });
        }
    }

}
