

import AVFoundation
import AVFAudio

class BackgroundTask {
    
    // MARK: - Vars
    var player = AVAudioPlayer()
    var timer = Timer()
    
    // MARK: - Methods
    func startBackgroundTask() {
        NotificationCenter.default.addObserver(self, selector: #selector(interruptedAudio), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        self.playAudio()
    }
    
    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        player.stop()
    }
    
    @objc fileprivate func interruptedAudio(_ notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification && notification.userInfo != nil {
            var info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 { playAudio() }
        }
    }
    
    fileprivate func playAudio() {
        do {
            let bundle = Bundle.main.path(forResource: "blank", ofType: "wav")
            let alertSound = URL(fileURLWithPath: bundle!)
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playback,
                                        mode: .default,
                                        policy: .longForm,
                                        options: [])
            } catch let error {
                fatalError("*** Unable to set up the audio session: \(error.localizedDescription) ***")
            }
               
            try self.player = AVAudioPlayer(contentsOf: alertSound)
            // Play audio forever by setting num of loops to -1
            
            
            AVAudioSession.sharedInstance().activate(options: []) { (success, error) in
                guard error == nil else {
                    print("*** An error occurred: \(error!.localizedDescription) ***")
                    // Handle the error here.
                    return
                }
                
                self.player.numberOfLoops = -1
                self.player.volume = 0.01
                // Play the audio file.
                self.player.play()
            }
            
           
        } catch { print(error) }
    }
}
