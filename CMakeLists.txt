#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

cmake_minimum_required(VERSION 3.1)

project(pulsar-cpp-demo)

set(Boost_NO_BOOST_CMAKE ON)
if (NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
endif ()

find_path(PULSAR_INCLUDE_DIR pulsar/Client.h)
find_library(PULSAR_LIBRARIES pulsar)
if (PULSAR_INCLUDE_DIR AND PULSAR_LIBRARIES)
    message(STATUS "PULSAR_INCLUDE_DIR: ${PULSAR_INCLUDE_DIR}")
    message(STATUS "PULSAR_LIBRARIES: ${PULSAR_LIBRARIES}")
else ()
    message(FATAL_ERROR "Failed to find PULSAR_INCLUDE_DIR and PULSAR_LIBRARIES")
endif ()
include_directories(${PULSAR_INCLUDE_DIR})

find_package(Threads REQUIRED)

add_executable(example ./example.cc)
set_target_properties(example PROPERTIES OUTPUT_NAME "example.out")
target_link_libraries(example PRIVATE ${PULSAR_LIBRARIES})

add_executable(multi_topics ./multi_topics.cc)
set_target_properties(multi_topics PROPERTIES OUTPUT_NAME "multi_topics.out")
target_link_libraries(multi_topics PRIVATE ${PULSAR_LIBRARIES} Threads::Threads)
