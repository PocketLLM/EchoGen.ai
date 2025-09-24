"""Utility function tests."""
from backend.app.utils.id_generator import generate_job_id


def test_generate_job_id_unique():
    job_ids = {generate_job_id() for _ in range(100)}
    assert len(job_ids) == 100
    assert all(job_id.startswith("job_") for job_id in job_ids)
