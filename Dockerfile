# AI Image Similarity Search - Production Dockerfile
# Uses CPU-only PyTorch for smaller image size (~2GB vs ~8GB)

FROM python:3.11-slim

# Install system dependencies for pdf2image, Pillow, and OpenCV
RUN apt-get update && apt-get install -y --no-install-recommends \
    poppler-utils \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install CPU-only PyTorch first (much smaller than GPU version)
RUN pip install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cpu \
    torch torchvision

# Copy and install remaining requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py config.json pdf_utils.py ./

# Create directories for data (these should be mounted as volumes)
RUN mkdir -p images catalog metadata-files

# Expose Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Run Streamlit
ENTRYPOINT ["streamlit", "run", "app.py", \
    "--server.address=0.0.0.0", \
    "--server.port=8501", \
    "--server.headless=true"]
