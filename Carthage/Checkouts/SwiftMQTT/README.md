<p align="center">
    <a href="http://cocoadocs.org/docsets/SwiftyVK">
        <img src="https://img.shields.io/badge/Platform-iOS-lightgrey.svg" alt="Platform">
    </a>
    <a href="https://developer.apple.com/swift/">
        <img src="https://img.shields.io/badge/Swift-5.2.0-orange.svg?style=flat" alt="Swift">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-%E2%9C%93-brightgreen.svg?style=flat"/>
    </a>  
    <a href="http://cocoapods.org/pods/SwiftMQTT">
        <img src="https://img.shields.io/cocoapods/v/SwiftMQTT.svg?style=flat" alt="Cocoapods compatible">
    </a>
    <a href="https://github.com/apple/swift-package-manager">
        <img alt="Swift Package Manager compatible" src="https://img.shields.io/badge/SPM-%E2%9C%93-brightgreen.svg?style=flat"/>
    </a>
</p>
<p align="center">
    <a href="https://github.com/anatoliykant/SwiftMQTT/actions?query=event%3Apush+branch%3Adevelop">
        <img src="https://github.com/anatoliykant/SwiftMQTT/workflows/Swift/badge.svg?branch=develop" alt="Donale">
   </a>   
   <a href="https://codecov.io/gh/anatoliykant/SwiftMQTT">
        <img src="https://codecov.io/gh/anatoliykant/SwiftMQTT/branch/develop/graph/badge.svg" />
    </a>
</p>
<p align="center">
    <a href="https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2Fanatoliykant%2FSwiftMQTT">
        <img src="https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Ftwitter.com%2FKantAnatoliy" alt="Donale">
   </a>
   <a href="https://paypal.me/kantAnatoliy?locale.x=ru_RU">
        <img src="https://img.shields.io/badge/Donate-💰-lightblue.svg" alt="Donale">
   </a>
</p>
<p align="center">
    <a href="./LICENSE.txt">
        <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="License">
    </a>
</p>

# SwiftMQTT

**SwiftMQTT** is an simple **MQTT client** written on **Swift** based on **MQTT** version **3.1.1**

* Fully written in **Swift 5.2**
* Robust error handling
* **C** performance
* Based on [MQTT 3.1.1 Specification](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html)

## Features

- [ ] **MacOS** support
- [ ] **tvOS** support
- [ ] [MQTT 5.0 Specification](http://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [ ] Out of the box **encryption** support
- [ ] **Documentation**

## Usage

### Create Session
```swift
mqttSession = MQTTSession(
	host: "localhost",
	port: 1883,
	clientID: "swift", // must be unique to the client
	cleanSession: true,
	keepAlive: 15,
	useSSL: false
)
```

### Connect
```swift
mqttSession.connect { error in
    if error == .none {
        print("Connected!")
    } else {
        print(error.description)
    }
}
```

### Subscribe
```swift
let topic = "mytopic" 
mqttSession.subscribe(to: topic, delivering: .atLeastOnce) { error in
    if error == .none {
        print("Subscribed to \(topic)!")
    } else {
        print(error.description)
    }
}
```

### Unsubscribe
```swift
let topic = "mytopic"
mqttSession.unSubscribe(from: topic) { error in
    if error == .none {
        print("Unsubscribed from \(topic)!")
    } else {
        print(error.description)
    }
}
```

### Publish

```swift
let json = ["key" : "value"]
let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
let topic = "mytopic"

mqttSession.publish(data, in: topic, delivering: .atLeastOnce, retain: false) { error in
    if error == .none {
        print("Published data in \(topic)!")
    } else {
        print(error.description)
    }
}
```

### Conform to `MQTTSessionDelegate` to receive messages 
```swift
mqttSession.delegate = self
```
```swift
func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
    print(message.topic)
    print(message.stringRepresentation)
}
```
```swift
func mqttDidDisconnect(session: MQTTSession, error: MQTTSessionError) {
    if error == .none {
        print("Successfully disconnected from MQTT broker")
    } else {
        print(error.description)
    }
}
```

## Installation

### [Carthage](https://github.com/Carthage/Carthage) (recommended)

1. Install **Carthage 0.33.0** or later
2. Add `github "anatoliykant/SwiftMQTT"` to your **Cartfile**
3. Run `carthage update --platform ios`
4. Drag **SwiftMQTT.framework** from the appropriate platform directory in **Carthage/Build/** to the **“Linked Frameworks and Libraries”** section of your Xcode project’s **“General”** settings

*  On your application target’s **“Build Phases”** settings tab, click the **“+”** icon and choose **“New Run Script Phase”**. Create a Run Script with the following contents:
```
/usr/local/bin/carthage copy-frameworks
```
and add the paths to the frameworks you want to use under **“Input Files”**, e.g.:
```
$(SRCROOT)/Carthage/Build/iOS/SwiftMQTT.framework
```
This script works around an [App Store submission](http://www.openradar.me/radar?id=6409498411401216) bug triggered by universal binaries.


### [CocoaPods](https://github.com/CocoaPods/CocoaPods)

To integrate **SwiftMQTT** into your Xcode project using **CocoaPods**, specify it in your **Podfile**:

````ruby
target 'MyApp' do
    use_frameworks!
    pod 'SwiftMQTT'
end
````

### Swift Package Manager

Once you have your Swift package set up, adding **SwiftMQTT** as a dependency is as easy as adding it to the dependencies value of your **Package.swift**:

```swift
dependencies: [
    .package(url: "https://github.com/anatoliykant/SwiftMQTT.git", from: "3.0.0")
]
```
### License

**SwiftMQTT** is released under the **MIT** license. See [LICENSE](https://github.com/anatoliykant/SwiftMQTT/blob/develop/LICENSE) for details
