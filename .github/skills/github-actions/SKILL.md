---
name: github-actions
description: Створює скрипти збірки ci.sh / ci.bat та GitHub Actions workflow .github/workflows/ci.yml з matrix Windows/Linux/macOS, який лише викликає ці скрипти і зберігає виконувані файли як artifacts.
---

# Skill: github-actions

## Коли застосовувати
- Проєкт уже збирається локально (є `CMakeLists.txt`), але немає CI.
- Команда `/create-actions` або крок 4 оркестратора `/init`.

## Входи
| Параметр | За замовчуванням | Опис |
|---|---|---|
| `branches` | `develop`, `master` | гілки для `push` і `pull_request` |
| `os_matrix` | `ubuntu-latest`, `windows-latest`, `macos-latest` | ОС |
| `artifact_name` | `hello-${{ matrix.os }}` | назва артефакту |

**Передумова:** існує `CMakeLists.txt` (інакше — помилка, запропонувати `/create-build`).

## Головне правило
`ci.yml` НЕ містить команд cmake/ctest. Він лише робить checkout, викликає
`ci.sh` (Linux/macOS) або `ci.bat` (Windows) і завантажує `dist/` як artifact.
Уся логіка конфігурації, складання, тестування та пакування — у скриптах,
тому локальний запуск і CI ідентичні.

## Виходи
```
ci.sh                       # Linux/macOS, виконуваний (chmod +x / git update-index --chmod=+x)
ci.bat                      # Windows
.github/workflows/ci.yml
```

### Що роблять скрипти (однаково на всіх ОС)
1. `cmake -S . -B build -DCMAKE_BUILD_TYPE=Release` — конфігурація
2. `cmake --build build --config Release` — складання
3. `ctest --test-dir build -C Release --output-on-failure` — тести
4. копіювання `hello` / `hello.exe` у `dist/`
5. запуск `dist/hello` — smoke-тест
6. будь-яка помилка → ненульовий код виходу

### Еталон `ci.sh`
```bash
#!/usr/bin/env bash
# Configure, build, test and package the project (Linux/macOS)
set -euo pipefail
cd "$(dirname "$0")"

BUILD_DIR=build
DIST_DIR=dist

echo "== Configure =="
cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release

echo "== Build =="
cmake --build "$BUILD_DIR" --config Release --parallel

echo "== Test =="
ctest --test-dir "$BUILD_DIR" -C Release --output-on-failure

echo "== Package =="
mkdir -p "$DIST_DIR"
cp "$BUILD_DIR/hello" "$DIST_DIR/hello"

echo "== Smoke test =="
"$DIST_DIR/hello"

echo "CI: SUCCESS"
```

### Еталон `ci.bat`
```bat
@echo off
rem Configure, build, test and package the project (Windows)
setlocal
cd /d "%~dp0"

set BUILD_DIR=build
set DIST_DIR=dist

echo == Configure ==
cmake -S . -B %BUILD_DIR% -DCMAKE_BUILD_TYPE=Release || goto :fail

echo == Build ==
cmake --build %BUILD_DIR% --config Release --parallel || goto :fail

echo == Test ==
ctest --test-dir %BUILD_DIR% -C Release --output-on-failure || goto :fail

echo == Package ==
if not exist %DIST_DIR% mkdir %DIST_DIR%
if exist %BUILD_DIR%\Release\hello.exe (
  copy /Y %BUILD_DIR%\Release\hello.exe %DIST_DIR%\hello.exe >nul || goto :fail
) else (
  copy /Y %BUILD_DIR%\hello.exe %DIST_DIR%\hello.exe >nul || goto :fail
)

echo == Smoke test ==
%DIST_DIR%\hello.exe || goto :fail

echo CI: SUCCESS
exit /b 0

:fail
echo CI: FAILED
exit /b 1
```

### Еталон `.github/workflows/ci.yml`
```yaml
name: CI

on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build-and-test:
    name: Build & Test (${{ matrix.os }})
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build and test (Linux/macOS)
        if: runner.os != 'Windows'
        shell: bash
        run: ./ci.sh

      - name: Build and test (Windows)
        if: runner.os == 'Windows'
        shell: cmd
        run: ci.bat

      - name: Upload executable
        uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

## Перевірки
- YAML валідний: `python -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml'))"`
  (або розширення *GitHub Actions* у VS Code не показує помилок);
- у файлі є всі три ОС: `ubuntu-latest`, `windows-latest`, `macos-latest`;
- у `ci.yml` немає слів `cmake` і `ctest` (усе у скриптах);
- у `ci.yml` немає `secrets.` і жодних токенів;
- локально `./ci.sh` (або `ci.bat`) завершується з кодом 0 і створює `dist/hello`;
- `ci.sh` має біт виконання в Git: `git ls-files -s ci.sh` → `100755`.

## Приклад
**Вхід:** `/create-actions`
**Очікуваний результат:**
```
ci.sh                     CREATED (+x)
ci.bat                    CREATED
.github/workflows/ci.yml  CREATED
yaml: OK, matrix: 3 OS, local ci.sh: exit 0
```

## Типовий сценарій помилки
**Ситуація:** job на Linux падає з `./ci.sh: Permission denied`.
**Причина:** файл закомічено без біта виконання (типово при роботі з Windows).
**Дія:** запропонувати користувачу `git update-index --chmod=+x ci.sh` і новий коміт.

**Ситуація:** Windows job не знаходить `hello.exe`.
**Причина:** MSVC — multi-config генератор, файл лежить у `build/Release/`.
**Дія:** у `ci.bat` перевіряти обидва шляхи: `build\Release\hello.exe` і `build\hello.exe`.
