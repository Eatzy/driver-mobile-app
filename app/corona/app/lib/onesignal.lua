local M = {};

local json = require "json";

local initialized;
local externalCallback;
local registrationEnabled;
local registrationTimer;
local currentToken;
local registrationSuccessful;
local lastCall;
local playerId;
local lastOnFocus;

M.enableRegistration = function (flag)
	registrationEnabled = flag;
end

M.isRegistered = function ()
	if registrationSuccessful ~= nil and registrationSuccessful == true then
		return true;
	else
		return false;
	end
end

M.notificationListener = function ( event )
    if ( event.type == "remote" or event.type == "local" ) then
        logger.log("OneSignal.com Remote notification event: "..json.encode(event));
    elseif ( event.type == "remoteRegistration" ) then
        local deviceToken = event.token;
		
		M.registerDevice(deviceToken);
	else
		logger.log("OneSignal.com Unknown notification event: "..json.encode(event));
    end
end

M.networkListener = function ( event )
    local response = event.response;
    	
    if ( event.isError ) then
    	logger.log( "OneSignal.com Network error: ", tostring(json.encode(response)) );
    else
        logger.log( "OneSignal.com RESPONSE: " .. tostring(json.encode(response)) );
        
        if lastCall ~= nil then
        	if lastCall == "register" then
				local responseData = json.decode(event.response);
        		if responseData ~= nil then
        			local success = responseData["success"];
        			if success == "true" then
						success = true;
					elseif success == "false" then
						success = false;
					end
        			local osPlayerId = responseData["id"];
        			if success == true then
        				if osPlayerId ~= nil then
        					playerId = osPlayerId;
        					
        					local appConfiguration = storage.getConfiguration();
        					if appConfiguration ~= nil then
								appConfiguration["onesignal_player_id"] = playerId;
								storage.saveConfiguration(appConfiguration);
							end
        				end
        				registrationSuccessful = true;
        				logger.log("OneSignal.com registration successful with playerId="..tostring(playerId));
        			else
        				logger.log("OneSignal.com response not successful: "..tostring(success));
        			end
        		else
        			logger.log("OneSignal.com responseData is nil");
        		end
        	elseif lastCall == "updatesession" then
        		local responseData = json.decode(event.response);
        		if responseData ~= nil then
        			local success = responseData["success"];
        			if success == "true" then
						success = true;
					elseif success == "false" then
						success = false;
					end
        			if success == true then
        				lastOnFocus = system.getTimer();
        			end
        		end
        	else
        		logger.log("OneSignal.com RESPONSE TODO handle lastCall: "..tostring(lastCall));
        	end
        else
        	logger.log( "OneSignal.com RESPONSE: lastCall is nil");
        end
    end
end

M.setLogLevel = function (logLevel)
	-- TODO
end

local function onSystemEvent( event )
    local eventType = event.type
    local updateSessionTime = false;
    
    if ( eventType == "applicationStart" ) then
        -- Occurs when the application is launched and all code in "main.lua" is executed
    elseif ( eventType == "applicationExit" ) then
        -- Occurs when the user or OS task manager quits the application
    elseif ( eventType == "applicationSuspend" ) then
        -- Perform all necessary actions for when the device suspends the application, i.e. during a phone call
        updateSessionTime = true;
    elseif ( eventType == "applicationResume" ) then
        -- Perform all necessary actions for when the app resumes from a suspended state
        updateSessionTime = true;
    elseif ( eventType == "applicationOpen" ) then
        -- Occurs when the application is asked to open a URL resource (Android and iOS only)
    end
    
    if updateSessionTime == true then
    	if registrationSuccessful == true then
    		if playerId ~= nil then
    			M.updateSessionTime();
    		end
    	end
    end
end

M.init = function (appId, googlePlayProjectNumber, extCB)
	if initialized ~= true then
		M.appId = appId;
		M.googlePlayProjectNumber = googlePlayProjectNumber;
		externalCallback = extCB;
		
		-- Runtime:addEventListener( "notification", M.notificationListener );
		
		local appConfiguration = storage.getConfiguration();
		if appConfiguration ~= nil then
			local oneSignalPlayerId = appConfiguration["onesignal_player_id"];
			if oneSignalPlayerId ~= nil then
				playerId = oneSignalPlayerId;
			end
			
			if device.platform == "android" then
				local lastPushToken = appConfiguration["push_token"];
				if lastPushToken ~= nil then
					M.registerDevice(lastPushToken);
				end
			end
		end
		
		logger.log( "OneSignal.com plugin initialized!");
		lastOnFocus = system.getTimer();
		Runtime:addEventListener( "system", onSystemEvent );
		initialized = true;
	end
end

