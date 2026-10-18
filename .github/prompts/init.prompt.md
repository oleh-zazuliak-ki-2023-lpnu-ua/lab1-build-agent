---
mode: agent
description: Оркестратор — послідовно запускає git-init, create-project, create-build, create-actions і check; зупиняється при першій помилці.
---

# /init — оркестратор

Ти працюєш як агент `build-engineer` (`.github/agents/build-engineer.agent.md`).
Виконай повний сценарій створення проєкту. Кожен крок — це інструкції з
відповідного prompt-файлу; прочитай його перед виконанням.

## Параметри
- `project_name` = `${input:project_name:hello}`

## Перевірка передумов (крок 0)
Виконай і покажи результати:
```bash
git --version
cmake --version
```
плюс наявність компілятора (`g++ --version` / `clang++ --version` / `cl`).
Якщо чогось бракує — `[init] FAILED at step 0` і порада, як встановити. Далі не йти.

## Порядок кроків
| Крок | Command | Файл інструкції | Вхід від попереднього кроку |
|---|---|---|---|
| 1 | git-init | `.github/prompts/git-init.prompt.md` | — |
| 2 | create-project | `.github/prompts/create-project.prompt.md` | репозиторій готовий, `.gitignore` |
| 3 | create-build | `.github/prompts/create-build.prompt.md` | `src/main.cpp` |
| 4 | create-actions | `.github/prompts/create-actions.prompt.md` | `CMakeLists.txt`, збірка OK |
| 5 | check | `.github/prompts/check.prompt.md` | усі файли |

## Правила оркестрації
1. Виконуй кроки СТРОГО в цьому порядку.
2. Після кожного кроку перевір його рядок статусу: `[<step>] PASSED`.
3. Якщо крок повернув `FAILED` — **зупинись**, не запускай наступні кроки,
   виведи підсумок і назву кроку, на якому зупинилися.
4. Не приховуй помилки і не оголошуй успіх без кроку 5 (`check`).
5. Повторний запуск `/init` безпечний: кожен крок пропускає вже правильні файли
   (`SKIPPED`) і не дублює конфігурацію.
6. Не комітити і не пушити — наприкінці лише запропонувати користувачу команди Git.

## Фінальний звіт
```
=== /init report ===
step 0 prerequisites   PASSED
step 1 git-init        PASSED
step 2 create-project  PASSED  (created: 3, skipped: 2)
step 3 create-build    PASSED  (ctest 1/1)
step 4 create-actions  PASSED
step 5 check           PASSED  (12/12)
RESULT: SUCCESS
Наступні кроки (виконує користувач):
  git add . && git commit -m "feat: generate project via build-engineer agent"
  git push -u origin <branch>
```
При помилці: `RESULT: FAILED at step N (<command>)` + причина.
