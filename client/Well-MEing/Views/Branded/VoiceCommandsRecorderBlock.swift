import SwiftUI

struct VoiceCommandsRecorderBlock: View {
    @State private var speechRecognizer = SpeechRecognizer()
    @Binding var actions: (
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
                actions: $actions
            )
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        }
        .padding()
        .onAppear {
            speechRecognizer.setupSpeechRecognition()
        }

        Spacer()
    }
}

struct SpeechActions: View {
    @Binding var speechRecognizer: SpeechRecognizer
    @Binding var actions: (
        habits: [Habit]?,
        submissions: [String: Submission]?
    )

    var body: some View {
        HStack {
            // Recognize speech with AI button
            Button(action: {
                actions = VoiceCommands.processSpeech(speech: speechRecognizer.recognizedText)
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
                .frame(maxWidth: 50)
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

