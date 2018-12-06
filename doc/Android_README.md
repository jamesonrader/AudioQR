# CUE Audio -- Android Demo

To run CUE Audio's ultrasonic engine on Android, simply follow these steps:

(1) Open the `Android/consumer` directory, then open the `consumer` application in Android Studio. 

(2) At the top of `MainActivity.java`, insert your API Key into the following:

`private static final String API_KEY = "myAPIKey"`

(3) Run the project. If your Android Studio gradle settings are not configured, it may be necessary to re-sync your project by selecting `File --> Sync Project with Gradle Files`. 

Now, transmit ultrasonic audio by playing a trigger from the `SampleTones` directory. Upon registering the tone, the device display the binary signal received.

(4) To customize the ultrasonic trigger response, simply modify the following callback within  `MainActivity.java`:

```
CUEEngine.getInstance().setTriggerCallback(new CUEEngineCallbackInterface() {
                @Override
                public void engineCallback(ECM mode, final int[] symbols) {
                    String trigger = null;

                    switch (mode) {
                        case MODE_3_TONE:
                            trigger = String.format("%d,%d,%d", symbols[0], symbols[1], symbols[2]);
                            break;

                        default:
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
```

## Custom Implementation Notes

(1) Make sure you add the cue `engine` AAR library to your project structure:

> Hint: the easiest way to add AARs is to import them as modules. In Android Studio's goto menu `File > New > New Module > Import JAR / ARR`, select AAR to import library files one-by-one. 

(2) After AARs are imported, don't forget to add the dependencies to your `app` project:

```groovy
dependencies {
implementation project(':engine')
...
}
``` 

(3) Setup the engine using your API Key and start listening. 

(4) To stop listening in your project, simply call `CUEEngine.getInstance().stopListening()`.

(5) To check listening status, call `CUEEngine.getInstance().isListening()`.