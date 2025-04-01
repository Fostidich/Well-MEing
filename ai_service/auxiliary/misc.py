from pydantic import BaseModel, ValidationError
from typing import Type, Optional
from enum import Enum


def build_habit_map(habit_groups):
    group_map = {}
    for group in habit_groups:
        group_name = group["group_name"]
        group_map[group_name] = {
            metric["habit_name"]: {
                "input_type": metric["input_type"],
                "note": metric["note"]
            } for metric in group["metrics"]
        }
    return group_map


def generate_enum_docs(enum_cls) -> str:
    return ", ".join(
        f"{member.value}" if member.__doc__ is None
        else f"{member.value}: {member.__doc__}"
        for member in enum_cls
    )


def wrapper_parse_function(input_string: str, input_schema: Type[BaseModel],
                           expected_parts_count: Optional[int] = None):
    """
    Generic function to parse and validate input string based on the given expected parts count and schema.

    Args:
    - input_string (str): The input string to parse.
    - expected_parts_count (Optional[int]): The number of expected parts in the input string. If None, uses InputSchema.
    - InputSchema (Type[BaseModel]): The Pydantic schema class for validation.

    Returns:
    - Structured data if valid, else validation error.
    """
    # If expected_parts_count is None, use the number of fields in the InputSchema
    if expected_parts_count is None:
        expected_parts_count = len(input_schema.__annotations__)

    # Split the input string by commas
    parts = input_string.split(",")
    # Check if the number of parts matches the expected count
    if len(parts) < expected_parts_count:
        return f"Error: Insufficient arguments. Expected at least {expected_parts_count} parts."

    # Map the parsed data to a dictionary using the InputSchema field names
    field_names = list(input_schema.__annotations__.keys())
    data = {field_names[i]: parts[i] for i in range(len(parts))}

    try:
        # Validate data using the provided InputSchema
        validated_input = input_schema(**data)
        return validated_input  # Return the validated data
    except ValidationError as e:
        return f"Validation Error: {e.errors()}"
