"""
This module contains Firebase Cloud Functions for managing habits, submissions, and user profiles.
It includes functions to create, delete, and update habits and submissions,
as well as user profile information like name, bio and reports.
"""

# MARK: - Imports & Init
from datetime import datetime

from firebase_admin import auth, db
from firebase_functions import https_fn

"""Global variables and constants."""
MAX_HABITS = 10
MAX_METRICS = 10
MAX_SUBMISSIONS = 20
MAX_DESCRIPTION_LENGTH = 500
MAX_GOAL_LENGTH = 500
MAX_HABITNAME_LENGTH = 50
MAX_HABIT_NOTES_LENGTH = 500
MIN_LENGHT_NAME = 4
MAX_LENGHT_NAME = 32
MIN_LENGHT_BIO = 8
MAX_LENGHT_BIO = 500

# MARK: - Create habit


@https_fn.on_request(region="europe-west1")
def create_habit(req: https_fn.Request) -> https_fn.Response:
    """Creates a new habit for the authenticated user."""
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Limit habits to 10
        habits_ref = db.reference(f"users/{user_id}/habits")
        habits = habits_ref.get() or {}

        if len(habits) >= MAX_HABITS:
            return https_fn.Response("You can only have {MAX_HABITS} habits", status=400)

        # Extract data safely
        data = req.get_json(silent=True) or {}
        habitname = req.args.get("habit", "").strip()

        if not habitname or len(habitname) > MAX_HABITNAME_LENGTH:
            return https_fn.Response(
                "Habit name is required and must be less than {MAX_HABITNAME_LENGTH} characters", status=400
            )

        if habitname in habits:
            return https_fn.Response("Habit already exists", status=400)

        # Check if the habit name is valid
        habit = data.get("habit")
        if habit is None:
            return https_fn.Response("Habit data is missing", status=400)
        
        # Check that the habit description is not empty and limited
        description = habit.get("description", "").strip()
        if len(description) > MAX_DESCRIPTION_LENGTH:
            return https_fn.Response(
                "Habit description is required and must be less than {MAX_DESCRIPTION_LENGTH} characters", status=400
            )
        
        # Check that the habit goal is not empty and limited
        goal = habit.get("goal", "").strip()
        if len(goal) > MAX_GOAL_LENGTH:
            return https_fn.Response(
                "Habit goal is required and must be less than {MAX_GOAL_LENGTH} characters", status=400
            )
    
        # Check that the habit has not more than MAX_METRICS metrics
        if len(habit.get("metrics", [])) > MAX_METRICS:
            return https_fn.Response(
                "A habit can have a maximum of {MAXMETRICS} metrics", status=400
            )

        # Save the habit
        habits_ref.child(habitname).set(habit)
        return https_fn.Response("Habit created", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)


# MARK: - Delete habit


@https_fn.on_request(region="europe-west1")
def delete_habit(req: https_fn.Request) -> https_fn.Response:
    """Deletes an existing habit for the authenticated user."""
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name from the request
        habitname = req.args.get("habit").strip()
        if not habitname:
            return https_fn.Response("Habit name is required", status=400)

        # Check if the habit is not in the db
        ref = db.reference(f"users/{user_id}/habits/{habitname}")
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
    """Creates a new submission for a specific habit of the authenticated user."""
    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # If not present, initialize usage info
        if not db.reference(f"users/{user_id}/usage").get():
            db.reference(f"users/{user_id}/usage").set({
                "today": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
                "submissions": 0
            })

        # Fetch usage info
        usage = db.reference(f"users/{user_id}/usage").get() or {}

        # Reset daily usage if date changed
        if usage.get("today").split("T")[0] != datetime.now().strftime("%Y-%m-%d"):
            usage["today"] = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
            usage["submissions"] = 0
            db.reference(f"users/{user_id}/usage").set(usage)

        # Get habit name safely
        habitname = req.args.get("habit")
        if not habitname or not habitname.strip():
            return https_fn.Response("Habit name is required", status=400)
        habitname = habitname.strip()

        # Check daily submission limit before proceeding
        if usage.get("submissions", 0) >= MAX_SUBMISSIONS:
            return https_fn.Response("Daily submission limit reached", status=429)        

        # Get submission from request JSON
        data = req.get_json()
        submission = data.get("submission")
        if submission is None:
            return https_fn.Response("Submission data is missing", status=400)
        
        # Check that the details of the submission are limited to MAX_HABIT_NOTES_LENGTH
        if len(submission.get("notes", "")) > MAX_HABIT_NOTES_LENGTH:
            return https_fn.Response(
                "Submission notes must be less than {MAX_HABIT_NOTES_LENGTH} characters", status=400
            )

        # Add new submission
        history_ref = db.reference(f"users/{user_id}/habits/{habitname}/history")
        new_entry_ref = history_ref.push()
        new_entry_ref.set(submission)

        # Increment submissions and update usage
        usage["submissions"] = usage.get("submissions", 0) + 1
        db.reference(f"users/{user_id}/usage").set(usage)

        return https_fn.Response("Submission saved successfully", status=200)
    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)


