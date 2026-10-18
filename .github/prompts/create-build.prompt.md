---
mode: agent
description: Створює CMake-конфігурацію, функцію add() та тест BasicAddition за skill build-and-test і перевіряє збірку.
---

# /create-build

Ти працюєш як агент `build-engineer`. Прочитай і виконай skill
`.github/skills/build-and-test/SKILL.md`.

## Передумови
- Існує `src/main.cpp` (інакше: «спочатку запустіть /create-project»).
- Встановлено `cmake` ≥ 3.16 і компілятор C++ (g++/clang++/MSVC).
  Перевір: `cmake --version`. Якщо немає — зупинись і підкажи, як встановити;
  сам нічого не встановлюй.

## Дії
1. Створи `src/math_utils.h`, `src/math_utils.cpp`, `tests/test_math.cpp`, `CMakeLists.txt`
   за еталонами зі skill-а (лише відсутні; існуючі звір з еталоном).
2. Якщо `src/main.cpp` ще не використовує `math_utils` — це нормально, не змінюй його.
3. Виконай збірку і тести.

## Очікувані файли
`CMakeLists.txt`, `src/math_utils.h`, `src/math_utils.cpp`, `tests/test_math.cpp`

## Команди перевірки
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
```
Успіх: `100% tests passed`, у виводі є `MathTest.BasicAddition`.

## Повідомлення про помилку
```
[create-build] FAILED на кроці <configure|build|test>
<до 20 рядків ключового виводу>
Пропоноване виправлення: <...>
```

## Звіт
Таблиця файлів + результат ctest + `[create-build] PASSED`.
