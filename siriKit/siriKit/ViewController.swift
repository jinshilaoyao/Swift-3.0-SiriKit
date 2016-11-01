//
//  ViewController.swift
//  siriKit
//
//  Created by yesway on 2016/11/1.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum Instruction: String {
        case 左
        case 右
        case 上
        case 下
    }

    @IBOutlet weak var speechButton: UIButton!
    
    private var speechRecognizer = SpeechTranscriber()
    
    let ball: UIView = {
        let b = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        b.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ball.center = view.center
        view.addSubview(ball)
        
        speechRecognizer.onTranscriptionCompletion = { [unowned self] transcription in
            
            let instructions = transcription.components(separatedBy: " ").flatMap({
                return Instruction(rawValue: $0)
            })
            
            if instructions.count == 0 {
                return
            }
            print(instructions)
            // So we can see the individual instructions more clearly, we'll animate each one.
            let individualInstructionAnimationDuration = 0.5
            let totalAnimationDuration = Double(instructions.count) * individualInstructionAnimationDuration
            let relativeIndividualDuration = 1 / Double(instructions.count)
            
            
            //用来直接使用关键帧动画而不用借助CoreAnimation来实现
            UIView.animateKeyframes(withDuration: totalAnimationDuration, delay: 0, options: [], animations: { 
              
                for (index,instruction) in instructions.enumerated() {
                    
                    UIView.addKeyframe(withRelativeStartTime: relativeIndividualDuration * Double(index), relativeDuration: relativeIndividualDuration, animations: {
                        self.moveStep(for: instruction)
                        self.view.layoutIfNeeded()
                    })
                }
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    @IBAction func start(_ sender: UIButton) {
        if !speechRecognizer.isTranscribing {
            speechRecognizer.start()
            sender.setTitle("End Recording", for: .normal)
            sender.backgroundColor = .red
        } else {
            speechRecognizer.stop()
            sender.setTitle("Record Directions", for: .normal)
            sender.backgroundColor = .green
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension ViewController {
    
    /// Moves the ninja character based on the given instruction.
    func moveStep(for instruction: Instruction) {
        let movement: CGVector
        
        // The distance to move in any direction
        let distance = 50
        
        switch instruction {
        case .左:
            movement = CGVector(dx: -distance, dy: 0)
        case .右:
            movement = CGVector(dx: distance, dy: 0)
        case .下:
            movement = CGVector(dx: 0, dy: distance)
        case .上:
            movement = CGVector(dx: 0, dy: -distance)
        }
        
        self.ball.center.x += movement.dx
        self.ball.center.y += movement.dy
    }
    
    @objc func deviceOrientationChange() {
        UIView.animate(withDuration: 0.1) { [unowned self] in
            self.ball.center = self.view.center
        }
    }
    
}


