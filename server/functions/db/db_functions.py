"""
This module contains Firebase Cloud Functions for managing habits, submissions, and user profiles.
It includes functions to create, delete, and update habits and submissions,
as well as user profile information like name, bio and reports.
"""

# MARK: - Imports & Init
from datetime import datetime
from zoneinfo import ZoneInfo

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
MAX_SUBMITTED_TEXT = 500

available_input_metrics = ["slider", "text", "form", "time", "rating"]
required_keys_in_submission = ["timestamp", "metrics"]

ITALY_TZ = ZoneInfo("Europe/Rome")

# MARK: - Create habit


@https_fn.on_request(region="europe-west1")
def create_habit(req: https_fn.Request) -> https_fn.Response:
    """Creates a new habit for the authenticated user."""
    try:
        # Check if the request method is POST
        if req.method != "POST":
            return https_fn.Response("Method not allowed", status=405)
        
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)

        # Limit habits to 10
        habits_ref = db.reference(f"users/{user_id}/habits")
        habits = habits_ref.get() or {}

        if len(habits) >= MAX_HABITS:
            return https_fn.Response("You can only have {MAX_HABITS} habits", status=400)

        # Extract data safely
        data = req.get_json(silent=True) or {}

        #Check that the habit contains only the correct metrics
        if data.get("habit") is not None:
            for metric_data in data.get("habit", {}).get("metrics", {}).values():
                input_type = metric_data.get("input")
                if input_type not in available_input_metrics:
                    return https_fn.Response(
                        f"Invalid metric '{input_type}'. Available metrics are: {', '.join(available_input_metrics)}",
                        status=400
                    )
        else:
            return https_fn.Response("Habit data is missing", status=400)
        
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

        # Check if the request method is DELETE
        if req.method != "DELETE":
            return https_fn.Response("Method not allowed", status=405)
        
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
    """Creates a new submission for a habit of the authenticated user."""
    try:
        # Check if the request method is POST
        if req.method != "POST":
            return https_fn.Response("Method not allowed", status=405)
        
        # Get the user ID from the request
        user_id = get_authenticated_user_id(req)
        # Initialize user usage and reset daily usage if needed
        initialize_user_usage(user_id)
        usage = reset_daily_usage_if_needed(user_id)

        # Get the habit name and data from the request
        habitname = req.args.get("habit", "").strip()
        if not habitname:
            return https_fn.Response("Habit name is required", status=400)

        if usage.get("submissions", 0) >= MAX_SUBMISSIONS:
            return https_fn.Response("Daily submission limit reached", status=429)

        # Check if the habit is not already in the db
        data = req.get_json()
        submission = data.get("submission")
        if submission is None:
            return https_fn.Response("Submission data is missing", status=400)

        # Validate the submission keys
        try:
            validate_submission_keys(submission)
        except ValueError as e:
            return https_fn.Response(str(e), status=400)

        # Get the habit from the database
        habit = db.reference(f"users/{user_id}/habits/{habitname}").get()
        if not habit:
            return https_fn.Response("Habit does not exist", status=400)

        # Validate the metrics in the submission
        try:
            validate_metrics(submission.get("metrics", {}), habit.get("metrics", {}))
        except ValueError as e:
            return https_fn.Response(str(e), status=400)

        # Validate the timestamp
        try:
            validate_timestamp(submission.get("timestamp"))
        except ValueError as e:
            return https_fn.Response(str(e), status=400)

        # Validate the notes if present
        if "notes" in submission:
            try:
                validate_notes(submission.get("notes", ""))
            except ValueError as e:
                return https_fn.Response(str(e), status=400)

        history_ref = db.reference(f"users/{user_id}/habits/{habitname}/history")
        history_ref.push().set(submission)

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
        # Check if the request method is DELETE
        if req.method != "DELETE":
            return https_fn.Response("Method not allowed", status=405)
        
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
        data = req.get_json(silent=True)
        ref = db.reference(f"users/{user_id}/name")

        if req.method == "DELETE": 
            ref.delete()
            return https_fn.Response("Name deleted successfully", status=200)

        # Check if the request method is POST
        if req.method != "POST":
            return https_fn.Response("Method not allowed", status=405)
        
        name = data.get("name").strip() or []
        if len(name) < MIN_LENGHT_NAME or len(name) > MAX_LENGHT_NAME:
            return https_fn.Response(
                f"Name must be between {MIN_LENGHT_NAME} and {MAX_LENGHT_NAME} characters",
                status=400,
            )
        

        # Check if the habit is not already in the db
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
        data = req.get_json(silent=True)
        ref = db.reference(f"users/{user_id}/bio")
        if req.method == "DELETE":
            ref.delete()
            return https_fn.Response("Bio deleted successfully", status=200)

        # Check if the request method is POST
        if req.method != "POST":
            return https_fn.Response("Method not allowed", status=405)
        bio = data.get("bio").strip() or ""
        # Check if the bio is valid
        if not bio or len(bio) < MIN_LENGHT_BIO or len(bio) > MAX_LENGHT_BIO:
            return https_fn.Response(
                f"Bio must be between {MIN_LENGHT_BIO} and {MAX_LENGHT_BIO} characters",
                status=400,
            )

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
        # Check if the request method is DELETE
        if req.method != "DELETE":
            return https_fn.Response("Method not allowed", status=405)
        
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
        raise ValueError("Unauthorized: Missing Authorization header", status=401)

    if not auth_header.startswith("Bearer "):
        raise ValueError("Unauthorized: Invalid Authorization header", status=401)

    id_token = auth_header.split("Bearer ")[-1].strip()

    # Verify the ID token using Firebase Admin SDK
    decoded_token = auth.verify_id_token(id_token)
    user_id = decoded_token.get("uid")

    if user_id is None:
        raise ValueError("Unauthorized: Invalid token", status=401)

    return user_id

