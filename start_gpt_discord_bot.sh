#!/bin/sh

# Check if a command-line argument is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a configuration name (e.g., dnd-party, ai-assistant)"
    exit 1
fi

# Get the filename from the argument
env_file=".env-${1}"

# Check if the specified .env file exists
if [ ! -f "$env_file" ]; then
    echo "Error: The .env file '$env_file' does not exist."
    exit 1
fi

# Load the environment variables from the specified file
eval $(cat "$env_file")

# Start the webserver and main process
python3 -m src.webserver &
python3 -m src.main
