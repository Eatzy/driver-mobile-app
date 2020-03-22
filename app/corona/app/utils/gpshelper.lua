local M = {};

local TORAD = math.pi / 180.0;

local initialized;

local timers = {};
local values = {};

M.handleGPSClock = function (event)
  local params = event.source.params;
  if params ~= nil and params.feed ~= nil and params.clock ~= nil and M.gps_speed ~= nil then
    local feed = params.feed;
    local period = params.clock;
    local newSpeed = math.max(0, (M.gps_speed + values[feed][1] + values[feed][2])/3);

    values[feed][2] = values[feed][1];
    if newSpeed > parameters.SENSORS.IGNORE_SPEED_BELOW then
      values[feed][1] = newSpeed;
    else
      -- logger.log("Speed "..tostring(newSpeed).." ignored");
      values[feed][1] = 0;
    end
    M[feed].speed = values[feed][1];
    
    local newAcceleration = (values[feed][1] - values[feed][2])/period;
    if math.abs(newAcceleration) > parameters.SENSORS.IGNORE_ACCELERATION_BELOW then
      M[feed].acceleration = math.min(newAcceleration,parameters.SENSORS.IGNORE_ACCELERATION_ABOVE);
    else
      -- logger.log("Acceleration "..tostring(newAcceleration).." ignored");
      M[feed].acceleration = 0;
    end
    
    if values[feed][1] > parameters.SENSORS.IGNORE_SPEED_ABOVE then
      values[feed][1] = parameters.SENSORS.IGNORE_SPEED_ABOVE;
      M[feed].speed = values[feed][1];
      M[feed].acceleration = 0;
    end
    
  end
end

M.calculateDistance = function (lat1, lon1, lat2, lon2)
    -- Convert degrees to radians
    lat1 = lat1 * TORAD;
    lon1 = lon1 * TORAD;
 
    lat2 = lat2 * TORAD;
    lon2 = lon2 * TORAD;
 
    -- radius of earth in meters
    local r = 6378100;
 
    -- P
    local rho1 = r * math.cos(lat1);
    local z1 = r * math.sin(lat1);
    local x1 = rho1 * math.cos(lon1);
    local y1 = rho1 * math.sin(lon1);
 
    -- Q
    local rho2 = r * math.cos(lat2);
    local z2 = r * math.sin(lat2);
    local x2 = rho2 * math.cos(lon2);
    local y2 = rho2 * math.sin(lon2);
 
    -- Dot product
    local dot = (x1 * x2 + y1 * y2 + z1 * z2);
    local cos_theta = dot / (r * r);
 
    local theta = math.acos(cos_theta);
 
    -- Distance in meters
    local distance = r * theta;
    if tonumber(distance) == nil then
      distance = 0;
    end
    
    return distance;
end

M.gpsHandler = function (event)
  if event ~= nil and event.errorCode == nil then
    
    if event.speed ~= nil and event.speed > 0 then
      M.gps_speed = event.speed;
    else
      if (M.gps_latitude ~= nil and M.gps_latitude > 0 and M.gps_longitude ~= nil and M.gps_longitude > 0 and M.gps_time ~= nil and M.gps_time > 0) and (event.latitude ~= nil and event.latitude > 0 and event.longitude ~= nil and event.longitude > 0 and event.time ~= nil and event.time > 0) then
        -- logger.log("calculating speed from lat/long delta");
        local distance = math.abs(M.calculateDistance(M.gps_latitude,M.gps_longitude,event.latitude,event.longitude));
        -- logger.log("distance is "..tostring(distance));
        local delay = event.time - M.gps_time;
        -- logger.log("delay is "..tostring(delay));
        if delay > 0 then
          M.gps_speed = distance/delay;
        else
          M.gps_speed = 0;
        end
        -- logger.log("speed is "..tostring(M.gps_speed));
      else
        M.gps_speed = 0;
      end
    end
    
    M.gps_latitude = event.latitude;
    M.gps_longitude = event.longitude;
    M.gps_altitude = event.altitude;
    M.gps_accuracy = event.accuracy;
    M.gps_direction = event.direction;
    M.gps_time = event.time;
    
    logger.log("sensor update: latitude="..tostring(M.gps_latitude).." longitude="..tostring(M.gps_longitude).." speed="..tostring(M.gps_speed));
  end
end

M.init = function ()
	if initialized ~= true then
		for k,v in pairs(timers) do
		  timer.cancel(timers[k]);
		  timers[k] = nil;
		end

		timers['instant'] = timer.performWithDelay( parameters.SENSORS.INSTANT_PERIOD, M.handleGPSClock, -1 );
		timers['instant'].params = { feed = "instant", clock = parameters.SENSORS.INSTANT_PERIOD };
		values['instant'] = {}; values['instant'][1] = 0; values['instant'][2] = 0;
		M['instant'] = {}; M['instant'].acceleration = 0; M['instant'].speed = 0;

		timers['short'] = timer.performWithDelay( parameters.SENSORS.SHORT_PERIOD, M.handleGPSClock, -1 );
		timers['short'].params = { feed = "short", clock = parameters.SENSORS.SHORT_PERIOD };
		values['short'] = {}; values['short'][1] = 0; values['short'][2] = 0;
		M['short'] = {}; M['short'].acceleration = 0; M['short'].speed = 0;

		timers['normal'] = timer.performWithDelay( parameters.SENSORS.NORMAL_PERIOD, M.handleGPSClock, -1 );
		timers['normal'].params = { feed = "normal", clock = parameters.SENSORS.NORMAL_PERIOD };
		values['normal'] = {}; values['normal'][1] = 0; values['normal'][2] = 0;
		M['normal'] = {}; M['normal'].acceleration = 0; M['normal'].speed = 0;

		timers['long'] = timer.performWithDelay( parameters.SENSORS.LONG_PERIOD, M.handleGPSClock, -1 );
		timers['long'].params = { feed = "long", clock = parameters.SENSORS.LONG_PERIOD };
		values['long'] = {}; values['long'][1] = 0; values['long'][2] = 0;
		M['long'] = {}; M['long'].acceleration = 0; M['long'].speed = 0;
	
		-- Register device
		if device.platform == "ios" then
			logger.log("Enabling GPS tracking on iOS");
		elseif device.platform == "android" then
			logger.log("Enabling GPS tracking on Android");
		elseif device.platform == "simulator" then
			logger.log("GPS is not available on the simulator");
		end
		
		Runtime:addEventListener( "location", M.gpsHandler )
	
		initialized = true;
	end
end

M.destroy = function ()
	if initialized == true then
		Runtime:removeEventListener( "location", M.gpsHandler );
		
		for k,v in pairs(timers) do
		  timer.cancel(timers[k]);
		  timers[k] = nil;
		end
		
		initialized = false;
	end
end

return M;