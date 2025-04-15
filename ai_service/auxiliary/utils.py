
from test.emulators import get_context_json_from_db
from enum import Enum

def generate_enum_docs(enum_cls) -> str:
    return "\n".join(
        f"{member.value}: {member.description}"
        for member in enum_cls
    )


