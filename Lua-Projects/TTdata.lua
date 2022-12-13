--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2022
 Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

    This module saves and restores Lua tables as Json to disk.  
    Useful for maintaining state or settings between calls.

--  This project is currently stopped because ESP does not contain a encodeJson function.  
    So a lua table can not be encoded before written to disk. 

--]]
----------------------------------------------------------------------------------------------------
------------------
-- Constants
------------------

------------------
-- Modules
------------------
local M = {}
local M_mt = { __index = M }

--local json = require( "json" )  -- need to change this to the ESP version 
-- local lfs = require( "lfs" )    --  delete references to these
--  local crypto = require( "crypto" )

--------------------------
--  Local Functions
--------------------------


-------- Functions used for converting tables to strings which is used for data integrity. Functions sourced from here - http://lua-users.org/wiki/TableUtils
function table.val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
			return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and table.tostring( v ) or tostring( v )
	end
end

function table.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
end

function table.tostring( tbl )
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, table.val_to_str( v ) )
		done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] then
	  		table.insert( result,
			table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
		end
	end
	return "{" .. table.concat( result, "," ) .. "}"
end

local toString = function( value )
	if type( value ) == "table" then
		return table.tostring( value )
	else
		return tostring( value )
	end
end
-----------------------------------------------

--- Initiates a new M object.
-- @param id The name of the M to create or load ( if it already exists ).
-- @param path The path to the M. Optional, defaults to "boxes".
-- @param baseDir The base directory for the M. Optional, defaults to system.DocumentsDirectory.
-- @return The new object.
function M:new( id, path, baseDir )

    local self = {}

    setmetatable( self, M_mt )

    self.id = id
    self.path = path or "boxes"
    self.baseDir = baseDir

    if self.id then
    	self:load()
    end

    return self

end

--- Loads, or reloads, this M object from disk.
-- @param id The id of the M object.
-- @param path The path to the M. Optional, defaults to "boxes".
-- @param baseDir The base directory for the M. Optional, defaults to system.DocumentsDirectory.
function M:load( id, path, baseDir )

	-- Set up the path
	local path2 = path or "/export/sas-viya/data/Common"

	-- Pre-declare the new M object
	local box

	-- If no id was passed in then assume we're working with a pre-loaded M object so use its id
	if not id then
		id = self.id
		box = self
	end

	local path =  path2 .. "/" .. id .. ".box"

	local file = io.open( path, "r" )

	if not file then
		return
	end

    local data = {}   -- create table 
	data = parseJson( file:read( "*a" ) )  -- parse data into table 
	io.close( file )

	-- If no M exists then we are acting on a Class function i.e. not a pre-loaded M object.
	if not box then
		-- Create the new M object.
		box = M:new()
	end

	-- Copy all the properties across.
	for k, v in pairs( data ) do
		box[ k ] = v
	end

	return box

end

--- Saves this M object to disk.
function M:save()

	local data = {}

	-- Copy across all the properties that can be saved.
	for k, v in pairs( self ) do
		if type( v ) ~= "function" and type( v ) ~= "userdata" then
			data[ k ] = v
		end
	end

	-- Check for and create if necessary the boxes directory.
	-- local path = system.pathForFile( "", system.DocumentsDirectory )
	--local success = lfs.chdir( path )

	if success then
		-- lfs.mkdir( self.path )
		path = self.path
	else
		path = ""
	end

	-- data = json.encode( data )

	-- path = system.pathForFile( self.path .. "/" .. self.id .. ".box", system.DocumentsDirectory )
	local file = io.open( path, "w" )

	if not file then
		return
	end

	file:write( data )

	io.close( file )
	file = nil

end

--- Sets a value in this M object.
-- @param name The name of the value to set.
-- @param value The value to set.
function M:set( name, value )
	self[ name ] = value
end

--- Gets a value from this M object.
-- @param name The name of the value to get.
-- @return The value.
function M:get( name )
	return self[ name ] or self[ tostring( name) ]
end

--- Checks whether a value of this M object is higher than another value.
-- @param name The name of the first value to check.
-- @param otherValue The name of the other value to check. Can also be a number.
-- @return True if the first value is higher, false otherwise.
function M:isValueHigher( name, otherValue )
	if type( otherValue ) == "string" then
		otherValue = self:get( otherValue )
	end
	return self[ name ] > otherValue
end

--- Checks whether a value of this M object is lower than another value.
-- @param name The name of the first value to check.
-- @param otherValue The name of the other value to check. Can also be a number.
-- @return True if the first value is lower, false otherwise.
function M:isValueLower( name, otherValue )
	if type( otherValue ) == "string" then
		otherValue = self:get( otherValue )
	end
	return self[ name ] < otherValue
end

--- Checks whether a value of this M object is equal to another value.
-- @param name The name of the first value to check.
-- @param otherValue The name of the other value to check. Can also be a number.
-- @return True if the first value is equal, false otherwise.
function M:isValueEqual( name, otherValue )
	if type( otherValue ) == "string" then
		otherValue = self:get( otherValue )
	end
	return self[ name ] == otherValue
end

--- Checks whether this M object has a specific property or not.
-- @param name The name of the value to check.
-- @return True if the value exists and isn't nil, false otherwise.
function M:hasValue( name )
	return self[ name ] ~= nil and true or false
end

--- Sets a value on this M object if it is new.
-- @param name The name of the value to set.
-- @param value The value to set.
function M:setIfNew( name, value )
	if self[ name ] == nil then
		self[ name ] = value
	end
end

--- Sets a value on this M object if it is higher than the current value.
-- @param name The name of the value to set.
-- @param value The value to set.
function M:setIfHigher( name, value )
	if self[ name ] and value > self[ name ] or not self[ name ] then
		self[ name ] = value
	end
end

--- Sets a value on this M object if it is lower than the current value.
-- @param name The name of the value to set.
-- @param value The value to set.
function M:setIfLower( name, value )
	if self[ name ] and value < self[ name ] or not self[ name ] then
		self[ name ] = value
	end
end

--- Increments a value in this M object.
-- @param name The name of the value to increment. Must be a number. If it doesn't exist it will be set to 0 and then incremented.
-- @param amount The amount to increment. Optional, defaults to 1.
function M:increment( name, amount )
	if not self[ name ] then
		self:set( name, 0 )
	end
	if self[ name ] and type( self[ name ] ) == "number" then
		self[ name ] = self[ name ] + ( amount or 1 )
	end
end

--- Decrements a value in this M object.
-- @param name The name of the value to decrement. Must be a number. If it doesn't exist it will be set to 0 and then decremented.
-- @param amount The amount to decrement. Optional, defaults to 1.
function M:decrement( name, amount )
	if not self[ name ] then
		self:set( name, 0 )
	end
	if self[ name ] and type( self[ name ] ) == "number" then
		self[ name ] = self[ name ] - ( amount or 1 )
	end
end

--- Clears this M object.
function M:clear()
	for k, v in pairs( self ) do
		if k ~= "integrityControlEnabled"
			and k ~= "integrityAlgorithm"
			and k ~= "integrityKey"
			and k ~= "id"
			and k ~= "path"
			and type( k ) ~= "function" then
				self[ k ] = nil
		end
	end
end

--- Deletes this M object from disk.
-- @param id The id of the M to delete. Optional, only required if calling on a non-loaded object.
function M:delete( id )

	-- If no id was passed in then assume we're working with a pre-loaded M object so use its id
	if not id then
		id = self.id
	end

	local path = system.pathForFile( self.path, system.DocumentsDirectory )

	-- local success = lfs.chdir( path )

	os.remove( path .. "/" .. id .. ".box" )

	if not success then
		return
	end

end

--  This might be able to be changed to sync data with cloud providers 
--- Enables or disables the Syncing of this box.
-- @param enabled True if Sync should be enabled, false otherwise.
function M:setSync( enabled, id )

	-- If no id was passed in then assume we're working with a pre-loaded M object so use its id
	if not id then
		id = self.id
	end

	-- native.setSync( self.path .. "/" .. id .. ".box", { iCloudBackup = enabled } )

end

--- Checks if Syncing for this box is enabled or not.
-- @param enabled True if Sync is enabled, false otherwise.
function M:getSync( id )

	-- If no id was passed in then assume we're working with a pre-loaded M object so use its id
	if not id then
		id = self.id
	end

	-- return native.getSync( self.path .. "/" .. id .. ".box", { key = "iCloudBackup" } )

end


--- Destroys this M object.
function M:destroy()
	self:clear()
	self = nil
end


return M
