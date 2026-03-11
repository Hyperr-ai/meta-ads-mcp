FROM python:3.11-slim

# Install system dependencies in one layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install uv (faster than pip)
RUN pip install --no-cache-dir --upgrade pip uv

# Copy only requirements first (better caching)
COPY requirements.txt .

# Install dependencies using uv with --system flag and no cache
RUN uv pip install --system --no-cache -r requirements.txt

# Copy application code
COPY meta_ads_mcp ./meta_ads_mcp
COPY setup.py .

# Set Python to run in unbuffered mode
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import meta_ads_mcp" || exit 1

# Command to run the Meta Ads MCP server
CMD ["python", "-m", "meta_ads_mcp"]
