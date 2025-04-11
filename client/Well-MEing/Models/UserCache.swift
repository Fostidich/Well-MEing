import FirebaseDatabase
import Foundation

@MainActor
@Observable
class UserCache: ObservableObject {
    static let shared = UserCache()

    // TODO: add user reports to its data

    var name: String? = nil
    var description: String? = nil
    var habits: [Habit]? = nil

    // Private initializer to ensure it's a singleton
    private init() {}

    func fromDictionary(_ dictionary: [String: Any]?) {
        guard let dictionary = dictionary else { return }

        self.name = dictionary["name"] as? String
        self.description = dictionary["description"] as? String
        self.habits = (dictionary["habits"] as? [[String: Any]])?.compactMap {
            Habit(dict: $0)
        }
    }

    /// The whole user data in the DB is fetched and put into the ``UserCache`` class.
    /// Its variables are static and can be retrieve from everywhere.
    /// - SeeAlso: ``UserCache`` contains static data of the user.
    func fetchUserData() {
        print("Fetching user data")

        // Retrieve user id from user defaults
        guard let userId = UserDefaults.standard.string(forKey: "userUID")
        else {
            print("Error: user UID not found")
            return
        }

        // Get db reference and navigate the required data path
        let databaseRef = Database.database().reference()
        let habitsRef = databaseRef.child("users").child(userId)

        habitsRef.observeSingleEvent(
            of: .value,
            with: { snapshot in
                // Get data if exists
                let data = snapshot.value as? [String: Any]

                // Map the data into objects
                Task { @MainActor in
                    self.fromDictionary(data)
                }
            }
        )
    }

}
