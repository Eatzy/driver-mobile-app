local M = {};

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

M.newLoader = function (params)
	local onRepeatCb = nil;
	local onStartCb = nil;
	local onStopCb = nil;
	
	local loadingAnimation = nil;
	-- local loaderStarted = false;
	
	local loaderWidth = _W;
	local loaderHeight = _H;
	local loaderText = nil;
	local loaderBgColor = parameters.GRAPHICS.COLORS["background"];
	
	if params ~= nil then
		if params["width"] ~= nil then loaderWidth = params["width"]; end
		if params["height"] ~= nil then loaderHeight = params["height"]; end
		if params["text"] ~= nil then loaderText = params["text"]; end
		if params["bgcolor"] ~= nil then loaderBgColor = params["bgcolor"]; end
	end

	local loader = display.newGroup();
	loader.started = false;
	
	local backgroundBox = display.newRect(0,0,loaderWidth,loaderHeight);
  	backgroundBox:setFillColor(loaderBgColor[1],loaderBgColor[2],loaderBgColor[3]);
  	backgroundBox.anchorX = 0.5;
  	backgroundBox.anchorY = 0.5;
  	backgroundBox.x = loaderWidth*0.5;
  	backgroundBox.y = loaderHeight*0.5;
  	loader:insert(backgroundBox);

  	local loadingIcon = display.newImageRect("media/images/icons/spinner.png",32,32);
    loadingIcon:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
    loadingIcon.anchorX = 0.5;
    loadingIcon.anchorY = 0.5;
    loadingIcon.x = backgroundBox.x;
	loadingIcon.y = backgroundBox.y;
	loadingIcon.alpha = 1.0;
	loader:insert(loadingIcon);
	
	local defaultText = parameters.GRAPHICS.TEXT["loading"];
	if loaderText ~= nil then
		defaultText = loaderText;
	end
	
	local loadingText = textmaker.newText(defaultText,0,0,{"roboto-regular"}, parameters.GRAPHICS.FONT_BASE_SIZE);
  	loadingText:setFillColor(parameters.GRAPHICS.COLORS["main_text"][1],parameters.GRAPHICS.COLORS["main_text"][2],parameters.GRAPHICS.COLORS["main_text"][3]);
  	loadingText.anchorX = 0.5;
  	loadingText.anchorY = 0.5;
  	loadingText.x = loadingIcon.x;
  	loadingText.y = loadingIcon.y + loadingIcon.height;
  	loader:insert(loadingText);
	
	local touchOverlayListener = function ( event )
		if loader.started == true then
			native.setKeyboardFocus( nil ); -- if keyboard is on focus
			return true;
		else
			return false;
		end
	end
	
	loader.initialize = function (config)
		if config ~= nil then
			onStartCb = config["onStart"];
			onStopCb = config["onStop"];
			onRepeatCb = config["onRepeat"];
		end
		
		if loadingAnimation ~= nil then
			transition.cancel(loadingAnimation);
			loadingAnimation = nil;
		end
		
		loader.started = false;
		loader.alpha = 0.0;
		
		if loaderText == nil then
			loadingText.alpha = 0.0;
		end
	end
	
	loader.start = function ()
		if loader.started ~= true then
			if onStartCb ~= nil then
				onStartCb();
			end
			
			if loadingAnimation ~= nil then
				transition.cancel(loadingAnimation);
				loadingAnimation = nil;
			end
			
			if loaderText ~= nil then
				loadingText.alpha = 1.0;
			end
			
			loadingIcon.rotation = 0.0;
			loader.alpha = 1.0;
			loadingAnimation = transition.to( loadingIcon, { time=400, rotation=90, transition=easing.inOutQuad, iterations=-1, onRepeat=onRepeatCb } )


			backgroundBox:addEventListener( "touch", touchOverlayListener );
			
			loader.started = true;
		end
	end
	
	loader.stop = function ()
		if loader.started == true then
			if onStopCb ~= nil then
				onStopCb();
			end
			
			backgroundBox:removeEventListener( "touch", touchOverlayListener );
		
			loader.alpha = 0.0;
			loadingText.alpha = 0.0;
			
			if loadingAnimation ~= nil then
				transition.cancel(loadingAnimation);
				loadingAnimation = nil;
			end
			
			loader.started = false;
		end
	end
	
	loader.setText = function (text)
		if text ~= nil then
			loadingText.text = text;
		else
			loadingText.alpha = 0.0;
		end
	end
	
	return loader;
end

return M;