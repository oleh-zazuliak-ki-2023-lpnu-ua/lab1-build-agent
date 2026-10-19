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
  # Keep the GoogleTest runtime consistent with the main project on Windows.
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  FetchContent_MakeAvailable(googletest)

  enable_testing()
  add_executable(unit_tests tests/test_math.cpp)
  target_link_libraries(unit_tests PRIVATE math_utils GTest::gtest_main)

  include(GoogleTest)
  gtest_discover_tests(unit_tests)
endif()
