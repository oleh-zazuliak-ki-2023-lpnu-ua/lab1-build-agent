---
mode: agent
description: Створює початковий C++ Hello World проєкт за skill project-scaffold.
---

# /create-project

Ти працюєш як агент `build-engineer`. Прочитай і виконай skill
`.github/skills/project-scaffold/SKILL.md`.

## Параметри
- `project_name` = `${input:project_name:hello}`
- `language` = `cpp`

## Передумови
- Поточний каталог — Git-репозиторій (інакше: «спочатку запустіть /git-init»).

## Дії
1. Створи відсутні файли зі списку «Виходи» skill-а.
2. Існуючі файли не перезаписуй (`SKIPPED`), `.gitignore` лише доповнюй.

## Очікувані файли
`src/main.cpp`, `tests/.gitkeep`, `docs/usage.md`, `README.md`, `.gitignore`

## Команди перевірки
```bash
test -f src/main.cpp && grep -q "Hello, World!" src/main.cpp && echo OK
```
Windows (PowerShell): `Select-String -Path src/main.cpp -Pattern "Hello, World!"`

## Повідомлення про помилку
```
[create-project] FAILED: <файл> — <причина>
```

## Звіт
Таблиця файлів зі статусами `CREATED / UPDATED / SKIPPED` і рядок `[create-project] PASSED`.
