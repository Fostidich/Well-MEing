
from test.emulators import get_context_json_from_db


def generate_enum_docs(enum_cls) -> str:
    return ", ".join(
        f"{member.value}" if member.__doc__ is None
        else f"{member.value}: {member.__doc__}"
        for member in enum_cls
    )



