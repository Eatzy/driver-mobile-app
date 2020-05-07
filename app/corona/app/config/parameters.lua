local M = {};

local crypto = require("crypto");

-- General
M.GENERAL = {};
M.GENERAL.DEV = false;
M.GENERAL.ADHOC = false;
M.GENERAL.LOG_ENABLED = false; -- enable logs and console output both on simulator and devices
M.GENERAL.VERSION = "1.7.2";
M.GENERAL.BUILD = "107002";

-- Graphics
M.GRAPHICS = {};

M.GRAPHICS.FONT_BASE_SIZE = 17;
M.GRAPHICS.FONT_MESSAGE_BUBBLE_SIZE = 16;

M.GRAPHICS.BUTTONS = {};
M.GRAPHICS.BUTTONS.NAVIGATION = {};
M.GRAPHICS.BUTTONS.NAVIGATION["width"] = display.contentWidth*0.95;
M.GRAPHICS.BUTTONS.NAVIGATION["height"] = display.contentHeight*0.08;
M.GRAPHICS.BUTTONS.NAVIGATION["corner_radius"] = 6;
M.GRAPHICS.BUTTONS.NAVIGATION["font_name"] = "roboto-bold";
M.GRAPHICS.BUTTONS.NAVIGATION["font_size"] = M.GRAPHICS.FONT_BASE_SIZE*1.25;

M.GRAPHICS.COLORS = {};

M.GRAPHICS.COLORS["eatzydriver_colorscheme_01"] = {(30/255),(133/255),(149/255)};
M.GRAPHICS.COLORS["eatzydriver_colorscheme_02"] = {(102/255),(102/255),(102/255)};
M.GRAPHICS.COLORS["eatzydriver_colorscheme_03"] = {(255/255),(255/255),(255/255)};
M.GRAPHICS.COLORS["eatzydriver_colorscheme_04"] = {(67/255),(67/255),(67/255)};
M.GRAPHICS.COLORS["eatzydriver_colorscheme_05"] = {(251/255),(154/255),(2/255)};

M.GRAPHICS.COLORS["flatdesign_colorscheme_01"] = {(52/255),(152/255),(219/255)};
M.GRAPHICS.COLORS["flatdesign_colorscheme_02"] = {(222/255),(215/255),(205/255)};
M.GRAPHICS.COLORS["flatdesign_colorscheme_03"] = {(26/255),(188/255),(186/255)};
M.GRAPHICS.COLORS["flatdesign_colorscheme_04"] = {(222/255),(215/255),(205/255)};
M.GRAPHICS.COLORS["flatdesign_colorscheme_05"] = {(52/255),(73/255),(94/255)};

M.GRAPHICS.COLORS["background"] = M.GRAPHICS.COLORS["eatzydriver_colorscheme_04"]; -- main background color
M.GRAPHICS.COLORS["main_text"] = M.GRAPHICS.COLORS["eatzydriver_colorscheme_03"]; -- main text color
M.GRAPHICS.COLORS["cell_odd"] = {((189+25)/255),((195+25)/255),((199+25)/255)}; -- odd cell color
M.GRAPHICS.COLORS["cell_even"] = {((189+10)/255),((195+10)/255),((199+10)/255)}; -- even cell color

M.GRAPHICS.COLORS["bubble_local_bg"] = {(225/255),(255/255),(200/255)}; -- bubble local bg color
M.GRAPHICS.COLORS["bubble_remote_bg"] = {(255/255),(255/255),(255/255)}; -- bubble remote bg color
M.GRAPHICS.COLORS["bubble_text"] = {(0/255),(0/255),(0/255)}; -- bubble text color
M.GRAPHICS.COLORS["bubble_sender"] = {(50/255),(180/255),(240/255)}; -- bubble sender color
M.GRAPHICS.COLORS["bubble_timestamp"] = M.GRAPHICS.COLORS["background"]; -- bubble timestamp color

