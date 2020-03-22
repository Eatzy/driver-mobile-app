/*
 * Created by 1010
 * June 23, 2015.
 * This controller contains methods related to login.
 */
Ext.define('Eatzy.controller.LoginController',{
    extend:'Eatzy.controller.GenericController',

    config:{
            views : [
                   'LoginView'
            ],

            refs: {
                        loginView: 'loginView'
                        
            },

            control:{
            	
                'button[action=onLoginClick]':{
                    tap : 'showLoginView'
                },
                'button[action=logoutBtnClick]':{
                    tap : 'doLogOutUser'
                }
                
                   
            }
    },
    /*
     * This method used to show login screen on click of sign in button.
     */
     showLoginView: function( button ){
    	     Eatzy.util.CommonUtil.showLoadMask();
    	     
             var formPanelObject = button.up('formpanel');
             var formValueObject = formPanelObject.getValues();
             var userName = formValueObject.userName;
             var password = Eatzy.util.CommonUtil.encryptPaswwordUsingMD5HashEncryption(formValueObject.password); // Encrypt password using MD5 hash encryption.
             var errorLabel = Ext.ComponentQuery.query('label[name=errorLabel]')[0];
             if(  userName.trim() == "" || password.trim() == "" ){
                     errorLabel.setHidden(false);
                     errorLabel.setHtml("Please enter a valid username and password combination.");
                     Eatzy.util.CommonUtil.hideLoadMask();
                     return;
             }
             errorLabel.setHidden(true);
             Ext.ComponentQuery.query('label[name=errorLabel]')[0].setHtml("");
             Ext.ComponentQuery.query('label[name=errorLabel]')[0].setHtml("Please enter a valid username and password combination.");
             var requestUrl = Eatzy.util.GlobalUtil.getLoginUrl();
             var paramsObject ='';
             var lat = Eatzy.util.CommonUtil.getUserLatitude();
		     var userLongitude = Eatzy.util.CommonUtil.getUserLongitude();
            	 
            	  paramsObject = {
                          'u': userName,
                          'p': password,
                          'lat':lat,
				          'lng':userLongitude,
                          'request': requestUrl
                      };
         	
           if(!Ext.os.is.Desktop){
        	   if(Ext.os.is.Android){
              	 Eatzy.util.CommonUtil.deviceRegisterationForPushNotification('Android');
              } else{
              	 Eatzy.util.CommonUtil.deviceRegisterationForPushNotification('ios');
              } 
           } 
                     
           this.commonWebServiceCall( 'POST', paramsObject, this.onLoginCallback, this );
     },

     /**
      * This is callback methods which called in case of login webservice success or fail.
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      **/
     onLoginCallback: function( serviceResponseStatus, responseData, currentObject ){
    	 
             var errorLabel = Ext.ComponentQuery.query('label[name=errorLabel]')[0];
             if(serviceResponseStatus){
            	 Eatzy.util.CommonUtil.hideLoadMask();
                      if(responseData.error){
                             errorLabel.setHidden(false);
                             errorLabel.setHtml(responseData.description);
                             Eatzy.util.CommonUtil.hideLoadMask();
                             return;
                      }
                      var loginStore = Ext.getStore('loginStoreId');
                      loginStore.removeAll();
                      var rdsDeliveryServiceLogoUrl = ( responseData.rds_logo_delivery==undefined ||responseData.rds_logo_delivery=="")?"":responseData.rds_logo_delivery;
                      var rdsDeliveryServiceTakeOutLogoUrl = ( responseData.rds_logo_takeout==undefined ||responseData.rds_logo_takeout=="")?"":responseData.rds_logo_takeout;
                      var loginModel = Ext.create('Eatzy.model.LoginModel',{
                             userId: ( responseData.id==undefined ||responseData.id=="")?"":responseData.id,
                             userToken: ( responseData.token==undefined ||responseData.token=="")?"":responseData.token,
                             job_assignment_id:( responseData.job_assignment_id==undefined ||responseData.job_assignment_id=="")?"":responseData.job_assignment_id,
                             rds_logo_delivery :( responseData.rds_logo_delivery==undefined ||responseData.rds_logo_delivery=="")?"":responseData.rds_logo_delivery,
                             rds_logo_takeout:( responseData.rds_logo_takeout==undefined ||responseData.rds_logo_takeout=="")?"":responseData.rds_logo_takeout,
                             rds_message:( responseData.rds_message==undefined ||responseData.rds_message=="")?"":responseData.rds_message,
                             rds_name:( responseData.rds_name==undefined ||responseData.rds_name=="")?"":responseData.rds_name,
                             rds_phone:( responseData.rds_phone==undefined ||responseData.rds_phone=="")?"":responseData.rds_phone,
                             tz:( responseData.tz==undefined ||responseData.tz=="")?"":responseData.tz
                      });
                      loginModel.setDirty();
                      loginStore.add(loginModel);
                      Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
                      var loginUserRecordObject = loginStore.getAt(0);
                      Ext.ComponentQuery.query('panel[name=loginView]')[0].destroy();
                      if(Ext.getCmp('mainTabPanel')!=undefined){
                    	  Ext.getCmp('mainTabPanel').setActiveItem(3);
                      }else{
                    	  
                    	 
                    	  var bottomTabPanelView = Ext.create('Eatzy.view.BottomTabPanelView');
                          Ext.Viewport.add(bottomTabPanelView);
                          Ext.Viewport.setActiveItem(bottomTabPanelView);
                          Ext.getCmp('mainTabPanel').setActiveItem(3);
                        
                          Ext.ComponentQuery.query('button[name=ridersName]')[0].setText(loginUserRecordObject.get('rds_name').toUpperCase());
                          // To save current time
                          Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
                      }
                                           
                                  
                      
                     
             }else{
            	    Eatzy.util.CommonUtil.hideLoadMask();
                    var validationErrors = [];
                    validationErrors.push('Unable to login, try again.');
                    Eatzy.util.CommonUtil.showErrors(validationErrors);
             }
     },
     /**
      * Function: To retrieve logged in clock user clock in options
      *
      * **/
     getClockInOptions:function(){
    	  var loginStore = Ext.getStore('loginStoreId');
          var loginUserRecordObject = loginStore.getAt(0);
                  
          var paramsObject = { 
              	'id' : loginUserRecordObject.get('userId'),
              	'token' : loginUserRecordObject.get('userToken'),
              	'request': 'getclockinoptions'
                };
          this.commonWebServiceCall( 'POST', paramsObject, this.onGetClockInOptionsSccuesscallback, this );
     },
     /**
      * Function: To logout user and clean data from store.
      *
      * **/
     doLogOutUser:function(){  	 
    	 //Eatzy.util.CommonUtil.showAlertMessage('Are you sure you want to logout?', true, 'logoutButton');
    	 Eatzy.util.CommonUtil.clearUsersBasicInfo();
     },
     
     /**
      * This is callback methods which called in case of periodic webservice success to check check in status.
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      **/
     onSuccessOfCheckIn:function( serviceResponseStatus, responseData, currentObject ){
    	 if(serviceResponseStatus){
    		 console.log("In success of periodic webservice of check in flag.");
    	 }else{
    		 Eatzy.util.CommonUtil.hideLoadMask();
    		 responseData = Ext.JSON.decode(responseData.responseText);
             var validationErrors = [];
             validationErrors.push(responseData.description);
             Eatzy.util.CommonUtil.showErrors(validationErrors);
    	 }
     }


  
});