local M = {};

local json = require "json";
local crypto = require "crypto";
local openudid = require ("app.utils.openudid")

local initialized;
local gpsIsUpdating;
local gpsTimer;
local isClockedIn;
local pushRegToken;
local currentRuns;

local function getIntervalString(delta)
	if delta ~= nil and delta >= 0 then
		if delta <= 10 then
			return "10ms";
		elseif delta <= 50 then
			return "50ms";
		elseif delta <= 100 then
			return "100ms";
		elseif delta <= 200 then
			return "200ms";
		elseif delta <= 300 then
			return "300ms";
		elseif delta <= 500 then
			return "500ms";
		elseif delta <= 700 then
			return "700ms";
		elseif delta <= 1000 then
			return "1S";
		elseif delta <= 1500 then
			return "1.5S";
		elseif delta <= 2000 then
			return "2S";
		elseif delta <= 3000 then
			return "3S";
		elseif delta <= 5000 then
			return "5S";
		elseif delta <= 10000 then
			return "10S";
		elseif delta <= 15000 then
			return "15S";
		elseif delta <= 20000 then
			return "20S";
		elseif delta <= 30000 then
			return "30S";
		else
			return "OVER30S";
		end
	else
		return "unknown";
	end
end

local DEFAULT_DELAY_SAMPLES_BEFORE_SEND = 1;
local delayMeasureAmounts = {
	["getDriverRuns"] = 5,
	["getDriverMessages"] = 10,
	["getOrderDetails"] = 1,
	["clockDriver"] = 1,
	["getDriverStatus"] = 1,
	["updateDevicePosition"] = 10,
	["registerPush"] = 1,
	["driverLogin"] = 1,
	["driverLogout"] = 1,
	["changeOrderStatus"] = 1,
	["sendDriverMessages"] = 1,
	["checkApp"] = 1
}
local delayMeasureSamples = {};
local function sendDelayMeasureToAnalytics (eventName, delta)
	if eventName ~= nil and delta ~= nil then
		if delta > 0 then
			local minSamples = delayMeasureAmounts[eventName];
			if minSamples == nil then
				minSamples = DEFAULT_DELAY_SAMPLES_BEFORE_SEND;
			end
			
			local dmsGroup = delayMeasureSamples[eventName];
			if dmsGroup == nil then
				dmsGroup = {};
			end
			
			dmsGroup[#dmsGroup+1] = delta;
			if #dmsGroup >= minSamples then
				-- calculate average
				local total = 0;
				for i=1, #dmsGroup do
					total = total + dmsGroup[i];
				end
				local avg = (total / #dmsGroup);
				dmsGroup = nil;
				
				local evSuffix = getIntervalString(delta);
				local eventFullName = "APERF_"..string.upper(eventName).."_"..evSuffix;
				
				logger.log("API performance: "..tostring(eventFullName).."="..tostring(delta).." ms");
				analytics.logEvent(eventFullName);
			end
			
			delayMeasureSamples[eventName] = dmsGroup;
		end
	end
end

local function apiResponse(event, callback)
	local jsonResult = {};
	jsonResult["error"] = false;
	
	logger.log("Event status: "..tostring(event.status).." --> "..tostring(event.response));	
	
	-- Token expiration check
	if event.status == 401 then
		M.tokenExpired();
	elseif event.status == 403 then -- not authorized
		M.tokenExpired();
	end
			
	if ( event.isError ) then
		logger.log( "Network error: ", event.response );
		
		jsonResult["error"] = true;
		jsonResult["message"] = event.response;
	elseif (event.status ~= 200) then
		logger.log( "Network error: ", event.response );
		
		jsonResult["error"] = true;
		jsonResult["message"] = event.response;
	else
		local data = json.decode( event.response );
		if (data ~= nil) then
			jsonResult["data"] = data;
		else
			jsonResult["error"] = true;
			jsonResult["message"] = "no data";
		end
	end
		
	if (callback ~= nil) then
		callback(jsonResult);
	end
end

M.init = function ()
	if initialized ~= true then
		gpsIsUpdating = false;
		isClockedIn = false;
	
		logger.log( "Menunu plugin initialized!");
		initialized = true;
	end
end

M.stopUpdatingGPS = function ()
	if gpsIsUpdating == true then
		if gpsTimer ~= nil then
			timer.cancel(gpsTimer);
			gpsTimer = nil;
		end
		
		gpsIsUpdating = false;
	end
end

M.startUpdatingGPS = function ()
	if gpsIsUpdating ~= true then
		local function gpsListener( event )
			if isClockedIn == true then
				local function onUpdate(data)
					if data["error"] == true then
						logger.log("Can't update position: "..tostring(data["message"]));
						
						-- go to the clock in scene
						-- local composer = require( "composer" );
						-- composer.gotoScene("app.scenes.clock");
					else
						logger.log("Device position updated");
					end
				end
		
				local position = {};
				position["latitude"] = gpshelper.gps_latitude;
				position["longitude"] = gpshelper.gps_longitude;
				position["altitude"] = gpshelper.gps_altitude;
				position["accuracy"] = gpshelper.gps_accuracy;
				position["direction"] = gpshelper.gps_direction;
				position["time"] = gpshelper.gps_time;
				position["speed"] = gpshelper.gps_speed;
				
				if parameters.DRIVERS.FORCE_POSITION == true then
					position["latitude"] = parameters.DRIVERS.FORCED_POSITION.LATITUDE;
					position["longitude"] = parameters.DRIVERS.FORCED_POSITION.LONGITUDE;
					position["altitude"] = parameters.DRIVERS.FORCED_POSITION.ALTITUDE;
				end
			
				menunu.updateDevicePosition(position, onUpdate);
			end
		end
		
		local gpsPeriod = parameters.SERVER.GPS_SERVER_UPDATE_PERIOD;
		local appSetup = storage.getConfiguration();
		
		if appSetup["configuration"] ~= nil then
			local appConfig = appSetup["configuration"];
			if appConfig["gps_period"] ~= nil then
				gpsPeriod = tonumber(appConfig["gps_period"]);
			end
		end
		
		gpsPeriod = gpsPeriod * 1000;
		
		gpsTimer = timer.performWithDelay( gpsPeriod, gpsListener, -1 );
		
		gpsIsUpdating = true;
	end
end

M.getSeed = function ()
	local utcDate = os.date( "!*t" );
	local utcTime = tonumber(os.time(utcDate));
	local epochTime = tonumber(os.time{year=1970, month=1, day=1, hour=0});
	
	local salt = ""..(utcTime - epochTime);
	
	local partA = tonumber(string.sub( salt, 0, 4 )) + 1983;
	local partB = tonumber(string.sub( salt, 5, 7 ));
	local partC = tonumber(string.sub( salt, 4, 7 )) + 36;
	local partD = tonumber(string.sub( salt, 2, 3 ));
	
	local seed = partB .. partD .. partC .. partA;
	
	return seed;
end

M.encryptKey = function (seed)
	local seedB = tonumber(string.sub( seed, -4 ));
	local seedA = tonumber(string.sub( seed, 0, -5 ));
	
	local saltA = seedA;
	if (seedB > 6524) then
		saltA = seedA * 5 + 16664328;
	elseif (seedB > 1267) then
		saltA = seedA * 2 + 17723;
	else
		saltA = seedA * 7 + 172;
	end
	
	local saltB = seedB;
	if (seedA > 72346) then
		saltB = seedB * 3 + 18829;
	elseif (seedA > 55342) then
		saltB = seedB * 6 + 182;
	else
		saltB = seedB * 4 + 188237;
	end
	
	local salt = saltB .. 'menunu-InTernaL-AUTH' .. saltA;
	local encrypted = crypto.digest( crypto.sha1, salt );
	
	return encrypted;
end

M.newAuthKey = function ()
	local seed = M.getSeed();
	if (seed == nil) then
		seed = math.random(100000000, 999999999);
	end
	
	local encrypted = M.encryptKey(seed);
	local key = seed .. '-' .. encrypted;
	
	return key;
end

M.driverLogin = function (username, password, callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("driverLogin",delta);
			end
		end
	end
	
	local url = parameters.SERVER.API_URL_DRIVER_LOGIN;
	
	local data = {};
	data["username"] = username;
	data["password"] = crypto.digest( crypto.md5, password );
	data["device"] = openudid.getValue();
	
	local deviceData = {};
	deviceData["udid"] = openudid.getValue();
	deviceData["platform"] = device.platform;
	deviceData["model"] = device.model;
	
	data["device"] = deviceData;
	
	local bodyEncoded = json.encode( data );
	
	local headers = {}
	headers["Content-Type"] = "application/json";
	headers["Accept-Language"] = "en-US";
	headers["X-Mobile-Token"] = M.newAuthKey();
	headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

	local params = {}
	params.headers = headers;
	params.body = bodyEncoded;
	
	callAt = system.getTimer();
	logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
	network.request ( url, "POST", networkListener, params );
end

M.driverLogout = function (callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("driverLogout",delta);
			end
		end
	end
	
	local url = parameters.SERVER.API_URL_DRIVER_LOGOUT;
	
	local appConfiguration = storage.getConfiguration();
	local userToken = appConfiguration["token"];
	
	local authData = {};
	authData["token"] = userToken["value"];
	authData["user"] = appConfiguration["user_id"];
	authData["device"] = openudid.getValue();
	
	local data = {};
	data["auth"] = authData;
	
	local bodyEncoded = json.encode( data );
	
	local headers = {}
	headers["Content-Type"] = "application/json";
	headers["Accept-Language"] = "en-US";
	headers["X-Mobile-Token"] = M.newAuthKey();
	headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

	local params = {}
	params.headers = headers;
	params.body = bodyEncoded;
	
	callAt = system.getTimer();
	logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
	network.request ( url, "POST", networkListener, params );
end

M.tokenExpired = function ()
	local appConfiguration = storage.getConfiguration();
	appConfiguration["token"] = nil
	storage.saveConfiguration(appConfiguration);
	
	-- DO ADDITIONAL RESET FOR TOKEN EXPIRATION
	M.stopUpdatingGPS();
	
	local composer = require( "composer" );
	composer.gotoScene("app.scenes.login");
end

M.registerPush = function (registrationToken, callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("registerPush",delta);
			end
		end
	end

	local url = parameters.SERVER.API_URL_PUSH_REGISTRATION;
	
	local appConfiguration = storage.getConfiguration();
	local userToken = nil;
	
	local validRequest = true;
	if appConfiguration == nil then
		validRequest = false;
	else
		userToken = appConfiguration["token"];
		if userToken == nil then
			validRequest = false;
		end
	end
	
	if validRequest == true then
		local authData = {};
		authData["token"] = userToken["value"];
		authData["user"] = appConfiguration["user_id"];
		authData["device"] = openudid.getValue();
	
		local pushData = {};
		pushData["registration"] = registrationToken;
	
		local data = {};
		data["auth"] = authData;
		data["push"] = pushData;
	
		local bodyEncoded = json.encode( data );
	
		local headers = {}
		headers["Content-Type"] = "application/json";
		headers["Accept-Language"] = "en-US";
		headers["X-Mobile-Token"] = M.newAuthKey();
		headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

		local params = {}
		params.headers = headers;
		params.body = bodyEncoded;
		
		callAt = system.getTimer();
		logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
		network.request ( url, "POST", networkListener, params );
	else
		local jsonResult = {};
		jsonResult["error"] = true;
		jsonResult["message"] = "Still logged out";
		
		callback(jsonResult);
	end
end

M.isTokenExpired = function ()
	local expired = true;
	
	local appConfiguration = storage.getConfiguration();
	
	if appConfiguration["token"] ~= nil then
    	local userToken = appConfiguration["token"];
    	if userToken["value"] ~= nil and userToken["expires"] ~= nil then
    		local expiresTime = tonumber(userToken["expires"]);
    		
    		local utcDate = os.date( "!*t" );
			local utcTime = tonumber(os.time(utcDate));
			local epochTime = tonumber(os.time{year=1970, month=1, day=1, hour=0});
	
			local nowTime = (utcTime - epochTime);
			
			if nowTime < expiresTime then
				expired = false;
			end
			
			logger.log("token expiration is "..expiresTime.." now is "..nowTime);
    	end
    end
	
	return expired;
end

M.updateDevicePosition = function (position, callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("updateDevicePosition",delta);
			end
		end
	end
	
	local url = parameters.SERVER.API_URL_UPDATE_POSITION;
	
	local appConfiguration = storage.getConfiguration();
	local userToken = appConfiguration["token"];
	
	local authData = {};
	authData["token"] = userToken["value"];
	authData["user"] = appConfiguration["user_id"];
	authData["device"] = openudid.getValue();
	
	local positionData = position;
	
	local data = {};
	data["auth"] = authData;
	data["position"] = positionData;
	
	local bodyEncoded = json.encode( data );
	
	local headers = {}
	headers["Content-Type"] = "application/json";
	headers["Accept-Language"] = "en-US";
	headers["X-Mobile-Token"] = M.newAuthKey();
	headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

	local params = {}
	params.headers = headers;
	params.body = bodyEncoded;
	
	callAt = system.getTimer();
	logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
	network.request ( url, "PUT", networkListener, params );
end

M.getDriverStatus = function (callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("getDriverStatus",delta);
			end
		end
	end
	
	local appConfiguration = storage.getConfiguration();
	local userToken = appConfiguration["token"];
	
	local url = parameters.SERVER.API_URL_DRIVER_STATUS;
	url = url .. "?token=" .. userToken["value"] .. "&user=" .. appConfiguration["user_id"];
	
	local headers = {}
	headers["Content-Type"] = "application/json";
	headers["Accept-Language"] = "en-US";
	headers["X-Mobile-Token"] = M.newAuthKey();
	headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

	local params = {}
	params.headers = headers;
	params.body = nil;
	
	callAt = system.getTimer();
	logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
	network.request ( url, "GET", networkListener, params );
end

M.setDriverClockedIn = function (clockedIn)
	isClockedIn = clockedIn;
	
	if isClockedIn ~= true then
		M.stopUpdatingGPS();
	else
		M.startUpdatingGPS();
	end
end

M.clockDriver = function (mode, callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("clockDriver",delta);
			end
		end
	end
	
	local url = parameters.SERVER.API_URL_CLOCKING;
	
	local appConfiguration = storage.getConfiguration();
	local userToken = appConfiguration["token"];
	
	if userToken ~= nil then
		local authData = {};
		authData["token"] = userToken["value"];
		authData["user"] = appConfiguration["user_id"];
		authData["device"] = openudid.getValue();
	
		local data = {};
		data["auth"] = authData;
		data["mode"] = tonumber(mode);
	
		local bodyEncoded = json.encode( data );
	
		local headers = {}
		headers["Content-Type"] = "application/json";
		headers["Accept-Language"] = "en-US";
		headers["X-Mobile-Token"] = M.newAuthKey();
		headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

		local params = {}
		params.headers = headers;
		params.body = bodyEncoded;
		
		callAt = system.getTimer();
		logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
		network.request ( url, "POST", networkListener, params );
	else
		callback();
	end
end

M.getDriverRuns = function (callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("getDriverRuns",delta);
			end
		end
	end
	
	local appConfiguration = storage.getConfiguration();
	
	if appConfiguration["user_id"] ~= nil and appConfiguration["token"] ~= nil then
		local userToken = appConfiguration["token"];
		
		local url = parameters.SERVER.API_URL_DRIVER_RUNS;
		url = url .. "?token=" .. userToken["value"] .. "&user=" .. appConfiguration["user_id"];
	
		local headers = {}
		headers["Content-Type"] = "application/json";
		headers["Accept-Language"] = "en-US";
		headers["X-Mobile-Token"] = M.newAuthKey();
		headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

		local params = {}
		params.headers = headers;
		params.body = nil;
		
		callAt = system.getTimer();
		logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
		network.request ( url, "GET", networkListener, params );
	else
		callback();
	end
end

M.getOrderDetails = function (orderId, callback)
	local callAt = nil;
	
	local function networkListener( event )
		apiResponse(event, callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("getOrderDetails",delta);
			end
		end
	end
	
	local appConfiguration = storage.getConfiguration();
	
	if appConfiguration["user_id"] ~= nil and appConfiguration["token"] ~= nil then
		local userToken = appConfiguration["token"];
		local url = parameters.SERVER.API_URL_DRIVER_ORDER .. "/" .. orderId;
		url = url .. "?token=" .. userToken["value"] .. "&user=" .. appConfiguration["user_id"];
	
		local headers = {}
		headers["Content-Type"] = "application/json";
		headers["Accept-Language"] = "en-US";
		headers["X-Mobile-Token"] = M.newAuthKey();
		headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

		local params = {}
		params.headers = headers;
		params.body = nil;
		
		callAt = system.getTimer();
		logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
		network.request ( url, "GET", networkListener, params );
	else
		callback();
	end
end

M.changeOrderStatus = function (orderId, statusId, callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("changeOrderStatus",delta);
			end
		end
	end
	
	local appConfiguration = storage.getConfiguration();
	
	if appConfiguration["user_id"] ~= nil and appConfiguration["token"] ~= nil then
		local userToken = appConfiguration["token"];
		local url = parameters.SERVER.API_URL_DRIVER_ORDER .. "/" .. orderId;
		
		local authData = {};
		authData["token"] = userToken["value"];
		authData["user"] = appConfiguration["user_id"];
		authData["device"] = openudid.getValue();
	
		local messagesData = messages;
	
		local data = {};
		data["auth"] = authData;
		data["status"] = statusId;
	
		local bodyEncoded = json.encode( data );
	
		local headers = {}
		headers["Content-Type"] = "application/json";
		headers["Accept-Language"] = "en-US";
		headers["X-Mobile-Token"] = M.newAuthKey();
		headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

		local params = {}
		params.headers = headers;
		params.body = bodyEncoded;
		
		callAt = system.getTimer();
		logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
		network.request ( url, "POST", networkListener, params );
	else
		callback();
	end
end

M.getStatusName = function (statusCode)
	local statusName = "unknown";
	
	if statusCode ~= nil then
		local sCode = tonumber(statusCode);
		
		if sCode == 1 then statusName = "open";
		elseif sCode == 2 then statusName = "finalized-manual";
		elseif sCode == 3 then statusName = "finalized-auto";
		elseif sCode == 4 then statusName = "faxed";
		elseif sCode == 5 then statusName = "confirmed";
		elseif sCode == 6 then statusName = "cooking";
		elseif sCode == 7 then statusName = "checking";
		elseif sCode == 8 then statusName = "driving";
		elseif sCode == 9 then statusName = "dropping-off";
		elseif sCode == 10 then statusName = "completed";
		elseif sCode == 11 then statusName = "canceled";
		elseif sCode == 12 then statusName = "saved";
		elseif sCode == 13 then statusName = "autosaved";
		elseif sCode == 14 then statusName = "redelivery";
		end
	end
	
	return statusName;
end

M.getDriverMessages = function (callback)
	local callAt = nil;
	
	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("getDriverMessages",delta);
			end
		end
	end
	
	local appConfiguration = storage.getConfiguration();
	local userToken = appConfiguration["token"];
	
	local url = parameters.SERVER.API_URL_DRIVER_GET_MESSAGES;
	url = url .. "?token=" .. userToken["value"] .. "&user=" .. appConfiguration["user_id"];
	
	local headers = {}
	headers["Content-Type"] = "application/json";
	headers["Accept-Language"] = "en-US";
	headers["X-Mobile-Token"] = M.newAuthKey();
	headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

	local params = {}
	params.headers = headers;
	params.body = nil;
	
	callAt = system.getTimer();
	logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
	network.request ( url, "GET", networkListener, params );
end

M.sendDriverMessages = function (messages, callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("sendDriverMessages",delta);
			end
		end
	end
	
	local url = parameters.SERVER.API_URL_DRIVER_PUT_MESSAGES;
	
	local appConfiguration = storage.getConfiguration();
	local userToken = appConfiguration["token"];
	
	if userToken ~= nil then
		local authData = {};
		authData["token"] = userToken["value"];
		authData["user"] = appConfiguration["user_id"];
		authData["device"] = openudid.getValue();
	
		local messagesData = messages;
	
		local data = {};
		data["auth"] = authData;
		data["messages"] = messagesData;
	
		local bodyEncoded = json.encode( data );
	
		local headers = {}
		headers["Content-Type"] = "application/json";
		headers["Accept-Language"] = "en-US";
		headers["X-Mobile-Token"] = M.newAuthKey();
		headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

		local params = {}
		params.headers = headers;
		params.body = bodyEncoded;
		
		callAt = system.getTimer();
		logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
		network.request ( url, "PUT", networkListener, params );
	else
		callback();
	end
end

M.checkApp = function (callback)
	local callAt = nil;

	local function networkListener( event )
		apiResponse(event,callback);
		
		if callAt ~= nil then
			local trackable = true;
			if event.isError then
				trackable = false;
			elseif (event.status ~= 200) then
				trackable = false;
			end
		
			if trackable == true then
				local now = system.getTimer();
				local delta = (now - callAt);
				sendDelayMeasureToAnalytics("checkApp",delta);
			end
		end
	end
	
	local url = parameters.SERVER.API_URL_APP_CHECK;
	
	local data = {};
	data["build"] = tonumber(parameters.GENERAL.BUILD);
	data["platform"] = device.platform;

	local bodyEncoded = json.encode( data );

	local headers = {}
	headers["Content-Type"] = "application/json";
	headers["Accept-Language"] = "en-US";
	headers["X-Mobile-Token"] = M.newAuthKey();
	headers["X-Mobile-API"] = parameters.SERVER.API_VERSION;

	local params = {}
	params.headers = headers;
	params.body = bodyEncoded;
	
	callAt = system.getTimer();
	logger.log("requesting "..url.." with key: "..headers["X-Mobile-Token"]);
	network.request ( url, "POST", networkListener, params );
end

M.setCurrentRuns = function (runs)
	if runs ~= nil then
		logger.log("Current runs set #"..tostring(#runs));
		currentRuns = runs;
	end
end

M.getCurrentRuns = function ()
	return currentRuns;
end

return M;