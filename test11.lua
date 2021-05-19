-- test11.lua

--[[
Баланс покупок/продаж поминутно
]]

TICER = "SBER";
CLASS_CODE = "TQBR";

stopped = false;
t_id = nil
H = -1;
M = -1;
VSELL = 0;
VBUY  = 0;

function OnInit()
    CreateTable();
end 

function main() 
	while not stopped do 
		if IsWindowClosed(t_id) then
			stopped = true;
		end        
		sleep(100);
	end
end

function CreateTable()
	t_id = AllocTable(); 
	AddColumn(t_id, 0, "Время", true, QTABLE_STRING_TYPE, 10);
	AddColumn(t_id, 1, "BUY", true, QTABLE_INT_TYPE, 15);
	AddColumn(t_id, 2, "SELL", true, QTABLE_INT_TYPE, 15);
	AddColumn(t_id, 3, "Дельта V", true, QTABLE_INT_TYPE, 15);   
	AddColumn(t_id, 4, "Цена", true, QTABLE_DOUBLE_TYPE, 15);
	tab = CreateWindow(t_id);
	SetWindowCaption(t_id, TICER.." Баланс покупок/продаж");
	SetTableNotificationCallback(t_id, EventCallBack);
end

function OnAllTrade(alltrade)
	if alltrade.sec_code == TICER then      
		fl = tostring(alltrade.flags);
		if H == alltrade.datetime.hour then
			if M == alltrade.datetime.min then
				if fl == "1025" then VSELL = VSELL + alltrade.qty; end --Продажа
				if fl == "1026" then VBUY  = VBUY + alltrade.qty;  end
			else               
				M = alltrade.datetime.min;
				--Rows --срока   Coll -- Колонка
				InsertRow(t_id, -1);
				local Rows, Col = GetTableSize(t_id);
				local Delta = VBUY - VSELL;
				--local t = tostring(alltrade.datetime.hour)..":"..tostring(alltrade.datetime.min);
				local t = tostring(H)..":"..tostring(M);
				SetCell(t_id, Rows-1, 0, t);
				SetCell(t_id, Rows-1, 1, tostring(VBUY));
				SetCell(t_id, Rows-1, 2, tostring(VSELL));                      
				SetCell(t_id, Rows-1, 3, tostring(Delta));
				SetCell(t_id, Rows-1, 4, tostring(alltrade.price));

				if Delta<0 then Red(Rows-1,3); end
				if Delta>0 then Green(Rows-1,3); end
				if Delta==0 then Yellow(Rows-1,3); end
				if fl == "1025" then VSELL = alltrade.qty; end --Продажа
				if fl == "1026" then VBUY  = alltrade.qty; end
			end
		else                   
			H = alltrade.datetime.hour;
			M = alltrade.datetime.min;
		end
	end
end

function Red(row,col)
    SetColor(t_id, row, col, RGB(255,0,0), RGB(0,0,0), RGB(255,0,0), RGB(0,0,0));
end

function Yellow(row,col)
    SetColor(t_id, row, col, RGB(240,240,0), RGB(0,0,0), RGB(240,240,0), RGB(0,0,0));
end

function Green(row,col)
    SetColor(t_id, row, col, RGB(0,200,0), RGB(0,0,0), RGB(0,200,0), RGB(0,0,0));
end


function EventCallBack(t_id, msg, par1, par2)
	if msg==QTABLE_CLOSE then
		OnStop();
	end;
end

function OnStop(s)
	if t_id ~= nil then
		DestroyTable (t_id);
	end;
	stopped = true;
end