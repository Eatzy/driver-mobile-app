local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

-- Display objects
local loader;
local businessName;
local shiftsGroup;
local shiftsContainer;

-- Display variables
local navButtonWidth = parameters.GRAPHICS.BUTTONS.NAVIGATION["width"];
local navButtonHeight = parameters.GRAPHICS.BUTTONS.NAVIGATION["height"];
local navButtonCorner = parameters.GRAPHICS.BUTTONS.NAVIGATION["corner_radius"];
local navButtonFontName = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_name"];
local navButtonFontSize = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_size"];

local requesting = false;

local clockButtonPress = function( event )
	if requesting ~= true then
		loader.start();
		
		local onClocking = function (response)
			if response["error"] == true then
    			loader.stop();
    			native.showAlert( "Clock In Error", tostring(response["message"]), { "OK" } );
    			
    			menunu.setDriverClockedIn(false);
    		else
    			local data = response["data"];
    			loader.stop();
					
				-- Change scene
				local composer = require( "composer" );
				composer.gotoScene("app.scenes.driver");
    		end
    		
    		requesting = false;
		end
		
		menunu.clockDriver(1, onClocking);
		
		requesting = true;
	end
end

local logoutButtonPress = function( event )
	if requesting ~= true then
		if externalLoader ~= nil then
			externalLoader.start();
		end
	
		local onLogout = function (response)
			menunu.setDriverClockedIn(false);
				
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

