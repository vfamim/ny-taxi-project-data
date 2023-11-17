FROM python:3.9


ENV POETRY_VERSION=1.6.1
ENV POETRY_HOME="/opt/poetry"
ENV POETRY_ENV=/opt/poetry-venv
ENV POETRY_CHACHE_DIR=/opt/.cache

RUN python -m venv $POETRY_ENV \
  && $POETRY_ENV/bin/pip install -U pip setuptools \
  && $POETRY_ENV/bin/pip install poetry==$POETRY_VERSION

ENV PATH="${PATH}:${POETRY_ENV}/bin"

WORKDIR /opt

COPY marte/poetry.lock marte/pyproject.toml ./

RUN poetry config virtualenvs.create false \
  && poetry install --no-dev

COPY marte/flows/pipeline.py /opt/flows
COPY marte/dbt/* /opt/dbt

ENTRYPOINT ["poetry", "run", "python", "flows/pipeline.py"]
