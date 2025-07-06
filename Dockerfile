# Stage 1: Builder - To compile dependencies
FROM python:3.10-bullseye as builder

WORKDIR /app

# Install system dependencies required for building Python packages
# gcc is for C extensions, rustc is for Rust-based packages like pydantic-core
RUN apt-get update && apt-get install -y --no-install-recommends gcc rustc

# Create and activate a virtual environment for clean dependency management
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies into the virtual environment
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final - The actual runtime image
FROM python:3.10-slim-bullseye

WORKDIR /app

# Copy the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Copy the application source code
COPY . .

# Set the PATH to use the virtual environment in the final image
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8000

# Run the application. The --reload flag is removed as it's intended for development, not for production containers.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
