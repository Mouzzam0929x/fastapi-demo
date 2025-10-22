# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a FastAPI application with automated CI/CD deployment to a production server via GitHub Actions. The application is deployed using rsync over SSH and managed with a custom restart script.

## Development Commands

### Running the Application Locally
```bash
# Install dependencies
pip install -r requirements.txt

# Run the application (development)
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Run the application (production-like)
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Testing
```bash
# Run all tests
pytest

# Run tests with verbose output
pytest -v

# Run a specific test file
pytest tests/test_main.py

# Run a specific test function
pytest tests/test_main.py::test_read_root
```

## Architecture

### Application Structure
- **main.py**: FastAPI application entry point with API endpoints
  - `/` - Root endpoint returning hello world message
  - `/hello/{name}` - Parameterized greeting endpoint
  - `/health` - Health check endpoint for monitoring
- **tests/test_main.py**: Test suite using FastAPI's TestClient
- **scripts/restart.sh**: Production deployment restart script

### CI/CD Pipeline (.github/workflows/deploy.yml)
The deployment workflow automatically triggers on pushes to the `main` branch:

1. **Checkout**: Pulls the latest code
2. **Setup SSH**: Configures SSH keys from GitHub secrets for server access
3. **Deploy using rsync**: Syncs code to production server excluding:
   - `.git`, `.github`, `__pycache__`, `.env`, `venv`
4. **Restart application**: Executes `scripts/restart.sh` on the remote server
5. **Cleanup**: Removes SSH keys for security

#### Required GitHub Secrets
- `SERVER_SSH_KEY`: Private SSH key for server authentication
- `SERVER_HOST`: Production server hostname/IP
- `SERVER_USER`: SSH user for deployment
- `APP_PATH`: Absolute path to application directory on server

### Deployment Script (scripts/restart.sh)
The restart script handles application deployment on the production server:
- Stops existing uvicorn processes
- Installs/updates dependencies from requirements.txt
- Starts application in background with logs to `logs/app.log`
- Validates application started successfully

## Key Dependencies
- **FastAPI** (0.104.1): Web framework
- **uvicorn** (0.24.0): ASGI server
- **pytest** (7.4.3): Testing framework
- **pytest-asyncio** (0.21.1): Async test support
- **httpx** (0.25.2): HTTP client for testing

## Development Notes

### Testing Considerations
- Test assertions in `test_main.py:9` expect `"Hello World"` but `main.py:7` returns `"Hello World 12345"` - tests may be outdated
- Tests use FastAPI's TestClient for synchronous testing of async endpoints

### Deployment Considerations
- Application runs on port 8000 in production
- Logs are stored in `logs/app.log` on the production server
- The restart script assumes a Unix-like environment (uses pkill, nohup)
- Virtual environment (venv) is optional but supported by restart script
