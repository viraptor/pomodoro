import Foundation
import AVFoundation

/// Service that manages sound playback for the Pomodoro app
class SoundService {
    /// Sound types available in the application
    enum SoundType {
        case workComplete
        case restComplete
        case reminder
        
        /// Return the filename for the sound type
        var filename: String {
            switch self {
            case .workComplete:
                return "work-complete"
            case .restComplete:
                return "rest-complete"
            case .reminder:
                return "reminder"
            }
        }
        
        /// Return the file extension for the sound
        var fileExtension: String {
            return "mp3"
        }
    }
    
    /// Audio players for each sound type
    private var audioPlayers: [SoundType: AVAudioPlayer] = [:]
    
    /// Initialize the sound service and preload sounds
    init() {
        preloadSounds()
    }
    
    /// Preload all sounds for better performance
    private func preloadSounds() {
        for soundType in [SoundType.workComplete, .restComplete, .reminder] {
            loadSound(type: soundType)
        }
    }
    
    /// Load a specific sound
    /// - Parameter type: The type of sound to load
    private func loadSound(type: SoundType) {
        guard let url = Bundle.main.url(forResource: type.filename, withExtension: type.fileExtension) else {
            print("Could not find sound file: \(type.filename).\(type.fileExtension)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[type] = player
        } catch {
            print("Could not load sound: \(error.localizedDescription)")
        }
    }
    
    /// Play a specific sound
    /// - Parameter type: The type of sound to play
    func playSound(type: SoundType) {
        // If the sound isn't loaded yet, try to load it
        if audioPlayers[type] == nil {
            loadSound(type: type)
        }
        
        guard let player = audioPlayers[type] else {
            print("Could not find player for sound type: \(type)")
            return
        }
        
        // Reset and play the sound
        player.currentTime = 0
        player.play()
    }
} 
