-- test9.lua


-- Р¤Р»Р°Рі РїРѕРґРґРµСЂР¶Р°РЅРёСЏ СЂР°Р±РѕС‚С‹ СЃРєСЂРёРїС‚Р°
IsRun = true;

log = require "log"
myqlua = require "myqlua"

function main()
	
	log.trace('-- -- -- -- -- test9 begin')

	-- РљРѕРґ РєР»Р°СЃСЃР°
	class_code = "TQBR"
	-- РљРѕРґ Р±СѓРјР°РіРё
	sec_code = "VTBR"
	
	--log.trace("sma7: "..tostring(sma7)..type(sma7))
	--log.trace("price: "..tostring(curpr)..type(curpr))
	log.trace("LONGNAME '"..getParamEx(class_code, sec_code, "LONGNAME").param_image.."'")
	log.trace("pricemax "..tostring(getParamEx(class_code, sec_code, "pricemax").param_value))
	log.trace("LOTSIZE "..tostring(getParamEx(class_code, sec_code, "LOTSIZE").param_value))
	log.trace("SEC_PRICE_STEP "..tostring(getParamEx(class_code, sec_code, "SEC_PRICE_STEP").param_value))
	log.trace("pricemin "..getParamEx("TQBR", sec_code, "pricemin").param_value)
	
	log.trace('test9 end')
end;
