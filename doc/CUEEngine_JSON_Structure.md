# Structure of CUETrigger

## Basic terms
Each time a CUE audio signal is detected by the device's audio input or microphone, a JSON payload is returned to your application within the `ReceiverCallback` block you provide to the `CUEEngine` shared instance.

There are two types of audio signal formats: a ***trigger*** message and a ***data*** message. The type of audio signal is stated in the `mode` field of the returned JSON.

Within a ***trigger*** audio signal, the `id` is encoded in the `raw-indices` as three  ***symbols*** separated by a `.` character.  E.g. `"42.21.43"`, `"1.2.34"`, etc., where each ***symbol*** is an integer between `0` and `461`.

The ***data*** audio signal is encoded in the `message` field as a byte stream represented by a JSON string.

Example payloads are provided below.

## **Example Payloads**
### Trigger payload
```json
{
    "generation": 2,
    "latency_ms": 960.0,
    "mode": "trigger",
    "noise": 163.40673828125,
    "payload": {"myKey":"myValue"},
    "power": 69682.734375,
    "raw-indices": "1.32.45",
    "trigger-as-number": 228273,
    "winner-indices": "1.32.45"
}
```

### Data payload
```json
{
    "generation": 2,
    "latency_ms": 6375.0,
    "message": "hello world",
    "mode": "data",
    "payload": {}
}
```

## **Description**

### Basic Parameters

- `"mode"`:
    1. `"trigger"`:

		_Intended for transmitting content IDs or small amounts of data over short to long distances. Each `trigger` consists of a three-symbol ID (each symbol ranging from 0 to 461), and can easily transmit throughout a 120,000-person stadium._

        • _payload size_: 26 bits  
        • _latency_: ~1.0 seconds  
    
    2. `"data"`:

		_For transmitting arbitrarily large data payloads over short to medium distances. Transmission occurs at a rate of 26bps. Payload size varies according to signal duration._

        _bandwidth_: 26 bits/sec  
        _latency_: **N/A** (varies according to number of packets in message)

- `"latency_ms"`:

    Time in milliseconds since *start* of the CUE message decoding process


- `"raw-indices"`:

    The "symbol string" or "indices" of the detected trigger (e.g., `"1.2.3"`).

- `"winner-indices"`:
    
    The same as `"raw-indices"`

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