"""
This script is optional and is specifically designed for deployment on Google Cloud Run.

**Purpose:**

- Provides a basic HTTP endpoint for health checks, as required by Cloud Run.
- Offers a foundation for adding additional HTTP routes (e.g., for webhooks or other interactions).

**Cloud Run Requirements:**

- All apps deployed to Cloud Run must listen on an HTTP port (8080 by default).
- This script fulfills that requirement by creating a Flask app and running it on port 8080.

**Usage:**

- Include this script in your project if you intend to deploy it on Google Cloud Run. E.g. $ python3 -m src.main & python3 -m src.webserver
- It's not strictly necessary for local development or other deployment environments that don't have the same HTTP port listening requirement.
"""

from flask import Flask

app = Flask(__name__)

@app.route("/")  # Basic health check endpoint
def health_check():
    return "Bot is running!"

# Optionally, add other routes for webhooks or other HTTP interactions

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
