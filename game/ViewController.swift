//
//  ViewController.swift
//  game
//
//  Created by Daniel Hjartstrom on 13/01/2017.
//  Copyright © 2017 Daniel Hjartstrom. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var touchView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var label: UILabel? = nil
    
    var totalDistance: Int = 14000
    var longGestureRecognizer: UILongPressGestureRecognizer?
    var panGestureRecognizer: UIPanGestureRecognizer?
    var player: AVAudioPlayer?
    var timer: Timer? = nil
    var startPoint: CGPoint? = nil
    var timerCount: Double = 0.0 {
        
        didSet {
            
            if timerCount < 10.0 && timerCount >= 1 {
       
                timerLabel.text = "0\(String(format: "%.2f", timerCount))"
                
            } else {
            
                timerLabel.text = "\(String(format: "%.2f", timerCount))"
            
            }
        }
    }
    
    var totalDraggedDistance: Int = 0 {
    
        didSet {
            
            let distanceLeft = totalDistance - totalDraggedDistance
            
            distanceLabel.text = "\(distanceLeft)"
        
            if distanceLeft < 0 {
       
                distanceLabel.text = "0"
                
            }
            
            if player != nil {
            
            if totalDraggedDistance < totalDistance {
                
                player?.play()
            
            } else {
            
                setAudioPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "finished", ofType: "wav")!))
                player?.play()
                
                panGestureRecognizer?.isEnabled = false
                timer?.invalidate()
                self.imageView.image = UIImage(named: "splash")
                
                label = UILabel(frame: CGRect(x: 0, y: 0, width: self.touchView.frame.size.width, height: 21))
                label?.center = self.touchView.center
                label?.textAlignment = .center
                label?.font = UIFont(name: "Ping Fang HK" , size: 34)
                label?.minimumScaleFactor = 0.5
                label?.textColor = UIColor.white
                label?.text = "You splashed the cat \(String(format: "%.1f", timerCount)) seconds!"
                self.touchView.addSubview(label!)
                
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceLabel.text = "\(totalDistance)"

        longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        longGestureRecognizer?.minimumPressDuration = 4.0
        touchView.addGestureRecognizer(longGestureRecognizer!)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        touchView.addGestureRecognizer(panGestureRecognizer!)
        
        setAudioPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "cat_purr", ofType: "wav")!))
        
    }
    
    func setAudioPlayer(url: URL){
    
        do {
            
            self.player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer){
    
        player = nil
        label?.removeFromSuperview()
        timer = nil
        
        timerCount = 0.0
        totalDraggedDistance = 0
        self.imageView.image = UIImage(named: "cat")
        setAudioPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "cat_purr", ofType: "wav")!))
        
        panGestureRecognizer?.isEnabled = true
        
    }
    
    func didPan(sender: UIPanGestureRecognizer){
    
        switch sender.state {
        case .began:
            
            if timer == nil {
                
                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (Timer) in
                    
                    self.timerCount += 0.01
                    
                })
            }
            
            startPoint = sender.location(in: self.view)
            
            break
        case .changed:
            
            
            
            break
        case .ended:
   
            let pos = sender.location(in: self.view)
            self.totalDraggedDistance += startPoint?.distanceCount(pos) ?? 0

            break
        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CGPoint {
    func distanceCount(_ point: CGPoint) -> Int {
        return abs(Int(hypotf(Float(point.x - x), Float(point.y - y))))
    }
}

