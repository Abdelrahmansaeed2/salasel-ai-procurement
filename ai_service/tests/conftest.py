import pytest


def pytest_configure(config: pytest.Config) -> None:
    config.addinivalue_line("markers", "integration: marks tests that require external services (Redis, Qdrant, SQL Server)")


def pytest_collection_modifyitems(config: pytest.Config, items: list[pytest.Item]) -> None:
    import os
    if os.environ.get("RUN_INTEGRATION") != "true":
        skip_integration = pytest.mark.skip(reason="set RUN_INTEGRATION=true to run")
        for item in items:
            if "integration" in item.keywords:
                item.add_marker(skip_integration)
