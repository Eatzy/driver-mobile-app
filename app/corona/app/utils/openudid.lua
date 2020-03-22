local M = {};

local crypto = require("crypto");

local initialized;
local UDID;

M.init = function ()
  if initialized ~= true then
  
    local filePath = system.pathForFile( "device.genid", system.DocumentsDirectory );
    local rfile = io.open( filePath, "r" );
    
    if rfile ~= nil then
      UDID = rfile:read( "*a" );
      io.close( rfile );
      rfile = nil;
    end
    
    if UDID == nil then
      local udidSeed = system.getInfo("deviceID");
      if device.platform == "ios" then
        local trackingEnabled = system.getInfo( "iosAdvertisingTrackingEnabled" );
        if trackingEnabled == true and system.getInfo( "iosAdvertisingIdentifier" ) ~= nil then
          udidSeed = system.getInfo( "iosAdvertisingIdentifier" );
        end
      end
  
      if udidSeed == nil then
        udidSeed = tostring(device.model).."_"..tostring(device.architectureInfo).."_";
        for i=1, 8 do
          local sDigit = math.max(0,math.min(9,math.random(9)));
          udidSeed = udidSeed .. tostring(sDigit);
        end
      end
  
      UDID = string.sub(crypto.digest( crypto.sha1, udidSeed ), -12);
      local code = parameters.VERIFICATION.DEVICE[math.random(#parameters.VERIFICATION.DEVICE)];
      UDID = UDID .. tostring(code);
  
      local wfile = io.open( filePath, "w" );
      wfile:write( UDID );
      io.close( wfile );
      wfile = nil;
    end
    
    logger.log("UDID is "..tostring(UDID));

    initialized = true;
  end
end

M.getValue = function ()
  if initialized ~= true then
    M.init();
  end

  return UDID;
end

M.setOptOut = function (optingOut)
  if initialized ~= true then
    M.init();
  end

  -- TODO
end

return M;