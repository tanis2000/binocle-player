# Generated by YCM Generator at 2020-06-09 16:48:00.795892

# This file is NOT licensed under the GPLv3, which is the license for the rest
# of YouCompleteMe.
#
# Here's the license text for this file:
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

import os
import ycm_core

flags = [
    '-x',
    'c',
    '-DFT2_BUILD_LIBRARY',
    '-DHAVE_ALLOCA_H',
    '-DHAVE_LIBC',
    '-DHX_MACOS',
    '-DSDL_VIDEO_METAL=0',
    '-DSDL_VIDEO_OPENGL_EGL=0',
    '-DSDL_VIDEO_OPENGL_ES2=0',
    '-DSDL_VIDEO_RENDER_METAL=0',
    '-DSDL_VIDEO_RENDER_OGL_ES2=0',
    '-DSDL_VIDEO_VULKAN=0',
    '-DTARGET_API_MAC_CARBON',
    '-DTARGET_API_MAC_OSX',
    '-D_THREAD_SAFE',
    '-D__APPLE__',
    '-Dgameplay_EXPORTS',
    '-I/U-D__APPLE__',
    '-I/Ulatform/Developer/SDKs/MacOSX10.15.sdk',
    '-I/Users/-DHX_MACOS',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/binocle',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/binocle/core',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/fr-DHAVE_ALLOCA_H',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/fr-D__APPLE__',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/fr.dir/src/lstrlib.c.o',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/include/config',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/include/internal',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/src/autofit',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/src/psaux',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/src/psnames',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/src/raster',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/src/sfnt',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/src/smooth',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/freetype/src/truetype',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/glew/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/glew/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/glew/src',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/kazmath/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/kazmath/../lua/src',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/libuv/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/libuv/src',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/libuv/src/unix',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/lua/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/lua/src',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/ogg/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/ogg/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/parson/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/physfs',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/physfs/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/rxi_map/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/sdl/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/sdl/include/configs/mac',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/sdl/src/hidapi/hidapi',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/sdl_mixer',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/sokol',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/stb_image',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/vorbis/.',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/vorbis/../ogg/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/vorbis/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/vorbis/lib',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/vorbis/lib-D__APPLE__',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/wren/../libuv/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/wren/src/cli',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/wren/src/include',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/wren/src/module',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/wren/src/optional',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/wren/src/vm',
    '-I/Users/tanis/Documents/binocle-player/binocle-c/src/deps/zlib/.',
    '-I/Users/tanis/Documents/binocle-player/src',
    '-I/Users/tanis/Documents/binocle-player/src/deps',
    '-I/Users/tanis/Documents/binocle-player/src/deps/freetype',
    '-I/Users/tanis/Documents/binocle-player/src/deps/glew',
    '-I/Users/tanis/Documents/binocle-player/src/deps/kazmath',
    '-I/Users/tanis/Documents/binocle-player/src/deps/libuv',
    '-I/Users/tanis/Documents/binocle-player/src/deps/lua/src',
    '-I/Users/tanis/Documents/binocle-player/src/deps/miniaudio',
    '-I/Users/tanis/Documents/binocle-player/src/deps/ogg',
    '-I/Users/tanis/Documents/binocle-player/src/deps/physfs',
    '-I/Users/tanis/Documents/binocle-player/src/deps/sdl/include',
    '-I/Users/tanis/Documents/binocle-player/src/deps/sdl_mixer',
    '-I/Users/tanis/Documents/binocle-player/src/deps/sokol',
    '-I/Users/tanis/Documents/binocle-player/src/deps/stb_image',
    '-I/Users/tanis/Documents/binocle-player/src/deps/vorbis',
    '-I/Users/tanis/Documents/binocle-player/src/deps/wren',
    '-I/Users/tanis/Documents/binocle-player/src/deps/zlib',
    '-I/Users/tanis/Documents/binocle-player/src/gameplay',
    '-I/Utd=c11',
    '-std=c11',
    '-std=c99',
    '-std=gnu99',
    '-isysroot', '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.p-D__APPLE__',
    '-isysroot', '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk',
]


# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# You can get CMake to generate this file for you by adding:
#   set( CMAKE_EXPORT_COMPILE_COMMANDS 1 )
# to your CMakeLists.txt file.
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
compilation_database_folder = ''

if os.path.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

SOURCE_EXTENSIONS = [ '.C', '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return list( flags )
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path )
        break

    if new_flag:
      new_flags.append( new_flag )
  return new_flags


def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.H', '.h', '.hxx', '.hpp', '.hh' ]


def GetCompilationInfoForFile( filename ):
  # The compilation_commands.json file generated by CMake does not have entries
  # for header files. So we do our best by asking the db for flags for a
  # corresponding source file, if any. If one exists, the flags for that file
  # should be good enough.
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


def FlagsForFile( filename, **kwargs ):
  if database:
    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object
    compilation_info = GetCompilationInfoForFile( filename )
    if not compilation_info:
      return None

    final_flags = MakeRelativePathsInFlagsAbsolute(
      compilation_info.compiler_flags_,
      compilation_info.compiler_working_dir_ )

  else:
    relative_to = DirectoryOfThisScript()
    final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )

  return {
    'flags': final_flags,
    'do_cache': True
  }

def Settings( **kwargs ):
    language = kwargs[ 'language' ]
    if language == 'cfamily':
        return {
            'flags': flags
        }

    return {}