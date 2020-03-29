//
//  ViewController.swift
//  mic-repeater-ios
//
//  Created by Khang Vu on 3/28/20.
//  Copyright © 2020 Khang Vu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let audioSession = AVAudioSession.sharedInstance()
    var isRunning = false
    override func viewDidLoad() {
        super.viewDidLoad()
        do {

            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setMode(AVAudioSession.Mode.default)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }

        let input = engine.inputNode

        engine.attach(player)

        let bus = 0
        let inputFormat = input.inputFormat(forBus: bus)

        engine.connect(player, to: engine.mainMixerNode, format: inputFormat)

        input.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { (buffer, time) -> Void in
            self.player.scheduleBuffer(buffer)
            print(buffer)
        }
    }

    @IBAction func start(_ sender: AnyObject) {
        isRunning = !isRunning
        sender.setTitle(isRunning ? "Stop" : "Start", for: .normal)
        
        if isRunning {
            do {
                try engine.start()
            } catch {
                print(error)
            }
            player.play()
        } else {
            engine.stop()
            player.stop()
        }
        
    }
}

