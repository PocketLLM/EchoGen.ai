"""Tests for the in-process JobManager."""
import asyncio
from datetime import datetime
from typing import Any, Dict, List

import pytest

pytest.importorskip("pydantic")

from backend.app.schemas.jobs import JobCreate
from backend.app.services.jobs import JobManager


class DummySupabaseClient:
    def __init__(self) -> None:
        self._tables: Dict[str, Dict[str, Dict[str, Any]]] = {}

    async def insert(self, table: str, record: Dict[str, Any]) -> List[Dict[str, Any]]:
        table_store = self._tables.setdefault(table, {})
        now = datetime.utcnow().isoformat()
        stored = {
            **record,
            "created_at": now,
            "updated_at": now,
        }
        table_store[record["id"]] = stored
        return [stored]

    async def update(self, table: str, payload: Dict[str, Any], *, filters: Dict[str, str] | None = None) -> List[Dict[str, Any]]:
        table_store = self._tables.setdefault(table, {})
        records = self._apply_filters(table_store, filters)
        now = datetime.utcnow().isoformat()
        updated = []
        for record in records:
            record.update(payload)
            record["updated_at"] = now
            updated.append(record)
        return updated

    async def select(
        self,
        table: str,
        *,
        filters: Dict[str, str] | None = None,
        limit: int | None = None,
        offset: int | None = None,
        order: str | None = None,
        columns: str | None = None,
    ) -> List[Dict[str, Any]]:
        table_store = self._tables.setdefault(table, {})
        records = list(self._apply_filters(table_store, filters))
        if order == "created_at.desc":
            records.sort(key=lambda x: x["created_at"], reverse=True)
        if offset:
            records = records[offset:]
        if limit is not None:
            records = records[:limit]
        return [dict(item) for item in records]

    async def delete(self, table: str, *, filters: Dict[str, str] | None = None) -> List[Dict[str, Any]]:
        table_store = self._tables.setdefault(table, {})
        records = list(self._apply_filters(table_store, filters))
        for record in records:
            table_store.pop(record["id"], None)
        return records

    def _apply_filters(self, table_store: Dict[str, Dict[str, Any]], filters: Dict[str, str] | None):
        values = table_store.values()
        if not filters:
            return list(values)
        result = []
        for record in values:
            matched = True
            for column, expression in filters.items():
                if not expression.startswith("eq."):
                    continue
                expected = expression.split("eq.", 1)[1]
                if str(record.get(column)) != expected:
                    matched = False
                    break
            if matched:
                result.append(record)
        return result


@pytest.mark.asyncio
async def test_job_lifecycle():
    client = DummySupabaseClient()
    manager = JobManager(client)  # type: ignore[arg-type]

    async def handler(job: JobCreate) -> Dict[str, Any]:
        await asyncio.sleep(0.05)
        return {"handled": job.payload}

    manager.register_handler("script_generation", handler)

    job_request = JobCreate(job_type="script_generation", payload={"foo": "bar"})
    job = await manager.enqueue_job("user-1", job_request)

    assert job.status == "queued"
    await asyncio.sleep(0.1)

    stored = await manager.get_job("user-1", job.id)
    assert stored.status == "succeeded"
    assert stored.result == {"handled": {"foo": "bar"}}

    jobs = await manager.list_jobs("user-1")
    assert len(jobs) == 1
