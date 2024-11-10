local app_name = "Dbg"
--[[
 ______________________________________________________________________
/   main.lua                                                           \
                DEMO of Tool for widget test and development.          |
                Debug support with messages and variables              |
                show on the TX simulator screen, for Horus TX          |
                                                                       |
 Author:  BeGab                                                        |
 Date:    2024-08-28                                                   |
 Version: 0.9.0                                                        |
 URL : https://github.com/Be-Gab/Dbg                                   |
                                                                       |
                      Copyright (C) "BeGab"                            |
                                                                       |
_______________________________________________________________________|
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

local options =	{ 
		{ "COLS"			, VALUE,  1, 1,  4 } ,
		{ "LineChars"	, VALUE, 40, 1, 60 }							
						}

dbg = nil

local function loadDbg()

	if dbg ~= nil then
		return dbg
	end 

  local chunk, errMsg = loadScript( "/WIDGETS/" .. app_name .. "/dbg.lua" )
  
  if errMsg then
    print(  "loadDbg:: " .. errMsg )  else
    dbg = chunk()
  end
  
end

local function create(zone, options)
	-- Runs one time when the widget instance is registered
	-- Store zone and options in the widget table for later use

	loadDbg()
	
	local widget = {
		zone = zone,
		options = options
	}
	
	-- Return widget table to EdgeTX
	return widget
end

local function update(widget, options)
	-- Runs if options are changed from the Widget Settings menu
	widget.options = options
	
end

local function background(widget)
	-- Runs periodically only when widget instance is not visible
	
end

local function refresh(widget, event, touchState)
	-- Runs periodically only when widget instance is visible
	-- If full screen, then event is 0 or event value, otherwise nil

	dbg.set( "DBG_COLS"		, widget.options.COLS )
	dbg.set( "DBG_MSG_CHAR"	, widget.options.LineChars )

	dbg.showDebug(widget)

end


return {
  name = app_name,
  create = create,
  refresh = refresh,
  background = background,
  options = options,
  update = update
}