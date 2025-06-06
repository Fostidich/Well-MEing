import SwiftUI

struct VoiceCommandsRecorderBlock: View {
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()
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
                speechRecognizer: speechRecognizer,
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

        // Show rolling wheel while sending speech to AI
        if recognizing {
            ProgressView()
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
        }

        // Show error message if nothing was received
        if requested && !recognizing && actions == nil {
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
    @ObservedObject var speechRecognizer: SpeechRecognizer
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
                    let request = Request.processSpeech(
                        speech: speechRecognizer.recognizedText
                    )
                    let (success, json) = await request.call()

                    // Set states accordingly
                    if success, let json = json {
                        actions = Actions(dict: json)
                    } else {
                        showError = true
                    }
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
