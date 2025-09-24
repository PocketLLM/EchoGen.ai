"""Helper for generating unique identifiers."""
import secrets
import string


def generate_job_id(prefix: str = "job") -> str:
    """Return a collision-resistant job identifier."""

    suffix = "".join(secrets.choice(string.ascii_lowercase + string.digits) for _ in range(12))
    return f"{prefix}_{suffix}"
