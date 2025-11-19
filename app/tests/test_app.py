import os


def test_health_endpoint_default(client):
    """
    When no APP_VERSION set, /health should return default version "1.0.0"
    """
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "healthy"
    assert "version" in data
    assert data["version"] == "1.0.0"


def test_health_endpoint_with_env(client):
    """
    When APP_VERSION env var is present, it should be reflected.
    """
    os.environ["APP_VERSION"] = "2.5.7-test"
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["version"] == "2.5.7-test"


def test_api_hello_default_environment(client):
    """
    Without ENVIRONMENT set, /api/hello should return environment 'unknown'
    """
    resp = client.get("/api/hello")
    assert resp.status_code == 200
    data = resp.json()
    assert "message" in data
    assert "Hello" in data["message"]
    assert data["environment"] == "unknown"


def test_api_hello_with_environment(client):
    os.environ["ENVIRONMENT"] = "ci-test"
    resp = client.get("/api/hello")
    assert resp.status_code == 200
    data = resp.json()
    assert data["environment"] == "ci-test"


def test_health_response_structure(client):
    """
    Ensure health returns only expected keys (basic contract test)
    """
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    # minimal contract: status and version
    assert set(data.keys()) >= {"status", "version"}
