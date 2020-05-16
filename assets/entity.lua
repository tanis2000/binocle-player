local entity = {}

entity.test_entity = "test"

function entity.say_test()
    log.info("I said test!")
end

return entity