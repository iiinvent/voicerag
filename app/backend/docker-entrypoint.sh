#!/bin/bash
set -e

# Function to replace environment variables in the .env file
setup_env() {
    # List of environment variables to check and set
    ENV_VARS=(
        "AZURE_OPENAI_ENDPOINT"
        "AZURE_OPENAI_REALTIME_DEPLOYMENT"
        "AZURE_OPENAI_REALTIME_VOICE_CHOICE"
        "AZURE_SEARCH_ENDPOINT"
        "AZURE_SEARCH_INDEX"
        "AZURE_TENANT_ID"
        "AZURE_SEARCH_SEMANTIC_CONFIGURATION"
        "AZURE_SEARCH_IDENTIFIER_FIELD"
        "AZURE_SEARCH_CONTENT_FIELD"
        "AZURE_SEARCH_TITLE_FIELD"
        "AZURE_SEARCH_EMBEDDING_FIELD"
        "AZURE_SEARCH_USE_VECTOR_QUERY"
    )

    # Create a new .env file if it doesn't exist
    touch .env.tmp

    # For each environment variable
    for var in "${ENV_VARS[@]}"; do
        # If the environment variable is set
        if [ ! -z "${!var}" ]; then
            # Update or add the environment variable in the .env file
            echo "${var}=${!var}" >> .env.tmp
        elif [ -f .env ]; then
            # If the variable isn't set but exists in the original .env, copy it
            grep "^${var}=" .env >> .env.tmp 2>/dev/null || true
        fi
    done

    # Replace the original .env file
    mv .env.tmp .env
}

# Setup environment variables
setup_env

# Execute the main container command
exec "$@"
