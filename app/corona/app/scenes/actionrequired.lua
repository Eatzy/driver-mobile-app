local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

local textGroup;

-- Display variables
local navButtonWidth = parameters.GRAPHICS.BUTTONS.NAVIGATION["width"];
local navButtonHeight = parameters.GRAPHICS.BUTTONS.NAVIGATION["height"];
local navButtonCorner = parameters.GRAPHICS.BUTTONS.NAVIGATION["corner_radius"];
local navButtonFontName = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_name"];
local navButtonFontSize = parameters.GRAPHICS.BUTTONS.NAVIGATION["font_size"];

function scene:create( event )
  	local group = self.view;

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
  	
  	textGroup = display.newGroup();
  	Foreground:insert(textGroup);
end

local function appCheckScene(params)
	logger.log("DRAWING APP CHECK SCENE...");
	
	local lineAText = "This version is no longer supported";
	local lineBText = "Please update to the latest version";
	local buttonText = "Update";
	
	local badVersionCode = nil;
	local badVersionReason = nil;
	
	if params ~= nil then
		logger.log("parameters ok");
		badVersionCode = params["code"];
		badVersionReason = params["reason"];
		
		if badVersionCode ~= nil then
			if badVersionCode == "server-error" then
				lineAText = "Server is currently unreachable";
				lineBText = "Please verify your connection";
				buttonText = "Close";
			elseif badVersionCode == "server-missing-response" then
				lineAText = "We can't verify your app right now";
				lineBText = "Please try again later";
				buttonText = "Close";
			elseif badVersionCode == "server-missing-message" then
				lineAText = "Sorry, our servers are currently";
				lineBText = "on maintenance. We'll be back soon!";
				buttonText = "Close";
			end
		end
    end
	
	local textLineA = textmaker.newText(lineAText,0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE);
  	textLineA:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	textLineA.anchorX = 0.5;
  	textLineA.anchorY = 0.5;
  	textLineA.x = _CX;
  	textLineA.y = _H*0.35;
  	
  	local textLineB = textmaker.newText(lineBText,0,0,{"roboto-bold"}, parameters.GRAPHICS.FONT_BASE_SIZE);
  	textLineB:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	textLineB.anchorX = 0.5;
  	textLineB.anchorY = 0.5;
  	textLineB.x = _CX;
  	textLineB.y = textLineA.y + textLineA.height + 2;
	
	local updateButtonOverColor = parameters.GRAPHICS.COLORS["button_update_over"];
  	local updateButtonActiveColor = parameters.GRAPHICS.COLORS["button_update_active"];
  	local updateButtonTextColor = parameters.GRAPHICS.COLORS["button_update_text"];
  	
  	local updateButtonGroup = display.newGroup();
  	
  	local updateButtonBg = display.newRoundedRect( 0, 0, navButtonWidth, navButtonHeight, navButtonCorner );
  	updateButtonBg:setFillColor(updateButtonOverColor[1],updateButtonOverColor[2],updateButtonOverColor[3]);
  	updateButtonBg.anchorX = 0.5;
  	updateButtonBg.anchorY = 0.5;
  	updateButtonBg.x = _CX;
  	updateButtonBg.y = textLineB.y + textLineB.height + navButtonHeight*0.5 + 4;
  	
  	local updateButtonText = textmaker.newText(buttonText,0,0,{navButtonFontName}, navButtonFontSize);
  	updateButtonText:setFillColor(updateButtonTextColor[1],updateButtonTextColor[2],updateButtonTextColor[3]);
  	updateButtonText.anchorX = updateButtonBg.anchorX;
  	updateButtonText.anchorY = updateButtonBg.anchorY;
  	updateButtonText.x = updateButtonBg.x;
  	updateButtonText.y = updateButtonBg.y;
  	
  	local function onUpdate(event)
  		if ( "began" == event.phase) then
  			updateButtonBg:setFillColor(updateButtonActiveColor[1],updateButtonActiveColor[2],updateButtonActiveColor[3]);
		elseif ( "ended" == event.phase ) then
			updateButtonBg:setFillColor(updateButtonOverColor[1],updateButtonOverColor[2],updateButtonOverColor[3]);
			logger.log("UPDATE BUTTON PRESSED!");
			
			if badVersionCode == "server-error" then
				os.exit();
			else
				local targetURL = parameters.EXTERNAL.UPDATE_URL_DEFAULT;
				if device.platform == "ios" then
					targetURL = parameters.EXTERNAL.UPDATE_URL_IOS;
				elseif device.platform == "android" then
					targetURL = parameters.EXTERNAL.UPDATE_URL_ANDROID;
				end
			end
			
			system.openURL( targetURL );
		end
  	end
  	
  	local updateButtonAction = widget.newButton {
		width = navButtonWidth,
		height = navButtonHeight,
		label = "",
		defaultFile = "media/images/transparent.png",
		overFile = "media/images/transparent.png",
		onEvent = onUpdate
	};
	updateButtonAction.anchorX = updateButtonText.anchorX;
  	updateButtonAction.anchorY = updateButtonText.anchorX;
  	updateButtonAction.x = updateButtonText.x;
  	updateButtonAction.y = updateButtonText.y;
  	
  	updateButtonGroup:insert(updateButtonBg);
  	updateButtonGroup:insert(updateButtonText);
  	updateButtonGroup:insert(updateButtonAction);
	
  	
  	textGroup:insert(textLineA);
  	textGroup:insert(textLineB);
  	textGroup:insert(updateButtonGroup);
end

function scene:show( event )
    local phase = event.phase;

    if ( phase == "will" ) then
    	if textGroup ~= nil then
    		for j=textGroup.numChildren, 1, -1 do
    			local dObj = textGroup[textGroup.numChildren];
				dObj:removeSelf();
				dObj = nil
			end
    	end
    	
    	local params = event.params;
    	
    	if params ~= nil then
    		local pageSource = params["source"];
    		if pageSource ~= nil then
    			if pageSource == "app-check" then
    				appCheckScene(params);
    			else
    				logger.log("Unknown action required source: "..tostring(pageSource));
    			end
    		else
    			logger.log("Unknown action required no source");
    		end
    	else
    		logger.log("Action required: no parameters");
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