package com.cueaudio.engine_consumer;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.TextInputEditText;
import android.support.design.widget.TextInputLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.NotificationCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.Editable;
import android.text.InputType;
import android.text.Selection;
import android.text.TextWatcher;
import android.text.method.DigitsKeyListener;
import android.text.method.ScrollingMovementMethod;
import android.text.method.TextKeyListener;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;

import com.cueaudio.engine.CUEEngine;
import com.cueaudio.engine.CUEReceiverCallbackInterface;
import com.google.gson.Gson;

import java.util.regex.Pattern;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = "AndroidConsumer";

    private static final int REQUEST_RECORD_AUDIO = 13;
    private static final String API_KEY = "H7v7NMMNh6im735w331iLHtqnduxGCTL";
    private static final int NOTIFICATION_ID = 1;

    private static final int MODE_TRIGGER = 0;
    private static final int MODE_LIVE = 1;
    private static final int MODE_ASCII = 2;
    private static final int MODE_RAW = 3;

    private TextView outputView;
    private Switch outputMode;
    private View sendButton;
    private Spinner spinner;
    private TextInputLayout messageLayout;
    private TextInputEditText messageInput;

    private boolean isShown = false;

    /**
     * Used to parse engine callback.
     */
    private final Gson gson = new Gson();
    /**
     * Used to validate the input.
     */
    private Pattern inputMatcher = null;
    private String[] hints;
    private String[] regex;
    private String[] errors;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        checkPermission();

        messageLayout = findViewById(R.id.message_layout);
        messageInput = findViewById(R.id.message);
        sendButton = findViewById(R.id.send);
        outputView = findViewById(R.id.outputView);
        outputMode = findViewById(R.id.output_mode);

        hints = getResources().getStringArray(R.array.message_hints);
        regex = getResources().getStringArray(R.array.message_regex);
        errors = getResources().getStringArray(R.array.message_errors);
        spinner = findViewById(R.id.message_mode);
        final ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(
                this,
                R.array.message_modes,
                android.R.layout.simple_spinner_item
        );
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectMode(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        messageInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                validateInput(s.toString());
            }
        });

        outputView.setMovementMethod(new ScrollingMovementMethod());
        sendButton.setEnabled(false);
        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //noinspection ConstantConditions
                final String input = messageInput.getText().toString();
                final int mode = spinner.getSelectedItemPosition();
                queueInput(input, mode);
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        isShown = true;
    }

    @Override
    protected void onStop() {
        isShown = false;
        super.onStop();
    }

    private void selectMode(int mode) {
        hideKeyboardFrom(messageInput);

        messageInput.setHint(hints[mode]);
        messageLayout.setHint(null);
        inputMatcher = Pattern.compile(regex[mode]);
        switch (mode) {
            case MODE_TRIGGER:
            case MODE_LIVE:
            case MODE_RAW:
                messageInput.setInputType(InputType.TYPE_CLASS_NUMBER);
                messageInput.setKeyListener(DigitsKeyListener.getInstance("0123456789."));
                break;
            case MODE_ASCII:
                messageInput.setInputType(InputType.TYPE_CLASS_TEXT);
                messageInput.setKeyListener(TextKeyListener.getInstance());
                break;
        }

        validateInput(messageInput.getText().toString());
    }

    private void validateInput(@NonNull String input) {
        final boolean matches = inputMatcher.matcher(input).matches();
        sendButton.setEnabled(matches);
        if (!matches) {
            final int mode = spinner.getSelectedItemPosition();
            // HACK: to prevent error message to be cut https://stackoverflow.com/a/55468225/322955
            messageLayout.setError(null);
            messageLayout.setError(errors[mode]);
        } else {
            messageLayout.setError(null);
        }
    }

    private void queueInput(@NonNull String input, int mode) {
        switch (mode) {
            case MODE_TRIGGER:
                CUEEngine.getInstance().queueTrigger(input);
                break;
            case MODE_LIVE:
                CUEEngine.getInstance().queueLive(input);
                break;
            case MODE_ASCII:
                CUEEngine.getInstance().queueMessage(input);
                break;
            case MODE_RAW:
                CUEEngine.getInstance().queueData(input);
                break;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int id = item.getItemId();
        switch (id) {
            case R.id.menu_start:
                CUEEngine.getInstance().startListening();
                return true;
            case R.id.menu_stop:
                CUEEngine.getInstance().stopListening();
                return true;
        }
        return super.onOptionsItemSelected(item);
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

        final String config = CUEEngine.getInstance().getConfig();
        Log.v(TAG, config);

        CUEEngine.getInstance().runSendingThread();

        /*
        // Transmitter test
//        new Timer().schedule(new TimerTask() {
//            @Override
//            public void run() {
//                CUEEngine.getInstance().queueTrigger("212.68.181");
//                CUEEngine.getInstance().queueData("131.54.32.43.221");
//            }
//        }, 5000);
        */
    }

    private void onTriggerHeard(CUETrigger model) {
        if (!isShown) {
            showNotification(model.getIndices());
        }

        if (outputMode.isChecked()) {
            outputView.append(model.toString());
        } else {
            outputView.append(model.toShortString());
        }
        outputView.append("\n");
        outputView.append("\n");

        // scroll to end
        // https://stackoverflow.com/a/43290961
        final Editable editable = (Editable) outputView.getText();
        Selection.setSelection(editable, editable.length());
    }

    private void showNotification(@NonNull String message) {
        final NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        final String channelId = getString(R.string.notification_channel_id);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = getString(R.string.notification_channel_name);
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(
                    channelId,
                    name,
                    NotificationManager.IMPORTANCE_DEFAULT
            );

            //noinspection ConstantConditions
            notificationManager.createNotificationChannel(channel);
        }

        final Intent intent = new Intent(this, MainActivity.class);
        final PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, intent, 0
        );

        final NotificationCompat.Builder builder = new NotificationCompat.Builder(this, channelId)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle(getText(R.string.notification_title))
                .setContentText(message)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setSound(Settings.System.DEFAULT_NOTIFICATION_URI)
                .setContentIntent(pendingIntent)
                .setVibrate(new long[] { 1000, 1000, 1000 })
                .setAutoCancel(true);
        //noinspection ConstantConditions
        notificationManager.notify(NOTIFICATION_ID, builder.build());
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

    private static void hideKeyboardFrom(@NonNull View view) {
        final InputMethodManager imm =
                (InputMethodManager) view.getContext().getSystemService(Activity.INPUT_METHOD_SERVICE);
        //noinspection ConstantConditions
        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    private class OutputListener implements CUEReceiverCallbackInterface {
        @Override
        public void run(String json) {
            final CUETrigger model = parse(json);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    onTriggerHeard(model);
                }
            });
        }
    }
}
