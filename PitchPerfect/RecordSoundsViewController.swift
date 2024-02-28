//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Mateus Andreatta on 24/02/24.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {

    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!

    // MARK: Alerts
    
    struct Strings {
        static let dismissAlert = "Dismiss"
        static let recordingLabel = "Recording in Progress"
        static let tapToRecordLabel = "Tap to Record"
        static let errorAlertTitle = "Ops, we have a problem!"
        static let errorAlertMessage = "Recording was not successful"
    }
    
    struct Constants {
        static let audioFile = "recordedVoice.wav"
        static let segueIdentifier = "stopRecording"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(isRecording: false)
    }

    @IBAction func recordAudio(_ sender: Any) {
        configureUI(isRecording: true)
        
        startRecordAudio()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        configureUI(isRecording: false)
        
        stopRecordingAudio()
    }
    
    private func configureUI(isRecording: Bool) {
        if isRecording {
            recordingLabel.text = Strings.recordingLabel
            stopRecordingButton.isEnabled = true
            recordButton.isEnabled = false
        } else {
            stopRecordingButton.isEnabled = false
            recordButton.isEnabled = true
            recordingLabel.text = Strings.tapToRecordLabel
        }
    }
    
    private func startRecordAudio() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = Constants.audioFile
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    private func stopRecordingAudio() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.dismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueIdentifier {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: Constants.segueIdentifier, sender: audioRecorder.url)
        } else {
            showAlert(Strings.errorAlertTitle, message: Strings.errorAlertMessage)
        }
    }
}
