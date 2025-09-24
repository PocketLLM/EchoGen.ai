"""In-process async job manager used for long running tasks."""
from __future__ import annotations

import asyncio
from datetime import datetime
from typing import Any, Awaitable, Callable, Dict

from ..core.database import SupabaseAsyncClient
from ..schemas.jobs import JobCreate, JobStatus
from ..utils.id_generator import generate_job_id

JOBS_TABLE = "processing_jobs"

JobHandler = Callable[[JobCreate], Awaitable[Dict[str, Any]]]


class JobManager:
    def __init__(self, client: SupabaseAsyncClient) -> None:
        self._client = client
        self._handlers: Dict[str, JobHandler] = {}
        self._tasks: Dict[str, asyncio.Task[None]] = {}
        self._lock = asyncio.Lock()

    def register_handler(self, job_type: str, handler: JobHandler) -> None:
        self._handlers[job_type] = handler

    async def enqueue_job(self, user_id: str, payload: JobCreate) -> JobStatus:
        if payload.job_type not in self._handlers:
            raise ValueError(f"No handler registered for job type '{payload.job_type}'")

        job_id = generate_job_id(payload.job_type)
        record = {
            "id": job_id,
            "user_id": user_id,
            "job_type": payload.job_type,
            "status": "queued",
            "payload": payload.payload,
        }
        response = await self._client.insert(JOBS_TABLE, record)
        job = JobStatus(**response[0])
        task = asyncio.create_task(self._execute_job(job_id, payload))
        async with self._lock:
            self._tasks[job_id] = task
        return job

    async def _execute_job(self, job_id: str, payload: JobCreate) -> None:
        handler = self._handlers[payload.job_type]
        await self._client.update(
            JOBS_TABLE,
            {"status": "running", "started_at": datetime.utcnow().isoformat()},
            filters={"id": f"eq.{job_id}"},
        )
        try:
            result = await handler(payload)
        except Exception as exc:  # pragma: no cover - logging would go here
            await self._client.update(
                JOBS_TABLE,
                {
                    "status": "failed",
                    "error": str(exc),
                    "finished_at": datetime.utcnow().isoformat(),
                },
                filters={"id": f"eq.{job_id}"},
            )
        else:
            await self._client.update(
                JOBS_TABLE,
                {
                    "status": "succeeded",
                    "result": result,
                    "finished_at": datetime.utcnow().isoformat(),
                },
                filters={"id": f"eq.{job_id}"},
            )
        finally:
            async with self._lock:
                self._tasks.pop(job_id, None)

    async def get_job(self, user_id: str, job_id: str) -> JobStatus:
        response = await self._client.select(
            JOBS_TABLE,
            filters={"id": f"eq.{job_id}", "user_id": f"eq.{user_id}"},
            limit=1,
        )
        if not response:
            raise ValueError("Job not found")
        return JobStatus(**response[0])

    async def list_jobs(self, user_id: str, limit: int = 20, offset: int = 0) -> list[JobStatus]:
        response = await self._client.select(
            JOBS_TABLE,
            filters={"user_id": f"eq.{user_id}"},
            order="created_at.desc",
            limit=limit,
            offset=offset,
        )
        return [JobStatus(**item) for item in response]
