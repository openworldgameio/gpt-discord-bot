FROM python:3.9-slim

WORKDIR /src

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . /src

COPY start_gpt_discord_bot.sh /src/start_gpt_discord_bot.sh
COPY start_gpt_discord_bot_on_cloudrun.sh /src/start_gpt_discord_bot_on_cloudrun.sh
COPY .env /src/.env
COPY src/webserver.py /src/webserver.py

CMD ["/bin/bash", "/src/start_gpt_discord_bot.sh"]
