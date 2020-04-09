local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local widget = require( "widget" )

-- Display variables
local navButtonWidth = parameters.GRAPHICS.BUTTONS.NAVIGATION["width"];
local navButtonHeight = parameters.GRAPHICS.BUTTONS.NAVIGATION["height"];
local navButtonCorner = parameters.GRAPHICS.BUTTONS.NAVIGATION["corner_radius"];
local navButtonFontName = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_name"];
local navButtonFontSize = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_size"];

M.newTab = function (params)
  	
  	local containerEnabled = false;
  	local containerLoaded = false;
  	
	local containerWidth = _W;
	local containerHeight = _H;
	local externalLoader = nil;
	local notificationsGw = nil;
	local navigationGW = nil;
	
	if params ~= nil then
		if params["width"] ~= nil then containerWidth = params["width"]; end
		if params["height"] ~= nil then containerHeight = params["height"]; end
		if params["loader"] ~= nil then externalLoader = params["loader"]; end
		if params["notifications"] ~= nil then notificationsGw = params["notifications"]; end
		if params["navigation"] ~= nil then navigationGW = params["navigation"]; end
	end
	
	local Container = display.newGroup();
	
	local Background = display.newGroup();
  	local Foreground = display.newGroup();
  	local GUI = display.newGroup();
  	
  	Container:insert(Background);
  	Container:insert(Foreground);
  	Container:insert(GUI);
  	
  	local loaderParams = {};
  	loaderParams["width"] = containerWidth;
	loaderParams["height"] = containerHeight;
	loaderParams["bgcolor"] = parameters.GRAPHICS.COLORS["background_settings"];
  	local loaderBuilder = require( "app.lib.loader" );
  	local loader = loaderBuilder.newLoader(loaderParams);
  	loader.initialize();

  	local backgroundBox = display.newRect(0,0,containerWidth,containerHeight);
  	backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background_settings"][1],parameters.GRAPHICS.COLORS["background_settings"][2],parameters.GRAPHICS.COLORS["background_settings"][3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.0;
  	backgroundBox.x = _CX;
  	backgroundBox.y = 0;
  	Background:insert(backgroundBox);
  	
  	local buttonDistance = 8;
  	local sectionsDistance = buttonDistance*3;
  	
  	local infoGroup = display.newGroup();
  	GUI:insert(infoGroup);
  	
  	local installedVersionText = "unknown";
  	local installedTSText = "unknown";
  	local currentVersionText = "unknown";
  	local currentTSText = "unknown";
  	local appConfiguration = storage.getConfiguration();
    if appConfiguration ~= nil then
    	local appStats = appConfiguration["stats"];
    	if appStats ~= nil then
    		local appVersion = appStats["version"];
    		if appVersion ~= nil then
				currentVersionText = appVersion["current_ver"];
				currentTSText = appVersion["current_ts"];
				installedVersionText = appVersion["install_ver"];
				installedTSText = appVersion["install_ts"];
			end
    	end
	end
  	
  	local infoKeyText = textmaker.newText("Current Ver: "..tostring(currentVersionText).." ("..tostring(currentTSText)..")",0,0,{"roboto-thin"}, 14);
  	infoKeyText:setFillColor(1.0,1.0,1.0);
  	infoKeyText.anchorX = 0.5;
  	infoKeyText.anchorY = 0.0;
	infoKeyText.x = _CX;
	infoKeyText.y = device.safeYOffset + 10;
  	infoGroup:insert(infoKeyText);
  	
  	local installedText = textmaker.newText("Installed Ver: "..tostring(installedVersionText).." ("..tostring(installedTSText)..")",0,0,{"roboto-thin"}, 14);
  	installedText:setFillColor(1.0,1.0,1.0);
  	installedText.anchorX = infoKeyText.anchorX;
  	installedText.anchorY = infoKeyText.anchorY;
  	installedText.x = infoKeyText.x;
  	installedText.y = infoKeyText.y + infoKeyText.height;
  	infoGroup:insert(installedText);
  	
  	local buttonsGroup = display.newGroup();
  	GUI:insert(buttonsGroup);
  	
  	local requesting = false;
  	local clockButtonPress = function( event )
		logger.log("CLOCK OUT BUTTON PRESSED!");
	
		if requesting ~= true then
			if externalLoader ~= nil then
				externalLoader.start();
			end
		
			local onClocking = function (response)
				if response["error"] == true then
					if externalLoader ~= nil then
						externalLoader.stop();
					end
					native.showAlert( "Clock Out Error", tostring(response["message"]), { "OK" } );
				
					menunu.setDriverClockedIn(false);
				else
					local data = response["data"];
					if externalLoader ~= nil then
						externalLoader.stop();
					end
					menunu.setDriverClockedIn(false);
					
					-- Change scene
					local composer = require( "composer" );
					composer.gotoScene("app.scenes.clock");
				end
			
				requesting = false;
			end
		
			menunu.clockDriver(0, onClocking);
		
			requesting = true;
		end
	end
	
	local logoutButtonPress = function( event )
		logger.log("LOGOUT BUTTON PRESSED!");
	
		if requesting ~= true then
			if externalLoader ~= nil then
				externalLoader.start();
			end
		
			local onLogout = function (response)
				if response["error"] == true then
					if externalLoader ~= nil then
						externalLoader.stop();
					end
					native.showAlert( "Logout Error", tostring(response["message"]), { "OK" } );
				else
					local data = response["data"];
					if externalLoader ~= nil then
						externalLoader.stop();
					end
					menunu.setDriverClockedIn(false);
					
					-- Reset local configuration (no longer valid)
					local appConfiguration = storage.getConfiguration();
		
					if appConfiguration ~= nil then
						appConfiguration["token"] = nil;
						appConfiguration["configuration"] = nil;
						appConfiguration["user_id"] = nil;
						appConfiguration["driver"] = nil;
							
						storage.saveConfiguration(appConfiguration);
					end
					
					-- Change scene
					local composer = require( "composer" );
					composer.gotoScene("app.scenes.login");
				end
			
				requesting = false;
			end
		
			menunu.driverLogout(onLogout);
		
			requesting = true;
		end
	end
	
	local clockoutButtonOverColor = parameters.GRAPHICS.COLORS["button_clockout_over"];
  	local clockoutButtonActiveColor = parameters.GRAPHICS.COLORS["button_clockout_active"];
  	
  	local logoutButtonOverColor = parameters.GRAPHICS.COLORS["button_logout_over"];
  	local logoutButtonActiveColor = parameters.GRAPHICS.COLORS["button_logout_active"];
  	
  	local clockoutButtonGroup = display.newGroup();
  	
  	local clockoutButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	clockoutButtonBg:setFillColor(clockoutButtonOverColor[1],clockoutButtonOverColor[2],clockoutButtonOverColor[3]);
  	clockoutButtonBg.anchorX = 0.5;
  	clockoutButtonBg.anchorY = 0.5;
  	clockoutButtonBg.x = _CX;
  	clockoutButtonBg.y = infoKeyText.y + infoGroup.height + sectionsDistance + navButtonHeight*0.5;
  	
  	local clockoutButtonText = textmaker.newText(parameters.GRAPHICS.TEXT["clockout"],0,0,{navButtonFontName}, navButtonFontSize);
  	clockoutButtonText:setFillColor(parameters.GRAPHICS.COLORS["button_clockout_text"][1],parameters.GRAPHICS.COLORS["button_clockout_text"][2],parameters.GRAPHICS.COLORS["button_clockout_text"][3]);
  	clockoutButtonText.anchorX = clockoutButtonBg.anchorX;
  	clockoutButtonText.anchorY = clockoutButtonBg.anchorY;
  	clockoutButtonText.x = clockoutButtonBg.x;
  	clockoutButtonText.y = clockoutButtonBg.y;
  	
  	local function onClockout(event)
  		if ( "began" == event.phase) then
  			clockoutButtonBg:setFillColor(clockoutButtonActiveColor[1],clockoutButtonActiveColor[2],clockoutButtonActiveColor[3]);
		elseif ( "ended" == event.phase ) then
			clockoutButtonBg:setFillColor(clockoutButtonOverColor[1],clockoutButtonOverColor[2],clockoutButtonOverColor[3]);
			logger.log("CLOCKOUT BUTTON PRESSED!");
			analytics.logEvent("settings_clockout_tap");
			
			local function onAlert( event )
				if ( event.action == "clicked" ) then
					local i = event.index
					if ( i == 1 ) then
						-- Do nothing; dialog will simply dismiss
					elseif ( i == 2 ) then
						logger.log("Clocking out...");
						analytics.logEvent("settings_clockout_confirmed");
						clockButtonPress();
					end
				end
			end
  
			-- Show alert with two buttons
			local alert = native.showAlert( parameters.GRAPHICS.TEXT["clockout_alert_title"], parameters.GRAPHICS.TEXT["clockout_alert_body"], { parameters.GRAPHICS.TEXT["alert_cancel"], parameters.GRAPHICS.TEXT["alert_ok"] }, onAlert );
		end
  	end
  	
  	local clockoutButtonAction = widget.newButton {
		width = navButtonWidth,
		height = navButtonHeight,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onClockout
	};
	clockoutButtonAction.anchorX = clockoutButtonText.anchorX;
  	clockoutButtonAction.anchorY = clockoutButtonText.anchorX;
  	clockoutButtonAction.x = clockoutButtonText.x;
  	clockoutButtonAction.y = clockoutButtonText.y;
  	
  	clockoutButtonGroup:insert(clockoutButtonBg);
  	clockoutButtonGroup:insert(clockoutButtonText);
  	clockoutButtonGroup:insert(clockoutButtonAction);
	
	local logoutButtonGroup = display.newGroup();
  	
  	local logoutButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	logoutButtonBg:setFillColor(logoutButtonOverColor[1],logoutButtonOverColor[2],logoutButtonOverColor[3]);
  	logoutButtonBg.anchorX = 0.5;
  	logoutButtonBg.anchorY = 0.5;
  	logoutButtonBg.x = _CX;
  	logoutButtonBg.y = clockoutButtonBg.y + navButtonHeight + buttonDistance;
  	
  	local logoutButtonText = textmaker.newText(parameters.GRAPHICS.TEXT["logout"],0,0,{navButtonFontName}, navButtonFontSize);
  	logoutButtonText:setFillColor(parameters.GRAPHICS.COLORS["button_logout_text"][1],parameters.GRAPHICS.COLORS["button_logout_text"][2],parameters.GRAPHICS.COLORS["button_logout_text"][3]);
  	logoutButtonText.anchorX = logoutButtonBg.anchorX;
  	logoutButtonText.anchorY = logoutButtonBg.anchorY;
  	logoutButtonText.x = logoutButtonBg.x;
  	logoutButtonText.y = logoutButtonBg.y;
  	
  	local function onLogout(event)
  		if ( "began" == event.phase) then
  			logoutButtonBg:setFillColor(logoutButtonActiveColor[1],logoutButtonActiveColor[2],logoutButtonActiveColor[3]);
		elseif ( "ended" == event.phase ) then
			logoutButtonBg:setFillColor(logoutButtonOverColor[1],logoutButtonOverColor[2],logoutButtonOverColor[3]);
			logger.log("LOGOUT BUTTON PRESSED!");
			analytics.logEvent("settings_logout_tap");
			
			local function onAlert( event )
				if ( event.action == "clicked" ) then
					local i = event.index
					if ( i == 1 ) then
						-- Do nothing; dialog will simply dismiss
					elseif ( i == 2 ) then
						logger.log("Logging out...");
						analytics.logEvent("settings_logout_confirmed");
						logoutButtonPress();
					end
				end
			end
  
			-- Show alert with two buttons
			local alert = native.showAlert( parameters.GRAPHICS.TEXT["logout_alert_title"], parameters.GRAPHICS.TEXT["logout_alert_body"], { parameters.GRAPHICS.TEXT["alert_cancel"], parameters.GRAPHICS.TEXT["alert_ok"] }, onAlert );
		end
  	end
  	
  	local logoutButtonAction = widget.newButton {
		width = navButtonWidth,
		height = navButtonHeight,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onLogout
	};
	logoutButtonAction.anchorX = logoutButtonText.anchorX;
  	logoutButtonAction.anchorY = logoutButtonText.anchorX;
  	logoutButtonAction.x = logoutButtonText.x;
  	logoutButtonAction.y = logoutButtonText.y;
  	
  	logoutButtonGroup:insert(logoutButtonBg);
  	logoutButtonGroup:insert(logoutButtonText);
  	logoutButtonGroup:insert(logoutButtonAction);
  	
  	buttonsGroup:insert(clockoutButtonGroup);
  	buttonsGroup:insert(logoutButtonGroup);
  	
  	-- FUNCTIONS BEGIN
  	
  	local enableContainerFunc = function ()
  		if containerEnabled ~= true then
  			containerEnabled = true;
  		end
  	end
  	
  	local disableContainerFunc = function ()
  		if containerEnabled == true then
  			containerEnabled = false;
  		end
  	end
  	
  	local loadContainerFunc = function ()
  		if containerLoaded ~= true then
  			containerLoaded = true;
  		end
  	end
  	
  	local unloadContainerFunc = function ()
  		if containerLoaded == true then
  			disableContainerFunc();
  		
  			containerLoaded = false;
  		end
  	end
  	
  	-- FUNCTIONS END
  	Container.onEnable = enableContainerFunc;
  	Container.onDisable = disableContainerFunc;
  	Container.onLoad = loadContainerFunc;
  	Container.onUnload = unloadContainerFunc;
  	
  	return Container;
end

return M;