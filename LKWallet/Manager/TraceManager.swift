//
//  TraceManager.swift
//  LKWallet
//
//  Created by Hao Wang on 11/11/2017.
//  Copyright © 2017 Tuluobo. All rights reserved.
//

import Amplitude_iOS

final class TraceManager {
    
    static let shared = TraceManager()
    private init() { }
    
    func setup() {
        Amplitude.instance().initializeApiKey("d932f4e3122b02afd38a89593795aafb")
    }
    
    func traceEvent(event: String, properties: [String: Any]) {
        Amplitude.instance().logEvent(event, withEventProperties: properties)
    }
    
    func traceEvent(event: String) {
        Amplitude.instance().logEvent(event)
    }
    
}