M.GRAPHICS.COLORS["background_orders"] = M.GRAPHICS.COLORS["background"]; -- orders background color
M.GRAPHICS.COLORS["background_chat"] = M.GRAPHICS.COLORS["background"]; -- orders background color
M.GRAPHICS.COLORS["background_directions"] = M.GRAPHICS.COLORS["background"]; -- orders background color
M.GRAPHICS.COLORS["background_settings"] = M.GRAPHICS.COLORS["background"]; -- orders background color
M.GRAPHICS.COLORS["countdown_good"] = {(0/255),(255/255),(0/255)}; -- orders countdown good color
M.GRAPHICS.COLORS["countdown_warning"] = {(255/255),(255/255),(0/255)}; -- orders countdown warning color
M.GRAPHICS.COLORS["countdown_late"] = {(255/255),(0/255),(0/255)}; -- orders countdown late color
M.GRAPHICS.COLORS["button_navigation_text"] = M.GRAPHICS.COLORS["background"]; -- navigation button text color
M.GRAPHICS.COLORS["button_navigation_over"] = {(255/255),(255/255),(255/255)}; -- navigation button over color
M.GRAPHICS.COLORS["button_navigation_active"] = {M.GRAPHICS.COLORS["button_navigation_over"][1]*0.9,M.GRAPHICS.COLORS["button_navigation_over"][2]*0.9,M.GRAPHICS.COLORS["button_navigation_over"][3]*0.9}; -- navigation button active color
M.GRAPHICS.COLORS["button_login_over"] = {(39/255),(174/255),(96/255)};
M.GRAPHICS.COLORS["button_login_active"] = {M.GRAPHICS.COLORS["button_login_over"][1]*0.9,M.GRAPHICS.COLORS["button_login_over"][2]*0.9,M.GRAPHICS.COLORS["button_login_over"][3]*0.9};
M.GRAPHICS.COLORS["button_login_text"] = {(255/255),(255/255),(255/255)};
M.GRAPHICS.COLORS["button_logout_over"] = {(192/255),(57/255),(43/255)};
M.GRAPHICS.COLORS["button_logout_active"] = {M.GRAPHICS.COLORS["button_logout_over"][1]*0.9,M.GRAPHICS.COLORS["button_logout_over"][2]*0.9,M.GRAPHICS.COLORS["button_logout_over"][3]*0.9};
M.GRAPHICS.COLORS["button_logout_text"] = M.GRAPHICS.COLORS["button_login_text"];
M.GRAPHICS.COLORS["button_register_over"] = {(41/255),(128/255),(185/255)};
M.GRAPHICS.COLORS["button_register_active"] = {M.GRAPHICS.COLORS["button_register_over"][1]*0.9,M.GRAPHICS.COLORS["button_register_over"][2]*0.9,M.GRAPHICS.COLORS["button_register_over"][3]*0.9};
M.GRAPHICS.COLORS["button_register_text"] = M.GRAPHICS.COLORS["button_login_text"];
M.GRAPHICS.COLORS["button_clockin_over"] = {(230/255),(126/255),(34/255)};
M.GRAPHICS.COLORS["button_clockin_active"] = {M.GRAPHICS.COLORS["button_clockin_over"][1]*0.9,M.GRAPHICS.COLORS["button_clockin_over"][2]*0.9,M.GRAPHICS.COLORS["button_clockin_over"][3]*0.9};
M.GRAPHICS.COLORS["button_clockin_text"] = M.GRAPHICS.COLORS["button_login_text"];
M.GRAPHICS.COLORS["button_clockout_over"] = M.GRAPHICS.COLORS["button_clockin_over"];
M.GRAPHICS.COLORS["button_clockout_active"] = {M.GRAPHICS.COLORS["button_clockout_over"][1]*0.9,M.GRAPHICS.COLORS["button_clockout_over"][2]*0.9,M.GRAPHICS.COLORS["button_clockout_over"][3]*0.9};
M.GRAPHICS.COLORS["button_clockout_text"] = M.GRAPHICS.COLORS["button_login_text"];
M.GRAPHICS.COLORS["button_action_over"] = {(0/255),(255/255),(0/255)}; -- navigation button over color
M.GRAPHICS.COLORS["button_action_active"] = {M.GRAPHICS.COLORS["button_action_over"][1]*0.9,M.GRAPHICS.COLORS["button_action_over"][2]*0.9,M.GRAPHICS.COLORS["button_action_over"][3]*0.9};
M.GRAPHICS.COLORS["button_update_over"] = {(39/255),(174/255),(96/255)};
M.GRAPHICS.COLORS["button_update_active"] = {M.GRAPHICS.COLORS["button_update_over"][1]*0.9,M.GRAPHICS.COLORS["button_update_over"][2]*0.9,M.GRAPHICS.COLORS["button_update_over"][3]*0.9};
M.GRAPHICS.COLORS["button_update_text"] = M.GRAPHICS.COLORS["button_login_text"];

