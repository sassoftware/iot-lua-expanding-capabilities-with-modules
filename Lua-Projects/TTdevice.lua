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
-- Module Device
------------------
local M = {}  -- define a new table
local M_mt = { __index = M }
M.class = "device"
M.LAGdepth = 5
M.deviceID = ""
M.sensordata = {}
M.metadata = {}

-- Create new instance of this class and return new object
function M:new( )
    local self = {}
    setmetatable( self, M_mt )  --  New object inherits from M 
    return self
end
--  delete this object 
function M:destroy()
	self = nil
    return
end
function M:addmetadata(k,v)
    -- update self.metadata with incoming values by key 
    return
end
function M:addsensordata(k,v)
    -- update self.sensordata with incoming values by key 
    -- maintain self.LAGdepth 
    return
end
function M:setLAGdepth(v)
        -- maintain self.LAGdepth 
        self.LAGdepth = v
    return
end
function M:runSummaryStats()
        -- Loop through sensor data and perform summary stats 
        
    return
end
function M:runDataIntegrity()
        -- Check for data integrity on incoming sensor data
        
    return
end
return M  -- table index returned