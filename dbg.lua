--[[
 ______________________________________________________________________
/ main.lua                                                             \
                Tool for widget test and development.                  | 
                Debug support with messages and variables              |
                show on the TX simulator screen, for Horus TX          |
                Full documentation on the github site                  |
                                                                       |
 Author:  BeGab                                                        |
 Date:    2024-08-28                                                   |
 Version: 0.8.1                                                        |
 URL : https://github.com/Be-Gab/dbgDemo                               |
                                                                       |
                      Copyright (C) "BeGab"                            |
 ______________________________________________________________________|
 License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html               |
                                                                       |
 This program is free software; you can redistribute it and/or modify  |
 it under the terms of the GNU General Public License version 2 as     |
 published by the Free Software Foundation.                            |
                                                                       |
 This program is distributed in the hope that it will be useful        |
 but WITHOUT ANY WARRANTY; without even the implied warranty of        |
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
 GNU General Public License for more details.                          |
\______________________________________________________________________/
]]
-- Filter in Debug Output Window : 
--				/(dbg:|dbg:^f_stat|filerw|error^f_stat|warning|^f_stat|-(E|W)-)/i

dbg = {}

dbg.dbgT = {}		-- DBG dataTable
dbg.dbgTKeys = {}	-- DBG dataTable -> Sorted Key
dbg.dbgP = {}		-- DBG Parameters


-- Default parameters, can modify with dbg.set() 
dbg.dbgP[ "DATE_FORMAT" ] = "hu"
dbg.dbgP[ "DBG_COLS" ]= 1
dbg.dbgP[ "DBG_LOG_SWITCH" ]	= "6pos"
dbg.dbgP[ "DBG_SEPARATOR_LINE" ] = true
dbg.dbgP[ "DBG_VAL_TYPE" ] = true
dbg.dbgP[ "DBG_WIDGET_ID" ] = ""
 
dbg.dbgP[ "DBG_CHAR_SIZE" ]	= SMLSIZE	-- 6px
dbg.dbgP[ "DBG_LINE_HEIGHT" ]= 16
dbg.dbgP[ "DBG_MSG_CHAR" ]	= 56

-- dbg.dbgP[ "DBG_CHAR_SIZE" ]	= 0 -- = Default, 8px
-- dbg.dbgP[ "DBG_LINE_HEIGHT" ]= 10
-- dbg.dbgP[ "DBG_MSG_CHAR" ]	= 20

-- dbg.dbgP[ "DBG_CHAR_SIZE" ]	= 12 -- = MIDSIZE 12px
-- dbg.dbgP[ "DBG_LINE_HEIGHT" ]= 14
-- dbg.dbgP[ "DBG_MSG_CHAR" ]	= 16

function dbg.getT()
	return dbg.dbgT
end 

function dbg.set( key , value )
	local oldValue = dbg.dbgP[ key ]
	
	dbg.dbgP[ key ] = value
	
	return oldValue
end
function dbg.get( key )
	return dbg.dbgP[ key ]
end

function dbg.now()
	local dt = getDateTime()
	local dateTime

	if dbg.get( "DATE_FORMAT" ) == "hu" then
		dateTime = string.format( "%04d.%02d.%02d. %02d:%02d:%02d" , dt.year, dt.mon, dt.day, dt.hour, dt.min , dt.sec )
		
	elseif dbg.get( "DATE_FORMAT" ) == "jp"	then
		dateTime = string.format( "%04d-%02d-%02d %02d:%02d:%02d" , dt.year, dt.mon, dt.day, dt.hour, dt.min , dt.sec )

	elseif dbg.get( "DATE_FORMAT" ) == "ca"	then
		dateTime = string.format( "%04d/%02d/%02d %02d:%02d:%02d" , dt.year, dt.mon, dt.day, dt.hour, dt.min , dt.sec )

	elseif dbg.get( "DATE_FORMAT" ) == "us"	then
		dateTime = string.format( "%02d-%02d-%04d %02d:%02d:%02d" , dt.mon, dt.day, dt.year, dt.hour, dt.min , dt.sec )

	elseif dbg.get( "DATE_FORMAT" ) == "uk"	then
		dateTime = string.format( "%02d.%02d.%04d. %02d:%02d:%02d" , dt.mon, dt.day, dt.year, dt.hour, dt.min , dt.sec )
		
	else	-- uk format ::
		dateTime = string.format( "%02d.%02d.%04d. %02d:%02d:%02d" , dt.mon, dt.day, dt.year, dt.hour, dt.min , dt.sec )
	end 
	
	return dateTime
end


function dbg.sortDbgT(tbl)

	-- Kulcsok gyűjtése
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	-- Kulcsok rendezése
	table.sort(keys)

	-- Rendezett asszociatív tábla létrehozása
	local sortedTable = {}
	for _, key in ipairs(keys) do

		if type( tbl[key] ) == "table" then
			tbl[key] = dbg.sortDbgT(tbl[key])
		end 

		sortedTable[key] = tbl[key]
	end

	return sortedTable
end

