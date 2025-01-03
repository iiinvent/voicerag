# Stage 1: Build the Vite app
FROM node:20-slim AS build-stage

WORKDIR /app

# Copy package files first for better caching
COPY frontend/package.json frontend/pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install

# Copy the rest of the frontend files
COPY frontend/ ./

# Build with production environment
RUN pnpm run build

# Stage 2: Serve the built app with a static file server
FROM python:3.12-slim AS production-stage

# Create a non-root user
RUN adduser --disabled-password --gecos "" appuser

WORKDIR /app

# Copy Python requirements first for better caching
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

# Copy the built frontend assets
COPY --from=build-stage /app/dist /app/static

# Copy the backend code
COPY backend/ .

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Copy and set permissions for the .env file
COPY backend/.env /app/.env
RUN chown appuser:appuser /app/.env && \
    chmod 600 /app/.env

# Set proper permissions
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8000

# Use an entrypoint script to handle environment variables
COPY backend/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gunicorn", "app:create_app", "-b", "0.0.0.0:8000", "--worker-class", "aiohttp.GunicornWebWorker"]
