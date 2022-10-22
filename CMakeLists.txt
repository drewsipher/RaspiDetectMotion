
cmake_minimum_required(VERSION 3.10.0)

project(camDetect)

include(Definitions.cmake)

find_package(OpenCV 4.6 REQUIRED PATHS ${DEPENDENCIES_PATH}/opencv)

# Add executable target
add_executable(camDetect)

# Set target sources
target_sources(camDetect PRIVATE main.cpp)

target_include_directories(camDetect PUBLIC
    ${OpenCV_INCLUDE_DIRS}
)

target_link_libraries(camDetect PUBLIC
    ${OpenCV_LIBRARIES}
)

# Set target runtime directory
set_target_properties(camDetect PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)