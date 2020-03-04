# Structure of CUETrigger

## Basic Terms

A ***symbol*** is an integer between `0` and `461`.

Each time a CUE ***message*** is detected, a JSON payload is returned to your application within the `ReceiverCallback` block. An example payload is provided below. 

The _message_ is encoded in the `"raw-indices"` field as one or more _symbols_ separated by `"."`.  e.g. `"42"`, `"1.2.3.4.461"`.  It is either a ***trigger*** _message_ or a ***data*** _message_.

(**NOTE**: _For basic CUE integration, the `"raw-indices"` field alone is sufficient. However, for advanced techniques (such as device synchronization), additional fields may be of use._)

A standard ***trigger message*** comprises 3 symbols  e.g. `"1.2.3"`. 

In a _data message_, each _symbol_ represents a raw ASCII character (so only symbols `0-255` are used). 

The symbols detected are always contained within the `raw-indices` parameter. An example is: `314.113.249` 

### **Example Payload**

```json
{
    "latency_ms": 1098.666748046875,
    "mode": "trigger",
    "noise": 2.6632914540414276e-08,
    "power": 1.301682710647583,
    "raw-calib": [
        2964.01953125,
        3567.908935546875,
        4280.40478515625,
        4363.642578125,
        10862.3046875,
        13959.982421875,
        13396.447265625,
        9639.3505859375,
        8616.88671875,
        9829.439453125,
        3577.36962890625
    ],
    "raw-indices": "461.55.2",
    "raw-trigger": [
        [
            1.340452790260315,
            1.0443354845046997,
            1.301682710647583,
            1.3165124654769897,
            1.2063624858856201,
            2.1123546503076795e-06,
            1.6651646319587599e-06,
            3.0747736445846385e-07,
            2.6632914540414276e-08,
            1.9589916355755577e-09,
            2.2603559024503284e-09
        ],
        [
            1.1291226655885112e-05,
            9.196763130603358e-06,
            1.3689917068404611e-05,
            1.854666829109192,
            1.6051558256149292,
            1.6042137145996094,
            1.6473720073699951,
            1.9475325345993042,
            2.4772757569735404e-06,
            3.202313507699728e-07,
            1.079893991118297e-05
        ],
        [
            1.0163649477590297e-07,
            4.56131829196238e-06,
            5.350073479348794e-06,
            3.090347945544636e-06,
            8.375304605579004e-05,
            0.9339805841445923,
            0.984634518623352,
            0.00014288285456132144,
            0.8292697668075562,
            0.8757519125938416,
            0.8339946866035461
        ]
    ],
    "winner-binary": "11111000000.00011111000.00000110111",
    "winner-indices": "461.55.2",
    "trigger-as-number": 214377
}
```

## **Description**

### Basic Parameters

Each payload has a `"mode"` (`"trigger"`, `"live"` or  `"data"`).  Particular `"modes"`  are appropriate for certain situations. 

(**NOTE:** _The standard profile is `"trigger"` mode. Unless stated otherwise, a this mode should be assumed._)

- `"mode"`:
    1. `"trigger"`:

		_Intended for transmitting content IDs or small amounts of data over short to long distances. For a 3-symbol trigger, each payload consists of a three-symbol ID (each symbol ranging from 0 to 461), and can easily transmit throughout a 20,000 person arena. Example: `421.379.49`._

        • _bandwidth_: 26 bits  
        • _latency_: ~1.0 seconds  
    
    2. `"live"`:

		_Ultra low-latency detection of one-symbol payloads (`< 0.03` seconds). Payload consists of a single symbol. Example: `421`. For `live` triggers, latency is prioritized over accuracy._ 

        _bandwidth_: 8.5 bits  
        _latency_: ~0.03 seconds
    
    3. `"data"`:

		_For transmitting arbitrarily large data payloads across short to medium distances. Transmission occurs at a rate of 100bps. Payload size varies according to signal duration. Example: `421.379.49.55.409.392`._

        _bandwidth_: 100 bits/sec  
        _latency_: **N/A** (notification once entire message received)

- `"latency_ms"`:

    Time in milliseconds since *start* of the trigger?


- `"raw-indices"`:

    The "symbol string" or "indices" of the detected trigger (e.g., `"1.2.3"`).
    
- `"trigger-as-number"`:

	You can convert a `trigger` back and forth to an `integer` from `0` to `98611127`. Transmit an `integer` by calling:
	
	```objc
	[CUEEngine.sharedInstance queueTriggerAsNumber:number];
	```
	
	```java
	CUEEngine.getInstance().queueTriggerAsNumber(number);
	```
	
	Then, when a `trigger` is received, convert a `trigger` to an integer with the following:
	
	```objc
	long triggerNum = [trigger triggerAsNumber];
	```

### Advanced Parameters

The following parameters are only needed for advanced metrics, such as estimating distance from the audio source. 

- `"power"`:

    Log (base 10) of the median channel strength and noise level


- `"noise"`:

    Log (base 10) of the median background noise level

- If `"disable_nearest_match" : false` in `engine-config`:

    + `"winner-indices"`:

        Indices of winner (e.g., `"1.2.3"`)
        If the engine is informed (via CUE's API) to only listen for a subset of triggers (rather than all possible triggers), if the detected trigger nearly (but not exactly) matches a trigger from the set supplied, the engine will return modified indices to match a signal from the initial set. Otherwise, `raw-indices` are returned. For this reason, 

    + `"scores"`

        List of similarity-measure of this trigger with universe of triggers we're listening for

    + `"winner-binary"`:

        Binary of winner (e.g., `"11111000000.00011111000.00000011111"``)

    + `"error"`

        Closeness. `0.0` is a perfect match
else:
    `"winner-indices"`:
        same as `"raw-indices"`

**NOTE:** _It is recommended to use `"winner-indices"` rather than `"raw-indices"`._

- If `"calib_symbol" : false` in `engine-config`:
    + `"raw-trigger"`:
        + For each symbol in the trigger:
            + Raw FFT-bin level for the signal strength of each of the 11 channels
- else:
    + `"raw-calib"`: 
        + Raw FFT-bin level for the signal strength of each of the 11 channels of the (initial) `calibration symbol`.

    + `"raw-trigger"`:
        + For each symbol in the trigger:
            + Raw FFT-bin level for the signal strength of each of the 11 channels *divided by* the corresponding value in `"raw-calib"` (i.e., normalized/calibrated).