M.GRAPHICS.ORDERS = {};
M.GRAPHICS.ORDERS.COLORS = {};

local darkeningRatio = 0.75;
M.GRAPHICS.ORDERS.COLORS["init"] = {(250/255)*darkeningRatio,(250/255)*darkeningRatio,(250/255)*darkeningRatio}; -- order init color
M.GRAPHICS.ORDERS.COLORS["assign"] = {(239/255)*darkeningRatio,(196/255)*darkeningRatio,(49/255)*darkeningRatio}; -- order assign color
M.GRAPHICS.ORDERS.COLORS["placing"] = {(104/255)*darkeningRatio,(142/255)*darkeningRatio,(44/255)*darkeningRatio}; -- order placing color
M.GRAPHICS.ORDERS.COLORS["placed"] = {(160/255)*darkeningRatio,(197/255)*darkeningRatio,(234/255)*darkeningRatio}; -- order placed color
M.GRAPHICS.ORDERS.COLORS["enroute"] = {(163/255)*darkeningRatio,(0/255)*darkeningRatio,(163/255)*darkeningRatio}; -- order en route color
M.GRAPHICS.ORDERS.COLORS["atdropoff"] = {(163/255)*darkeningRatio,(0/255)*darkeningRatio,(163/255)*darkeningRatio}; -- order en route color
M.GRAPHICS.ORDERS.COLORS["delivered"] = {(204/255)*darkeningRatio,(204/255)*darkeningRatio,(204/255)*darkeningRatio}; -- order delivered color

M.GRAPHICS.ORDERS.ACTIONS = {};
M.GRAPHICS.ORDERS.ACTIONS.COLORS = {};
M.GRAPHICS.ORDERS.ACTIONS.COLORS["confirm"] = {(39/255),(174/255),(96/255)};
M.GRAPHICS.ORDERS.ACTIONS.COLORS["atrestaurant"] = {(160/255),(197/255),(234/255)};
M.GRAPHICS.ORDERS.ACTIONS.COLORS["enroute"] = {(163/255),(0/255),(163/255)};
M.GRAPHICS.ORDERS.ACTIONS.COLORS["atdropoff"] = {(163/255),(0/255),(163/255)};
M.GRAPHICS.ORDERS.ACTIONS.COLORS["delivered"] = {(204/255),(204/255),(204/255)};

M.GRAPHICS.TEXT = {};
M.GRAPHICS.TEXT["username"] = "Username";
M.GRAPHICS.TEXT["password"] = "Password";
M.GRAPHICS.TEXT["login"] = "Sign In";
M.GRAPHICS.TEXT["logout"] = "Logout";
M.GRAPHICS.TEXT["register"] = "Become a Driver";
M.GRAPHICS.TEXT["clockin"] = "Clock In";
M.GRAPHICS.TEXT["clockout"] = "Clock Out";
M.GRAPHICS.TEXT["clockheading"] = "You are going to clock in for";
M.GRAPHICS.TEXT["orders"] = "GET ORDERS";
M.GRAPHICS.TEXT["loading"] = "Loading ...";
M.GRAPHICS.TEXT["loading_orders"] = "Getting assigned orders ...";
M.GRAPHICS.TEXT["back"] = "Back";
M.GRAPHICS.TEXT["send"] = "Send";
M.GRAPHICS.TEXT["you"] = "Me";
M.GRAPHICS.TEXT["section_in_progress"] = "This section will be available soon";
M.GRAPHICS.TEXT["clockout_header"] = "Tap the button to clock out";
M.GRAPHICS.TEXT["logout_header"] = "Tap the button to log out";
M.GRAPHICS.TEXT["tos_button"] = "Terms of Use";
M.GRAPHICS.TEXT["pp_button"] = "Privacy Policy";
M.GRAPHICS.TEXT["alert_ok"] = "OK";
M.GRAPHICS.TEXT["alert_cancel"] = "Cancel";
M.GRAPHICS.TEXT["logout_alert_title"] = "Logout";
M.GRAPHICS.TEXT["logout_alert_body"] = "Do you want to logout?";
M.GRAPHICS.TEXT["clockin_alert_title"] = "Clock In";
M.GRAPHICS.TEXT["clockin_alert_body"] = "Confirm to clock in?";
M.GRAPHICS.TEXT["clockout_alert_title"] = "Clock Out";
M.GRAPHICS.TEXT["clockout_alert_body"] = "Confirm to clock out?";

