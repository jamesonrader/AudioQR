package com.qraider.xtultrasonicsdemo;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.content.ContextCompat;
import android.view.ContextThemeWrapper;
import android.view.Menu;
import android.view.MenuItem;

import com.qraider.xt.XTUltrasonicsActivity;
import com.rodolfonavalon.shaperipplelibrary.ShapeRipple;
import com.rodolfonavalon.shaperipplelibrary.model.Circle;

import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends XTUltrasonicsActivity {
    //for sound beacon proximity UI
    private ShapeRipple ripple;
    private int mProximityLevel = 0;
    private ProximityReset mProximityResetTimer;
    private Timer mProximityIndicatorTimer;

    //for unlockable content demo
    private boolean contentUnlocked;
    private MenuItem mPadlock;


    //================================================================================
    // XT Interface Methods
    //================================================================================

    @Override
    public void didHearTriggerWithTitle(String title, double amplitude) {

        /* ----------
        Amplitude can be used as a rough measure of proximity.

        For a list of trigger titles, simply call the method [self logTriggerTitles];

        Infinite triggers can be produced. For details or customized usage, contact info@qraider.com

        NOTE: Before publishing your app, make sure you've read the FAQ and terms and conditions located here: http://qraider.com/XT/FAQ/
        ----------- */

        //must call super
        super.didHearTriggerWithTitle(title, amplitude);

        //================================================================================
        // LIST OF DEMOS
        //================================================================================

        //================================================================================
        // PRODUCT DISPLAY
        //================================================================================
        //link to commercial: http://qraider.com/XT/Demo/XTcommercial.html
        if (title.equalsIgnoreCase("C-400-96")) {
            presentWebView("http://www.coca-colaproductfacts.com/en/coca-cola-products/coca-cola-zero/", "Coke Zero");

            //set proximity to green to signify loading
            mProximityLevel = 5;
        }

        //================================================================================
        // ERROR RECOGNITION AND RESPONSE
        //================================================================================
        //link to simulated error: http://qraider.com/XT/Demo/simulated_error.html
        if(title.equalsIgnoreCase("C-300-96")) {
            presentWebView("https://support.directv.com/equipment/1609", "DirectTV Error 771");

            //set proximity to green to signify loading
            mProximityLevel = 5;
        }

        //================================================================================
        // SOUND BEACON
        //================================================================================
        /* sound-beacon demo. Rather than have beacon IDs, each sound-beacon emits a unique fingerprint, allowing beacon A to be distinguished from beacon B.
           Any ultrasonic fingerprint on loop can serve as a beacon track. */
        //link to loop track: http://qraider.com/XT/Demo/soundBeaconLoop.wav
        if(title.equalsIgnoreCase("C-99-97") || title.equalsIgnoreCase("C-97-99")) //track is a loop, so order is variable
        {
            //set proximity level based on magnitude
            if (amplitude > 250000) {
                mProximityLevel = 4;
            } else if (amplitude > 150000) {
                mProximityLevel = 3;
            } else if (amplitude > 40000) {
                mProximityLevel = 2;
            } else if (amplitude > 0) {
                mProximityLevel = 1;
            } else {
                mProximityLevel = 0;
            }

            //lower proximity level if ultrasonic fingerprint not heard for 2.0 seconds
            if (mProximityResetTimer != null) {
                mProximityResetTimer.stop = true;
                mProximityResetTimer = null;
            }
            mProximityResetTimer = new ProximityReset();
        }

        //================================================================================
        // UNLOCKABLE CONTENT
        //================================================================================
        //link to unlockable: http://qraider.com/XT/Demo/unlockable_content.html
        if(title.equalsIgnoreCase("C-96-400")) {
            contentUnlocked = true;
            mPadlock.setIcon(R.drawable.padlock_open);
        }

        //================================================================================
        // COUPON DIALOG
        //================================================================================
        //link to audio: http://qraider.com/XT/Demo/audio_only.wav
        if(title.equalsIgnoreCase("C-400-100")) {
            presentAlert("Thanks for listening!", "Click 'Proceed' to collect a coupon for $5 off a yearly subscription to the Wall Street Journal", "http://subscription.wsj.com/", "The Wall Street Journal");
        }

        //================================================================================
        // ULTRASONIC "PUSH" NOTIFICATION (1)
        //================================================================================
        //link to trigger: http://qraider.com/XT/Demo/300-95.wav
        if (title.equalsIgnoreCase("C-300-95")) {
            presentAlert("10% off all merchandise!", "10% off all merchandise until the end of the third period.");
        }

        //================================================================================
        // ULTRASONIC "PUSH" NOTIFICATION (2)
        //================================================================================
        //link to trigger: http://qraider.com/XT/Demo/400-95.wav
        if (title.equalsIgnoreCase("C-400-95")) {
            presentAlert("Tickets", "Fans, the Thunder are back in town this Thursday night. Click here to purchase your tickets.");
        }
    }

    private void setDialogTexts() {
        //text for acquiring recording permission (if handleRecordPermissionsForMe = true)
        kPrePermissionTitle = "To use this app...";
        kPrePermissionBody = "This app detects ultrasonic triggers in your local environement. To use this app, we will need your permission to record audio (access your microphone). Please grant microphone access by selecting 'Allow' to the following question.";
        kPermissionBodyRejected = "This app detects ultrasonic triggers in your local environement. To use this app, we will need your permission to record audio (access your microphone). Please grant microphone access in settings.";
        kMicPermissionDenyTitle = "Microphone Access Denied";
        kMicPermissionDenyBody = "This app detects ultrasonic triggers in your local environement. To use this app, we will need your permission to record audio (access your microphone). Please grant microphone access in settings.";
    }

    //================================================================================
    // Life Cycle
    //================================================================================

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (getActionBar() != null)
            getActionBar().show();

        if (getSupportActionBar() != null)
            getSupportActionBar().show();

        //permissions
        handleRecordPermissionsForMe = true;
        //set dialog texts for permissions
        setDialogTexts();

        //display "listening" label
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED) {
            createListeningLabel();
            displayListeningLabelWithFadeTime(true, 600);
        }

        //set up proximity indicator UI
        ripple = (ShapeRipple) findViewById(R.id.proximity_indicator);
        setUpSoundBeaconUI();
    }

    @Override
    public void onResume() {
        super.onResume();
        mProximityLevel = 0;
    }

    //================================================================================
    // Sound-Beacon UI Proximity Indicator
    //================================================================================

    private void setUpSoundBeaconUI() {
        if (ripple == null) return;

        ripple.setRippleShape(new Circle());
        ripple.setEnableSingleRipple(false);
        ripple.setRippleDuration(2000);
        mProximityIndicatorTimer = new Timer();
        mProximityIndicatorTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                indicateProximity();
            }
        }, 0, 2000);
    }

    private void resetProximity()
    {
        if (mProximityLevel == 5) return;

        //lower proximityLevel
        if (mProximityLevel > 0)
            --mProximityLevel;
    }

    private void indicateProximity()
    {
        if (ripple == null) return;

        //set ripple color and speed depending on proximity
        switch (mProximityLevel) {
            case 5:
                //color: green
                ripple.setRippleColor(getResources().getColor(R.color.green));
                break;
            case 4:
                //color: red
                ripple.setRippleColor(getResources().getColor(R.color.red));
                break;
            case 3:
                //color: orange
                ripple.setRippleColor(getResources().getColor(R.color.orange));
                break;
            case 2:
                //color: yellow
                ripple.setRippleColor(getResources().getColor(R.color.yellow));
                break;
            case 1:
                //color: blue
                ripple.setRippleColor(getResources().getColor(R.color.blue));
                break;

            default:
                //color: gray
                ripple.setRippleColor(getResources().getColor(R.color.lightgray));
                break;
        }
    }

    public class ProximityReset implements Runnable {
        private Handler handler;
        public boolean stop;

        public ProximityReset () {
            handler = new Handler(Looper.getMainLooper());
            loop();
        }

        @Override
        public void run() {
            if (stop){
                handler.removeCallbacks(this);
                return;
            }
            resetProximity();
            loop();
        }

        private void loop() {
            handler.postDelayed(this, 2000);
        }
    }



    //================================================================================
    // Padlock -- Unlockable Content Demo
    //================================================================================

    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.padlockmenu, menu);

        if (contentUnlocked) {
            menu.findItem(R.id.padlock).setIcon(R.drawable.padlock_closed);
        } else menu.findItem(R.id.padlock).setIcon(R.drawable.padlock_open);

        mPadlock = menu.findItem(R.id.padlock);
        mPadlock.setIcon(R.drawable.padlock_closed);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        if (item.getItemId() == R.id.padlock) {
            if (contentUnlocked) {
                presentAlert("Content Unlocked", "Good job.", "https://www.youtube.com/watch?v=UkxqUhp2RCk", "Content Unlocked");
            } else {
                presentAlert("Content Locked", "Unlock content by playing the \"Unlockable Content\" fingerprint");
            }
        }

        return super.onOptionsItemSelected(item);
    }


    //================================================================================
    // WebView
    //================================================================================

    public void presentWebView(String URL, String title) {
        Intent i = new Intent(this, WebViewActivity.class);
        i.putExtra(WebViewActivity.EXTRA_TITLE, title);
        i.putExtra(WebViewActivity.EXTRA_URL, URL);
        startActivity(i);
    }


    //================================================================================
    // Dialog
    //================================================================================

    public void presentAlert(String title, String body) {
        AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(this, android.R.style.Theme_Holo_Dialog_NoActionBar));
        builder.setTitle(title)
                .setMessage(body)
               .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {

                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }

    public void presentAlert(String title, String body, final String URL, final String URLTitle) {
        AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(this, android.R.style.Theme_Holo_Dialog_NoActionBar));
        builder.setTitle(title)
                .setMessage(body)
                .setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                })
                .setPositiveButton("Proceed", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // continue with delete
                        presentWebView(URL, URLTitle);
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }
}
