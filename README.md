# sdd-taskanalyzer

[![CI](https://github.com/EduardoFernandes7/sdd-taskanalyzer/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/EduardoFernandes7/sdd-taskanalyzer/actions/workflows/ci.yml)

Módulo de métricas de produtividade desenvolvido com Spec-Driven Development
(SDD) e assistentes de IA, como parte do Bootcamp III (Fase 3: DevOps,
containerização e governança de IA).

O módulo recebe uma lista de tarefas e devolve métricas agregadas: totais,
tempo médio de conclusão (geral e por prioridade) e taxa de atraso.

## Estrutura

```
sdd-taskanalyzer/
├── .github/workflows/ci.yml   # Pipeline de CI (GitHub Actions)
├── Dockerfile                 # Imagem python:3.11-slim que executa o Test Harness
├── docker-compose.yml         # Orquestração: suíte inteira com um único comando
├── CONTEXT_RULES.md           # Regras de governança para agentes de IA
├── specs/
│   ├── task_analyzer_spec.md  # Especificação SDD v1.1 (fonte da verdade)
│   └── requirements.yaml      # Matriz de rastreabilidade: regra de negócio -> teste
├── tests/test_harness.py      # Test Harness (pytest)
├── src/task_analyzer.py       # Código gerado via IA e homologado por humano
├── requirements.txt           # Dependências de teste (pytest, pytest-cov)
└── README.md
```

## Como executar localmente

Requer Python 3.11 ou superior.

```bash
python -m venv venv
# Windows:      venv\Scripts\activate
# Linux/macOS:  source venv/bin/activate
pip install -r requirements.txt
pytest tests/test_harness.py -v --cov=src --cov-report=term-missing --cov-fail-under=90
```

## Como executar com Docker

Não exige Python instalado na máquina, apenas Docker.

```bash
# Com um único comando (build + execução):
docker compose run --rm --build tests

# Ou manualmente:
docker build -t sdd-taskanalyzer .
docker run --rm sdd-taskanalyzer
```

O container executa `pytest tests/test_harness.py -v` com cobertura e falha se
algum teste quebrar ou se a cobertura de `src/` ficar abaixo de 90%.

## Integração contínua

O workflow [`CI`](.github/workflows/ci.yml) roda em push e pull request nas
branches `main` e `develop` (e pode ser disparado manualmente):

1. **Test Harness (pytest)**: ubuntu-latest com Python 3.11, instala
   `requirements.txt` e executa `pytest tests/test_harness.py -v` com cobertura
   mínima de 90%.
2. **Docker (build e run)**: após o job de testes, constrói a imagem com
   `docker compose build` e executa a suíte dentro do container.

## Exemplo de uso

```python
from datetime import datetime, timezone

from src.task_analyzer import analyze_tasks

tarefas = [
    {
        "id_tarefa": 1,
        "titulo": "Escrever especificação",
        "prioridade": "alta",
        "status": "concluida",
        "data_criacao": datetime(2026, 1, 5, 9, 0, tzinfo=timezone.utc),
        "prazo": datetime(2026, 1, 7, 9, 0, tzinfo=timezone.utc),
        "data_conclusao": datetime(2026, 1, 6, 9, 0, tzinfo=timezone.utc),
    }
]
print(analyze_tasks(tarefas))
```

## Governança de IA

Todo código de produção foi gerado por assistente de IA sob as restrições de
[`CONTEXT_RULES.md`](CONTEXT_RULES.md) e da [especificação](specs/task_analyzer_spec.md),
e homologado por revisão humana (modelo *Critical-in-the-Loop*) antes do merge.
A matriz [`specs/requirements.yaml`](specs/requirements.yaml) liga cada regra de
negócio aos testes que a verificam.

## Fluxo de trabalho

Git Flow simplificado: `main` recebe alterações apenas via Pull Request, a
partir de branches `feature/*`. O CI precisa estar verde para o merge.
