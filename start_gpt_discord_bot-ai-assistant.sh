## This script is provided as an example for how to start
## this Discord Bot locally

## Add the environment variable from the .env file into the shell's environment
eval $(cat .env-ai-assistant)

## Optionally, start the webserver module.  This step is only needed for testing this module.
## And, this module is only needed if you plan to run this Discord bot remotely on Google Cloud Run
python3 -m src.webserver &

## Start the main Discord bot
python3 -m src.main
