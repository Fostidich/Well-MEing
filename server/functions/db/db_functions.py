# MARK: - Imports & Init
from firebase_functions import https_fn
from firebase_admin import db, auth

# MARK: - Create habit
@https_fn.on_request(region="europe-west1")
def create_habit(req: https_fn.Request) -> https_fn.Response:
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and habit from the request
        data = req.get_json()
        habitname = req.args.get("habit")
        habit = data.get("habit")

        # Check if the habit is already in the db
        ref = db.reference(f'users/{user_id}/habits/{habitname}')
        if ref.get() is not None:
            return https_fn.Response("Habit already exists", status=400)
        ref.set(habit)

        # return 200 OK if there are not errors
        return https_fn.Response("Habit created successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)
    
# MARK: - Delete habit
@https_fn.on_request(region="europe-west1")
def delete_habit(req: https_fn.Request) -> https_fn.Response:
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name from the request
        habitname = req.args.get("habit")
        
        # Check if the habit is not already in the db
        ref = db.reference(f'users/{user_id}/habits/{habitname}')
        if ref.get() is None:
            return https_fn.Response("Habit do not exists", status=400)
        ref.delete()

        # return 200 OK if there are not errors
        return https_fn.Response("Habit deleted successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)
    
# MARK: - Create submission
@https_fn.on_request(region="europe-west1")
def create_submission(req: https_fn.Request) -> https_fn.Response:
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and submission from the request
        data = req.get_json()
        habitname = req.args.get("habit")
        submission = data.get("submission")
        
        # Check if the habit is not already in the db
        history_ref = db.reference(f'users/{user_id}/habits/{habitname}/history')
        new_entry_ref = history_ref.push()
        new_entry_ref.set(submission)

        # return 200 OK if there are not errors
        return https_fn.Response("Submission saved successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)

# MARK: - Delete submission
@https_fn.on_request(region="europe-west1")
def delete_submission(req: https_fn.Request) -> https_fn.Response:
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and data from the request
        habitname = req.args.get("habit")
        submission_id = req.args.get("submission")
        
        # Check if the habit is not already in the db
        ref = db.reference(f'users/{user_id}/habits/{habitname}/history/{submission_id}')
        ref.delete()
        # return 200 OK if there are not errors
        return https_fn.Response("Submission deleted successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)
    
# MARK: - Update name
@https_fn.on_request(region="europe-west1")
def update_name(req: https_fn.Request) -> https_fn.Response:
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and data from the request
        data = req.get_json()
        name = data.get("name")
        
        # Check if the habit is not already in the db
        ref = db.reference(f'users/{user_id}/name')
        ref.set(name)
        # return 200 OK if there are not errors
        return https_fn.Response("Name saved successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)

# MARK: - Update bio
@https_fn.on_request(region="europe-west1")
def update_bio(req: https_fn.Request) -> https_fn.Response:
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and data from the request
        data = req.get_json()
        bio = data.get("bio")
        
        # Check if the habit is not already in the db
        ref = db.reference(f'users/{user_id}/bio')
        ref.set(bio)
        # return 200 OK if there are not errors
        return https_fn.Response("Bio saved successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)

# MARK: - Delete report
@https_fn.on_request(region="europe-west1")
def delete_report(req: https_fn.Request) -> https_fn.Response:
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and data from the request
        report_date = req.args.get("report")
        
        # Check if the habit is not already in the db
        ref = db.reference(f'users/{user_id}/reports/{report_date}')
        ref.delete()
        # return 200 OK if there are not errors
        return https_fn.Response("Submission deleted successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)
    
# MARK: - Utilities
def get_authenticated_user_id(req: https_fn.Request) -> str:
    auth_header = req.headers.get("Authorization")
    
    if not auth_header:
        raise ValueError("Unauthorized: Missing Authorization header")
    
    if not auth_header.startswith("Bearer "):
        raise ValueError("Unauthorized: Invalid Authorization header")
    
    id_token = auth_header.split("Bearer ")[-1].strip()

    # Verify the ID token using Firebase Admin SDK
    decoded_token = auth.verify_id_token(id_token)
    user_id = decoded_token.get("uid")
    
    if user_id is None:
        raise ValueError("Unauthorized: Invalid token")
    
    return user_id
