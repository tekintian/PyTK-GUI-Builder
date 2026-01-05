#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

rm -rf dist build    # 清理旧构建
pyinstaller pytk_gui_builder.spec  # 重新构建
cd dist && ./pytk_gui_builder     # 运行测试