function scene:create( event )
  	local group = self.view;
  	
  	local appConfiguration = storage.getConfiguration();
  	local driverDetails = appConfiguration["driver"];
  	local driverBusinessDetails = driverDetails["business"];
  	
  	local navButtonWidth = parameters.GRAPHICS.BUTTONS.NAVIGATION["width"];
	local navButtonHeight = parameters.GRAPHICS.BUTTONS.NAVIGATION["height"];
	local navButtonCorner = parameters.GRAPHICS.BUTTONS.NAVIGATION["corner_radius"];
	local navButtonFontName = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_name"];
	local navButtonFontSize = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_size"];

  	local Background = display.newGroup();
  	local Foreground = display.newGroup();
  	local GUI = display.newGroup();

  	group:insert(Background);
  	group:insert(Foreground);
  	group:insert(GUI);

  	local backgroundBox = display.newRect(0,0,_W,_H);
  	backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background"][1],parameters.GRAPHICS.COLORS["background"][2],parameters.GRAPHICS.COLORS["background"][3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.5;
  	backgroundBox.x = _CX;
  	backgroundBox.y = _CY;
  	Background:insert(backgroundBox);
  	
  	businessName = textmaker.newText(driverBusinessDetails["name"],0,0,{"roboto-thin"}, parameters.GRAPHICS.FONT_BASE_SIZE*2);
  	businessName:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	businessName.anchorX = 0.5;
  	businessName.anchorY = 0.0;
  	businessName.x = _CX;
  	businessName.y = 20;
  	GUI:insert(businessName);
  	
  	shiftsContainer = display.newGroup();
  	GUI:insert(shiftsContainer);
  	
  	local loaderBuilder = require( "app.lib.loader" );
  	loader = loaderBuilder.newLoader();
  	loader.initialize();
  	
  	local clockinButtonOverColor = parameters.GRAPHICS.COLORS["button_clockin_over"];
  	local clockinButtonActiveColor = parameters.GRAPHICS.COLORS["button_clockin_active"];
  	
  	local logoutButtonOverColor = parameters.GRAPHICS.COLORS["button_logout_over"];
  	local logoutButtonActiveColor = parameters.GRAPHICS.COLORS["button_logout_active"];
  	
  	local logoutButtonGroup = display.newGroup();
  	
  	local logoutButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	logoutButtonBg:setFillColor(logoutButtonOverColor[1],logoutButtonOverColor[2],logoutButtonOverColor[3]);
  	logoutButtonBg.anchorX = 0.5;
  	logoutButtonBg.anchorY = 0.5;
  	logoutButtonBg.x = _CX;
  	logoutButtonBg.y = _H - navButtonHeight*0.5 - 10;
  	
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
			analytics.logEvent("clock_logout_tap");
			
			local function onAlert( event )
				if ( event.action == "clicked" ) then
					local i = event.index
					if ( i == 1 ) then
						-- Do nothing; dialog will simply dismiss
					elseif ( i == 2 ) then
						logger.log("Logging out...");
						analytics.logEvent("clock_logout_confirmed");
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
  	
  	local clockinButtonGroup = display.newGroup();
  	
  	local clockinButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	clockinButtonBg:setFillColor(clockinButtonOverColor[1],clockinButtonOverColor[2],clockinButtonOverColor[3]);
  	clockinButtonBg.anchorX = 0.5;
  	clockinButtonBg.anchorY = 0.5;
  	clockinButtonBg.x = _CX;
  	clockinButtonBg.y = logoutButtonBg.y - navButtonHeight*0.5 - (_H - logoutButtonBg.y);
  	
  	local clockinButtonText = textmaker.newText(parameters.GRAPHICS.TEXT["clockin"],0,0,{navButtonFontName}, navButtonFontSize);
  	clockinButtonText:setFillColor(parameters.GRAPHICS.COLORS["button_clockin_text"][1],parameters.GRAPHICS.COLORS["button_clockin_text"][2],parameters.GRAPHICS.COLORS["button_clockin_text"][3]);
  	clockinButtonText.anchorX = clockinButtonBg.anchorX;
  	clockinButtonText.anchorY = clockinButtonBg.anchorY;
  	clockinButtonText.x = clockinButtonBg.x;
  	clockinButtonText.y = clockinButtonBg.y;
  	
  	local function onClockin(event)
  		if ( "began" == event.phase) then
  			clockinButtonBg:setFillColor(clockinButtonActiveColor[1],clockinButtonActiveColor[2],clockinButtonActiveColor[3]);
		elseif ( "ended" == event.phase ) then
			clockinButtonBg:setFillColor(clockinButtonOverColor[1],clockinButtonOverColor[2],clockinButtonOverColor[3]);
			logger.log("CLOCKIN BUTTON PRESSED!");
			analytics.logEvent("clock_clockin_tap");
			clockButtonPress();
		end
  	end
  	
  	local clockinButtonAction = widget.newButton {
		width = navButtonWidth,
		height = navButtonHeight,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onClockin
	};
	clockinButtonAction.anchorX = clockinButtonText.anchorX;
  	clockinButtonAction.anchorY = clockinButtonText.anchorX;
  	clockinButtonAction.x = clockinButtonText.x;
  	clockinButtonAction.y = clockinButtonText.y;
  	
  	clockinButtonGroup:insert(clockinButtonBg);
  	clockinButtonGroup:insert(clockinButtonText);
  	clockinButtonGroup:insert(clockinButtonAction);
  	
  	GUI:insert(clockinButtonGroup);
  	GUI:insert(logoutButtonGroup);
  	
  	GUI:insert(loader);
end

