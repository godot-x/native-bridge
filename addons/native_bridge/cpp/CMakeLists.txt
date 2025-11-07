cmake_minimum_required(VERSION 3.20)
project(native_bridge LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(${CMAKE_CURRENT_SOURCE_DIR}/config.cmake)

include(FetchContent)

FetchContent_Declare(
    godot_cpp
    GIT_REPOSITORY ${GODOT_CPP_REPO}
    GIT_TAG        ${GODOT_CPP_TAG}
)

FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY ${NLOHMANN_JSON_REPO}
    GIT_TAG        ${NLOHMANN_JSON_TAG}
)

FetchContent_MakeAvailable(godot_cpp nlohmann_json)

if (NOT TARGET godot-cpp)
    message(FATAL_ERROR "godot-cpp target 'godot-cpp' not found. Please check the version/tag.")
endif()

file(GLOB NATIVE_BRIDGE_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)

add_library(native_bridge SHARED ${NATIVE_BRIDGE_SOURCES})

target_include_directories(native_bridge PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${godot_cpp_SOURCE_DIR}/include
    ${godot_cpp_SOURCE_DIR}/gdextension
)

target_link_libraries(native_bridge PRIVATE godot-cpp nlohmann_json::nlohmann_json)

if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set_target_properties(native_bridge PROPERTIES
        OUTPUT_NAME "native_bridge_macos"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
    )
elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(native_bridge PROPERTIES
        OUTPUT_NAME "native_bridge_windows"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
    )
else()
    set_target_properties(native_bridge PROPERTIES
        OUTPUT_NAME "native_bridge_linux"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
    )
endif()
