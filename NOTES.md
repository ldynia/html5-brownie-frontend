1. TDD: end-to-end testing with bash

    tests/e2e.sh

    ```bash
    #!/usr/bin/env bash

    SUCCESS=0
    FAILED=1

    function test_response_code(){
      TEST_NAME="Test status code"

      STATUS_CODE=$(curl localhost:5000 \
      --head \
      --output /dev/null \
      --silent \
      --write-out '%{http_code}\n')

      if [ $STATUS_CODE == $1 ]; then
        echo "$TEST_NAME : Success"
        return $SUCCESS
      else
        echo "$TEST_NAME : Failed"
        return $FAILED
      fi
    }

    function test_body_content() {
      TEST_NAME="Test body content"
      # regex101.com Pattern <figcaption id="footer">some words</figcaption>
      MATCH=$(curl --silent localhost:5000 | grep -E '<figcaption id="footer">(\w.+)<\/figcaption>' | xargs echo -n)
      if [ ! -z "$MATCH" ]; then
        echo "$TEST_NAME : Success"
        return $SUCCESS
      else
        echo "$TEST_NAME : Failed"
        return $FAILED
      fi
    }

    # Run tests
    test_response_code 200
    test_body_content
    ```

1. Refactoring to API

    app/templates/index.html

    ```html
    <html>
      <body>
      ...
      </body>
      <script src="/static/scripts/main.js"></script>
    </html>
    ```

    app/main.py

    ```python
    from flask import jsonify

    @app.route("/api/v1/skills")
    def skills():
        WORKDIR = os.environ.get("WORKDIR", f"{os.getcwd()}/app")

        data, err = read_data(f"{WORKDIR}/data/db.json")
        skill = {"skill": "Fallback skills"}
        if data:
            skill = random.choice(data)

        return jsonify(skill)
    ```

    app/static/scripts/main.js

    ```javascript
    fetch('/api/v1/skills')
      .then(function(response) {
        return response.json();
      })
      .then(function(data) {
        document.getElementById('footer').textContent = data.skill.toUpperCase();
      });
    ```
1. Refactoring to Dockerfile

    devops/docker/app.Dockerfile

    ```Dockerfile
    FROM python:3.11.2-alpine

    ARG FLASK_DEBUG=False \
        GROUP=nogroup \
        USER=nobody \
        WORKDIR=/usr/src

    ENV FLASK_APP=$WORKDIR/main.py \
        FLASK_DEBUG=$FLASK_DEBUG \
        HOST=0.0.0.0 \
        PORT=5000 \
        PYTHONUNBUFFERED=True \
        WORKDIR=$WORKDIR

    # App's file system
    WORKDIR $WORKDIR
    RUN chown $USER:$GROUP $WORKDIR
    COPY --chown=$USER:$GROUP app/ $WORKDIR

    RUN pip install --upgrade pip --requirement $WORKDIR/requirements.txt

    EXPOSE $PORT

    USER $USER:$GROUP

    CMD flask run --host=$HOST --port=$PORT
    ```

    Build and run docker image

    ```bash
    docker build --tag brownie --file devops/docker/app.Dockerfile --build-arg FLASK_DEBUG=True .
    docker run --detach --rm --name brownie --publish 5000:5000 brownie
    docker stop brownie
    ```

    .dockerignore

    ```
    __pycache__
    .cache
    .coverage
    .coverage.*
    .git
    .mypy_cache
    .pytest_cache
    .Python
    .tox
    *.log
    *.md
    *.pyc
    *.pyd
    *.pyo
    LICENSE
    venv
    ```

1. Refactor to docker compose

    devops/docker/app.Dockerfile

    ```yaml
    version: '3.9'
    services:
      app:
        container_name: brownie
        image: brownie
        build:
          context: ../../
          dockerfile: devops/docker/app.Dockerfile
          args:
            FLASK_DEBUG: "True"
        ports:
          - "5000:5000"
    ```

    ```bash
    docker-compose --file devops/docker/docker-compose.yaml build
    docker-compose --file devops/docker/docker-compose.yaml up --detach
    docker-compose --file devops/docker/docker-compose.yaml stop
    docker-compose --file devops/docker/docker-compose.yaml down
    ```