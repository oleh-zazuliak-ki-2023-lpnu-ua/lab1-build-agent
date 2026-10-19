# Використання

## Передумови

- Git
- CMake версії 3.16 або новішої
- Компілятор C++17: Visual Studio Build Tools на Windows, GCC/Clang на Linux або Xcode Command Line Tools на macOS
- Доступ до інтернету для завантаження GoogleTest через CMake FetchContent

## Запуск агента

У VS Code відкрийте Copilot Chat, увімкніть режим Agent, оберіть агента
`build-engineer` і виконайте `/init`.

Окремі команди агента:

- `/git-init` — перевірити Git-репозиторій і `.gitignore`
- `/create-project` — створити початковий C++ проєкт
- `/create-build` — створити CMake-конфігурацію та тести
- `/create-actions` — створити локальні CI-скрипти та workflow
- `/check` — виконати всі перевірки без змін

## Локальна збірка і тести

Linux/macOS:

```bash
./ci.sh
```

Windows:

```bat
ci.bat
```

Ручні команди:

```bash
cmake -S . -B build
cmake --build build --config Release
ctest --test-dir build -C Release
```

## Запуск програми

Після виконання CI:

- Linux/macOS: `./dist/hello`
- Windows: `dist\hello.exe`

Очікуваний вивід:

```text
Hello, World!
```

## Перевірка

Виконайте `/check` в Copilot Chat. Статус `PASSED` означає, що структура агента,
вихідні файли, збірка, тест `MathTest.BasicAddition`, CI-конфігурація та документація
успішно перевірені.
