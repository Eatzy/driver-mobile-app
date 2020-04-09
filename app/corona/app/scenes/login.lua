local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local logging = false;
local userLoginResult = nil;

-- Display objects
local Background;
local Foreground;
local GUI;

local usernameLabel;
local passwordLabel;
local usernameField;
local passwordField;
local loader;
-- local submitButton;
local loadingLayer;
local loadingIcon;

-- Display variables
local navButtonWidth = parameters.GRAPHICS.BUTTONS.NAVIGATION["width"];
local navButtonHeight = parameters.GRAPHICS.BUTTONS.NAVIGATION["height"];
local navButtonCorner = parameters.GRAPHICS.BUTTONS.NAVIGATION["corner_radius"];
local navButtonFontName = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_name"];
local navButtonFontSize = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_size"];

-- Data
local driverData;

local function fieldHandler( textField )
	return function( event )
		if ( "began" == event.phase ) then
			-- This is the "keyboard has appeared" event
			-- In some cases you may want to adjust the interface when the keyboard appears.
		
		elseif ( "ended" == event.phase ) then
			-- This event is called when the user stops editing a field: for example, when they touch a different field
			
		elseif ( "editing" == event.phase ) then
		
		elseif ( "submitted" == event.phase ) then
			-- This event occurs when the user presses the "return" key (if available) on the onscreen keyboard
			print( textField().text )
			
			-- Hide keyboard
			native.setKeyboardFocus( nil );
		end
	end
end

