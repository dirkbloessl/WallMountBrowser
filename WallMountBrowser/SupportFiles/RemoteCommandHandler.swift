import Foundation
import SwiftMQTT

class RemoteCommandHandler: MQTTSessionDelegate {

    weak var delegate : RemoteCommandHandlerDelegate?
    private var mqttSession: MQTTSession!
    
    var topLevelPrefix: String = "wmbrowser"
    /*
    var seconds: TimeInterval = 0 {
        didSet {
            self.delegate?.timeoutChanged(command: self)
        }
    }
    
    init(seconds: TimeInterval) {
        self.seconds = seconds
    }
    */
    public func start() {
//        self.scheduleTick()
        establishConnection()
    }
    
    func scheduleTick() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.seconds -= 1
//            if self.seconds > 0 {
                self.scheduleTick()
//            }
        }
    }
    
    func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
        print("data received on topic: \"\(message.topic)\" payload: \"\(message.stringRepresentation ?? "<>")\"")
        
        let topicParts = message.topic.components(separatedBy: "/")
        
        if (topicParts[0] == "wmbrowser")
        {
            print("Found!")
        }
        
    }

    func mqttDidDisconnect(session: MQTTSession, error: MQTTSessionError) {
        print("Session Disconnected.")
        if error != .none {
            print(error.description)
        }
    }
    
    func mqttDidAcknowledgePing(from session: MQTTSession) {
        print("Ack ping.")
    }
    
    private func clientID() -> String {

            let userDefaults = UserDefaults.standard
            let clientIDPersistenceKey = "clientID"
            let clientID: String

            if let savedClientID = userDefaults.object(forKey: clientIDPersistenceKey) as? String {
                clientID = savedClientID
            } else {
                clientID = randomStringWithLength(5)
                userDefaults.set(clientID, forKey: clientIDPersistenceKey)
                userDefaults.synchronize()
            }
            
            return clientID
    }
    
    // http://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift
    private func randomStringWithLength(_ len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

        var randomString = String()
        for _ in 0..<len {
            let length = UInt32(letters.count)
            let rand = arc4random_uniform(length)
            let index = String.Index(utf16Offset: Int(rand), in: letters)
            randomString += String(letters[index])
        }
        return String(randomString)
    }

    func sub(completion: @escaping ()->()) {
        self.mqttSession.subscribe(to: "blah/xyz", delivering: .atMostOnce) { error in
            if error == .none {
                print("Subscribed to topic \"blah/xyz\"")
            } else {
                print(error.description)
            }
            completion()
        }
    }
    
    public func establishConnection() {
            let host = "ha-local.duckdns.org"
            let port: UInt16 = 8883
            let clientID = self.clientID()
            
            mqttSession = MQTTSession(host: host, port: port, clientID: clientID, cleanSession: true, keepAlive: 15, useSSL: true)
            mqttSession.delegate = self
            print("Trying to connect to \(host) on port \(port) for clientID \(clientID)")
            mqttSession.username = "test"
            mqttSession.password = "test"

            mqttSession.connect { (error) in
                if error == .none {
                    print("Connected.")

                    self.sub(completion: { () in
                        print("done!!!!")
                    })

                    var subscribeTopic = self.topLevelPrefix + "/get/+"
                    self.mqttSession.subscribe(to: subscribeTopic, delivering: .atMostOnce) { error in
                        if error == .none {
                            print("Subscribed to topic \"\(subscribeTopic)\"")
                        } else {
                            print(error.description)
                        }
                    }

                    subscribeTopic = self.topLevelPrefix + "/set/+"
                    self.mqttSession.subscribe(to: subscribeTopic, delivering: .atMostOnce) { error in
                        if error == .none {
                            print("Subscribed to topic \"\(subscribeTopic)\"")
                        } else {
                            print(error.description)
                        }
                    }

                    let json = ["key" : "value"]
                    let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let publishTopic = self.topLevelPrefix + "/status/screensaver"
                    self.mqttSession.publish(data, in: publishTopic, delivering: .atMostOnce, retain: false) { error in
                        if error == .none {
                            print("Published data in topic \"\(publishTopic)\"")
                        } else {
                            print(error.description)
                        }
                    }
                } else {
                    print("Error occurred during connection:")
                    print(error.description)
                }
            }
    }

}

protocol RemoteCommandHandlerDelegate : AnyObject {
    
    func timeoutChanged(command: RemoteCommandHandler)
    func urlChanged(command: RemoteCommandHandler)
}

