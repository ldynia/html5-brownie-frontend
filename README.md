# Installation

1. Operating system libs

    ```bash
    sudo apt update
    sudo apt install --yes python3-venv
    ```

1. Virtual environment

    ```bash
    python3 -m venv venv

    # deactive venv
    . venv/bin/activate

    pip install --upgrade pip --requirement app/requirements.txt
    ```

# Run

```bash
flask --app app/main run --debug --port 5000 --reload --host 0.0.0.0
```

# Inspect

[http://localhost:5000/](http://localhost:5000/)