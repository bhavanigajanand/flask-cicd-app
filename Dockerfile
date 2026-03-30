# Base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first (layer caching benefit)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY app.py .

# Expose Flask port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
