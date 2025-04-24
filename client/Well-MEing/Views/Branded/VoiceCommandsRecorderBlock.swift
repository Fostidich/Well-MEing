import SwiftUI

struct VoiceCommandsRecorderBlock: View {
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var recognizing: Bool = false
    @Binding var actions:
        (
            habits: [Habit]?,
            submissions: [String: Submission]?
        )

    var body: some View {
        VStack {
            // Show recognized text while being recorded
            Text(
                speechRecognizer.recognizedText.isEmpty
                    ? "Start speaking!"
                    : speechRecognizer.recognizedText
            )
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .lineLimit(1)
            .truncationMode(.head)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5))
            )
            .foregroundColor(
                speechRecognizer.recognizedText.isEmpty
                    ? .secondary : .primary
            )
            .padding(.horizontal)
            .padding(.top)

            // Show buttons for submitting speech and recording
            SpeechActions(
                speechRecognizer: $speechRecognizer,
                recognizing: $recognizing,
                actions: $actions
            )
        }
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

        Spacer()
    }
}

struct SpeechActions: View {
    @Binding var speechRecognizer: SpeechRecognizer
    @Binding var recognizing: Bool
    @Binding var actions:
        (
            habits: [Habit]?,
            submissions: [String: Submission]?
        )

    var body: some View {
        HStack {
            // Recognize speech with AI button
            Button(action: {
                recognizing = true
                actions = (nil, nil)

                DispatchQueue.main.async {
                    actions = VoiceCommands.processSpeech(
                        speech: speechRecognizer.recognizedText)
                    recognizing = false
                    speechRecognizer.recognizedText = ""
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
                        .recognizedText.isEmpty
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
        .padding()
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
