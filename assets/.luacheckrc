allow_defined = true
stds.binocle = {
  -- these globals can be set and accessed.
  globals = { "on_init", "on_update" },

  -- these globals can only be accessed.
  read_globals = {
    -- embedded modules
    'color',
    'gd',
    'input',
    'log',
    'lkazmath',
    'sdl',
    'shader',
    'viewport_adapter',
    'window',

    -- global variables
    'gd_instance',
    'input_mgr',

    -- color
    'new', -- new()

    --[[
      copy(
        `-- from ${location.href} ${(new Date()).toISOString()}\n` +
        [].slice.call($('#WikiaMainContent').find('ul>li>a,.mw-headline'))
          .map(a => a.tagName == 'A' ?
            `'${a.innerText.replace(/\(.*/g,'')}', -- ${a.innerText.trim()}` :
            `\n-- ${a.innerText.trim()}`).join('\n'))
    ]]

    -- from http://pico-8.wikia.com/wiki/APIReference 2017-08-12T17:14:36.282Z

    -- The game loop
    'flip', -- flip()

    -- Graphics
    'camera', -- camera([x,] [y])
    'circ', -- circ(x, y, r, [col])
    'circfill', -- circfill(x, y, r, [col])
    'clip', -- clip([x,] [y,] [w,] [h])
    'cls', -- cls()
    'color', -- color(col)
    'cursor', -- cursor(x, y)
    'fget', -- fget(n, [f])
    'fset', -- fset(n, [f,] [v])
    'line', -- line(x0, y0, x1, y1, [col])
    'pal', -- pal([c0,] [c1,] [p])
    'palt', -- palt([c,] [t])
    'pget', -- pget(x, y)
    'print', -- print(str, [x,] [y,] [col])
    'pset', -- pset(x, y, [c])
    'rect', -- rect(x0, y0, x1, y1, [col])
    'rectfill', -- rectfill(x0, y0, x1, y1, [col])
    'sget', -- sget(x, y)
    'spr', -- spr(n, x, y, [w,] [h,] [flip_x,] [flip_y])
    'sset', -- sset(x, y, [c])
    'sspr', -- sspr(sx, sy, sw, sh, dx, dy, [dw,] [dh,] [flip_x,] [flip_y])

    -- Tables
    'add', -- add(t, v)
    'all', -- all(t)
    'del', -- del(t, v)
    'foreach', -- foreach(t, f)
    'pairs', -- pairs(t)

    -- Input
    'btn', -- btn([i,] [p])
    'btnp', -- btnp([i,] [p])

    -- Sound
    'music', -- music([n,] [fade_len,] [channel_mask])
    'sfx', -- sfx(n, [channel,] [offset])

    -- Map
    'map', -- map(cel_x, cel_y, sx, sy, cel_w, cel_h, [layer])
    'mget', -- mget(x, y)
    'mset', -- mset(x, y, v)

    -- Memory
    'cstore', -- cstore(dest_addr, source_addr, len, [filename])
    'memcpy', -- memcpy(dest_addr, source_addr, len)
    'memset', -- memset(dest_addr, val, len)
    'peek', -- peek(addr)
    'poke', -- poke(addr, val)
    'reload', -- reload(dest_addr, source_addr, len, [filename])

    -- Math
    'abs', -- abs(x)
    'atan2', -- atan2(dx, dy)
    'band', -- band(x, y)
    'bnot', -- bnot(x)
    'bor', -- bor(x, y)
    'bxor', -- bxor(x, y, )
    'cos', -- cos(x)
    'flr', -- flr(x)
    'max', -- max(x, y)
    'mid', -- mid(x, y, z)
    'min', -- min(x, y)
    'rnd', -- rnd(x)
    'shl', -- shl(x, y)
    'shr', -- shr(x, y)
    'sin', -- sin(x)
    'sqrt', -- sqrt(x)
    'srand', -- srand(x)

    -- Cartridge data
    'cartdata', -- cartdata(id)
    'dget', -- dget(index)
    'dset', -- dset(index, value)

    -- Coroutines
    'cocreate', -- cocreate(func)
    'coresume', -- coresume(cor)
    'costatus', -- costatus(cor)
    'yield', -- yield()

    -- Values and objects
    'setmetatable', -- setmetatable(tbl, metatbl)
    'type', -- type(v)
    'sub', -- sub(str, from, [to])

    -- Time
    'time', -- time()

    -- System
    'menuitem', -- menuitem(index, [label, callback])

    -- Debugging
    'assert', -- assert(expr)
    'printh', -- printh(str, [filename], [overwrite])
    'stat', -- stat(n)
    'stop', -- stop()
    'trace', -- trace()
  }
}

std = "min+binocle"
