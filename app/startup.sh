#!/bin/bash

# Exit on any error
set -e

echo "Starting Azure Web App initialization..."

# Create necessary directories if they don't exist
mkdir -p /home/logs

# Setup environment variables from Azure App Settings
if [ -n "$AZURE_OPENAI_ENDPOINT" ]; then
    echo "Setting up environment variables from Azure App Settings..."
    cat > /app/.env << EOF
AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT
AZURE_OPENAI_REALTIME_DEPLOYMENT=$AZURE_OPENAI_REALTIME_DEPLOYMENT
AZURE_OPENAI_REALTIME_VOICE_CHOICE=$AZURE_OPENAI_REALTIME_VOICE_CHOICE
AZURE_SEARCH_ENDPOINT=$AZURE_SEARCH_ENDPOINT
AZURE_SEARCH_INDEX=$AZURE_SEARCH_INDEX
AZURE_TENANT_ID=$AZURE_TENANT_ID
AZURE_SEARCH_SEMANTIC_CONFIGURATION=$AZURE_SEARCH_SEMANTIC_CONFIGURATION
AZURE_SEARCH_IDENTIFIER_FIELD=$AZURE_SEARCH_IDENTIFIER_FIELD
AZURE_SEARCH_CONTENT_FIELD=$AZURE_SEARCH_CONTENT_FIELD
AZURE_SEARCH_TITLE_FIELD=$AZURE_SEARCH_TITLE_FIELD
AZURE_SEARCH_EMBEDDING_FIELD=$AZURE_SEARCH_EMBEDDING_FIELD
AZURE_SEARCH_USE_VECTOR_QUERY=$AZURE_SEARCH_USE_VECTOR_QUERY
EOF
fi

# Set proper permissions
chmod 600 /app/.env

# Start Gunicorn with appropriate settings for Azure Web App
# - workers: auto-scaled based on CPU cores
# - timeout: increased for long-running operations
# - access logfile: in Azure logs directory
# - error logfile: in Azure logs directory
exec gunicorn app:create_app \
    --bind=0.0.0.0:8000 \
    --worker-class=aiohttp.GunicornWebWorker \
    --workers=$(nproc) \
    --timeout=300 \
    --access-logfile=/home/logs/access.log \
    --error-logfile=/home/logs/error.log \
    --capture-output \
    --enable-stdio-inheritance