function scene:show( event )
    local phase = event.phase;

    if ( phase == "will" ) then
    	local appConfiguration = storage.getConfiguration();
  		local driverDetails = appConfiguration["driver"];
  		
  		local driverBusinessDetails = driverDetails["business"];
  		local driverShifts = driverDetails["shifts"];
  		
  		businessName.text = driverBusinessDetails["name"];
  		
  		if businessName.width > navButtonWidth then
  			local scaling = navButtonWidth/businessName.width;
  			logger.log("scaling is "..tostring(scaling));
  			businessName.xScale = scaling;
  			businessName.yScale = scaling;
  		else
  			businessName.xScale = 1.0;
  			businessName.yScale = 1.0;
  		end
  		
  		if shiftsGroup ~= nil then
  			shiftsGroup:removeSelf();
  			shiftsGroup = nil;
  		end
  		
  		
  		if driverShifts ~= nil then
			shiftsGroup = display.newGroup();
		
			local shiftOffset = _H*0.15;
			for i=1, #driverShifts do
				local driverShift = driverShifts[i];
				
				local currentShift = false;
				if driverShift['current'] ~= nil and tonumber(driverShift['current']) > 0 then
					currentShift = true;
				end
			
				local shiftContainer = display.newGroup();
				local blockSize = 0;
				if currentShift == true then
					local topBorder = display.newRect(0,0,navButtonWidth,4);
					topBorder:setFillColor(0.0,1.0,0.0);
					topBorder.anchorX = 0.5;
					topBorder.anchorY = 0.0;
					topBorder.x = _CX;
					topBorder.y = shiftOffset;
				
					local bg = display.newRect(0,0,navButtonWidth,navButtonHeight*1.25);
					bg:setFillColor(1.0,1.0,1.0);
					bg.anchorX = 0.5;
					bg.anchorY = 0.0;
					bg.x = _CX;
					bg.y = topBorder.y + topBorder.height + 4;
				
					local bottomBorder = display.newRect(0,0,navButtonWidth,4);
					bottomBorder:setFillColor(0.0,1.0,0.0);
					bottomBorder.anchorX = 0.5;
					bottomBorder.anchorY = 0.0;
					bottomBorder.x = _CX;
					bottomBorder.y = bg.y + bg.height + 4;
					
					local shiftName = textmaker.newText(driverShift["name"],0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.5);
					shiftName:setFillColor(parameters.GRAPHICS.COLORS["background"][1],parameters.GRAPHICS.COLORS["background"][2],parameters.GRAPHICS.COLORS["background"][3]);
					shiftName.anchorX = 0.5;
					shiftName.anchorY = 0.5;
					shiftName.x = bg.x;
					shiftName.y = bg.y + bg.height*0.5;
				
					shiftContainer:insert(topBorder);
					shiftContainer:insert(bg);
					shiftContainer:insert(bottomBorder);
					shiftContainer:insert(shiftName);
				
					blockSize = bottomBorder.y + bottomBorder.height + 6 - shiftOffset;
				else
					-- Creating other shift block
					local bg = display.newRect(0,0,navButtonWidth,navButtonHeight);
					bg:setFillColor(1.0,1.0,1.0);
					bg.anchorX = 0.5;
					bg.anchorY = 0.0;
					bg.x = _CX;
					bg.y = shiftOffset;
					
					local shiftName = textmaker.newText(driverShift["name"],0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE*1.25);
					shiftName:setFillColor(parameters.GRAPHICS.COLORS["background"][1],parameters.GRAPHICS.COLORS["background"][2],parameters.GRAPHICS.COLORS["background"][3]);
					shiftName.anchorX = 0.5;
					shiftName.anchorY = 0.5;
					shiftName.x = bg.x;
					shiftName.y = bg.y + bg.height*0.5;
				
					shiftContainer:insert(bg);
					shiftContainer:insert(shiftName);
					shiftContainer.alpha = 0.25;
				
					blockSize = bg.y + bg.height + 6 - shiftOffset;
				end
			
				shiftsGroup:insert(shiftContainer);
				shiftOffset = shiftOffset + blockSize;
			end
  		
  			shiftsContainer:insert(shiftsGroup);
		end
    elseif ( phase == "did" ) then
    	-- TODO
    end
end

function scene:hide( event )
  	local phase = event.phase;

    if ( phase == "will" ) then
        -- TODO
    elseif ( phase == "did" ) then
    	businessName.text = "";
        if shiftsGroup ~= nil then
  			shiftsGroup:removeSelf();
  			shiftsGroup = nil;
  		end
    end
end

function scene:destroy( event )
-- TODO
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene