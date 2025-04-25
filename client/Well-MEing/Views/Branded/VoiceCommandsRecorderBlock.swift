import SwiftUI

struct VoiceCommandsRecorderBlock: View {
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var recognizing: Bool = false
    @State private var requested: Bool = false
    @Binding var actions: Actions?

    var body: some View {
        // FIXME: text field is a bit cluncky while recording
        VStack {
            // Show recognized text while being recorded
            TextField("Start speaking!", text: $speechRecognizer.recognizedText)
                .allowsHitTesting(!speechRecognizer.startedListening)
                .truncationMode(.head)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5))
                )
                .padding(.bottom, 4)

            // Show buttons for submitting speech and recording
            SpeechActions(
                speechRecognizer: $speechRecognizer,
                recognizing: $recognizing,
                requested: $requested,
                actions: $actions
            )
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        }
        .onAppear {
            speechRecognizer.setupSpeechRecognition()
        }

        // Show rolling wheel while sending speech to AI
        if recognizing {
            ProgressView()
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        }

        if requested && actions == nil {
            Text("No action recognized")
                .font(.callout)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }

        Spacer()
    }
}

struct SpeechActions: View {
    @Binding var speechRecognizer: SpeechRecognizer
    @Binding var recognizing: Bool
    @Binding var requested: Bool
    @Binding var actions: Actions?

    var body: some View {
        HStack {
            // Recognize speech with AI button
            Button(action: {
                recognizing = true
                actions = nil

                DispatchQueue.main.async {
                    // TODO: set up an alert for errors
                    _ = VoiceCommands.processSpeech(
                        speech: speechRecognizer.recognizedText,
                        actions: $actions
                    )
                    recognizing = false
                    speechRecognizer.recognizedText = ""
                    requested = true
                }
            }) {
                Text("Recognize")
                    .foregroundColor(Color(.systemBackground))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.accent)
                    }
            }
            .disabled(
                speechRecognizer.startedListening
                    || recognizing
                    || speechRecognizer
                        .recognizedText.clean == nil
            )
            .buttonStyle(.plain)

            // Recording button
            Button(action: {
                if speechRecognizer.audioEngine.isRunning {
                    speechRecognizer.stopListening()
                } else {
                    speechRecognizer.startListening()
                }
            }) {
                Image(
                    systemName: speechRecognizer
                        .startedListening
                        ? "stop.fill" : "mic.fill"
                )
                .foregroundColor(.white)
                .frame(maxWidth: 50, maxHeight: 20)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct RecordingButton: View {
    @Binding var speechRecognizer: SpeechRecognizer

    var body: some View {
        // Big red recording button
        Button(action: {
            if speechRecognizer.audioEngine.isRunning {
                speechRecognizer.stopListening()
            } else {
                speechRecognizer.startListening()
            }
        }) {
            Circle()
                .fill(Color.red)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(
                        systemName: speechRecognizer
                            .startedListening
                            ? "stop.fill" : "mic.fill"
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                )
                .shadow(radius: 5)
        }
    }
}
