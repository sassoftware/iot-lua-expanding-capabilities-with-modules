--[[

 - Version: 0.1
 - Made by Tom Tuning @ 2022
 Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
 
 - Mail: tom.tuning@sas.com

******************
 - INFORMATION
******************

  
  
  
--]]
----------------------------------------------------------------------------------------------------

------------------
-- Module Animal 
------------------
local M = {}  -- define a new table
local M_mt = { __index = M }
M.class = "animal"
M.sound = "grrr"
-- Create new instance of this class and return new object
function M:new( )
	print ("misc functions")
    local self = {}
    setmetatable( self, M_mt )  --  New object inherits from M 
    return self
end
--  delete this object 
function M:destroy()
	self = nil
    return
end
return M  -- table index returned