-- Catch launch parameters (notifications, etc...)
local launchArgs = ...

device = require ("app.utils.device")
parameters = require ("app.config.parameters")
logger = require ("app.utils.logger")
utils = require ("app.utils.utils")
textmaker = require ("app.utils.textmaker")
pushnotification = require ("app.utils.pushnotifications")
gpshelper = require ("app.utils.gpshelper")
menunu = require ("app.core.menunu")
storage = require ("app.core.storage")
openudid = require ("app.utils.openudid")
analytics = require ("app.core.analytics")

local _W = display.contentWidth;
local _H = display.contentHeight;
local _CX = _W*0.5;
local _CY = _H*0.5;

-- Some initial settings
display.setStatusBar( display.HiddenStatusBar );
if parameters.GENERAL.LOG_ENABLED == true then
  io.output():setvbuf('no'); -- print output on device
end

local function unhandledErrorListener( event )
    local handledError = true;
 
    if handledError then
        logger.log( "Handling the unhandled error: "..tostring(event.errorMessage));
    else
    	logger.log( "Not handling the unhandled error: "..tostring(event.errorMessage));
    end
    
    return handledError;
end
Runtime:addEventListener("unhandledError", unhandledErrorListener);

-- Init modules
storage.init();
menunu.init();
textmaker.init();
analytics.init();
pushnotification.init();

if launchArgs ~= nil then
	if parameters.GENERAL.LOG_ENABLED == true then
		utils.printTable(launchArgs);
	end

	if launchArgs.notification ~= nil then
		-- handle notification
		pushnotification.manageNotification( launchArgs.notification );
	end
end

-- Fonts
textmaker.addFont("roboto-regular",{ios="Roboto-Regular",android="Roboto-Regular"});
textmaker.addFont("roboto-italic",{ios="Roboto-Italic",android="Roboto-Italic"});
textmaker.addFont("roboto-black",{ios="Roboto-Black",android="Roboto-Black"});
textmaker.addFont("roboto-black-italic",{ios="Roboto-BlackItalic",android="Roboto-BlackItalic"});
textmaker.addFont("roboto-bold",{ios="Roboto-Bold",android="Roboto-Bold"});
textmaker.addFont("roboto-bold-italic",{ios="Roboto-BoldItalic",android="Roboto-BoldItalic"});
textmaker.addFont("roboto-thin",{ios="Roboto-Thin",android="Roboto-Thin"});
textmaker.addFont("roboto-thin-italic",{ios="Roboto-ThinItalic",android="Roboto-ThinItalic"});
textmaker.addFont("roboto-light",{ios="Roboto-Light",android="Roboto-Light"});
textmaker.addFont("roboto-light-italic",{ios="Roboto-LightItalic",android="Roboto-LightItalic"});
textmaker.addFont("roboto-medium",{ios="Roboto-Medium",android="Roboto-Medium"});
textmaker.addFont("roboto-medium-italic",{ios="Roboto-MediumItalic",android="Roboto-MediumItalic"});

-- Default background
local backgroundBox = display.newRect(0,0,_W,_H);
backgroundBox:setFillColor(parameters.GRAPHICS.COLORS["background"][1],parameters.GRAPHICS.COLORS["background"][2],parameters.GRAPHICS.COLORS["background"][3]);
backgroundBox.anchorX = 0.5;
backgroundBox.anchorY = 0.5;
backgroundBox.x = _CX;
backgroundBox.y = _CY;

local function checkGlobals()
	local count = 0;
	local list = {};
	for k,v in pairs(_G) do
		count = count+1;
		list[count] = k;
	end
	table.sort(list);

	print("Total global variables: #"..count);
	for i=1, #list do
		print("Global Variable ----> "..list[i]);
	end
end

-- local checkGlobalsTimer = timer.performWithDelay(10000, checkGlobals, -1);

local composer = require( "composer" );
composer.gotoScene("app.scenes.loading");
