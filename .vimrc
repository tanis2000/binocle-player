set makeprg=make\ -C\ ./build\ -j8
nnoremap <F4> :make<cr>
nnoremap <F5> :!./build/binocle-player.app/Contents/MacOS/binocle-player<cr>
let g:cmake_project_generator="Ninja"
let g:cmake_build_type="Debug"
let b:build_dir="build"
let g:syntastic_lua_luacheck_args = "--no-unused-args --config assets/.luacheckrc"

