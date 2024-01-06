## Hosting
This doc is designed to run in the "foreground" on a single server (e.g. laptop, server, VM, etc).  
But, there are advantages to running this bot in a public cloud platforms (E.g. in Amazon Web Services (AWS), 
Google Cloud Platform (GCP), etc). 

Running discord bots in the public cloud has several benefits... e.g. 
- Persistant: The bot will run 24x7 and not stop when you shutdown your laptop, VM, etc.
- Scalable: Ability to spin up multiple copies of the bot code, to support many Users.

And, running a discord on a "serverless" setup (e.g. Google Cloud Run) has even more benefits: E.g.
- Free or fairly cheap: 2 million requests free, then 0.40$ per 1 million requests
- Fully managed: No need to maintain or upgrade VMs, Operating Systems, etc.
- Very easy to deploy and release a new version- Based on standardized Docker images


### Examples
#### Google Cloud Run 
- Create a docker file called `Dockerfile`.  This is used to build a docker image with the code that can be deployed and run with Google Cloud Run.

`Dockerfile`
```
FROM python:3.9-slim

WORKDIR /src

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . /src

## WARNING: This docker file copies your .env file with API keys to the docker container.
##          This works, but should be replace with a proper Google Secret Manager
COPY .env-ai-assistant /src/.env-ai-assistant
COPY start_gpt_discord_bot.sh /src/start_gpt_discord_bot.sh
COPY start_gpt_discord_bot_on_cloudrun.sh /src/start_gpt_discord_bot_on_cloudrun.sh

COPY src/webserver.py /src/webserver.py

CMD ["/src/start_gpt_discord_bot.sh", "ai-assistant"]
```

- Make some additions to the `requirements.txt` file...

`requirements.txt`
```python-dotenv==0.21.*
openai==1.2.0
PyYAML==6.0
dacite==1.6.*
## Note: These requirements are needed for webserver.py and running on Google Cloud Run
Flask==0.11.1
Jinja2==2.11.3
MarkupSafe==1.1.1
itsdangerous==0.24
```

- Google Cloud Run requires the service to be listening on an http port (default is 8080), to make sure the service is "a live" and didn't quit or crash.
We'll make a python script called `webserver.py` to run this webserver on port 8080

`webserver.py`
```
"""
This script is optional and is specifically designed for deployment on Google Cloud Run.
**Purpose:**
- Provides a basic HTTP endpoint for health checks, as required by Cloud Run.
- Offers a foundation for adding additional HTTP routes (e.g., for webhooks or other interactions).
**Cloud Run Requirements:**
- All apps deployed to Cloud Run must listen on an HTTP port (8080 by default).
- This script fulfills that requirement by creating a Flask app and running it on port 8080.
**Usage:**
- Include this script in your project if you intend to deploy it on Google Cloud Run. E.g.
$ python3 -m src.main & python3 -m src.webserver
- It's not strictly necessary for local development or other deployment environments that don't
have the same HTTP port listening requirement.
"""

from flask import Flask

app = Flask(__name__)

@app.route("/")  # Basic health check endpoint
def health_check():
    return "Bot is running!"

# Optionally, add other routes for webhooks or other HTTP interactions

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
```

- Add a shell script called `start_gpt_discord_bot.sh` to run webserver and main...

`start_gpt_discord_bot.sh`
```
## This script is provided as an example for how to start
## this Discord Bot locally

## Add the environment variable from the .env file into the shell's environment
eval $(cat .env-ai-assistant)

## Optionally, start the webserver module.  This step is only needed for testing this module.
## And, this module is only needed if you plan to run this Discord bot remotely on Google Cloud Run
python3 -m src.webserver &

## Start the main Discord bot
python3 -m src.main
```

- Add a shell script called `start_gpt_discord_bot_on_cloudrun.sh` to deploy and run the service on Google Cloud Run...

`start_gpt_discord_bot_on_cloudrun.sh`
```
#!/bin/bash
## This script is provided as an example for how to build, deploy and start
## this Discord Bot on Google "Cloud Run"

## Get the current date and time and region to run it on...
ymdt=$(date "+%Y-%m-%d_%H-%M")
## Setup a logfile name...
log_file="logs/${GCP_APP_NAME}_${ymdt}.log"
echo "Start time: $ymdt" | tee $log_file

## Build a new version...
gcloud builds submit \
  --tag gcr.io/${GCP_PROJECT}/${GCP_APP_NAME} 2>&1 | tee -a $log_file
## Deploy the new version...
gcloud run deploy ${GCP_APP_NAME} \
  --image gcr.io/${GCP_PROJECT}/${GCP_APP_NAME} \
  --platform managed \
  --region ${GCP_REGION} \
  --no-cpu-throttling 2>&1 | tee -a $log_file

## Get proper URL
GCP_APP_URL=$(gcloud run services list --platform=managed --region=${GCP_REGION} \
  --filter="status.address.url ~ ${GCP_APP_NAME}-" \
  --format="value(status.address.url)")
## Setup a scheduler to call the URL every minute, to keep it alive
gcloud scheduler jobs create http GET-gpt-discord-bot-ai-assistant \
  --schedule="1 * * * *" \
  --uri="${GCP_APP_URL}" \
  --http-method GET | tee -a $log_file
```

##### Improvements:
This is just a quick example. There are a lot of improvments that could be added here.  E.g.
- Move all secret data outside of the docker image.
- Pass secret data to the Cloud Run in a secure way. E.g.  Using Google Secret Manager
- Make a better deployment process.
- Fix problems/errors with the opened ports.

##### References:
- https://cloud.google.com/blog/topics/developers-practitioners/build-and-run-discord-bot-top-google-cloud
- https://emilwypych.com/2020/10/25/how-to-run-discord-bot-on-cloud-run
