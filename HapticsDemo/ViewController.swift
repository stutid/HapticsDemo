//
//  ViewController.swift
//  HapticsDemo
//
//  Created by Stuti Dobhal on 17.12.20.
//

import UIKit
import CoreHaptics

class ViewController: UIViewController {

    var engine: CHHapticEngine?
    @IBOutlet weak var favoriteButton: UIButton!
    private let particleEmitter = CAEmitterLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error creating engine: \(error.localizedDescription)")
        }
    }

    @IBAction func favoriteButtonClicked(_ sender: UIButton) {
        createParticles()
        createHapticTouch()
        sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5.0,
                       options: .curveEaseInOut,
                       animations: { sender.transform = .identity },
                       completion: { _ in
                        self.particleEmitter.removeFromSuperlayer()
                       })
    }

    func createHapticTouch() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        var events = [CHHapticEvent]()

        for i in stride(from: 0, to: 1.5, by: 0.2) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }

    func createParticles() {
        particleEmitter.emitterPosition = CGPoint(x: favoriteButton.frame.midX,
                                                  y: favoriteButton.frame.midY)
        particleEmitter.emitterShape = .line
        let cell = createEmitterCell()
        particleEmitter.emitterCells = [cell]
        view.layer.addSublayer(particleEmitter)
    }

    func createEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 5
        cell.lifetime = 5
        cell.alphaSpeed = 0.5
        cell.alphaRange = -0.8
        cell.color = UIColor.red.cgColor
        cell.velocity = 50
        cell.emissionRange = CGFloat.pi
        cell.scale = 0.2
        cell.contents = UIImage(named: "favorite-icon")?.cgImage
        return cell
    }

}

