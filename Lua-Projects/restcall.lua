--Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
-- SPDX-License-Identifier: Apache-2.0
 
            local   url_fields = "FeatureServer/0/query?where=Type+in%28%27Stream+Gage%27%2C+%27Rain+Gage%27%29&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&distance=&units=esriSRUnit_Foot&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&having=&gdbVersion=&historicMoment=&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&multipatchOption=xyFootprint&resultOffset=&resultRecordCount=&returnTrueCurves=false&returnCentroid=false&sqlFormat=none&resultType=&f=pjson"
            local   url_base = "https://iot.connectedcary.org/server/rest/services/Hosted/vw_Site_Devices/"
            local   url_auth = "https://flashflood.info:8080/api/auth/login"
            
            local   connect_timeout = 3000
            local   data_timeout = 5000

            local   tokenTime = os.time()       -- Time of last token retrieval
            local   eventTime = os.time()       -- Time of last event generation
            local   tokenInterval = 60          -- Get new token every minute
            local   eventInterval =  5          -- Generate events every 30 seconds
            
            function getResults()
                local   url = url_base..url_fields
                local   request = {}
                local   headers = {}
                request["url"] = url
                headers["accept"] = "application/json"
                request["headers"] = headers
                request["method"] = "GET"
                request["connect-timeout"] = connect_timeout
                request["data-timeout"] = data_timeout
                request["tolua"] = true
                --print("***********  request  ***************" ,toString(request))

                local  response = sendHttp(request)
                
                --print("***********  response  ***************" , toString(response))

                return response
            end

            function create(context)
                local   events = nil
                local   current = os.time()

                    print(">>>>>>>*********Generating events***********<<<<<<<<<")
                    local   guid = getGuids()[1]
                    local   counter = 1

                    events = {}

                    local   data = getResults()
                    print("***********  response data ***************" , toString(data))
                    local features = 

                        for key,v2 in ipairs(data.response["features"])
                        do
                            local   e = {}
                            local   o = v2[key]
                            e.id = guid..":"..tostring(counter)
                            e.deviceid = o.siteid
                            e.measurement = key
                            e.zip = o.zip
                            
                            events[counter] = e
                            counter = counter + 1
                        end

                    eventTime = os.time()
                    print("Done generating "..tostring(counter).." events")

                return events
            end
            
            

            function getResultsByDevice(id)
                local   url = url_base..id..url_fields
                local   request = {}
                local   headers = {}
                request["url"] = url
                headers["Content-Type"] = "application/json"
                headers["X-Authorization"] = "Bearer "..token
                request["headers"] = headers
                request["connect-timeout"] = connect_timeout
                request["data-timeout"] = data_timeout
                request["tolua"] = true
                --print(toString(request))

                local   response = sendHttp(request)
                --print(toString(response))

                return response
            end

            
          