# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://just.systems/man/en/

clean-all: clean-cache clean-runtimes clean-builds

[windows]
clean-cache:
    -rm -Force .cache

[linux]
clean-cache:
    -rm -rf .cache

clean-runtimes: clean-uv clean-python

[windows]
clean-uv:
    -rm -Force runtimes/uv

[windows]
clean-python:
    -rm -Force runtimes/python

[windows]
clean-builds:
    -rm -Force out