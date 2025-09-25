"""Pytest fixtures and environment configuration."""
import asyncio
import inspect
import os
import sys
from pathlib import Path
from typing import Generator

import pytest

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


os.environ.setdefault("SUPABASE_URL", "https://example.supabase.co")
os.environ.setdefault("SUPABASE_ANON_KEY", "anon-key")
os.environ.setdefault("SUPABASE_SERVICE_ROLE_KEY", "service-role-key")
os.environ.setdefault("JWT_SECRET", "test-secret")


@pytest.fixture(scope="session")
def anyio_backend() -> str:
    """Limit AnyIO-powered tests to the asyncio backend."""

    return "asyncio"


@pytest.fixture
def event_loop() -> Generator[asyncio.AbstractEventLoop, None, None]:
    """Provide a fresh event loop for tests marked with ``@pytest.mark.asyncio``."""

    loop = asyncio.new_event_loop()
    try:
        yield loop
    finally:
        loop.close()


@pytest.hookimpl(tryfirst=True)
def pytest_pyfunc_call(pyfuncitem: pytest.Function) -> bool | None:
    """Run ``async def`` tests without requiring external plugins."""

    if "anyio_backend" in pyfuncitem.fixturenames:
        # Let AnyIO's plugin handle parametrised runs.
        return None

    test_function = pyfuncitem.obj
    if inspect.iscoroutinefunction(test_function):
        loop = asyncio.new_event_loop()
        try:
            loop.run_until_complete(test_function(**pyfuncitem.funcargs))
        finally:
            loop.close()
        return True

    return None
