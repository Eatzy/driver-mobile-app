-- Create base array
application = {};
application.launchPad = false;
-- content
application.content = {};
application.content.width = 320;
application.content.height = 320 * display.pixelHeight/display.pixelWidth;
application.content.xAlign = "center";
application.content.yAlign = "center";
application.content.scale = "letterBox";
-- image scaling
application.content.imageSuffix = {};
application.content.imageSuffix["@2x"] = 1.5; -- for iPhone, iPod touch, iPad1, and iPad2
application.content.imageSuffix["@4x"] = 3; -- for iPad 3
-- notifications
application.notification = {};
application.notification.iphone = {};
application.notification.iphone.types = { "badge", "sound", "alert" };
application.notification.google = {};
application.notification.google.projectNumber = "8967377732";