-- Notifications
M.GOOGLE_PLAY_PROJECT_NUMBER = "8967377732";
M.ONESIGNAL_APP_ID = "c5dde36d-d463-4435-b297-90fd804dc1a3";

-- Server
M.SERVER = {};
M.SERVER.API_VERSION = "1.0";
M.SERVER.GPS_SERVER_UPDATE_PERIOD = 30; -- in seconds
M.SERVER.ORDERS_REQUEST_PERIOD = 60; -- in seconds
M.SERVER.MESSAGES_REQUEST_PERIOD = 5; -- in seconds

-- Maps
M.MAPS = {};
M.MAPS.DIRECTIONS = {};
M.MAPS.DIRECTIONS.REFRESH_PERIOD = 500; -- in milliseconds

-- Force driver position
M.DRIVERS = {};
M.DRIVERS.FORCE_POSITION = false;
M.DRIVERS.FORCED_POSITION = {};
-- point A - Denver
--[[M.DRIVERS.FORCED_POSITION.LATITUDE = 39.68571;
M.DRIVERS.FORCED_POSITION.LONGITUDE = -104.91285;
M.DRIVERS.FORCED_POSITION.ALTITUDE = 1648.8;--]]
-- point B - Denver
--[[M.DRIVERS.FORCED_POSITION.LATITUDE = 39.70295;
M.DRIVERS.FORCED_POSITION.LONGITUDE = -104.95000;
M.DRIVERS.FORCED_POSITION.ALTITUDE = 1635.1; --]]
-- point C - Denver
--[[M.DRIVERS.FORCED_POSITION.LATITUDE = 39.71576;
M.DRIVERS.FORCED_POSITION.LONGITUDE = -104.98032;
M.DRIVERS.FORCED_POSITION.ALTITUDE = 1612.2; --]]

M.DRIVERS.WARNING_TIME_COUNTER = 60*10;
M.DRIVERS.LATE_TIME_COUNTER = 0;
M.DRIVERS.WARNING_DELIVERY_RUN_EVENT = 60*5;
M.DRIVERS.LATE_DELIVERY_RUN_EVENT = 0;

if device.platform ~= "simulator" then
	M.DRIVERS.FORCE_POSITION = false;
	
	if M.GENERAL.DEV ~= true then
		M.SERVER.API_BASE_URL = "https://api.eatzy.com/mobile"; -- production
	else
		M.SERVER.API_BASE_URL = "https://api.eatsy.net/mobile"; -- development
		-- M.SERVER.API_BASE_URL = "http://upcloudapi.eatsy.net/mobile"; -- upcloud
	end
else
	M.SERVER.API_BASE_URL = "http://api.eatsy.local:8080/mobile"; -- local testing
	-- M.SERVER.API_BASE_URL = "https://api.eatsy.net/mobile"; -- development
	-- M.SERVER.API_BASE_URL = "https://api.eatzy.com/mobile"; -- production
	-- M.SERVER.API_BASE_URL = "http://upcloudapi.eatsy.net/mobile"; -- upcloud
end

M.SERVER.NEW_ACCOUNT_URL = "http://tiny.cc/eatzysignup";
M.SERVER.TOS_URL = "http://tiny.cc/eatzytos";
M.SERVER.PRIVACY_URL = "http://tiny.cc/eatzypp";

