# Архітектура AI-агента build-engineer

## 1. Яку проблему вирішує агент
Створення навіть мінімального кросплатформного C++ проєкту вимагає узгодити
кілька частин: код, CMake, підключення GoogleTest, скрипти збірки для різних ОС,
CI-workflow і `.gitignore`. Помилка в будь-якій частині (дубльований рядок, забутий
біт виконання, MSVC-шлях до `.exe`) ламає CI. Агент фіксує цей процес у вигляді
повторюваних інструкцій, які:
- завжди дають однаковий результат (відтворюваність з гілки `develop`);
- перевіряють кожен крок, а не лише генерують файли;
- безпечні для повторного запуску (ідемпотентні).

## 2. Відповідність файлів ролям (GitHub Copilot у VS Code)
| Роль у лабораторній | Файл | Формат Copilot |
|---|---|---|
| Agent manifest | `.github/agents/build-engineer.agent.md` | custom agent (`*.agent.md`) |
| Skill: створення проєкту | `.github/skills/project-scaffold/SKILL.md` | agent skill |
| Skill: збірка і тести | `.github/skills/build-and-test/SKILL.md` | agent skill |
| Skill: GitHub Actions | `.github/skills/github-actions/SKILL.md` | agent skill |
| Command `git-init` | `.github/prompts/git-init.prompt.md` | prompt file → `/git-init` |
| Command `create-project` | `.github/prompts/create-project.prompt.md` | `/create-project` |
| Command `create-build` | `.github/prompts/create-build.prompt.md` | `/create-build` |
| Command `create-actions` | `.github/prompts/create-actions.prompt.md` | `/create-actions` |
| Command `check` | `.github/prompts/check.prompt.md` | `/check` |
| Orchestrator `init` | `.github/prompts/init.prompt.md` | `/init` |
| Налаштування VS Code | `.vscode/settings.json` | вмикає agent mode, prompt files, skills |

Структура збігається з рекомендованою в методичці, відхилень немає.

## 3. Схема взаємодії
```
                    ┌──────────────────────────────┐
                    │  build-engineer.agent.md     │
                    │  роль · правила · заборони   │
                    │  критерії завершення         │
                    └──────────────┬───────────────┘
                                   │ застосовується до всіх команд
                                   ▼
 користувач ──► /init (orchestrator)
                 │
                 ├─0─► перевірка передумов (git, cmake, компілятор)
                 ├─1─► /git-init ─────────────────────────────► .gitignore, стан Git
                 ├─2─► /create-project ──► skill project-scaffold ► src/main.cpp, README
                 ├─3─► /create-build ────► skill build-and-test ──► CMakeLists.txt, тест
                 ├─4─► /create-actions ──► skill github-actions ──► ci.sh, ci.bat, ci.yml
                 └─5─► /check (тільки читання) ─────────────────► звіт PASSED / FAILED
                 │
       будь-який крок FAILED ──► СТОП, звіт із назвою кроку
```

## 4. Дані між етапами
| Від кроку | До кроку | Що передається |
|---|---|---|
| git-init | create-project | ініціалізований репозиторій, `.gitignore` з `build/`, `dist/` |
| create-project | create-build | `src/main.cpp`, параметр `project_name` |
| create-build | create-actions | `CMakeLists.txt`, підтверджена локальна збірка, ім'я цілі `hello` |
| create-actions | check | `ci.sh`, `ci.bat`, `ci.yml` |
| усі | check | повний набір файлів + статуси `CREATED/UPDATED/SKIPPED` |

Кожен крок завершується рядком `[<step>] PASSED|FAILED`. Оркестратор продовжує
лише після `PASSED`.

## 5. Обробка помилок
1. **Передумови.** Немає git/cmake/компілятора — зупинка на кроці 0 з порадою щодо встановлення.
   Агент сам системні пакети не встановлює.
2. **Помилка кроку.** Агент показує команду та до 20 рядків виводу, пропонує виправлення в межах
   своєї області відповідальності, повторює перевірку не більше 2 разів.
3. **Невдача після повторів.** `RESULT: FAILED at step N`, подальші кроки не запускаються.
4. **Check.** Виконує всі 12 перевірок навіть після першої невдачі, щоб звіт був повним,
   але сам нічого не виправляє.
5. **Ідемпотентність.** Існуючі правильні файли — `SKIPPED`; `.gitignore` лише доповнюється;
   повторний `/init` не дублює конфігурацію.

## 6. Чому CI викликає лише скрипти
`ci.yml` містить тільки checkout, виклик `ci.sh`/`ci.bat` та upload artifact. Логіка
збірки зосереджена в скриптах, тому:
- локальний запуск і CI виконують однакові команди;
- помилку CI можна відтворити локально одним викликом;
- workflow не залежить від деталей CMake.

## 7. Обмеження агента
- Результат залежить від моделі LLM; тому еталони файлів зафіксовані в skills, а `check` перевіряє результат.
- Потрібен інтернет для завантаження GoogleTest (`FetchContent`).
- Агент не комітить і не пушить; перевірку на GitHub Actions ініціює користувач.
- Агент не встановлює компілятори та CMake.
