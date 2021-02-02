-- test8.lua


-- Флаг поддержания работы скрипта
IsRun = true;

log = require "log"
myqlua = require "myqlua"

function main()
	
	log.trace('-- -- -- -- -- test8 begin')

	tick = "VTBR"

	sma7 = myqlua.getSMA_7d(tick)
	curpr = myqlua.getPrice(tick)
	
	log.trace("sma7: "..tostring(sma7).." "..type(sma7))
	log.trace("price: "..tostring(curpr).." "..type(curpr))
	log.trace("Отклонение: "..tostring(curpr / sma7 - 1))
	
	log.trace(tostring(myqlua.getSMA(tick, INTERVAL_D1, 255)))
	log.trace(tostring(myqlua.getSMA(tick, INTERVAL_D1, 20)))
	log.trace(tostring(myqlua.getSMA(tick, INTERVAL_D1, 7)))
	
	log.trace('test8 end')
end;
