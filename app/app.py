from fastapi import FastAPI
from fastapi.responses import JSONResponse
import os
from pathlib import Path

app = FastAPI()


def get_app_version():
    """Reads the application version from the VERSION file."""
    try:
        # Build a path relative to this file's location
        version_file = Path(__file__).parent / "VERSION"
        return version_file.read_text().strip()
    except FileNotFoundError:
        return "unknown"


APP_VERSION = get_app_version()


@app.get("/health")
def health():
    return JSONResponse(content={"status": "healthy", "version": APP_VERSION})


@app.get("/version")
def version():
    return JSONResponse(content={"version": APP_VERSION})


@app.get("/api/hello")
def hello():
    return JSONResponse(
        content={
            "message": "Hello from Eloquent AI!",
            "environment": os.getenv("ENVIRONMENT", "unknown"),
        }
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)
