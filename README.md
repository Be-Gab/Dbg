# Dbg
 Debug on screen like a widget in CP
See DbgDemo!
https://github.com/Be-Gab/DbgDemo

## Import to your code
### Use this code
```
dbg = nil

local function loadDbg(widget)

	if dbg ~= nil then
		return
	end 
	
	-- !!!!
  local chunk, errMsg = loadScript( "/WIDGETS/Dbg/dbg.lua" )
  
  if errMsg then
    widget.errMsg = errMsg
  else
    dbg = chunk()
  end
  
end
```

### Call in create() 

## Functions
