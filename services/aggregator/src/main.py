from fastapi import FastAPI
from fastapi.responses import JSONResponse
import requests
import os
import time

app = FastAPI()


@app.get("/")
def home():
    return {"message": "Welcome to the aggregator"}


@app.get("/logs")
def logs():
    LOKI_URL = os.getenv("LOKI_URL")
    end_time = int(time.time() * 1_000_000_000)  # Current time in nanoseconds
    start_time = end_time - (15 * 60 * 1_000_000_000)  # 15 minutes ago
    # Construct the query
    log_label = '{platform="docker"}'

    # Create the query string
    query = f"{log_label}"
    params = {
        "query": query,
        "start": str(start_time),
        "end": str(end_time),
    }
    response = requests.get(f"{LOKI_URL}/loki/api/v1/query_range", params=params)
    # Check for a successful request
    assert response.status_code == 200

    return JSONResponse(content=response.json())
