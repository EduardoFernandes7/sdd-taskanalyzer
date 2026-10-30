FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ src/
COPY tests/ tests/

RUN useradd --create-home appuser && chown -R appuser /app
USER appuser

CMD ["pytest", "tests/test_harness.py", "-v", "-p", "no:cacheprovider", \
     "--cov=src", "--cov-report=term-missing", "--cov-fail-under=90"]
