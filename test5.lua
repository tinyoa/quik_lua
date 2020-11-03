--log = require "C:\\22\\lua\\log"
log = require "log"

-- Флаг поддержания работы скрипта
IsRun = true;
 
function main()
	log.trace('trace')
	log.debug('debug')
	log.info('info')
	log.warn('warn')
	log.error('error')
	log.fatal('fatal')
	
	-- Subscribe_Level_II_Quotes(STRING class_code, STRING sec_code)
	
	-- ret = Subscribe_Level_II_Quotes("TQBR", "VTBR")
	ret = CreateDataSource("TQBR", "VTBR", INTERVAL_D1)

	log.trace(ret)
	log.trace(ret:C	)
end;
 
function OnStop()
   IsRun = false;
end;