local function registerNow()
	if currentToken == nil then
		logger.log("OneSignal.com INVALID REGISTRATION TOKEN");
		return;
	end

	--[[
	0 = iOS, 1 = Android, 2 = Amazon, 3 = WindowsPhone(MPNS), 4 = ChromeApp, 5 = ChromeWebsite, 6 = WindowsPhone(WNS), 7 = Safari, 8 = Firefox, 9 = Mac OS X
	--]]
	local deviceType = -1;
	if device.platform == "ios" then
		deviceType = 0;
	elseif device.platform == "android" then
		deviceType = 1;
	elseif device.platform == "windows" then
		deviceType = 3;
	elseif device.platform == "macos" then
		deviceType = 9;
	end
	logger.log("OneSignal.com Device Type is "..deviceType);

	
	local utcDate = os.date( "!*t" );
	local utcTime = tonumber(os.time(utcDate));
	local nowDate = os.date( "*t" );
	local nowTime = tonumber(os.time(nowDate));
	local deltaSeconds = (nowTime - utcTime);

	logger.log("OneSignal.com deltaSeconds is "..deltaSeconds);

	if (deviceType >= 0)  then
		-- TODO add data for segments
		local tags = {};
	
		local appSetup = storage.getConfiguration();
		if appSetup ~= nil and appSetup["driver"] ~= nil then
			local appDriver = appSetup["driver"];
			if appDriver["business"] ~= nil then
				local appDriverBusiness = appDriver["business"];
			
				if appDriverBusiness["id"] ~= nil then
					local bizId = tonumber(appDriverBusiness["id"]);
					if bizId ~= nil and bizId > 0 then
						tags["business"] = ""..tostring(bizId);
					end
				end
				if appDriverBusiness["zone_territory"] ~= nil then
					local territoryId = tonumber(appDriverBusiness["zone_territory"]);
					if territoryId ~= nil and territoryId > 0 then
						tags["territory"] = ""..tostring(territoryId);
					end
				end
			end
			if appDriver["id"] ~= nil then
				local driverId = tonumber(appDriver["id"]);
				if driverId ~= nil and driverId > 0 then
					tags["driver"] = ""..tostring(driverId);
				end
			end
		end

		local url = "https://onesignal.com/api/v1/players";
		if playerId ~= nil then
			url = "https://onesignal.com/api/v1/players/"..tostring(playerId).."/on_session";
		end
		
		local data = {};
		
		data["identifier"] = currentToken;
		data["language"] = device.language;
		data["timezone"] = deltaSeconds;
		data["game_version"] = parameters.GENERAL.VERSION;
		data["device_os"] = tostring(system.getInfo("platformVersion"));
		data["tags"] = tags;
		
		if playerId == nil then
			data["app_id"] = parameters.ONESIGNAL_APP_ID;
			data["device_type"] = deviceType;
			data["device_model"] = tostring(system.getInfo("architectureInfo"));
			data["device_type"] = deviceType;
			if parameters.GENERAL.DEV == true then
				data["test_type"] = 1;
			elseif parameters.GENERAL.ADHOC == true then
				data["test_type"] = 2;
			else
				data["test_type"] = 0;
			end
			if gpshelper.gps_latitude ~= nil and gpshelper.gps_longitude ~= nil then
				data["long"] = gpshelper.gps_longitude;
				data["lat"] = gpshelper.gps_latitude;
			end
		end

		local bodyEncoded = json.encode( data );

		local headers = {}
		headers["Content-Type"] = "application/json"
		headers["Accept-Language"] = "en-US"

		local params = {}
		params.headers = headers;
		params.body = bodyEncoded;

		logger.log("OneSignal.com requesting "..url);
		lastCall = "register";
		network.request ( url, "POST", M.networkListener, params );
	end
end

M.registerDevice = function (token)
	if token ~= nil then
		currentToken = token;
	end
	
	if registrationTimer == nil then
		local function onRegistrationTimer(event)
			if registrationEnabled == true then
				logger.log("Registration on OneSignal.com...");
				
				if registrationTimer ~= nil then
					timer.cancel(registrationTimer);
					registrationTimer = nil;
				end
				
				registerNow();
			else
				logger.log("Waiting for registration enabled on OneSignal.com ...");
			end
		end
		
		registrationTimer = timer.performWithDelay( 1000, onRegistrationTimer, -1 );
	end
end

M.updateSessionTime = function ()
	local now = system.getTimer();
	local delay = math.round((now - lastOnFocus)/1000);
	
	local url = "https://onesignal.com/api/v1/players/"..tostring(playerId).."/on_focus";
	
	local data = {};
	data["state"] = "ping";
	data["active_time"] = delay;
    
    local bodyEncoded = json.encode( data );

	local headers = {}
	headers["Content-Type"] = "application/json"
	headers["Accept-Language"] = "en-US"

	local params = {}
	params.headers = headers;
	params.body = bodyEncoded;

	logger.log("OneSignal.com requesting "..url);
	lastCall = "updatesession";
	network.request ( url, "POST", M.networkListener, params );
end

return M;