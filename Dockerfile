FROM python:3.9-slim

WORKDIR /src

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . /src

## WARNING: This docker file copies your .env file with API keys to the docker container.
##          This works, but should be replace with a proper Google Secret Manager
COPY .env-python-expert /src/.env-python-expert
COPY .env-ai-assistant /src/.env-ai-assistant
COPY start_gpt_discord_bot.sh /src/start_gpt_discord_bot.sh
COPY start_gpt_discord_bot_on_cloudrun.sh /src/start_gpt_discord_bot_on_cloudrun.sh

COPY src/webserver.py /src/webserver.py

CMD ["/src/start_gpt_discord_bot.sh", "ai-assistant"]