function scene:create( event )
  	local group = self.view;

  	Background = display.newGroup();
  	Foreground = display.newGroup();
  	GUI = display.newGroup();

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
  	
  	local touchBackgroundListener = function ( event )
		native.setKeyboardFocus( nil );
	end
  	backgroundBox:addEventListener( "touch", touchBackgroundListener );
  
  	usernameLabel = textmaker.newText(parameters.GRAPHICS.TEXT["username"],0,0,{navButtonFontName}, navButtonFontSize);
  	usernameLabel:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	-- headingTitle:setReferencePoint(display.CenterReferencePoint);
  	usernameLabel.anchorX = 0.5;
  	usernameLabel.anchorY = 0.5;
  	usernameLabel.x = _CX;
  	usernameLabel.y = _H*0.09*0.5;
  	-- usernameLabel.alpha = 0.75;
  	GUI:insert(usernameLabel);
  
  	usernameField = native.newTextField( 0, 0, navButtonWidth-navButtonCorner*2, navButtonHeight-navButtonCorner*2 );
	usernameField:addEventListener( "userInput", fieldHandler( function() return usernameField end ) );
	usernameField.anchorX = 0.5;
  	usernameField.anchorY = 0.5;
  	usernameField.x = usernameLabel.x;
  	usernameField.y = usernameLabel.y + navButtonHeight;
  	
  	local usernameFieldBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	usernameFieldBg:setFillColor(1,1,1);
  	usernameFieldBg.anchorX = usernameField.anchorX;
  	usernameFieldBg.anchorY = usernameField.anchorY;
  	usernameFieldBg.x = usernameField.x;
  	usernameFieldBg.y = usernameField.y;
  	
  	GUI:insert(usernameFieldBg);
  	GUI:insert(usernameField);
  	
  	passwordLabel = textmaker.newText(parameters.GRAPHICS.TEXT["password"],0,0,{navButtonFontName}, navButtonFontSize);
  	passwordLabel:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
 	 -- headingTitle:setReferencePoint(display.CenterReferencePoint);
  	passwordLabel.anchorX = 0.5;
  	passwordLabel.anchorY = 0.5;
  	passwordLabel.x = _CX;
  	passwordLabel.y = usernameLabel.y + navButtonHeight + 40;
  	-- passwordLabel.alpha = 0.75;
  	GUI:insert(passwordLabel);

	passwordField = native.newTextField( 0, 0, navButtonWidth-navButtonCorner*2, navButtonHeight-navButtonCorner*2 );
	passwordField.isSecure = true;
	passwordField:addEventListener( "userInput", fieldHandler( function() return passwordField end ) );
	passwordField.anchorX = 0.5;
  	passwordField.anchorY = 0.5;
  	passwordField.x = passwordLabel.x;
  	passwordField.y = passwordLabel.y + navButtonHeight;
  	
  	local passwordFieldBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	passwordFieldBg:setFillColor(1,1,1);
  	passwordFieldBg.anchorX = passwordField.anchorX;
  	passwordFieldBg.anchorY = passwordField.anchorY;
  	passwordFieldBg.x = passwordField.x;
  	passwordFieldBg.y = passwordField.y;
  	
  	GUI:insert(passwordFieldBg);
  	GUI:insert(passwordField);
  	
  	local loginButtonOverColor = parameters.GRAPHICS.COLORS["button_login_over"];
  	local loginButtonActiveColor = parameters.GRAPHICS.COLORS["button_login_active"];
  	
  	local registerButtonOverColor = parameters.GRAPHICS.COLORS["button_register_over"];
  	local registerButtonActiveColor = parameters.GRAPHICS.COLORS["button_register_active"];
  	
  	local loginButtonGroup = display.newGroup();
  	
  	local loginButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	loginButtonBg:setFillColor(loginButtonOverColor[1],loginButtonOverColor[2],loginButtonOverColor[3]);
  	loginButtonBg.anchorX = 0.5;
  	loginButtonBg.anchorY = 0.5;
  	loginButtonBg.x = _CX;
  	loginButtonBg.y = passwordLabel.y + navButtonHeight*2 + 20;
  	
  	local loginButtonText = textmaker.newText(parameters.GRAPHICS.TEXT["login"],0,0,{navButtonFontName}, navButtonFontSize);
  	loginButtonText:setFillColor(parameters.GRAPHICS.COLORS["button_login_text"][1],parameters.GRAPHICS.COLORS["button_login_text"][2],parameters.GRAPHICS.COLORS["button_login_text"][3]);
  	loginButtonText.anchorX = loginButtonBg.anchorX;
  	loginButtonText.anchorY = loginButtonBg.anchorY;
  	loginButtonText.x = loginButtonBg.x;
  	loginButtonText.y = loginButtonBg.y;
  	
  	local function onLogin(event)
  		if ( "began" == event.phase) then
  			loginButtonBg:setFillColor(loginButtonActiveColor[1],loginButtonActiveColor[2],loginButtonActiveColor[3]);
		elseif ( "ended" == event.phase ) then
			loginButtonBg:setFillColor(loginButtonOverColor[1],loginButtonOverColor[2],loginButtonOverColor[3]);
			
			logger.log("LOGIN BUTTON PRESSED!");
			native.setKeyboardFocus( nil );
			analytics.logEvent("login_login_tap");
	
			if logging ~= true then
				logger.log("Trying to login...");
		
				local username = usernameField.text;
				local password = passwordField.text;
		
				local validParameters = true;
				if (string.len(username) <= 0) then
					validParameters = false;
				end
				if (string.len(password) <= 0) then
					validParameters = false;
				end
		
				if (validParameters == true) then
					-- username = string.lower(username);
					-- password = string.lower(password);
		
					-- Calling login
					local function onLoginResult(data)
						if data["error"] == true then
							loader.stop();
					
							native.showAlert( "Login Error", data["message"], { "OK" } );
							logging = false;
						else
							contents = data["data"];
					
							logger.log("User ID: "..contents["user_id"]);
					
							local tokenData = contents["token"];
							logger.log("Token: "..tostring(tokenData["value"]).." expires: "..tostring(tokenData["expires"]));
					
							local configurationData = contents["configuration"];
							logger.log("GPS period from server: "..tostring(configurationData["gps_period"]).." seconds");
							logger.log("Order updates period from server: "..tostring(configurationData["order_period"]).." seconds");
							logger.log("Messages updates period from server: "..tostring(configurationData["messages_period"]).." seconds");
							logger.log("Target recipient user id: "..tostring(configurationData["recipient_user"]));
					
							driverData = contents["driver"];
					
							local appConfiguration = storage.getConfiguration();
					
							appConfiguration["token"] = tokenData;
							appConfiguration["configuration"] = configurationData;
							appConfiguration["user_id"] = contents["user_id"];
							appConfiguration["driver"] = driverData;
					
							storage.saveConfiguration(appConfiguration);
					
							logger.log("LOGIN SUCCESS!!!!");
							userLoginResult = "success";
						end
					end
			
					loader.start();
					menunu.driverLogin(username,password,onLoginResult);
			
					logging = true;
				else
					native.showAlert( "Invalid Login", "Please fill all fields", { "OK" } );
				end
			end
		end
  	end
  	
  	local loginButtonAction = widget.newButton {
		width = navButtonWidth,
		height = navButtonHeight,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onLogin
	};
	loginButtonAction.anchorX = loginButtonText.anchorX;
  	loginButtonAction.anchorY = loginButtonText.anchorX;
  	loginButtonAction.x = loginButtonText.x;
  	loginButtonAction.y = loginButtonText.y;
  	
  	loginButtonGroup:insert(loginButtonBg);
  	loginButtonGroup:insert(loginButtonText);
  	loginButtonGroup:insert(loginButtonAction);
  	
  	GUI:insert(loginButtonGroup);
  	
  	local externalLinksGroup = display.newGroup();
  	
  	local tosText = textmaker.newText(parameters.GRAPHICS.TEXT["tos_button"],0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
  	tosText:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	tosText.alpha = 0.9;
  	tosText.anchorX = 0.5;
  	tosText.anchorY = 1.0;
  	tosText.x = _CX;
  	tosText.y = _H*0.9;
  	
  	local ppText = textmaker.newText(parameters.GRAPHICS.TEXT["pp_button"],0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
  	ppText:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	ppText.alpha = tosText.alpha;
  	ppText.anchorX = tosText.anchorX;
  	ppText.anchorY = tosText.anchorY;
  	ppText.x = tosText.x;
  	ppText.y = tosText.y + 38;
  	
  	local function onExternal(event)
  		if ( "began" == event.phase) then
  			-- do nothing
		elseif ( "ended" == event.phase ) then
			local target = event.target;
			
			if target ~= nil and target.action ~= nil then
				-- open external link
				local tAction = target.action;
				if tAction == "tos" then
					logger.log("Opening external link: "..tostring(parameters.SERVER.TOS_URL));
					system.openURL( parameters.SERVER.TOS_URL );
				else
					logger.log("Opening external link: "..tostring(parameters.SERVER.PRIVACY_URL));
					system.openURL( parameters.SERVER.PRIVACY_URL );
				end
			end
		end
	end 
  	
  	local tosAction = widget.newButton {
		width = _W*0.5,
		height = 40,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onExternal
	};
	tosAction.anchorX = 0.5;
  	tosAction.anchorY = 1.0;
  	tosAction.x = _CX;
  	tosAction.y = tosText.y + 10;
  	tosAction.action = "tos";
  	
  	local ppAction = widget.newButton {
		width = _W*0.5,
		height = 40,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onExternal
	};
	ppAction.anchorX = 0.5;
  	ppAction.anchorY = 0.0;
  	ppAction.x = _CX;
  	ppAction.y = tosText.y + 10;
  	ppAction.action = "pp";
  	
  	externalLinksGroup:insert(tosText);
  	externalLinksGroup:insert(ppText);
  	externalLinksGroup:insert(tosAction);
  	externalLinksGroup:insert(ppAction);
  	
  	GUI:insert(externalLinksGroup);
  	
  	local onLoaderStart = function ()
  		if usernameField ~= nil then
			GUI:remove(usernameField);
			usernameField:removeSelf();
			usernameField = nil;
		end
		
		if passwordField ~= nil then
			GUI:remove(passwordField);
			passwordField:removeSelf();
			passwordField = nil;
		end
	end
	
	local onLoaderStop = function ()
  		if usernameField == nil then
			usernameField = native.newTextField( 0, 0, navButtonWidth-navButtonCorner*2, navButtonHeight-navButtonCorner*2 );
			usernameField:addEventListener( "userInput", fieldHandler( function() return usernameField end ) );
			usernameField.anchorX = 0.5;
			usernameField.anchorY = 0.5;
			usernameField.x = usernameLabel.x;
			usernameField.y = usernameLabel.y + navButtonHeight;
			
			GUI:insert(usernameField);
		end
		
		if passwordField == nil then
			passwordField = native.newTextField( 0, 0, navButtonWidth-navButtonCorner*2, navButtonHeight-navButtonCorner*2 );
			passwordField.isSecure = true;
			passwordField:addEventListener( "userInput", fieldHandler( function() return passwordField end ) );
			passwordField.anchorX = 0.5;
			passwordField.anchorY = 0.5;
			passwordField.x = passwordLabel.x;
			passwordField.y = passwordLabel.y + navButtonHeight;
			
			GUI:insert(passwordField);
		end
	end
	
	
		
	local onLoaderRepeat = function ()
		if (userLoginResult ~= nil) then
			if userLoginResult == "success" then
				loader.stop();
				
				local targetScene = "app.scenes.clock";
				
				if driverData ~= nil then
					if driverData["clocked_in"] == true then
						targetScene = "app.scenes.driver";
					end
				end
				
				if usernameField ~= nil then
					GUI:remove(usernameField);
					usernameField:removeSelf();
					usernameField = nil;
				end
				if passwordField ~= nil then
					GUI:remove(passwordField);
					passwordField:removeSelf();
					passwordField = nil;
				end
				
				-- Change scene
				local composer = require( "composer" );
				composer.gotoScene(targetScene);
	  		end
	  	end
	end
  	
  	local loaderBuilder = require( "app.lib.loader" );
  	loader = loaderBuilder.newLoader();
  	loader.initialize({onStart=onLoaderStart, onStop=onLoaderStop, onRepeat=onLoaderRepeat});
  	GUI:insert(loader);
end

function scene:show( event )
    local phase = event.phase;

    if ( phase == "will" ) then
	  	logging = false;
	  	
	  	if usernameField == nil then
			usernameField = native.newTextField( 0, 0, navButtonWidth-navButtonCorner*2, navButtonHeight-navButtonCorner*2);
			usernameField:addEventListener( "userInput", fieldHandler( function() return usernameField end ) );
			usernameField.anchorX = 0.5;
			usernameField.anchorY = 0.5;
			usernameField.x = usernameLabel.x;
			usernameField.y = usernameLabel.y + navButtonHeight;
			
			GUI:insert(usernameField);
		end
		
		if passwordField == nil then
			passwordField = native.newTextField( 0, 0, navButtonWidth-navButtonCorner*2, navButtonHeight-navButtonCorner*2 );
			passwordField.isSecure = true;
			passwordField:addEventListener( "userInput", fieldHandler( function() return passwordField end ) );
			passwordField.anchorX = 0.5;
			passwordField.anchorY = 0.5;
			passwordField.x = passwordLabel.x;
			passwordField.y = passwordLabel.y + navButtonHeight;
			
			GUI:insert(passwordField);
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
    elseif ( phase == "did" ) then
    	loader.stop();
    end
end

function scene:hide( event )
  	local phase = event.phase;

    if ( phase == "will" ) then
    	native.setKeyboardFocus( nil );
        logging = false;
        userLoginResult = nil;
    elseif ( phase == "did" ) then
        -- TODO
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