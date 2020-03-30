//
//  ViewController.swift
//  mic-repeater-ios
//
//  Created by Khang Vu on 3/28/20.
//  Copyright © 2020 Khang Vu. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {

    var engine = AVAudioEngine()
    let player = AVAudioPlayerNode()
    let audioSession = AVAudioSession.sharedInstance()
    var routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
    var isRunning = false
    
    @IBOutlet weak var viewHolder: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpAVRoutePicker()
        setUpAVSession()
    }

    func setUpAVRoutePicker() {
        viewHolder.addArrangedSubview(routePickerView)
    }
    
    func setUpAVSession() {
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay])
            try audioSession.setMode(AVAudioSession.Mode.default)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up AV session!")
            print(error)
        }

        let input = engine.inputNode

        engine.attach(player)

        let bus = 0
        let inputFormat = input.inputFormat(forBus: bus)

        engine.connect(player, to: engine.mainMixerNode, format: inputFormat)

        input.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { (buffer, time) -> Void in
            self.player.scheduleBuffer(buffer)
        }
    }
    
    @IBAction func start(_ sender: AnyObject) {
        isRunning = !isRunning
        sender.setTitle(isRunning ? "Stop" : "Start", for: .normal)
        
        if isRunning {
            do {
                try engine.start()
            } catch {
                print("Engine start error")
                print(error)
                return
            }
            player.play()
        } else {
            engine.stop()
            player.stop()
        }
        
    }
    
    @IBAction func onInputBtnClicked(_ sender: AnyObject) {
        let controller = UIAlertController(title: "Select Input", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        for input in audioSession.availableInputs ?? [] {
            controller.addAction(UIAlertAction(title: input.portName, style: UIAlertAction.Style.default, handler: { action in
            do {
                try self.audioSession.setPreferredInput(input)
            } catch {
                print("Setting preferred input error")
                print(error)
            }
            }))
        }
        present(controller, animated: true, completion: nil)
    }

    
}

