local entity = {}

entity.cx = 0
entity.cy = 0
entity.xr = 0.5
entity.yr = 1.0

entity.dx = 0.0
entity.dy = 0.0
entity.bdx = 0.0
entity.bdy = 0.0

entity.frict = 0.82
entity.bump_frict = 0.93

entity.hei = const.GRID
entity.radius = const.GRID * 0.5

entity.test_entity = "test"

function entity.say_test()
    log.info("I said test!")
end

return entity