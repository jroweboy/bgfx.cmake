# bgfx.cmake - bgfx building in cmake
# Written in 2017 by Joshua Brookover <joshua.al.brookover@gmail.com>

# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.

# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

if( TARGET glsl-optimizer )
	return()
endif()

set( GLSL_OPTIMIZER_INCLUDES
	${BGFX_DIR}/3rdparty/glsl-optimizer/include
	${BGFX_DIR}/3rdparty/glsl-optimizer/src/mesa
	${BGFX_DIR}/3rdparty/glsl-optimizer/src/mapi
	${BGFX_DIR}/3rdparty/glsl-optimizer/src/glsl
	${BGFX_DIR}/3rdparty/glsl-optimizer/src
)

# glsl-optimizer makes UBSan segfault for whatever reason
# We already know that it's full of UB anyway... so just don't build it with UBSan
string(REPLACE "-fsanitize=undefined" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" )
string(REPLACE "-fsanitize=undefined" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )

# glcpp
file( GLOB GLCPP_SOURCES ${BGFX_DIR}/3rdparty/glsl-optimizer/src/glsl/glcpp/*.c ${BGFX_DIR}/3rdparty/glsl-optimizer/src/util/*.c )

# mesa
file( GLOB MESA_SOURCES ${BGFX_DIR}/3rdparty/glsl-optimizer/src/mesa/program/*.c ${BGFX_DIR}/3rdparty/glsl-optimizer/src/mesa/main/*.c )

# glsl-optimizer
file( GLOB GLSL_OPTIMIZER_SOURCES ${BGFX_DIR}/3rdparty/glsl-optimizer/src/glsl/*.cpp ${BGFX_DIR}/3rdparty/glsl-optimizer/src/glsl/*.c )
file( GLOB GLSL_OPTIMIZER_SOURCES_REMOVE ${BGFX_DIR}/3rdparty/glsl-optimizer/src/glsl/main.cpp ${BGFX_DIR}/3rdparty/glsl-optimizer/src/glsl/builtin_stubs.cpp )
list( REMOVE_ITEM GLSL_OPTIMIZER_SOURCES ${GLSL_OPTIMIZER_SOURCES_REMOVE} )
add_library( glsl-optimizer STATIC ${GLSL_OPTIMIZER_SOURCES} ${MESA_SOURCES} ${GLCPP_SOURCES})
target_include_directories(glsl-optimizer PUBLIC ${GLSL_OPTIMIZER_INCLUDES})
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
	target_compile_options( glsl-optimizer
		PRIVATE
		-fno-strict-aliasing
		-Wno-implicit-fallthrough
		-Wno-parentheses
		-Wno-sign-compare
		-Wno-unused-function
		-Wno-unused-parameter
	)
endif()
if( MSVC )
	set_target_properties( glsl-optimizer PROPERTIES COMPILE_FLAGS "/W0" )
	target_compile_definitions( glsl-optimizer
		PRIVATE
		__STDC__
		__STDC_VERSION__=199901L
		strdup=_strdup
		alloca=_alloca
		isascii=__isascii
	)
elseif(APPLE)
	target_compile_options( glsl-optimizer
		PRIVATE
		-Wno-deprecated-register
	)
endif()
set_target_properties( glsl-optimizer PROPERTIES FOLDER "bgfx/3rdparty" )
