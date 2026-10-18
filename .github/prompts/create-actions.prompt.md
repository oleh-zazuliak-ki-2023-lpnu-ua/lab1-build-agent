---
mode: agent
description: Створює ci.sh, ci.bat та .github/workflows/ci.yml (matrix Windows/Linux/macOS) за skill github-actions.
---

# /create-actions

Ти працюєш як агент `build-engineer`. Прочитай і виконай skill
`.github/skills/github-actions/SKILL.md`.

## Передумови
- Існує `CMakeLists.txt` (інакше: «спочатку запустіть /create-build»).

## Дії
1. Створи `ci.sh` і `ci.bat` за еталонами skill-а (лише відсутні).
2. Зроби `ci.sh` виконуваним: `chmod +x ci.sh` і, якщо файл уже в індексі Git,
   запропонуй `git update-index --chmod=+x ci.sh`.
3. Створи `.github/workflows/ci.yml` за еталоном. Не додавай кроків cmake/ctest у YAML.
4. Запусти локально відповідний скрипт для поточної ОС.

## Очікувані файли
`ci.sh`, `ci.bat`, `.github/workflows/ci.yml`

## Команди перевірки
```bash
python3 -c "import yaml; d=yaml.safe_load(open('.github/workflows/ci.yml')); print('YAML OK')"
grep -c -E "ubuntu-latest|windows-latest|macos-latest" .github/workflows/ci.yml   # >= 3
! grep -qiE "cmake|ctest" .github/workflows/ci.yml && echo "no build logic in yml: OK"
./ci.sh            # Linux/macOS, exit 0
```
Windows: `ci.bat` → `echo %ERRORLEVEL%` дорівнює `0`.

## Повідомлення про помилку
```
[create-actions] FAILED: <yaml|matrix|script> — <причина>
```

## Звіт
Таблиця файлів + `YAML OK` + `local ci: exit 0` + `[create-actions] PASSED`.
Нагадай користувачу: workflow перевіряється на GitHub лише після `git push` (робить користувач).
