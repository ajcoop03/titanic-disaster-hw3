# Python image for the Titanic logistic regression
FROM python:3.11-slim

# All work happens in /app inside the container
WORKDIR /app

# Install pinned packages first (cached unless requirements.txt changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the script
COPY titanic.py .

# Data is NOT copied in; it is mounted at /app/data at run time:
#   docker run --rm -v "$(pwd)/src/data:/app/data" titanic-python
CMD ["python", "titanic.py"]
