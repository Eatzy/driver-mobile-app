/*
 * Created by 1010
 * July 6, 2015.
 * This controller contains methods related to sign in and sign out.
 */
Ext.define('Eatzy.controller.StatusController',{
    extend:'Eatzy.controller.GenericController',

    config:{
           
            refs: {
                        
                        
            },

            control:{
            	
                'button[name=commonButtonForSignInOut]':{
                    tap : 'redirectToLoginView'
                },
                'panel[name = statusView]':{
                    initialize:'onInitializeOfStatusView'
                }
                   
            },
            testObj:''
    },
    /*
     * This method used to show login screen on click of sign in button.
     */
    redirectToLoginView: function( button ){
    	var me = this;
    	 var clsArray=button.getCls();
    	 if(clsArray[0]=="signInButtonCls"){
    		 Eatzy.util.CommonUtil.showLoadMask();
		    //Do clock in user		
    		 me.doClockInUser();
    	 }
    	 if(clsArray[0]=="signOutButtonCls"){
    		 Eatzy.util.CommonUtil.showLoadMask();	
		         me.doClockOutUser();  
    	 }
    	 
     },
     /**
      * Function: To retrieve logged in clock user clock in options
      *
      * **/
     doClockInUser:function(){
    	 Eatzy.util.CommonUtil.periodicallyCheckInDriverCurrentDriversOrder(this,this.doClockIn);
		
          
     
     },
     /**
      * Function: To handle clock user clock in options
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
     onGetClockInOptionsSccuesscallback:function( serviceResponseStatus, responseData, currentObject ){
    	 
    	 var responseData = Ext.JSON.decode(responseData.responseText);
    	 if(responseData.error){
	    		Eatzy.util.CommonUtil.hideLoadMask();
     	    
	     	    
	 	        var validationErrors = [];
	            
	           
	            if(responseData!=undefined){
	           	       validationErrors.push(responseData.description);
			            if(responseData.description == "User is already clocked in."){
			            	Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("activeButtonCls");
				           	Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signOutButtonCls");
				           	Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("ACTIVE");
			            }else{
			            	Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
			            }
			            	
	            }else{
	            	validationErrors.push("No shifts data found.");
	            }
	            
                Eatzy.util.CommonUtil.showErrors(validationErrors);
     	    
    	 }else{
    		 var clockInOptionsStore = Ext.getStore('clockInOptionsStoreId');
        	 clockInOptionsStore.removeAll();
        	 
        	 clockInOptionsStore.setData(responseData);
        	 //Function to do clock in for user
        	 currentObject.toDoClockinUser(responseData);
        	 
        	 
    	 }
    	
	     
    	
     },
     /**
      * Function:To do clockin User
      * @param{responseData} : responseData this is the response of getClockedInoptions web service
      * */
     toDoClockinUser:function(responseData){
    	
    	 var loginStore = Ext.getStore('loginStoreId');
         var loginUserRecordObject = loginStore.getAt(0);
         
    	 var clockInOptionsStore = Ext.getStore('clockInOptionsStoreId');
	     var clockInOptionsRecordObject = clockInOptionsStore.getAt(0);
	     var requestUrl = Eatzy.util.GlobalUtil.getClockInUrl();
	     var paramsObject = '';
	     if(clockInOptionsRecordObject!=undefined){
	    	
    		 paramsObject = { 
 	      	          	'id' : loginUserRecordObject.get('userId'),
 	      	          	'token' : loginUserRecordObject.get('userToken'),
 	      	          	'request': requestUrl,
 	      	          	"shift": clockInOptionsRecordObject.get('selected').shift,
 	      	          	"office": clockInOptionsRecordObject.get('selected').office,
 	      	          	"territory": clockInOptionsRecordObject.get('selected').territory
 	      	            };
	    	 
	    	  if(clockInOptionsRecordObject.get('selected')!=null || clockInOptionsRecordObject.get('selected')!=undefined){
	        	  
	      	      this.commonWebServiceCall( 'POST', paramsObject, this.onDoClockInUserSuccesscallback, this );
	          }else{
	        	  	Eatzy.util.CommonUtil.hideLoadMask();
	        	   
	        	     var validationErrors = [];
	 	            responseData = Ext.JSON.decode(responseData.responseText);
	 	            if(responseData!=undefined){
	 	           	 validationErrors.push(responseData.description);
	 	            if(responseData.description=="User is already clocked in"){
	 	            	Eatzy.util.CommonUtil.setIsDriverClockIn(true);
	 	            	
	 	            	Eatzy.util.CommonUtil.setIsStatusViewDisplay(true);
	 	            	Ext.getCmp('mainTabPanel').setActiveItem(3);
	 	            }else{
	 	            	Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
	 	            }
	 	            	
	 	            }else{
	 	           	 validationErrors.push("No shifts data found.");
	 	            }
	 	             
	 	             Eatzy.util.CommonUtil.showErrors(validationErrors);
	        	    
	          }
	      }else{
	    	  //Ext.Msg.alert("Eaty","Record not found.");
	    	  Eatzy.util.CommonUtil.hideLoadMask();
	      }
           
     },
     /**
      * Function: To handle clock in user data
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
     onDoClockInUserSuccesscallback:function( serviceResponseStatus, responseData, currentObject){
    	 
    	  Eatzy.util.CommonUtil.setIsStatusViewDisplay(true);
          if(Ext.getCmp('mainTabPanel')!=undefined){
        	 
        	 Eatzy.util.CommonUtil.hideLoadMask();
        	  
        	 Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("activeButtonCls");
        	 Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signOutButtonCls");
        	 Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("ACTIVE");
        	 
        	 var loginStore = Ext.getStore('loginStoreId');
   	         var loginUserRecordObject = loginStore.getAt(0);
   	         var name= loginUserRecordObject.get('rds_name');
        	 Ext.ComponentQuery.query('button[name=ridersName]')[0].setText(name.toUpperCase());
        	 
             Ext.getCmp('mainTabPanel').setActiveItem(3);
             Eatzy.util.CommonUtil.messageFunction(currentObject);
        	 Eatzy.util.CommonUtil.toSetStatusViewChatBubbleTextAndMessageCount();
        	 Eatzy.util.CommonUtil.setIsDriverClockIn(true);
         }else{
        	
        	 var bottomTabPanelView = Ext.create('Eatzy.view.BottomTabPanelView');
             Ext.Viewport.add(bottomTabPanelView);
             Ext.Viewport.setActiveItem(bottomTabPanelView);
             Ext.getCmp('mainTabPanel').setActiveItem(3);
             Eatzy.util.CommonUtil.onSoccessCallbackOfGetMessagesOfDriver(serviceResponseStatus, responseData, currentObject);
            
             
         }
        
    	
    	
     },
    
     /**
      * Function: To retrieve logged in clock user clock in options
      *
      * **/
     doClockOutUser:function(){
    	 Eatzy.util.CommonUtil.showLoadMask();
    	 Eatzy.util.CommonUtil.periodicallyCheckInDriverCurrentDriversOrder(this,this.doClockOutDriver);
		 
     },
     /**
      * Function: To handle clock in user data
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
     onDoClockOutUserSuccesscallback:function( serviceResponseStatus, responseData, currentObject){
    	      Eatzy.util.CommonUtil.hideLoadMask();
    	      if(Ext.ComponentQuery.query('panel[name=statusView]')[0]!=undefined){
    	    	  
    	    	  Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
    	    	  Ext.getCmp('mainTabPanel').setActiveItem(3);
    	    	  Eatzy.util.CommonUtil.setIsDriverClockIn(false);
    	          Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("offButtonCls");
    		      Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signInButtonCls");
    		      Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("NOT ACTIVE");
    		      
    	      }
    	     
        
    	 
     },
     /**
      * Function:To Clock in driver
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
     doClockIn:function(serviceResponseStatus, responseData, currentObject){
    	 if(responseData.error){
    		    Eatzy.util.CommonUtil.hideLoadMask();
  	    
	 	        var validationErrors = [];
	            
	           
	            var responseData = Ext.JSON.decode(responseData.responseText);
	            validationErrors.push(responseData.description)
	            Eatzy.util.CommonUtil.showErrors(validationErrors);
	            
    	 }else{
    		  var loginStore = Ext.getStore('loginStoreId');
   	          var loginUserRecordObject = loginStore.getAt(0);
   	     
   	          var loginStore = Ext.getStore('loginStoreId');
              var loginUserRecordObject = loginStore.getAt(0);
              var requestUrl = Eatzy.util.GlobalUtil.getClockInOptionsUrl();      
              var paramsObject = { 
                 	'id' : loginUserRecordObject.get('userId'),
                 	'token' : loginUserRecordObject.get('userToken'),
                 	'request': requestUrl
                   };
              currentObject.commonWebServiceCall( 'POST', paramsObject, currentObject.onGetClockInOptionsSccuesscallback, currentObject );
    	 }
     },
     /**
      * Function: To check driver clocked in status on initialize of Status View
      * 
      * **/
     onInitializeOfStatusView:function(){
    	 //console.log("In onInitializeOfStatusView "+Eatzy.util.CommonUtil.getIsDriverStatusServiceCall())
    	 var me = this;
    	 if(!Eatzy.util.CommonUtil.getIsDriverStatusServiceCall()){
	    		 Eatzy.util.CommonUtil.getCurrentLatLong();
	    		 Eatzy.util.CommonUtil.periodicallyCheckInDriverCurrentDriversOrder(me,me.driverCheckInStatusCallBackFunction);
    	 }
    	 
     },
     /**
      * Function: To handle periodically check in of drivers success data
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
     driverCheckInStatusCallBackFunction:function(serviceResponseStatus, responseData, currentObject){
    	 console.log("driverCheckInStatusCallBackFunction 28111111 :=== ",responseData);
    	 var responseData = Ext.JSON.decode(responseData.responseText);
    	 Eatzy.util.CommonUtil.setDriverCheckInFlagData(responseData);
    	 var validationErrors = [];
    	 //console.log("not_clocked_in :==== 285 "+responseData.not_clocked_in," Eatzy.util.CommonUtil.getIsDriverStatusServiceCall():: ",Eatzy.util.CommonUtil.getIsDriverStatusServiceCall());
    	 if(!Eatzy.util.CommonUtil.getIsDriverStatusServiceCall()){
    		 console.log("getIsDriverStatusServiceCall not");
    		 if(responseData.error){
     		    if(responseData.error=="token_mismatch"){
     		    	
     	            validationErrors.push(responseData.description)
     	            Eatzy.util.CommonUtil.showErrors(validationErrors);
     	            
     	            var loginStore = Ext.getStore('loginStoreId');
 	    	        loginStore.removeAll();
 	    	        var chatStore = Ext.getStore('chatdStoreId');
 	    	        chatStore.removeAll();
 	    	        var clockInStore = Ext.getStore('clockInOptionsStoreId');
 	    	        clockInStore.removeAll();
     	            
     	            
     	            Ext.Viewport.getActiveItem().destroy();
     	            Eatzy.util.CommonUtil.setIsStatusViewDisplay(false); 
     	        	var LoginView = Ext.create('Eatzy.view.LoginView');
     	            Ext.Viewport.add(LoginView);
     	            Ext.Viewport.setActiveItem(LoginView);
     	            
     		    }else if(responseData.not_clocked_in == 1){ //not_clocked_in previous flag
     		    	
     		    	
 	        		 Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
 	        		 Ext.getCmp('mainTabPanel').setActiveItem(3);
 	        		 validationErrors.push("Please clock in first.");
 	    	         Eatzy.util.CommonUtil.showErrors(validationErrors);
 	        	}else{
 	        		 
 	        		 Eatzy.util.CommonUtil.setIsStatusViewDisplay(true);
 	        		 Ext.getCmp('mainTabPanel').setActiveItem(3);
 	        		 Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("activeButtonCls");
 	            	 Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signOutButtonCls");
 	            	 Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("ACTIVE");
 	            	 //console.log("Before call ");
 	            	 var ref = currentObject.getTestObj();
 	            	 //console.log("Ref :=== ", currentObject );
 	            	 Eatzy.util.CommonUtil.setIsCalledFromStatusView(true);
 	            	 Eatzy.util.CommonUtil.setIsDriverClockIn(true)
 	            	 Eatzy.util.CommonUtil.messageFunction(currentObject);
 	            	 Eatzy.util.CommonUtil.toSetStatusViewChatBubbleTextAndMessageCount();
 	        	}
     		    
	     	 }else{
	     		    
	         		 Eatzy.util.CommonUtil.setIsStatusViewDisplay(true);
	         		 Ext.getCmp('mainTabPanel').setActiveItem(3);
	         		 Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("activeButtonCls");
	             	 Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signOutButtonCls");
	             	 Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("ACTIVE");
	             	 Eatzy.util.CommonUtil.getMessagesForDriver(currentObject,currentObject.onSoccessCallbackOfGetMessagesOfDriver);
	             	 var chatMessageStore = Ext.getStore('chatdStoreId');
	                  var messageStoreCount = chatMessageStore.getAllCount();
	                  //console.log("Message count :=== ",messageStoreCount);//chatMessageStore
	                 // Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
	     	 }
	    		 Eatzy.util.CommonUtil.setIsDriverStatusServiceCall(true);
		    	 Eatzy.util.CommonUtil.setCheckInDriverInterval(setInterval(function(){
		    		 Eatzy.util.CommonUtil.getCurrentLatLong();
		    		 Eatzy.util.CommonUtil.periodicallyCheckInDriverCurrentDriversOrder(currentObject,currentObject.driverCheckInStatusCallBackFunction);
		         },60000));
    	 }else{
    		 Eatzy.util.CommonUtil.setIsStatusViewDisplay(true);
         	 Eatzy.util.CommonUtil.getMessagesForDriver(currentObject,currentObject.onSoccessCallbackOfGetMessagesOfDriver);
         	 Eatzy.util.CommonUtil.toSetStatusViewChatBubbleTextAndMessageCount();
    	 }
    	
    	
    	 
     },
     
     /**
      * Function: To handle ger messages of driver success data
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
     onSoccessCallbackOfGetMessagesOfDriver:function(serviceResponseStatus, responseData, currentObject){
    	 Eatzy.util.CommonUtil.onSoccessCallbackOfGetMessagesOfDriver(serviceResponseStatus, responseData, currentObject);
     },
     /**
      * Function: To handle clock out of drivers success data
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
     doClockOutDriver:function(serviceResponseStatus, responseData, currentObject){
         if(responseData.error){
        	    
	    		Eatzy.util.CommonUtil.hideLoadMask();
	    
	 	        var validationErrors = [];
	           
	            var responseData = Ext.JSON.decode(responseData.responseText);
	            validationErrors.push(responseData.description)
	            Eatzy.util.CommonUtil.showErrors(validationErrors);
         }else{
        	    var loginStore = Ext.getStore('loginStoreId');
				var loginUserRecordObject = loginStore.getAt(0);
				var requestUrl = Eatzy.util.GlobalUtil.getClockOutUrl();      
				var paramsObject = { 
				   'id' : loginUserRecordObject.get('userId'),
				   'token' : loginUserRecordObject.get('userToken'),
				   'request': requestUrl
				};
				currentObject.commonWebServiceCall( 'POST', paramsObject, currentObject.onDoClockOutUserSuccesscallback, currentObject );
         }
    	 
     }
     
});