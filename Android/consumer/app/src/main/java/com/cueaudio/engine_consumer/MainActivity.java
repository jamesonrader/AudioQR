package com.cueaudio.engine_consumer;

//import android.content.Context;

import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.widget.TextView;

import com.cueaudio.engine.Config;
import com.cueaudio.engine.CUEEngine;
import com.cueaudio.engine.CUEEngineCallbackInterface;
import com.cueaudio.engine.ECM;

import java.sql.Wrapper;

public class MainActivity extends AppCompatActivity {
    private TextView mTextView;
    private static final int REQUEST_RECORD_AUDIO = 13;
    private static final String DEFAULT_CONFIG = Config.cfg_11C5x1;
    private static final String API_KEY = "PuVeNnczn1IqDJnqEzO4U85NapUSLGx8";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_activity);

        mTextView = findViewById(R.id.textView);

        ActivityCompat.requestPermissions(MainActivity.this, new String[]{
                android.Manifest.permission.RECORD_AUDIO}, REQUEST_RECORD_AUDIO);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        //check if permission was granted, and confirm that permission was mic access
        boolean permCondition = requestCode == REQUEST_RECORD_AUDIO &&
                                grantResults.length == 1 &&
                                grantResults[0] == PackageManager.PERMISSION_GRANTED;

        if(permCondition) {
            //run with valid API key or engine may take up to 5 min to re-authenticate
            CUEEngine.getInstance().setupWithConfig(this, DEFAULT_CONFIG, API_KEY);
            
            CUEEngine.getInstance().setTriggerCallback(new CUEEngineCallbackInterface() {
                @Override
                public void engineCallback(ECM mode, final int[] symbols) {
                    String trigger = null;
                    
                    switch (mode) {
                        case MODE_1_TONE:
                            trigger = String.format("%d", symbols[0]);
                            break;
                        case MODE_3_TONE:
                            trigger = String.format("%d,%d,%d", symbols[0], symbols[1], symbols[2]);
                            break;
                    }
                    
                    if(trigger != null) {
                        final String constTrigger = trigger;
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                mTextView.setText(constTrigger);
                            }
                        });
                    }
                }
            });
            CUEEngine.getInstance().startListening();
        }
    }
}
