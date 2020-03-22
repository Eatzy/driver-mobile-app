local M = {};

local json = require "json";
local crypto = require "crypto";

local flurryAnalytics = require( "plugin.flurry.analytics" )

local flurryIOSAppKey = "J2FWQRVFVJ4R924QVNSN";
local flurryAndroidAppKey = "3SKFY2ZNQGRX234NZ4YC";
local flurryLogLevel = "all";
local flurryCrashReportingEnabled = true;

local initialized;
local registered;

local function flurryListener ( event )
	logger.log("Event Flurry = " .. json.encode(event));
	
	if event.phase == "init" then  -- Successful initialization
        logger.log("Flurry successfuly initialized: "..tostring(event.provider));
        registered = true;
    end
end

M.init = function ()
	if initialized ~= true then
		local userId = openudid.getValue();
	
		if device.platform ~= nil then
			if device.platform == "ios" then
				local faOptions = {
					apiKey=flurryIOSAppKey,
					crashReportingEnabled = flurryCrashReportingEnabled,
					logLevel = flurryLogLevel
				}
				flurryAnalytics.init( flurryListener, faOptions );
			elseif device.platform == "android" then
				local faOptions = {
					apiKey=flurryAndroidAppKey,
					crashReportingEnabled = flurryCrashReportingEnabled,
					logLevel = flurryLogLevel
				}
				flurryAnalytics.init( flurryListener, faOptions );
			end
		end
		
		initialized = true;
	end
end

M.logEvent = function (eventName, eventData)
	if initialized ~= true then
		logger.log("Analytics error for "..tostring(eventName).." - analytics not initialized, please init before sending events");
	else
		if eventName ~= nil then
			flurryAnalytics.logEvent( eventName, eventData );
		end
	end
end


return M;