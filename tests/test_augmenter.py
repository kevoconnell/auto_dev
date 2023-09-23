"""
Test the augmenter.
"""
import os
import shutil
import tempfile
from pathlib import Path

import pytest
import yaml

from auto_dev.commands.augment import ConnectionScaffolder, LoggingScaffolder


def read_aea_config() -> list:
    """Small helper to load local aea-config.yaml"""
    content = Path("aea-config.yaml").read_text(encoding="utf-8")
    aea_config = list(yaml.safe_load_all(content))
    return aea_config


@pytest.fixture
def isolated_filesystem():
    """Fixture for invoking command-line interfaces."""
    cwd = os.getcwd()
    with tempfile.TemporaryDirectory() as tmpdir:
        test_dir = f"{tmpdir}/dir"
        shutil.copytree(Path(cwd), test_dir)
        template = Path(cwd) / "auto_dev" / "data" / "aea-config.yaml"
        shutil.copyfile(str(template), str(Path(test_dir) / "aea-config.yaml"))
        os.chdir(test_dir)
        yield test_dir
    os.chdir(cwd)


@pytest.fixture
def logging_scaffolder(isolated_filesystem):
    """Logging scaffolder fixture."""
    del isolated_filesystem
    return LoggingScaffolder()


@pytest.fixture
def connection_scaffolder(isolated_filesystem):
    """Logging scaffolder fixture."""
    del isolated_filesystem
    return ConnectionScaffolder()


def test_logging_scaffolder_scaffold_all(logging_scaffolder):
    """test the logging scaffolder."""
    scaffold = logging_scaffolder.scaffold(["all"])
    assert "console" in scaffold['logging_config']['handlers']
    assert "http" in scaffold['logging_config']['handlers']
    assert "logfile" in scaffold['logging_config']['handlers']


def test_logging_scaffolder_scaffold(logging_scaffolder):
    """test the logging scaffolder."""
    scaffold = logging_scaffolder.scaffold(["console"])
    assert "console" in scaffold['logging_config']['handlers']
    assert "http" not in scaffold['logging_config']['handlers']
    assert "logfile" not in scaffold['logging_config']['handlers']


def test_logging_scaffolder_scaffold_bad_handler(logging_scaffolder):
    """test the logging scaffolder."""
    with pytest.raises(ValueError):
        logging_scaffolder.scaffold(["bad"])


def test_scaffold_connection(connection_scaffolder):
    """Test scaffold connection"""
    aea_config = read_aea_config()
    assert len(aea_config) == 1
    connection_scaffolder.scaffold(("abci", "ledger"))
    aea_config = aea_config = read_aea_config()
    assert len(aea_config) == 3
