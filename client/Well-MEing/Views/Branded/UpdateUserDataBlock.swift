import SwiftUI

struct UpdateUserDataBlock: View {
    @State private var name: String = UserCache.shared.name ?? ""
    @State private var bio: String = UserCache.shared.bio ?? ""
    @State private var tapped: Bool = false
    @State private var showError: Bool = false
    @FocusState private var isFocussed: Bool

    var updated: Bool {
        name.clean != UserCache.shared.name.clean
            || bio.clean != UserCache.shared.bio.clean
    }

    var isNameValid: Bool {
        guard let cleanName = name.clean else { return true }
        return cleanName.count >= 4 && cleanName.count <= 32
            && cleanName.allSatisfy { $0.isLetter || $0.isWhitespace }
    }

    var isBioValid: Bool {
        guard let cleanBio = bio.clean else { return true }
        return cleanBio.count >= 8 && cleanBio.count <= 256
    }

    var body: some View {
        VStack(spacing: 16) {
            // Block title
            Text("About you")
                .font(.title)
                .bold()
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Explain data adoperation
            Text(
                "The information you insert will be used to make generated reports more specific about your lifestyle, goals and needs."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Let user insert its name
            TextField("Tell your name", text: $name)
                .focused($isFocussed)
                .padding()
                .submitLabel(.done)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground).opacity(0.8))
                }

            // Let user insert its bio
            ZStack(alignment: .topLeading) {
                TextEditor(text: $bio)
                    .focused($isFocussed)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground).opacity(0.8))
                    }

                if bio.isEmpty {
                    Text("Write about yourself")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                }
            }
            .frame(height: 150)

            // Error message for invalid name or bio
            if !isNameValid {
                Text("Name can only contain letters, and must be 4-32 long")
                    .font(.caption2)
                    .foregroundColor(.red)
            } else if !isBioValid {
                Text("Bio must be 8-256 long")
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            // Show save button
            HButton(
                text: "Save",
                textColor: Color(.systemBackground),
                backgroundColor: updated ? .accentColor : .secondary
            ) {
                tapped = true
                isFocussed = false
                let name = name.clean
                let bio = bio.clean

                // Defer action to next runloop so UI can update first
                Task {
                    // Update name
                    if name != UserCache.shared.name {
                        let (success, _) = await Request.updateName(name: name)
                            .call()
                        if !success { showError = true }
                    }

                    // Update bio
                    if bio != UserCache.shared.bio {
                        let (success, _) = await Request.updateBio(bio: bio)
                            .call()
                        if !success { showError = true }
                    }

                    tapped = false
                }
            }
            .disabled(!updated || tapped || !isNameValid || !isBioValid)
            .frame(width: 120)
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: showError)
        .alert("Failed to update personal data", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.secondary.opacity(0.2))
        }
        .padding(.bottom)
    }

}
