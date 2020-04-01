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
    let bus = 0
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
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up AV session!")
            print(error)
        }
    }
    
    @IBAction func start(_ sender: AnyObject) {
        isRunning = !isRunning
        sender.setTitle(isRunning ? "Stop" : "Start", for: .normal)
        
        if isRunning {
            engine.attach(player)
    
            let inputFormat = engine.inputNode.outputFormat(forBus: bus)
            
            engine.connect(player, to: engine.mainMixerNode, format: inputFormat)
//            engine.connect(engine.mainMixerNode, to: engine.outputNode, format: inputFormat)
            
            engine.inputNode.installTap(onBus: bus, bufferSize: 512, format: inputFormat) { (buffer, time) -> Void in
                self.player.scheduleBuffer(buffer)
            }
            
            do {
                try engine.start()
            } catch {
                print("Engine start error")
                print(error)
                return
            }
            player.play()
        } else {
            engine.inputNode.removeTap(onBus: bus)
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

    @IBAction func ontestBtnClicked(_ sender: Any) {
        print("\nOutput Data Sources:")
        for output in audioSession.outputDataSources ?? [] {
            print(output)
        }
        
        print("\nInput Data Sources:")
        for input in audioSession.inputDataSources ?? [] {
            print(input)
        }
        
        print("\nOutputs:")
        for output in audioSession.currentRoute.outputs {
            print(output)
        }
        
        print("\nInputs:")
        for input in audioSession.currentRoute.inputs {
            print(input)
        }
         
        print("\nCurrent Route:")
        print(audioSession.currentRoute)
        

    }
   

    
}

