/*
    This file is generated and updated by Sencha Cmd. You can edit this file as
    needed for your application, but these edits will have to be merged by
    Sencha Cmd when it performs code generation tasks such as generating new
    models, controllers or views and when running "sencha app upgrade".

    Ideally changes to this file would be limited and most work would be done
    in other places (such as Controllers). If Sencha Cmd cannot merge your
    changes and its generated code, it will produce a "merge conflict" that you
    will need to resolve manually.
*/

Ext.application({
    name: 'Eatzy',

    requires: [
        'Ext.MessageBox',
        'Ext.Toast',
        'Ext.device.Device',
        'Eatzy.util.CommonUtil',
        'Eatzy.util.ChatUtil',
        'Eatzy.util.PushWooshUtil',
        'Eatzy.util.GlobalUtil',
        'Eatzy.util.ExtendedPaintMonitor',
        'Eatzy.util.ExtendedSizeMonitor'
        
    ],
    /*
     * List of entities.
     */
     models: [
              	'LoginModel',
              	'ClockInOptionsModel',
              	'ChatFriendsModel',
              	'ChatModel',
              	'ChatScreenExitTimeModel',
              	'DeviceTokenModel'
             
     ],

    /*
     * List of store classes used in our application.
     */
     stores: [
            	 'LoginStore',
            	 'ClockInOptionsStore',
            	 'ChatFriendsStore',
            	 'ChatStore',
            	 'ChatScreenExitTimeStore',
            	 'DeviceTokenStore'
             
     ],

    /*
     * List of controller.
     */
     controllers: [
                   
	             'GenericController',
	             'LoginController',
	             'StatusController',
	             'ChatController',
	             'ExternalBrowserPageController'
     ],
    views: [
		        'Eatzy.view.LoginView',
		        'Eatzy.view.StatusView',
		        'Eatzy.view.BottomTabPanelView',
		        'Eatzy.view.widget.MessageBoxOverlay',
		        'ChatView',
		        'MenuButtonDropDownOverlayView',
		        'ExternalBrowserPageView'
    ],

    icon: {
        '57': 'resources/icons/Icon.png',
        '72': 'resources/icons/Icon~ipad.png',
        '114': 'resources/icons/Icon@2x.png',
        '144': 'resources/icons/Icon~ipad@2x.png'
    },

    isIconPrecomposed: true,

    startupImage: {
        '320x460': 'resources/startup/320x460.jpg',
        '640x920': 'resources/startup/640x920.png',
        '768x1004': 'resources/startup/768x1004.png',
        '748x1024': 'resources/startup/748x1024.png',
        '1536x2008': 'resources/startup/1536x2008.png',
        '1496x2048': 'resources/startup/1496x2048.png'
    },

    launch: function() {
    	 
    	//Ext.Msg.defaultAllowedConfig.showAnimation = false; // Added to fix, alert button not close message box issue
    	var me= this;
    	Eatzy.util.CommonUtil.getCurrentLatLong();
    	document.addEventListener('deviceready', me.onDeviceReady, false);
    	
    	//deviceId
        // Destroy the #appLoadingIndicator element
        
        Eatzy.util.GlobalUtil.setScreenWidth(Ext.Viewport.getWindowWidth());
        //Eatzy.util.GlobalUtil.setWindowHeight(Ext.Viewport.getWindowHeight());
        //var globalHeight = Ext.Viewport.getWindowHeight();
        Eatzy.util.GlobalUtil.setScreenHeight(Ext.Viewport.getWindowHeight());
        // Initialize the main view
       
        var loginStore = Ext.getStore('loginStoreId');
        if(loginStore.getAllCount() > 0){
        	 var bottomTabPanelView = Ext.create('Eatzy.view.BottomTabPanelView');
             Ext.Viewport.add(bottomTabPanelView);
             Ext.Viewport.setActiveItem(bottomTabPanelView);
             var clockedInData = Eatzy.util.CommonUtil.getDriverCheckInFlagData();
             
             if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
 	    		Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
 	    	 }
             Eatzy.util.CommonUtil.setIsStatusViewDisplay(false); 
             Ext.getCmp('mainTabPanel').setActiveItem(3); 
             var loginUserRecordObject = loginStore.getAt(0);
             Ext.ComponentQuery.query('button[name=ridersName]')[0].setText(loginUserRecordObject.get('rds_name').toUpperCase());
             var clockinStatus =  Eatzy.util.CommonUtil.getDriverCheckInFlagData();
             
             
        }else{
        	 Eatzy.util.CommonUtil.setIsStatusViewDisplay(false); 
        	 var LoginView = Ext.create('Eatzy.view.LoginView');
             Ext.Viewport.add(LoginView);
             Ext.Viewport.setActiveItem(LoginView);
             
        }
        
      
    },
    /**
     * success callback from native on receiving push notifications
    */
    onPushWooshNotificationsSuccessCallback: function(success){
        
        if(Ext.os.is.Android){
            if(success.success){
            	var loginStore = Ext.getStore('loginStoreId');
                if(loginStore.getAllCount() > 0){
                	 var bottomTabPanelView = Ext.create('Eatzy.view.BottomTabPanelView');
                     Ext.Viewport.add(bottomTabPanelView);
                     Ext.Viewport.setActiveItem(bottomTabPanelView);
                     var clockedInData = Eatzy.util.CommonUtil.getDriverCheckInFlagData();
                     
                     if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
         	    		Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
         	    	 }
                     Eatzy.util.CommonUtil.setIsStatusViewDisplay(false); 
                     Ext.getCmp('mainTabPanel').setActiveItem(3); 
                     var loginUserRecordObject = loginStore.getAt(0);
                     Ext.ComponentQuery.query('button[name=ridersName]')[0].setText(loginUserRecordObject.get('rds_name').toUpperCase());
                     var clockinStatus =  Eatzy.util.CommonUtil.getDriverCheckInFlagData();
                     
                     
                }else{
                	 Eatzy.util.CommonUtil.setIsStatusViewDisplay(false); 
                	 var LoginView = Ext.create('Eatzy.view.LoginView');
                     Ext.Viewport.add(LoginView);
                     Ext.Viewport.setActiveItem(LoginView);
                     
                }
                
            }else{
                Ext.Viewport.unmask();
                  console.log("In notification failure");
            }
        }else{
            Ext.Viewport.setMasked({xtype:'loadmask',message:'Loading...', indicator:true});
            me.redirectToMainScreen();
        }
    },
    
    /**
     * error callback from native on receiving push notifications
    */
    onPushWooshNotificationErrorCallback: function(error){
    	console.log(" error ",error);
        Ext.Viewport.unmask();
    	
    },
    onUpdated: function() {
        Ext.Msg.confirm(
            "Application Update",
            "This application has just successfully been updated to the latest version. Reload now?",
            function(buttonId) {
                if (buttonId === 'yes') {
                    window.location.reload();
                }
            }
        );
    },
    redirectToMainScreen:function(){
    	var loginStore = Ext.getStore('loginStoreId');
        if(loginStore.getAllCount() > 0){
        	 var bottomTabPanelView = Ext.create('Eatzy.view.BottomTabPanelView');
             Ext.Viewport.add(bottomTabPanelView);
             Ext.Viewport.setActiveItem(bottomTabPanelView);
             var clockedInData = Eatzy.util.CommonUtil.getDriverCheckInFlagData();
             
             if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
 	    		Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
 	    	 }
             Eatzy.util.CommonUtil.setIsStatusViewDisplay(false); 
             Ext.getCmp('mainTabPanel').setActiveItem(3); 
             var loginUserRecordObject = loginStore.getAt(0);
             Ext.ComponentQuery.query('button[name=ridersName]')[0].setText(loginUserRecordObject.get('rds_name').toUpperCase());
             var clockinStatus =  Eatzy.util.CommonUtil.getDriverCheckInFlagData();
             
             
        }else{
        	 Eatzy.util.CommonUtil.setIsStatusViewDisplay(false); 
        	 var LoginView = Ext.create('Eatzy.view.LoginView');
             Ext.Viewport.add(LoginView);
             Ext.Viewport.setActiveItem(LoginView);
             
        }
    },

    onDeviceReady:function(){
    	   	
        var me = this;
      
        if (device) {
            var me = this;
            console.log("device ready");
            pushNotification = window.plugins.pushNotification;
            if (device.platform == 'android' || device.platform == 'Android' || device.platform == "amazon-fireos") {
            	Eatzy.util.CommonUtil.deviceRegisterationForPushNotification(device.platform);
            }else {
            	Eatzy.util.CommonUtil.deviceRegisterationForPushNotification('ios');
            }  
        } else {
        	var validationErrors = [];
	        validationErrors.push(txt)
            Eatzy.util.CommonUtil.showErrors(validationErrors);
        	
        }
        
        if (device.platform == 'android' || device.platform == 'Android' || device.platform == "amazon-fireos") { //changes for background mode in android devices
	        cordova.plugins.backgroundMode.enable();
	        //The title, ticker and text for that notification can be customized as follows
	        cordova.plugins.backgroundMode.setDefaults({
	            title:  "Drive Eatzy",
	            ticker: "Drive Eatzy app",
	            text:   "Running in background mode...",
	            image:'./www/resources/images/logo.png'
	        });
			
	        document.addEventListener("backbutton", function(e) {
	        cordova.plugins.backgroundMode.disable();
	        navigator.notification.confirm(
                'Do you want to quit ?\nNote: To minimize the app, please use home button on the device', 
                function(button){
                	if(button == "1"){
                        navigator.app.exitApp(); 
                    }
                	if(button == "2"){
                     	cordova.plugins.backgroundMode.enable();
                     }
                }, 
                'Drive Eatzy', 
                'OK,Cancel'  
            	);
	        }, 
	        true);
        }
    }
});

