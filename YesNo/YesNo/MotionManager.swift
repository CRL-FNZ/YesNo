import SwiftUI
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var rotation: Double = 0.0
    @Published var isStable: Bool = false
    private var stabilityTimer: Timer?
    private var lastRotation: Double = 0.0
    private let stabilityThreshold: Double = 0.1 // Radians
    private let stabilityDuration: TimeInterval = 2.0 // Seconds

    init() {
        startMotionUpdates()
    }

    deinit {
        stopMotionUpdates()
    }

    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion else { return }
                // Use yaw for left/right rotation with screen parallel to the table
                self.rotation = motion.attitude.yaw
                self.checkStability()
            }
        }
    }

    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        stabilityTimer?.invalidate()
    }

    private func checkStability() {
        let currentRotation = rotation
        if abs(currentRotation - lastRotation) > stabilityThreshold {
            // Movement detected, reset timer
            stabilityTimer?.invalidate()
            isStable = false
            lastRotation = currentRotation
            startStabilityTimer()
        }
    }

    private func startStabilityTimer() {
        stabilityTimer = Timer.scheduledTimer(withTimeInterval: stabilityDuration, repeats: false) { [weak self] _ in
            self?.isStable = true
        }
    }

    func resetStability() {
        isStable = false
        stabilityTimer?.invalidate()
        startStabilityTimer()
    }
}