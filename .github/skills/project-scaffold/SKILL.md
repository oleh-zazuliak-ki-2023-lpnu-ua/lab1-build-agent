---
name: project-scaffold
description: Створює мінімальний C++ Hello World проєкт — структуру каталогів, src/main.cpp, README.md та .gitignore. Використовувати при першому створенні проєкту або коли бракує базових файлів.
---

# Skill: project-scaffold

## Коли застосовувати
- Репозиторій порожній або в ньому немає `src/main.cpp`.
- Команда `/create-project` або крок 2 оркестратора `/init`.

## Входи
| Параметр | За замовчуванням | Опис |
|---|---|---|
| `language` | `cpp` | мова проєкту (для варіанту 1 — лише `cpp`) |
| `project_name` | `hello` | назва проєкту та виконуваного файлу |

## Виходи
```
src/
  main.cpp          # точка входу, виводить "Hello, World!"
tests/              # порожній каталог з .gitkeep (заповнює build-and-test)
docs/
  usage.md          # заготовка інструкції запуску
README.md           # опис проєкту (не перезаписувати, якщо існує — лише додати відсутні розділи)
.gitignore
```

### Еталон `src/main.cpp`
```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

### Обов'язкові рядки `.gitignore`
```
build/
dist/
out/
cmake-build-*/
.vs/
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
CMakeUserPresets.json
*.exe
*.o
*.obj
.DS_Store
.env
```

### Обов'язкові розділи `docs/usage.md`
1. **Передумови** — Git, CMake ≥ 3.16, компілятор C++17 для кожної ОС.
2. **Запуск агента** — Copilot Chat → режим Agent → агент `build-engineer` → `/init`;
   перелік окремих команд.
3. **Локальна збірка і тести** — `./ci.sh` (Linux/macOS), `ci.bat` (Windows) та ручні команди
   `cmake -S . -B build`, `cmake --build build --config Release`, `ctest --test-dir build -C Release`.
4. **Запуск програми** — `./dist/hello` / `dist\hello.exe`, очікуваний вивід `Hello, World!`.
5. **Перевірка** — `/check` і що означає `PASSED`.

## Кроки
1. Перевір, чи існує кожен вихідний файл. Існуючі і правильні — `SKIPPED`.
2. Створи відсутні каталоги та файли.
3. У `.gitignore` додай лише ті рядки зі списку, яких ще немає (порівнюй рядок у рядок).
4. У `README.md`, якщо файл існує, не видаляй вміст користувача (ПІП, група, варіант).

## Перевірки
- `src/main.cpp` існує і містить рядок `Hello, World!`
- `.gitignore` містить `build/` і `dist/` рівно по одному разу:
  - Linux/macOS: `grep -cx 'build/' .gitignore` → `1`
  - Windows: `(Select-String -Pattern '^build/$' .gitignore).Count` → `1`
- Команда запуску задокументована в `docs/usage.md`

## Приклад
**Вхід:** `/create-project project_name=hello`
**Очікуваний результат:**
```
src/main.cpp      CREATED
tests/.gitkeep    CREATED
docs/usage.md     CREATED
README.md         SKIPPED (exists)
.gitignore        UPDATED (+N missing lines)
```

## Типовий сценарій помилки
**Ситуація:** `.gitignore` вже містить `build/`, а агент додає його вдруге.
**Ознака:** `grep -cx 'build/' .gitignore` повертає `2`.
**Дія:** не видаляти файл; прибрати лише дубльований рядок і повторити перевірку.

**Ситуація:** `src/main.cpp` існує, але з іншим вмістом (код користувача).
**Дія:** НЕ перезаписувати; повідомити користувача і позначити як `SKIPPED (custom)`.