# MARK: - Delete submission


@https_fn.on_request(region="europe-west1")
def delete_submission(req: https_fn.Request) -> https_fn.Response:
    """Deletes a specific submission for a habit of the authenticated user."""

    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Go on usage and remove one submission
        usage_ref = db.reference(f"users/{user_id}/usage")
        usage = usage_ref.get() or {}
        if usage.get("submissions", 0) > 0:
            usage["submissions"] -= 1
            usage_ref.set(usage)

        # Get the habit name and data from the request
        habitname = req.args.get("habit").strip()
        if not habitname:
            return https_fn.Response("Habit name is required", status=400)
        submission_id = req.args.get("submission")
        if not submission_id:
            return https_fn.Response("Submission ID is required", status=400)

        # Check if the habit is not already in the db
        ref = db.reference(
            f"users/{user_id}/habits/{habitname}/history/{submission_id}"
        )
        ref.delete()
        # return 200 OK if there are not errors
        return https_fn.Response("Submission deleted successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)


# MARK: - Update name


@https_fn.on_request(region="europe-west1")
def update_name(req: https_fn.Request) -> https_fn.Response:
    """Updates the user's name in the database."""

    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and data from the request
        data = req.get_json()
        name = data.get("name").strip()
        if not name or len(name) < MIN_LENGHT_NAME or len(name) > MAX_LENGHT_NAME:
            return https_fn.Response(
                f"Name must be between {MIN_LENGHT_NAME} and {MAX_LENGHT_NAME} characters",
                status=400,
            )

        # Check if the habit is not already in the db
        ref = db.reference(f"users/{user_id}/name")
        ref.set(name)
        # return 200 OK if there are not errors
        return https_fn.Response("Name saved successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)


# MARK: - Update bio


@https_fn.on_request(region="europe-west1")
def update_bio(req: https_fn.Request) -> https_fn.Response:
    """Updates the user's bio in the database."""

    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and data from the request
        data = req.get_json()
        bio = data.get("bio")

        # Check if the bio is valid
        if not bio or len(bio) < MIN_LENGHT_BIO or len(bio) > MAX_LENGHT_BIO:
            return https_fn.Response(
                f"Bio must be between {MIN_LENGHT_BIO} and {MAX_LENGHT_BIO} characters",
                status=400,
            )

        # Check if the habit is not already in the db
        ref = db.reference(f"users/{user_id}/bio")
        ref.set(bio)
        # return 200 OK if there are not errors
        return https_fn.Response("Bio saved successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)


# MARK: - Delete report


@https_fn.on_request(region="europe-west1")
def delete_report(req: https_fn.Request) -> https_fn.Response:
    """Deletes a specific report for the authenticated user."""

    try:
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Get the habit name and data from the request
        report_date = req.args.get("report")

        # Check if the habit is not already in the db
        ref = db.reference(f"users/{user_id}/reports/{report_date}")
        ref.delete()
        # return 200 OK if there are not errors
        return https_fn.Response("Submission deleted successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)


# MARK: - Utilities


def get_authenticated_user_id(req: https_fn.Request) -> str:
    """Extracts and verifies the user ID from the Authorization header in the request."""
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
