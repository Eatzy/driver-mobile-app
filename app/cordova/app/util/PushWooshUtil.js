/**  Add this util on project and call registeredDevice() function after login 
  *  Used to maintain all PushWoosh functionality.
**/
Ext.define('Eatzy.util.PushWooshUtil',{
	
	singleton:true,
	
	config : {
	   tagName:'fb_id',
	   tagId:'',					//ex login user ID
	   projectId:'1043646173488',	//android project ID
	   appId:'6506D-D3E4C',			//pushwoosh app ID
	   appName:'ProjectName',		//pushwoosh app name for ios
	   pushNotificationObj:''
	},
	
	constructor : function(config) {
        this.initConfig(config);
        this.callParent([config]);
    },
    
	
    /**
     * Function: used to register device for PushWoosh
     */
    registeredDevice:function(){
    	var me = this;
    	if(window.plugins){
	        var pushNotification = window.plugins.pushNotification;
	        me.setPushNotificationObj(pushNotification);
	        try{
	            if(Ext.os.is.Android){
	                pushNotification.registerAndroidDevice({ projectid: me.getProjectId, pw_appid : me.getAppId()},
	                	me.registeredSuccessCallback(),
	                	me.registeredErrorCallback()
	                );
	            }else if(Ext.os.is.iOS){
		            pushNotification.onDeviceReady({alert:true, badge:true, sound:true, pw_appid: me.getAppId(), appname:me.getAppName()});
		            pushNotification.registerIOSDevice(
		            	me.registeredSuccessCallback(),
	                	me.registeredErrorCallback()
		            );
	            }
	        }catch(e){
	            console.log("in catch error=="+e.message);
	        }
    	}
     },
     
     registeredSuccessCallback:function(status){
    	 var me = this;
         console.log('push token: ' +status);
         me.tagDevice();
     },
     
     registeredErrorCallback:function(status){
    	 console.log('failed to register : '+JSON.stringify(status));
     },
     
     /**
      * Function: used to tag Device on pushWoosh
      * */
     tagDevice:function(){
    	 var me = this;
    	 var pushNotification = me.getPushNotificationObj();
    	 var tagName = me.getTagName();
    	 var tagId = me.getTagId();
    	 
    	 pushNotification.setTags({tagName:tagId},
            function(status) {
               console.log('Set tags successfully.');
            },
            function(status) {
               console.log('error while tagging: '+status);
            }
        );
     },
     
     /**
      * Function: used to unregistered Device from pushWoosh
	  * call this on logout
      * */
     unregisteredDevice:function(){
    	 if(window.plugins){
    		 var pushNotification = window.plugins.pushNotification;
	         pushNotification.unregisterDevice(function(token) {
	             console.log('Device is Unregistered :- ',token);
	         },
	         function(status) {
	        	 console.log('failed to unregister ',status);
	         });
    	 }
     },
     
     /**
      * Function: used to check pushWoosh is received or not
      * EX:: checkPushWooshNotification(
      * 		function(success) {console.log('success',success);},
      * 		function(error) {console.log('error',error);}
      * 	 );
      * */
     checkPushWooshNotification:function(successCallback,errorCallback){
    	Ext.Viewport.unmask();
      	Ext.Viewport.setMasked({xtype:'loadmask',message:'Loading...', indicator:true});
  		cordova.exec(successCallback, errorCallback,"PushWooshNotification","notificationReceiver",[]);
     },
	 
	 /**
      * Function: add pushWoosh notification event listener
	  * EX:: call this on deviceReady in app.js launch function.
	  * document.addEventListener('deviceready', ProjectName.util.PushWooshUtil.pushNotificationEventListener, false);
      * */
	pushNotificationEventListener:function(){
		var me = this;
    	document.addEventListener('push-notification', function(event) {
            console.log("in a pushNotification.");
	      	var notification = event.notification;
	      	console.log("notification",notification);
			if (Ext.os.is('Android')) {
				navigator.notification.vibrate(2000);
			}else if(Ext.os.is.iOS){
				navigator.notification.vibrate(2000);
				navigator.notification.confirm(
					notification.aps.alert,  	// message
					me.alertDismissed,          // callback
					'Title',            		// title
					['Cancel','OK']             // buttonName
				);
			}
    	},false);
	},
	
	alertDismissed: function(){
        console.log("notification alert callback....");
    }
});