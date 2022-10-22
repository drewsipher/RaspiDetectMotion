# Check operating system
if (${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    # Linux
else()
    message(FATAL_ERROR "Operating system ${CMAKE_SYSTEM_NAME} is not supported.")
endif()

execute_process(COMMAND grep -q ubuntu /etc/os-release RESULT_VARIABLE IS_UBUNTU)
execute_process(COMMAND grep -q buster /etc/os-release RESULT_VARIABLE IS_BUSTER)
execute_process(COMMAND grep -q bullseye /etc/os-release RESULT_VARIABLE IS_BULLSEYE)

# Check operating system version
if (${IS_UBUNTU} EQUAL 0)
    # Ubuntu OS.  Check version
    execute_process(COMMAND grep -oP VERSION_ID="\\K[^"]+ /etc/os-release OUTPUT_VARIABLE UBUNTU_VERSION)
    if (${UBUNTU_VERSION} EQUAL 20.04)
        # Ubuntu 20.04 (Focal Fossa)
        set(OS_NAME ubuntu-20.04)
    elseif (${UBUNTU_VERSION} EQUAL 22.04)
        # Ubuntu 22.04 (Jammy Jellyfish)
        set(OS_NAME ubuntu-22.04)
    else()
        message(FATAL_ERROR "Ubuntu version ${UBUNTU_VERSION} is not supported.")
    endif()
elseif (${IS_BUSTER} EQUAL 0)
    # Raspian 10 (Buster)
    set(OS_NAME raspbian-10)
elseif (${IS_BULLSEYE} EQUAL 0)
    # Raspian 11 (Bullseye)
    set(OS_NAME raspbian-11)
else()
    message(FATAL_ERROR "Operating system version is not supported.")
endif()

# Check system architecture
if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL armv7l)
    # ARM 32-bit
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL aarch64)
    # ARM 64-bit
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL x86_64)
    # x86_64
else()
    message(FATAL_ERROR "Architecture ${CMAKE_SYSTEM_PROCESSOR} is not supported.")
endif()

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Set the dependencies path for this os and architecture
set(DEPENDENCIES_PATH ${CMAKE_CURRENT_LIST_DIR}/dependencies/${OS_NAME}/${CMAKE_SYSTEM_PROCESSOR})

# Set the absolute path of the repository
get_filename_component(REPOSITORY_PATH ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)

# Set the path to MFLib sources
set(SOURCE_PATH ${REPOSITORY_PATH}/MF)

# Set MFLib include directories
set(INCLUDE_DIRS ${REPOSITORY_PATH} ${CMAKE_CURRENT_LIST_DIR}/dependencies/include)

if (${OS_NAME} STREQUAL raspbian-10)
    # Additional include directories and link libraries for raspbian-10.
    set(OS_INCLUDE_DIRS /opt/vc/include)
    set(OS_LINK_DIRS /opt/vc/lib)
    set(OS_LIBRARIES bcm_host vcos mmal_core mmal_util mmal_vc_client vcsm stdc++fs)
elseif (${OS_NAME} STREQUAL raspbian-11)
    # Additional include directories and link libraries for raspbian-11.
    set(OS_INCLUDE_DIRS ${DEPENDENCIES_PATH}/libcamera/include/libcamera)
    set(OS_LINK_DIRS ${DEPENDENCIES_PATH}/libcamera/lib)
    set(OS_LIBRARIES camera-base camera)
endif()

# Set compiler options
set(COMPILE_OPTIONS -Werror -Wall -Wconversion -Wno-class-memaccess)

if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL armv7l)
     # Additional compiler options for armv7l
     list(APPEND COMPILE_OPTIONS -Wno-psabi -mcpu=cortex-a72 -mfpu=neon-vfpv4)
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL aarch64)
     # Additional compiler options for aarch64
     list(APPEND COMPILE_OPTIONS -Wno-psabi)
endif()

# Set compiler defintions
# Define the root of the MF Library directory so that resources (fonts, shaders, etc.) can be found.
set(COMPILE_DEFINITIONS DIR="${SOURCE_PATH}/")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    # In debug mode, add the compiler definition DEBUG_MF to switch on debug features
    list(APPEND COMPILE_DEFINITIONS DEBUG_MF)
endif()

if (${OS_NAME} STREQUAL raspbian-10)
    # Additional compiler definitions for raspbian-10
    list(APPEND COMPILE_DEFINITIONS __raspbian10__)
elseif (${OS_NAME} STREQUAL raspbian-11)
    # Additional compiler definitions for raspbian-11
    list(APPEND COMPILE_DEFINITIONS __raspbian11__)
endif()
