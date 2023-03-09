import json
import os
import random

from flask import jsonify
from flask import render_template
from json.decoder import JSONDecodeError

from . import app

@app.route("/")
def index():
    WORKDIR = os.environ.get("WORKDIR", f"{os.getcwd()}/app")

    data, err = read_data(f"{WORKDIR}/data/db.json")
    skill = "Fallback skills"
    if data:
        skill = random.choice(data)['skill']

    return render_template('index.html', skill=skill.upper())

@app.route("/api/v1/skills")
def skills():
    WORKDIR = os.environ.get("WORKDIR", f"{os.getcwd()}/app")

    data, err = read_data(f"{WORKDIR}/data/db.json")
    skill = {"skill": "Fallback skills"}
    if data:
        skill = random.choice(data)

    return jsonify(skill)

def read_data(source):
    data = []
    errors = []
    try:
        with open(source, encoding="utf8") as db:
            content = db.read()
        data = json.loads(content)
    except FileNotFoundError as err:
        errors = [f"Reading {source}, {str(err)}"]
    except JSONDecodeError as err:
        errors = [f"Reading {source}, {str(err)}"]
    except Exception as err:
        errors = [f"Reading {source}, {str(err)}"]

    return data, errors