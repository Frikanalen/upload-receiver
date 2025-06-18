FROM python:3.11-alpine3.22 AS deps

COPY --from=ghcr.io/astral-sh/uv:0.6.9 /uv /uvx /bin/

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
# Disable Python downloads, because we want to use the system interpreter
# across both images. If using a managed Python version, it needs to be
# copied from the build image into the final image; see `standalone.Dockerfile`
# for an example.
ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

COPY . /app

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


FROM tusproject/tusd:v2.8.0

# Copy the application from the builder
COPY --from=deps --chown=app:app /app .

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

COPY hooks /hooks

ENTRYPOINT [ "tusd" ]
CMD ["-behind-proxy", "-port=1080", "-cors-allow-credentials", "true", "-cors-allow-headers=X-CSRFToken", "-hooks-dir=/hooks"]