//
//  Sounds.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 16/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import AVFoundation

class Sounds {
    
    private var soundEffect: AVAudioPlayer?
    
    func playSound(named: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            soundEffect = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let soundEffect = soundEffect else { return }
            soundEffect.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
}
