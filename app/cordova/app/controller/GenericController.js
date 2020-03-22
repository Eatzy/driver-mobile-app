/*
 * Created by 1010
 * June 23,2015
 * This controller has generic method for webservice call.
 * All classes which extend this class are able to call commonWebServiceCall method using class object such as this.commonWebServiceCall().
 * We can use this method after extending this controller class in required place(Only in controller).
 */
Ext.define('Eatzy.controller.GenericController', {
    extend: 'Ext.app.Controller',

   /*
    * This method is used to get or post data on server.
    * @param: methodType type of the method to call service either GET or POST.
    * @param: paramsObject contains required parameter to call service.
    * @param: callback method execute on success or failure of webservice call.
    * @return: control returns to call back method.
    */
    commonWebServiceCall:function( methodType, paramsObject, callaBackMethod, currentObject ){
            var serviceUrl = Eatzy.util.GlobalUtil.getBaseUrl();
            var apiKey = Eatzy.util.GlobalUtil.getApiKey();
            var apiVersion = Eatzy.util.GlobalUtil.getApiVersion();
            var sandboxValue = Eatzy.util.GlobalUtil.getSandboxValue();
            //var deviceToken = Eatzy.util.CommonUtil.getDeviceToken();
            var deviceTokenStore = Ext.getStore('deviceTokenStoreId');
            var deviceToken='';
            if(deviceTokenStore.getAllCount()>0){
            	deviceToken = deviceTokenStore.getAt(0).get('deviceToken');
            	//console.log("Device token :===="+deviceToken);
            }else{
            	deviceToken="APA91bFcL0eMrnuCsEF7eHB5pWqJh8aFtrIyq82nOJDyW2LhXH_0FLN4IXUgyL6BElyIHWPZ-UJYzxMyBPRksAbEBvEBVy7IF-2kDLcNvaRma9XSxLVJVHo";
            }
            paramsObject['key'] = apiKey;
            paramsObject['version'] = apiVersion;
            Ext.Ajax.request({
                    url : serviceUrl,
                    method : methodType,
                    timeout: 7000,
					headers: {
							"X-Eatzy-DeviceRegToken":deviceToken
				    },
                    params : paramsObject,
                    withCredentials : false,
                    useDefaultXhrHeader : false,
                    success : function(response, request) {
                    	    try{
                                    responseData = Ext.JSON.decode(response.responseText);
                                    if( responseData == null || responseData.error){
                                           callaBackMethod( false, response, currentObject );
                                    }else{
                                            callaBackMethod( true, responseData, currentObject );
                                    }
                            }catch(error){
                                    callaBackMethod( false, response, currentObject );
                            }
                    },
                    failure : function(response, request) {
                    	
                            try{
                                  callaBackMethod( false, response, currentObject );
                            }
                            catch(err){
                                   var validationErrors = [];
                                   validationErrors.push(response.statusText);
                                   
                                   Eatzy.util.CommonUtil.showErrors(validationErrors);
                            }
                    }

            });
    }

 });
