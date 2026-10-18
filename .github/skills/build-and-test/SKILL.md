---
name: build-and-test
description: Створює систему складання CMake, тестову функцію add() та юніт-тест GoogleTest BasicAddition, що запускається через CTest. Використовувати після project-scaffold.
---

# Skill: build-and-test

## Коли застосовувати
- Існує `src/main.cpp`, але немає `CMakeLists.txt` або тестів.
- Команда `/create-build` або крок 3 оркестратора `/init`.

## Входи
| Параметр | За замовчуванням | Опис |
|---|---|---|
| `project_name` | `hello` | назва цілі виконуваного файлу |
| `cxx_standard` | `17` | стандарт C++ |
| `gtest_version` | `v1.14.0` | тег GoogleTest для FetchContent |

**Передумова:** `src/main.cpp` існує (інакше — помилка, запропонувати `/create-project`).

## Виходи
```
src/math_utils.h       # оголошення int add(int, int)
src/math_utils.cpp     # реалізація
tests/test_math.cpp    # TEST(MathTest, BasicAddition)
CMakeLists.txt
```

### Підкроки
1. **build** — бібліотека `math_utils` + виконуваний файл `hello`.
2. **test-function** — `int add(int a, int b)`.
3. **unit-test** — GoogleTest через `FetchContent`, реєстрація у CTest через `gtest_discover_tests`.

### Еталон `CMakeLists.txt`
```cmake
cmake_minimum_required(VERSION 3.16)
project(hello VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(math_utils src/math_utils.cpp)
target_include_directories(math_utils PUBLIC src)

add_executable(hello src/main.cpp)
target_link_libraries(hello PRIVATE math_utils)

option(BUILD_TESTING "Build unit tests" ON)
if(BUILD_TESTING)
  include(FetchContent)
  FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  )
  # На Windows узгоджуємо CRT з основним проєктом
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)

  enable_testing()
  add_executable(unit_tests tests/test_math.cpp)
  target_link_libraries(unit_tests PRIVATE math_utils GTest::gtest_main)

  include(GoogleTest)
  gtest_discover_tests(unit_tests)
endif()
```

### Еталон `src/math_utils.h`
```cpp
#pragma once

// Returns the sum of two integers.
int add(int a, int b);
```

### Еталон `src/math_utils.cpp`
```cpp
#include "math_utils.h"

int add(int a, int b) {
    return a + b;
}
```

### Еталон `tests/test_math.cpp`
```cpp
#include <gtest/gtest.h>
#include "math_utils.h"

TEST(MathTest, BasicAddition) {
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(-1, 1), 0);
}
```

## Кроки
1. Перевір передумову.
2. Створи відсутні файли; існуючі звір з еталоном (не дублюй `add_executable`, `FetchContent_Declare`).
3. Виконай перевірки нижче.

## Перевірки
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
```
- конфігурація та збірка без помилок;
- існує `build/hello` (Linux/macOS) або `build/Release/hello.exe` (Windows, MSVC);
- запуск `hello` виводить `Hello, World!`;
- вивід ctest містить `MathTest.BasicAddition` і `100% tests passed`.

## Приклад
**Вхід:** `/create-build`
**Очікуваний результат:**
```
src/math_utils.h     CREATED
src/math_utils.cpp   CREATED
tests/test_math.cpp  CREATED
CMakeLists.txt       CREATED
ctest: 1/1 MathTest.BasicAddition ... Passed
```

## Типовий сценарій помилки
**Ситуація:** немає доступу до мережі — `FetchContent` не може завантажити GoogleTest.
**Ознака:** `CMake Error ... Failed to download googletest`.
**Дія:** зупинитись, повідомити користувачу, що потрібен інтернет (або встановлений
GTest + `find_package(GTest)`), не підміняти тест заглушкою.

**Ситуація:** на Windows помилка `LNK2038: mismatch detected for 'RuntimeLibrary'`.
**Дія:** перевірити, що є рядок `set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)`.
