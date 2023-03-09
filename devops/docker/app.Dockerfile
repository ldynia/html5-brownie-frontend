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