import SwiftUI

struct VoiceCommandsRecorderBlock: View {
    @FocusState private var isTextFieldFocused: Bool
    @State private var speechRecognizer = SpeechRecognizer()
    @State private var recognizing: Bool = false
    @State private var requested: Bool = false
    @Binding var actions: Actions?

    var body: some View {
        VStack {
            // Show recognized text while being recorded
            TextField("Start speaking!", text: $speechRecognizer.recognizedText)
                .focused($isTextFieldFocused)
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
                actions: $actions,
                isTextFieldFocused: $isTextFieldFocused
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
    @State var showError: Bool = false
    @Binding var requested: Bool
    @Binding var actions: Actions?
    @FocusState.Binding var isTextFieldFocused: Bool

    var body: some View {
        HStack {
            // Recognize speech with AI button
            Button(action: {
                recognizing = true
                actions = nil
                isTextFieldFocused = false

                Task {
                    // Fetch actions from backend
                    let success = await VoiceCommands.processSpeech(
                        speech: speechRecognizer.recognizedText,
                        actions: $actions
                    )
                    
                    // Set states accordingly
                    if !success { showError = true }
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
                isTextFieldFocused = false

                // Start audio engine
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
        .alert("Failed to recognize actions", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }
}
