# Install script for directory: /home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/install/rosidl_generator_rs")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/ament_index/resource_index/rosidl_generator_packages" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_index/share/ament_index/resource_index/rosidl_generator_packages/rosidl_generator_rs")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/environment" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/pythonpath.sh")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/environment" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/pythonpath.dsv")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/python3.12/site-packages/rosidl_generator_rs-0.4.12-py3.12.egg-info" TYPE DIRECTORY FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_python/rosidl_generator_rs/rosidl_generator_rs.egg-info/")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/python3.12/site-packages/rosidl_generator_rs" TYPE DIRECTORY FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs/rosidl_generator_rs/" REGEX "/[^/]*\\.pyc$" EXCLUDE REGEX "/\\_\\_pycache\\_\\_$" EXCLUDE)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  execute_process(
        COMMAND
        "/usr/bin/python3" "-m" "compileall"
        "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/install/rosidl_generator_rs/lib/python3.12/site-packages/rosidl_generator_rs"
      )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/ament_index/resource_index/package_run_dependencies" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_index/share/ament_index/resource_index/package_run_dependencies/rosidl_generator_rs")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/ament_index/resource_index/parent_prefix_path" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_index/share/ament_index/resource_index/parent_prefix_path/rosidl_generator_rs")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/environment" TYPE FILE FILES "/opt/ros/jazzy/share/ament_cmake_core/cmake/environment_hooks/environment/ament_prefix_path.sh")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/environment" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/ament_prefix_path.dsv")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/environment" TYPE FILE FILES "/opt/ros/jazzy/share/ament_cmake_core/cmake/environment_hooks/environment/path.sh")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/environment" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/path.dsv")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/local_setup.bash")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/local_setup.sh")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/local_setup.zsh")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/local_setup.dsv")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_environment_hooks/package.dsv")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/ament_index/resource_index/packages" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_index/share/ament_index/resource_index/packages/rosidl_generator_rs")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/cmake" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_core/rosidl_generator_rs-extras.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/cmake" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs/cmake/register_rs.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/cmake" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_export_dependencies/ament_cmake_export_dependencies-extras.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs/cmake" TYPE FILE FILES
    "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_core/rosidl_generator_rsConfig.cmake"
    "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/ament_cmake_core/rosidl_generator_rsConfig-version.cmake"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE FILE FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs/package.xml")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE DIRECTORY FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs/cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/rosidl_generator_rs" TYPE PROGRAM FILES "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs/bin/rosidl_generator_rs")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/rosidl_generator_rs" TYPE DIRECTORY FILES
    "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs/cmake"
    "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/rosidl_rust/rosidl_generator_rs/resource"
    )
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/rsanz/git/learning/ros2/tutorials/RustROS2/src/build/rosidl_generator_rs/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