function dbg.sortDbgTK(tbl)

	-- Kulcsok gyűjtése
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	-- Kulcsok rendezése
	table.sort(keys)

	-- Rendezett asszociatív tábla létrehozása
	local sortedTable = {}
	for _, key in ipairs(keys) do

		if type( tbl[key] ) == "table" then
			tbl[key] = dbg.sortDbgTK(tbl[key])
		end 

		sortedTable[ #sortedTable + 1 ] = key
	end

	return sortedTable
end

function dbg.log( s, v )
	local b
	
	v = v or "nil"
	-- TODO: dbg.dbgP[ "DBG_WIDGET_ID" ] = ""

   print( dbg.now() .. " dbg:"  ,  s , v )
	
end

local gfi = getFieldInfo(dbg.get( "DBG_LOG_SWITCH" ))
local dbgSwitchID = gfi.id
function dbg.logDbg( s, v  )	
	if getValue( dbgSwitchID ) > 0 then
		dbg.log( "[o] " .. s , v )
	end	
end

function dbg.printAssoc( msg , tbl )

	dbg.log(  " ====================>> " , msg )
	
	for key, value in pairs( tbl) do
		if type( value ) == "table" then
			dbg.printAssoc( key , value)
		else
		 dbg.log(  key .. "=>" , value )
		end 
	end	

	dbg.log( " ====================<< "  , msg )

end
function dbg.assocConcat( tbl )
	local ret = "|"
	
	for key, value in pairs( tbl) do
		 ret = ret .. key .. "=" .. value .. "|"
	end	
	
	return ret
end
function dbg.add( key, value )

	if type( value ) == "boolean" then
		if value then
			value = "true"
		else
			value = "false"
		end
	end

	value = value or "nil"
	dbg.dbgT[key] = value
	
	-- Sub table sort
	-- if type( value ) == "table" then
		-- value = dbg.sortDbgTK(value)
	-- end

	-- local keys = {}
	-- for key in pairs(tbl) do
		-- table.insert(keys, key)
	-- end
	
	dbg.dbgTKeys = dbg.sortDbgTK( dbg.dbgT )
	
end
function dbg.del( key )
	dbg.dbgT[key] = nil
end
function dbg.clear( key )
	dbg.dbgT = {}
end

function dbg.drawDbG( pozY, lnShift, colWidth, curCol, msg, value )
	local dbgCols = dbg.get( "DBG_COLS") 
	local msgChar = dbg.get( "DBG_MSG_CHAR" ) 

	local pozLeft = colWidth * ( curCol - 1 )
	local pozRight= pozLeft + colWidth - 2
	
	msgChar = msgChar / dbgCols
	
	if string.len( msg ) > msgChar then
		local l = math.floor( ( msgChar -2 ) / 2 )
		
		msg = string.sub( msg, 1 , l ) .. ".." ..
				string.sub( msg, -l )
	end
	
	if dbg.get( "DBG_VAL_TYPE" ) then
		if type( value ) == "table" then
			value = ":t"
		elseif value == "true" then
			value = value .. ":b"
		elseif value == "false" then
			value = value .. ":b"
		elseif value == "nil" then
			value = value .. ":-"
		else	
			value = value .. ":" .. string.sub( type( value ) , 1,1 )
		end
	end
	
	lcd.drawText(	pozLeft + lnShift, pozY, msg	, dbg.get( "DBG_CHAR_SIZE" ) + LEFT )
	
	lcd.drawText(	pozRight			  , pozY, value, dbg.get( "DBG_CHAR_SIZE" ) + RIGHT )
	
	return pozY + dbg.get( "DBG_LINE_HEIGHT" )
end
function dbg.showDebug( widget )
	local fullWidth = widget.zone.w 
	local lineTop	= 0
	local lnShift	= 0
	local tblDbg	= dbg.dbgT
	local tblDbgK	= dbg.dbgTKeys
	local curCol	= 1
	local colWidth = widget.zone.w / dbg.get( "DBG_COLS" )

	-- oszlop elválasztók
	for i = 2, dbg.get( "DBG_COLS" ) do
		local pozLine = ( fullWidth / dbg.get( "DBG_COLS" ) ) * ( i - 1 )
		lcd.drawLine( pozLine, 0 , pozLine, widget.zone.h, SOLID )
	end

	-- ##############
	local function procItem( lineTop , curCol, colWidth, tblDbg, lnShift )
		local colPoz = colWidth * curCol
		
		for key, v in pairs( tblDbgK ) do
		-- for _ , key in pairs( tblDbgTKeys ) do
			-- value = tblDbg[ key ]
			
			key = v
			value = tblDbg[ key ]  
			
			if type( value ) == "table" then
						--  dbg.drawDbG( pozY, lnShift, colWidth, curCol, msg, value )
				lineTop = dbg.drawDbG( lineTop, lnShift, colWidth, curCol, key .. " =>" , {} )
				
				lineTop, curCol = procItem( lineTop , curCol, colWidth, value, lnShift + 10 )
				
			else
			
				-- Start a new col
				if ( dbg.get( "DBG_COLS" ) > curCol ) and 
					( lineTop >  ( widget.zone.h - dbg.get( "DBG_LINE_HEIGHT" ) )) then
					
					curCol = curCol + 1
					colPoz = colWidth * curCol
					lineTop = 0
					
				end

				lineTop = dbg.drawDbG( lineTop, lnShift, colWidth, curCol, key , value )
				
				if dbg.get( "DBG_SEPARATOR_LINE" ) then
				
					local pozLeft = ( colWidth * ( curCol - 1 ) ) + lnShift
				
					lcd.drawLine( pozLeft, lineTop , colPoz, lineTop, DOTTED )
					lineTop = lineTop + 1	
				end
				
			end 
			
		end	

		return lineTop, curCol
	end	-- procItem

	procItem( lineTop , curCol, colWidth, tblDbg, lnShift )

end


return dbg