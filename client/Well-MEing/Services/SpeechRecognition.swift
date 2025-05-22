import AVFoundation
import Foundation
import Speech

@Observable
class SpeechRecognizer {

    var recognizedText: String = ""
    var startedListening: Bool = false
    var audioEngine: AVAudioEngine!
    var speechRecognizer: SFSpeechRecognizer!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    var recognitionTask: SFSpeechRecognitionTask!

    init() {
        setupSpeechRecognition()
    }

    func setupSpeechRecognition() {
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()

        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func startListening() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        startedListening = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0, bufferSize: 1024, format: recordingFormat
        ) { buffer, when in
            self.recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        guard (try? audioEngine.start()) != nil else { return }

        speechRecognizer.recognitionTask(with: recognitionRequest) {
            result, error in
            if let result = result {
                self.recognizedText =
                    result.bestTranscription.formattedString
            }

            if error != nil || result?.isFinal == true {
                if let error = error {
                    print(
                        "Error while recognizing speech: \(error.localizedDescription)"
                    )
                }

                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        startedListening = false
    }
}
