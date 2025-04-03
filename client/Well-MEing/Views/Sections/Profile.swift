import SwiftUI
import GoogleSignIn

struct Profile: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Profile data title
            Text("Your profile")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Profile image
            ProfileImageCircle()
                .frame(width: 160, height: 160)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: -10) {
                // Profile information
                ProfileInformationList()

                // Bio
                Biography()
            }

            Button(action: {
                authViewModel.signOut()
            }) {
                ZStack {
                    // Button color fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.20))

                    // Content of the task button
                    Text("Log out")
                        .bold()
                        .foregroundColor(.red)
                        .padding()
                }
                .padding()
            }
        }.onAppear{
            fetchUserData()
        }
    }
}

struct ProfileImageCircle: View {
    @State private var profileImage: Image? = nil
    let imageURL = URL(string: "https://picsum.photos/200")!

    var body: some View {
        ZStack {
            // Placeholder borders if image is not yet loaded
            if profileImage == nil {
                Circle()
                    .fill(Color.clear)
                    .overlay(Circle().stroke(Color.secondary, lineWidth: 4))  // white border
            }

            // Show profile image when available
            profileImage?
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.secondary, lineWidth: 2)
                )  // white border
        }
        .onAppear {
            Task {
                profileImage = await loadImage(url: imageURL)
            }
        }
        .padding()
    }
}

struct ProfileInformationList: View {
    @State var name: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State var mail: String = UserDefaults.standard.string(forKey: "email") ?? ""

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Name")
                Spacer()
                TextField("Your name", text: $name)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal)
            .padding(.top)
            .onSubmit {
                updateUsername(newUsername: name)
            }
            
            Divider()
                .padding(.horizontal)

            HStack {
                Text("Mail")
                Spacer()
                Text(mail)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
                .padding()
        )
    }
}

struct Biography: View {
    @State var bio: String = UserDefaults.standard.string(forKey: "bio") ?? ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your interest")
                .padding(.horizontal)
                .padding(.top)
                .bold()

            Text(
                "This will be used to generate personalized reports."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)

            Divider().padding(.horizontal)
 
            TextField("Your bio", text: $bio)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom)
                .onSubmit {
                    updateBio(newBio: bio)
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.20))
                .padding()
        )
    }
}
