import os
import pytest
from fastapi.testclient import TestClient
from app import app


@pytest.fixture(scope="session")
def client():
    return TestClient(app)


@pytest.fixture(autouse=True)
def env_cleanup():
    """
    Ensure environment variables used by the app are controlled.
    This fixture runs for every test and cleans/resets env vars after test.
    """
    old_app_version = os.environ.get("APP_VERSION")
    old_env = os.environ.get("ENVIRONMENT")
    yield

    if old_app_version is None:
        os.environ.pop("APP_VERSION", None)
    else:
        os.environ["APP_VERSION"] = old_app_version
    if old_env is None:
        os.environ.pop("ENVIRONMENT", None)
    else:
        os.environ["ENVIRONMENT"] = old_env