def initialize_user_usage(user_id):
    """Initializes the user's usage data if it does not exist."""
    usage_ref = db.reference(f"users/{user_id}/usage")
    if not usage_ref.get():
        usage_ref.set({
            "today": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
            "submissions": 0
        })

def reset_daily_usage_if_needed(user_id):
    """Resets the user's daily usage if the date has changed."""
    usage_ref = db.reference(f"users/{user_id}/usage")
    usage = usage_ref.get() or {}
    if usage.get("today", "").split("T")[0] != datetime.now().strftime("%Y-%m-%d"):
        usage["today"] = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
        usage["submissions"] = 0
        usage_ref.set(usage)
    return usage

def validate_submission_keys(submission):
    """Validates that the submission contains the required keys."""
    for key in submission:
        if key not in required_keys_in_submission and key != "notes":
            raise ValueError(f"Invalid key '{key}' in submission. Required keys are: {', '.join(required_keys_in_submission)}")

def validate_metrics(submitted_metrics, valid_metrics):
    """Validates that the submitted metrics match the valid metrics for the habit."""
    # Check if the submitted metrics match the valid metrics
    if set(submitted_metrics.keys()) != set(valid_metrics.keys()):
        raise ValueError(
            f"Submitted metrics do not match habit metrics. Expected: {', '.join(valid_metrics.keys())}, "
            f"but got: {', '.join(submitted_metrics.keys())}"
        )
    
    # Check that is the input is text, it's limited to MAX_SUBMITTED_TEXT characters
    for metric_name, metric_value in submitted_metrics.items():
        valid_metric = valid_metrics.get(metric_name)
        if valid_metric is None:
            raise ValueError(f"Metric '{metric_name}' is not defined in the habit")

        input_type = valid_metric.get("input")
        if input_type == "text":
            if not isinstance(metric_value, str):
                raise ValueError(f"Metric '{metric_name}' must be a string")
            if len(metric_value) > MAX_SUBMITTED_TEXT:
                raise ValueError(
                    f"Metric '{metric_name}' must be a string with a maximum length of {MAX_SUBMITTED_TEXT} characters"
                )


def validate_timestamp(timestamp):
    """Validates the timestamp format and checks if it is in the past."""
    if not timestamp:
        raise ValueError("Timestamp is required")
    try:
        dt = datetime.fromisoformat(timestamp)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=ITALY_TZ)
        if dt > datetime.now(ITALY_TZ):
            raise ValueError("Timestamp cannot be in the future")
    except ValueError:
        raise ValueError("Invalid timestamp format")

def validate_notes(notes):
    """Validates the notes for the submission."""
    if not isinstance(notes, str):
        raise ValueError("Notes must be a string")
    if len(notes) > MAX_HABIT_NOTES_LENGTH:
        raise ValueError(f"Submission notes must be less than {MAX_HABIT_NOTES_LENGTH} characters")
