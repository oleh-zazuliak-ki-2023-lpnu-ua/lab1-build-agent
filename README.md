# Lab 1 — AI-агент Build Engineer (C++ / CMake / GoogleTest)

|                   |                                       |
| ----------------- | ------------------------------------- |
| **Студент**       | Зазуляк Олег Андрійович               |
| **Група**         | КІ-404                                |
| **Варіант**       | 7 — C++, CMake, GoogleTest / CTest    |
| **AI-інструмент** | GitHub Copilot (VS Code, режим Agent) |

## Опис

Репозиторій містить AI-агента `build-engineer`, який автоматично генерує
кросплатформний C++ проєкт Hello World: вихідний код, систему складання CMake,
юніт-тест `MathTest.BasicAddition` на GoogleTest, скрипти збірки `ci.sh` / `ci.bat`
та GitHub Actions workflow для Windows, Linux і macOS.

- гілка `develop` — лише агент та інструкції;
- гілка `feature/hello-agent` — результат запуску агента (код, тести, CI).

## Структура агента

```
.github/
├── agents/build-engineer.agent.md     # manifest агента
├── prompts/                            # commands
│   ├── git-init.prompt.md
│   ├── create-project.prompt.md
│   ├── create-build.prompt.md
│   ├── create-actions.prompt.md
│   ├── check.prompt.md
│   └── init.prompt.md                  # orchestrator
└── skills/
    ├── project-scaffold/SKILL.md
    ├── build-and-test/SKILL.md
    └── github-actions/SKILL.md
docs/
├── architecture.md                     # архітектура агента
├── ai-log.md                           # журнал взаємодії з AI
└── usage.md                            # створюється агентом
```

## Як запустити агента

**Потрібно:** VS Code, розширення GitHub Copilot + Copilot Chat (план Copilot Student),
Git, CMake ≥ 3.16, компілятор C++17 (Visual Studio Build Tools / g++ / Xcode CLT), інтернет
(CMake завантажує GoogleTest).

1. Клонувати репозиторій і створити гілку:
   ```bash
   git clone <url> && cd <repo>
   git checkout develop
   git checkout -b feature/hello-agent
   ```
2. Відкрити папку у VS Code, відкрити **Copilot Chat** і перемкнути режим на **Agent**.
3. У списку агентів обрати **build-engineer**.
4. Ввести в чат:
   ```
   /init
   ```
5. Дозволити виконання запропонованих команд терміналу, переглянути фінальний звіт
   (`RESULT: SUCCESS`).
6. Окремі операції: `/git-init`, `/create-project`, `/create-build`, `/create-actions`, `/check`.

## Як зібрати та запустити проєкт (після `/init`)

```bash
./ci.sh            # Linux / macOS
ci.bat             # Windows
./dist/hello       # Hello, World!
```

Детальніше — у `docs/usage.md`.