M.SERVER.API_URL_PUSH_REGISTRATION = M.SERVER.API_BASE_URL .. "/push/register";
M.SERVER.API_URL_UPDATE_POSITION = M.SERVER.API_BASE_URL .. "/position";
M.SERVER.API_URL_DRIVER_LOGIN = M.SERVER.API_BASE_URL .. "/driver/login";
M.SERVER.API_URL_DRIVER_STATUS = M.SERVER.API_BASE_URL .. "/driver/status";
M.SERVER.API_URL_CLOCKING = M.SERVER.API_BASE_URL .. "/driver/clocking";
M.SERVER.API_URL_DRIVER_RUNS = M.SERVER.API_BASE_URL .. "/driver/runs";
M.SERVER.API_URL_DRIVER_LOGOUT = M.SERVER.API_BASE_URL .. "/driver/logout";
M.SERVER.API_URL_DRIVER_GET_MESSAGES = M.SERVER.API_BASE_URL .. "/driver/messages";
M.SERVER.API_URL_DRIVER_PUT_MESSAGES = M.SERVER.API_BASE_URL .. "/driver/messages";
M.SERVER.API_URL_DRIVER_ORDER = M.SERVER.API_BASE_URL .. "/driver/order";
M.SERVER.API_URL_APP_CHECK = M.SERVER.API_BASE_URL .. "/driver/appcheck";

if M.GENERAL.DEV ~= true then
	M.SERVER.ORDER_BASE_URL = "http://bos.eatzy.com/drvorder/";
else
	M.SERVER.ORDER_BASE_URL = "http://dev2.bos.eatsy.net/drvorder/";
end
M.SERVER.DRIVER_MESSAGE_DEFAULT_SUBJECT = "Driver App";

-- Sensors
M.SENSORS = {};
M.SENSORS.GPS_TIMEOUT = 10000;
M.SENSORS.ANDROID_GPS_CLOCK = 500;
M.SENSORS.INSTANT_PERIOD = 1000; -- in milliseconds
M.SENSORS.SHORT_PERIOD = 3000; -- in milliseconds
M.SENSORS.NORMAL_PERIOD = 6000; -- in milliseconds
M.SENSORS.LONG_PERIOD = 30000; -- in milliseconds
M.SENSORS.IGNORE_ACCELERATION_BELOW = 0.00001; -- absolute value
M.SENSORS.IGNORE_SPEED_BELOW = 5000/3600; -- absolute value
M.SENSORS.IGNORE_ACCELERATION_ABOVE = 0.01; -- absolute value
M.SENSORS.IGNORE_SPEED_ABOVE = 300000/3600; -- absolute value

-- External urls
M.EXTERNAL = {};
M.EXTERNAL.UPDATE_URL_DEFAULT = "http://tiny.cc/eatzymain";
M.EXTERNAL.UPDATE_URL_IOS = "http://tiny.cc/deatzyid";
M.EXTERNAL.UPDATE_URL_ANDROID = "http://tiny.cc/deatzyad";

-- Verification
-- Id Verification
M.VERIFICATION = {};

-- Device
local deviceSeeds = {"condimentum","praesent","pellentesque","elementum","sollicitudin","scelerisque","blandit","tincidunt","ullamcorper","suspendisse","malesuada","bibendum"};
local derivedSeeds = {};
for i=1, #deviceSeeds do
  derivedSeeds[#derivedSeeds+1] = deviceSeeds[i];
  derivedSeeds[#derivedSeeds+1] = string.reverse(deviceSeeds[i]);
  derivedSeeds[#derivedSeeds+1] = deviceSeeds[i] .. string.reverse(deviceSeeds[i]);
  derivedSeeds[#derivedSeeds+1] = string.reverse(deviceSeeds[i]) .. deviceSeeds[i];
end

M.VERIFICATION.DEVICE = {};
for i=1, #derivedSeeds do
  local seed = derivedSeeds[i];
  M.VERIFICATION.DEVICE [#M.VERIFICATION.DEVICE + 1] = string.sub(crypto.digest( crypto.sha1, seed ), -11, -3);
end

return M;
