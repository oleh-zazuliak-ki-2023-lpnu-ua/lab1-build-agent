---
mode: agent
description: Перевіряє структуру агента та проєкту, конфігурацію, складання, тести і YAML workflow. НІЧОГО НЕ ЗМІНЮЄ.
---

# /check

Ти працюєш як агент `build-engineer` у режимі **тільки читання**.

## Головне правило
Ця команда НЕ створює, НЕ змінює і НЕ видаляє файли проєкту. Дозволено лише читати
файли і запускати команди перевірки (збірка в `build/` дозволена — вона ігнорується Git).
Якщо щось не так — повідом, але не виправляй.

## Передумови
Немає. Відсутній файл = провалена перевірка, а не помилка команди.

## Перевірки (виконай усі, не зупиняйся на першій невдачі)
| # | Перевірка | Як |
|---|---|---|
| 1 | Manifest існує і має розділи «Роль», «Заборонені дії», «Критерії» | `.github/agents/build-engineer.agent.md` |
| 2 | 3 skills, кожен має «Входи», «Виходи», «Перевірки» | `.github/skills/*/SKILL.md` |
| 3 | 6 prompts існують | `git-init, create-project, create-build, create-actions, check, init` |
| 4 | `init` викликає кроки в порядку git-init → create-project → create-build → create-actions → check | `.github/prompts/init.prompt.md` |
| 5 | Файли проєкту існують | `src/main.cpp`, `src/math_utils.*`, `tests/test_math.cpp`, `CMakeLists.txt` |
| 6 | Збірка проходить | `cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release` |
| 7 | `hello` виводить `Hello, World!` | `./build/hello` або `build\Release\hello.exe` |
| 8 | Тест `BasicAddition` проходить | `ctest --test-dir build -C Release --output-on-failure` |
| 9 | YAML валідний, 3 ОС, без cmake/ctest, без secrets | див. `/create-actions` |
| 10 | `build/`, `dist/` не відстежуються Git | `git ls-files build dist` → порожньо; `git check-ignore build` |
| 11 | Немає секретів | `git grep -nIiE "(api[_-]?key\|token\|password\|secret)\s*[:=]"` → порожньо |
| 12 | Документація існує | `README.md`, `docs/architecture.md`, `docs/usage.md`, `docs/ai-log.md` |

## Формат звіту
```
| # | Перевірка | Статус | Деталі |
|---|-----------|--------|--------|
| 1 | manifest  | ✅ PASS | |
| 8 | tests     | ❌ FAIL | MathTest.BasicAddition: expected 5, got 6 |
...
[check] PASSED (12/12)      або      [check] FAILED (10/12): #8, #11
```
Статус `PASSED` лише якщо пройшли ВСІ перевірки.
