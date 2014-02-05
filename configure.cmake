# Copyright (c) 2012-2014, Christian Rorvik
# Distributed under the Simplified BSD License (See accompanying file LICENSE.txt)

#
# Call built in FindBoost module
#

# FindBoost doesn't deal well with 32 vs 64 bit library on windows. Try to find the lib directory here.
if(WIN32 AND
  ${CMAKE_SIZEOF_VOID_P} EQUAL 8 AND
  EXISTS "$ENV{PROGRAMFILES}/boost/lib64" AND
  NOT DEFINED BOOST_LIBRARYDIR AND
  "$ENV{BOOST_LIBRARYDIR}" STREQUAL "")
  message(STATUS "Overriding boost library directory to $ENV{PROGRAMFILES}/boost/lib64")
  set(BOOST_LIBRARYDIR "$ENV{PROGRAMFILES}/boost/lib64")
endif()

set(_components
  date_time
  filesystem
  iostreams
  program_options
  regex
  serialization
  system
  thread
  unit_test_framework)

if(WIN32)
  set(Boost_USE_STATIC_LIBS ON)
else()
  set(Boost_USE_STATIC_LIBS OFF)
endif()
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
set(Boost_ADDITIONAL_VERSIONS "1.55" "1.55.0")
find_package(Boost 1.55.0 EXACT QUIET REQUIRED ${_components})

if(NOT Boost_FOUND)
  message(FATAL_ERROR "Boost not found")
endif()

include_directories(${Boost_INCLUDE_DIR})

# Disable boost auto linking
add_definitions("-DBOOST_ALL_NO_LIB")

#
# Add targets
#

foreach(_c ${_components})
  add_library(boost_${_c} STATIC IMPORTED)
  string(TOUPPER ${_c} _cu)

  if (NOT EXISTS ${Boost_${_cu}_LIBRARY_RELEASE})
    message(FATAL_ERROR "Release library for boost component ${_c} not found")
  endif()
  if (NOT EXISTS ${Boost_${_cu}_LIBRARY_DEBUG})
    message(FATAL_ERROR "Debug library for boost component ${_c} not found")
  endif()

  set_target_properties(boost_${_c} PROPERTIES IMPORTED_LOCATION ${Boost_${_cu}_LIBRARY_RELEASE})
  set_target_properties(boost_${_c} PROPERTIES IMPORTED_LOCATION_DEBUG ${Boost_${_cu}_LIBRARY_DEBUG})
endforeach()