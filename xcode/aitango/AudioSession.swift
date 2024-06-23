//
//  AudioSession.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/22/24.
//

import Foundation
import AVFoundation

struct AudioSession {
    public var session = AVAudioSession.sharedInstance()
    
    public func activateSession() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )
        } catch _ {
            print("session.setCategory failed")
        }
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch _ {
            print("session.setActivate failed")
        }
        /*
        do {
            try session.overrideOutputAudioPort(.speaker)
        } catch let error as NSError {
            print("session.overrideOutputaudioPort failed: \(error.localizedDescription)")
        }
        */
    }
}
