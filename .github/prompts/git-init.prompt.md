---
mode: agent
description: Перевіряє Git-репозиторій, створює або оновлює .gitignore, показує стан Git.
---

# /git-init

Ти працюєш як агент `build-engineer` (див. `.github/agents/build-engineer.agent.md`).

## Передумови
- Встановлено `git` (`git --version` повертає версію).

## Дії
1. Перевір, чи поточний каталог — Git-репозиторій: `git rev-parse --is-inside-work-tree`.
   - Якщо ні — виконай `git init -b master` (лише ініціалізація, без комітів).
   - Якщо так — нічого не ініціалізуй повторно.
2. Створи `.gitignore`, якщо його немає, або додай ЛИШЕ відсутні рядки зі списку
   «Обов'язкові рядки .gitignore» у `.github/skills/project-scaffold/SKILL.md`.
3. Покажи поточну гілку (`git branch --show-current`) і `git status --short`.
4. Попередь, якщо поточна гілка не `develop` і не `feature/*`.

## Очікувані файли
- `.gitignore`

## Команди перевірки
```bash
git rev-parse --is-inside-work-tree      # true
grep -cx 'build/' .gitignore             # 1
git check-ignore -q build/x && echo OK   # OK
```

## Заборонено
`git commit`, `git push`, `git reset`, `git checkout -- .`, видалення файлів.

## Повідомлення про помилку
```
[git-init] FAILED: <причина>
Команда: <команда>
Що зробити: <порада, напр. "встановіть Git: https://git-scm.com/downloads">
```

## Звіт
```
[git-init] PASSED
repo: OK | branch: <name> | .gitignore: CREATED/UPDATED/SKIPPED
```
