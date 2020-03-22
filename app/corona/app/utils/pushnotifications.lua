local M = {};

local notifications = require( "plugin.notifications" )

-- local OneSignal = require("plugin.OneSignal")
local OneSignal = require ("app.lib.onesignal")

local json = require "json";

local initialized;
local registeredOnMenunu;
local pushToken;
local pushToServerTimer;
local pushing;

M.onesignalListener = function ( event )
    -- TODO
end

M.notificationListener = function ( event )
	logger.log("PUSHNOTIFICATIONS module - Notification listener: new event: "..tostring(event.type).." - "..json.encode(event));
	
	OneSignal.notificationListener(event);
	
    if ( event.type == "remote" or event.type == "local" ) then
        -- handle the push or local notification
        logger.log("PUSHNOTIFICATIONS module - remote event: "..json.encode(event));
    elseif ( event.type == "remoteRegistration" ) then
    	if event.token ~= nil then
        	pushToken = event.token;
        	
			local appConfiguration = storage.getConfiguration();
			if appConfiguration ~= nil then
				appConfiguration["push_token"] = pushToken;
				storage.saveConfiguration(appConfiguration);
			end
        	
        	registeredOnMenunu = false;
        end
    else
		logger.log("PUSHNOTIFICATIONS module - Unknown notification event: "..json.encode(event));
    end
end

M.init = function ()
	if initialized ~= true then
		-- init onesignal plugin
		OneSignal.init(parameters.ONESIGNAL_APP_ID, parameters.GOOGLE_PLAY_PROJECT_NUMBER, M.onesignalListener);
		Runtime:addEventListener( "notification", M.notificationListener );
		
		-- Register device
		if device.platform == "ios" then
			notifications.registerForPushNotifications();
		elseif device.platform == "android" then
			notifications.registerForPushNotifications();
		elseif device.platform == "simulator" then
			-- TODO
		end
		
		local checkPush = function (event)
			if OneSignal.isRegistered() == true then
				if pushToken ~= nil and registeredOnMenunu ~= true and pushing ~= true then
					local onRegistered = function (data)
						if data["error"] == true then
							logger.log("PUSHNOTIFICATIONS module - Can't register push on server: "..tostring(data["message"]));
						else
							if pushToServerTimer ~= nil then
								timer.cancel(pushToServerTimer);
								pushToServerTimer = nil;
							end
							registeredOnMenunu = true;
						end
						pushing = false;
					end
			
					pushing = true;
					menunu.registerPush(pushToken, onRegistered);
				end
			else
				if device.platform ~= "simulator" then
					logger.log("PUSHNOTIFICATIONS module - Waiting for registration on OneSignal...");
				end
			end
		end
		
		if pushToServerTimer ~= nil then
			timer.cancel(pushToServerTimer);
			pushToServerTimer = nil;
		end
		pushToServerTimer = timer.performWithDelay( 3000, checkPush, -1 );
	
		initialized = true;
		registeredOnMenunu = false;
		pushing = false;
	end
end

M.manageNotification = function (notifications)
	-- TODO
	-- WARNING: not initialized when called, cache and schedule processing
end

return M;