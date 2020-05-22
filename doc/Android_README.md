# CUE Engine -- Android

## Using the Demo Project

To run CUE Audio's ultrasonic engine on Android, simply follow these steps:

(1) Open the `Android/consumer` directory, then open the `consumer` application in Android Studio. 

(2) At the top of `MainActivity.java`, insert your API Key into the following:

`private static final String API_KEY = "myAPIKey"`

(3) Run the project. If your Android Studio gradle settings are not configured, it may be necessary to re-sync your project by selecting `File --> Sync Project with Gradle Files`. 

Now, transmit ultrasonic audio by playing a trigger from the `SampleTones` directory. Upon registering the tone, the device display the binary signal received.

(4) To customize the ultrasonic trigger response, simply modify the following callback within  `MainActivity.java`:

```java
private class OutputListener implements CUEReceiverCallbackInterface {
        @Override
        public void run(@NonNull String json) {
            final CUETrigger model = CUETrigger.parse(json);
            // Use payload
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    // Modify UI
                }
            });
        }
    }
```

## Accessing CUEEngine with Custom API Key

1. Add Maven artifactory environment variables to your project's `local.properties` file:

```
com.cueaudio.maven.url=https://cueaudio.jfrog.io/cueaudio
com.cueaudio.maven.repokey=libs-release-local
com.cueaudio.maven.bucket=https://cueaudio.jfrog.io/cueaudio/libs-release-local
com.cueaudio.maven.username=<username>
com.cueaudio.maven.password=<password>
```

2. Import CUEEngine into your project by adding the following to your app's `build.gradle` file:

```
implementation "com.cueaudio:engine:1.+"
```

## Custom Implementation

1) Make sure your app has microphone access granted.

2) Setup the engine using your API key:

```java
CUEEngine.getInstance().setupWithAPIKey(<context>, <apiKey>);
```

You can start and stop listening with the methods:

```java
CUEEngine.getInstance().startListening();
CUEEngine.getInstance().stopListening();
```

3) To decode data from the engine, set the engine's `ReceiverCallback`. This is the block of code that will execute each time an ultrasonic signal is detected. An example is:

```java
private class CUEEngineCallbackInterfaceImpl implements CUEReceiverCallbackInterface {
        private final Gson mGson = new Gson();

        @Override
        public void run(String symbolsJson) {
            try {
                JSONObject obj = new JSONObject(symbolsJson);
                String triggerId = obj.getString("winner-indices");
                Log.i(TAG, "Trigger Detected with SymbolString: " + triggerId);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }
```

Then: `CUEEngine.getInstance().setReceiverCallback(new CUEEngineCallbackInterfaceImpl());` 

For details on the structure of the returned JSON, `symbolsJson`, see [here](CUEEngine_JSON_Structure.md).

4) To transmit an ultrasonic trigger from the engine, select from one of the following:

Transmit as an integer between `0` and `98,611,127`:

```java
result = CUEEngine.getInstance().queueTriggerAsNumber(number);
if( result < 0 ) {
    messageLayout.setError("Triggers us number can not exceed 98611127" );
}
```

Transmit as a "trigger" (format "X.X.X" where X is an integer from `0` - `461`):

```java
result = CUEEngine.getInstance().queueTrigger(input);
if( result < 0 ) {
    // handle error
}
```
