/*
 * Created by 1010
 * 22 June 2015
 * This class defines common methods and variables used in app.
 */
Ext.define('Eatzy.util.CommonUtil',{
    singleton : true,
    config : {
           isStatusViewDisplay:false,
           logedInUserId:'',
           isDriverClockIn:false,
           driverCheckInFlagData:'',
           isClockInFirst:false,
           messageInterval:'',
           deviceToken:'',
           isCalledFromStatusView:false,
           checkInDriverInterval:'',
           userLatitude:0,
           userLongitude:0,
           isDriverStatusServiceCall:false
    },

    constructor : function(config) {
            this.initConfig(config);
            this.callParent([config]);
    },
    
    /*
     * Checks whether device is tablet or not.
     */
     isTablet: function(){
            if( Ext.os.is.Tablet || screen.height > 950 ){
                    return true;
            }else{
                    return false;
            }
     },

     /*
      *This function is to encrypt password using MD5 Hash encrypt algorithm.
      *@password:Password string for encryption. 
      */
     
     encryptPaswwordUsingMD5HashEncryption:function (string) {
             function RotateLeft(lValue, iShiftBits) {
                     return (lValue<<iShiftBits) | (lValue>>>(32-iShiftBits));
             }
             function AddUnsigned(lX,lY) {
                     var lX4,lY4,lX8,lY8,lResult;
                     lX8 = (lX & 0x80000000);
                     lY8 = (lY & 0x80000000);
                     lX4 = (lX & 0x40000000);
                     lY4 = (lY & 0x40000000);
                     lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);
                     if (lX4 & lY4) {
                             return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
                     }
                     if (lX4 | lY4) {
                             if (lResult & 0x40000000) {
                                 return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
                             } else {
                                 return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
                             }
                     } else {
                             return (lResult ^ lX8 ^ lY8);
                     }
             }
             function F(x,y,z) { return (x & y) | ((~x) & z); }
             function G(x,y,z) { return (x & z) | (y & (~z)); }
             function H(x,y,z) { return (x ^ y ^ z); }
             function I(x,y,z) { return (y ^ (x | (~z))); }
             function FF(a,b,c,d,x,s,ac) {
                     a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
                     return AddUnsigned(RotateLeft(a, s), b);
             };
             function GG(a,b,c,d,x,s,ac) {
                     a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
                     return AddUnsigned(RotateLeft(a, s), b);
             };
             function HH(a,b,c,d,x,s,ac) {
                     a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
                     return AddUnsigned(RotateLeft(a, s), b);
             };
             function II(a,b,c,d,x,s,ac) {
                     a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
                     return AddUnsigned(RotateLeft(a, s), b);
             };
             function ConvertToWordArray(string) {
                     var lWordCount;
                     var lMessageLength = string.length;
                     var lNumberOfWords_temp1=lMessageLength + 8;
                     var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1 % 64))/64;
                     var lNumberOfWords = (lNumberOfWords_temp2+1)*16;
                     var lWordArray=Array(lNumberOfWords-1);
                     var lBytePosition = 0;
                     var lByteCount = 0;
                     while ( lByteCount < lMessageLength ) {
                             lWordCount = (lByteCount-(lByteCount % 4))/4;
                             lBytePosition = (lByteCount % 4)*8;
                             lWordArray[lWordCount] = (lWordArray[lWordCount] | (string.charCodeAt(lByteCount)<<lBytePosition));
                             lByteCount++;
                     }
                     lWordCount = (lByteCount-(lByteCount % 4))/4;
                     lBytePosition = (lByteCount % 4)*8;
                     lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80<<lBytePosition);
                     lWordArray[lNumberOfWords-2] = lMessageLength<<3;
                     lWordArray[lNumberOfWords-1] = lMessageLength>>>29;
                     return lWordArray;
             };
             function WordToHex(lValue) {
                     var WordToHexValue="",WordToHexValue_temp="",lByte,lCount;
                     for (lCount = 0;lCount<=3;lCount++) {
                             lByte = (lValue>>>(lCount*8)) & 255;
                             WordToHexValue_temp = "0" + lByte.toString(16);
                             WordToHexValue = WordToHexValue + WordToHexValue_temp.substr(WordToHexValue_temp.length-2,2);
                     }
                     return WordToHexValue;
             };
             function Utf8Encode(string) {
                     string = string.replace(/\r\n/g,"\n");
                     var utftext = "";
                     for (var n = 0; n < string.length; n++) {
                             var c = string.charCodeAt(n);
                             if (c < 128) {
                                 utftext += String.fromCharCode(c);
                             }
                             else if((c > 127) && (c < 2048)) {
                                 utftext += String.fromCharCode((c >> 6) | 192);
                                 utftext += String.fromCharCode((c & 63) | 128);
                             }
                             else {
                                 utftext += String.fromCharCode((c >> 12) | 224);
                                 utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                                 utftext += String.fromCharCode((c & 63) | 128);
                             }
                     }
                     return utftext;
             };

             var x=Array();
             var k,AA,BB,CC,DD,a,b,c,d;
             var S11=7, S12=12, S13=17, S14=22;
             var S21=5, S22=9 , S23=14, S24=20;
             var S31=4, S32=11, S33=16, S34=23;
             var S41=6, S42=10, S43=15, S44=21;

             string = Utf8Encode(string);

             x = ConvertToWordArray(string);

             a = 0x67452301; b = 0xEFCDAB89; c = 0x98BADCFE; d = 0x10325476;

             for (k=0;k<x.length;k+=16) {
                     AA=a; BB=b; CC=c; DD=d;
                     a=FF(a,b,c,d,x[k+0], S11,0xD76AA478);
                     d=FF(d,a,b,c,x[k+1], S12,0xE8C7B756);
                     c=FF(c,d,a,b,x[k+2], S13,0x242070DB);
                     b=FF(b,c,d,a,x[k+3], S14,0xC1BDCEEE);
                     a=FF(a,b,c,d,x[k+4], S11,0xF57C0FAF);
                     d=FF(d,a,b,c,x[k+5], S12,0x4787C62A);
                     c=FF(c,d,a,b,x[k+6], S13,0xA8304613);
                     b=FF(b,c,d,a,x[k+7], S14,0xFD469501);
                     a=FF(a,b,c,d,x[k+8], S11,0x698098D8);
                     d=FF(d,a,b,c,x[k+9], S12,0x8B44F7AF);
                     c=FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);
                     b=FF(b,c,d,a,x[k+11],S14,0x895CD7BE);
                     a=FF(a,b,c,d,x[k+12],S11,0x6B901122);
                     d=FF(d,a,b,c,x[k+13],S12,0xFD987193);
                     c=FF(c,d,a,b,x[k+14],S13,0xA679438E);
                     b=FF(b,c,d,a,x[k+15],S14,0x49B40821);
                     a=GG(a,b,c,d,x[k+1], S21,0xF61E2562);
                     d=GG(d,a,b,c,x[k+6], S22,0xC040B340);
                     c=GG(c,d,a,b,x[k+11],S23,0x265E5A51);
                     b=GG(b,c,d,a,x[k+0], S24,0xE9B6C7AA);
                     a=GG(a,b,c,d,x[k+5], S21,0xD62F105D);
                     d=GG(d,a,b,c,x[k+10],S22,0x2441453);
                     c=GG(c,d,a,b,x[k+15],S23,0xD8A1E681);
                     b=GG(b,c,d,a,x[k+4], S24,0xE7D3FBC8);
                     a=GG(a,b,c,d,x[k+9], S21,0x21E1CDE6);
                     d=GG(d,a,b,c,x[k+14],S22,0xC33707D6);
                     c=GG(c,d,a,b,x[k+3], S23,0xF4D50D87);
                     b=GG(b,c,d,a,x[k+8], S24,0x455A14ED);
                     a=GG(a,b,c,d,x[k+13],S21,0xA9E3E905);
                     d=GG(d,a,b,c,x[k+2], S22,0xFCEFA3F8);
                     c=GG(c,d,a,b,x[k+7], S23,0x676F02D9);
                     b=GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);
                     a=HH(a,b,c,d,x[k+5], S31,0xFFFA3942);
                     d=HH(d,a,b,c,x[k+8], S32,0x8771F681);
                     c=HH(c,d,a,b,x[k+11],S33,0x6D9D6122);
                     b=HH(b,c,d,a,x[k+14],S34,0xFDE5380C);
                     a=HH(a,b,c,d,x[k+1], S31,0xA4BEEA44);
                     d=HH(d,a,b,c,x[k+4], S32,0x4BDECFA9);
                     c=HH(c,d,a,b,x[k+7], S33,0xF6BB4B60);
                     b=HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);
                     a=HH(a,b,c,d,x[k+13],S31,0x289B7EC6);
                     d=HH(d,a,b,c,x[k+0], S32,0xEAA127FA);
                     c=HH(c,d,a,b,x[k+3], S33,0xD4EF3085);
                     b=HH(b,c,d,a,x[k+6], S34,0x4881D05);
                     a=HH(a,b,c,d,x[k+9], S31,0xD9D4D039);
                     d=HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);
                     c=HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);
                     b=HH(b,c,d,a,x[k+2], S34,0xC4AC5665);
                     a=II(a,b,c,d,x[k+0], S41,0xF4292244);
                     d=II(d,a,b,c,x[k+7], S42,0x432AFF97);
                     c=II(c,d,a,b,x[k+14],S43,0xAB9423A7);
                     b=II(b,c,d,a,x[k+5], S44,0xFC93A039);
                     a=II(a,b,c,d,x[k+12],S41,0x655B59C3);
                     d=II(d,a,b,c,x[k+3], S42,0x8F0CCC92);
                     c=II(c,d,a,b,x[k+10],S43,0xFFEFF47D);
                     b=II(b,c,d,a,x[k+1], S44,0x85845DD1);
                     a=II(a,b,c,d,x[k+8], S41,0x6FA87E4F);
                     d=II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);
                     c=II(c,d,a,b,x[k+6], S43,0xA3014314);
                     b=II(b,c,d,a,x[k+13],S44,0x4E0811A1);
                     a=II(a,b,c,d,x[k+4], S41,0xF7537E82);
                     d=II(d,a,b,c,x[k+11],S42,0xBD3AF235);
                     c=II(c,d,a,b,x[k+2], S43,0x2AD7D2BB);
                     b=II(b,c,d,a,x[k+9], S44,0xEB86D391);
                     a=AddUnsigned(a,AA);
                     b=AddUnsigned(b,BB);
                     c=AddUnsigned(c,CC);
                     d=AddUnsigned(d,DD);
             }
             var temp = WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d);
             var encryptPassword =  temp.toLowerCase();
             return encryptPassword;
     },
     /**
      * Function :To create top panel
      * 
      * **/
     createTopToolbarPanel:function(){
    	 var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
         var windowWidth= Eatzy.util.GlobalUtil.getScreenWidth();
         var isTablet = Eatzy.util.CommonUtil.isTablet();
         var isDisplay= Eatzy.util.CommonUtil.getIsStatusViewDisplay();
    	 var topPanel= {
             xtype: 'panel',
             width: '100%',
             height: windowHeight*0.1153169014084507,
             name:'topToolBarPanel',
             cls:'panelBoderColorCls',
             layout:{
            	      type:'hbox',
            	      pack:'start',
            	      align:'center'
            	      
             },
           
             items:[
                    
					{
						xtype:'spacer',
						width:windowWidth*0.0234375,
						height:'100%'
					},

                    {
                    	 xtype:'panel',
                    	 width:windowWidth*0.7359375,
                    	 height:windowHeight*0.0625,//0.0572183098591549,
                    	 action:'messageBubblePanelId',
                    	 cls:'statusViewUserFriendMessageCls',
                    	 style: 'line-height:'+windowHeight*0.0625+'px;',
                    	// style:'  border-radius: '+windowHeight*0.0166666666666667+'px;',
                    	 name:'messageBubblePanel',
                    	 html:'<div align="center" class="chatBadgeDivCls" style="width:'+windowWidth*0.071875+'px; height:'+windowWidth*0.071875+'px; font-size:'+windowHeight*0.0220070422535211+'px; top:'+(-1) * windowHeight*0.0176056338028169+'px; padding:'+windowHeight*0.0003961265625+'px; line-height:'+windowWidth*0.071875+'px;">0</div>',
                    	 items:[
                    	          {
                    	        	  xtype:'label',
                    	        	  name:'statusChatBubbleLabel',
                    	        	  html:'<div style="padding-top:1px;padding-left:20px;font-size:'+windowHeight*0.022887323943662+'px;color:#000;white-space: nowrap; width: '+windowWidth * 0.634375+'px; overflow: hidden;text-overflow: ellipsis;">No data available<div style="font-size:'+windowHeight*0.0140845070422535+'px;color:#000;"></div></div>'
                    	          }
                    	        
                    	        ],
            	        listeners:{
            	        	initialize: function(panel){
            	        		
                    		    panel.element.on('tap', function(event) {
                    		    	var loginStore = Ext.getStore('loginStoreId');
        							var loginRecordObj = loginStore.getAt(0);
        							//console.log("Eatzy.util.CommonUtil.getIsDriverClockIn() :=== ",Eatzy.util.CommonUtil.getIsDriverClockIn())
        							if(Eatzy.util.CommonUtil.getIsDriverClockIn()){
        								if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
                							
                							Ext.ComponentQuery.query('panel[name=chatView]')[0].destroy();
                							Ext.getCmp('chatContainer').add({xtype:'chatView'});
                							Eatzy.util.CommonUtil.reduceListItemHeight();
                							Ext.ComponentQuery.query('label[name=chatFriendName]')[0].setHtml('<div align="center">'+loginRecordObj.get('rds_name')+'</div>');
                						}else{
                							
                							Ext.getCmp('chatContainer').add({xtype:'chatView'});
                							Eatzy.util.CommonUtil.reduceListItemHeight();
                							Ext.ComponentQuery.query('label[name=chatFriendName]')[0].setHtml('<div align="center">'+loginRecordObj.get('rds_name')+'</div>');
                							
                						}
                						    Ext.ComponentQuery.query('panel[name=topToolBarPanel]')[0].setHidden(true);
                						    
        							}else{
        								/// In case of user is not clock in
        								var validationErrors = [];
        								validationErrors.push("Please clock in first");
        								Eatzy.util.CommonUtil.showErrors(validationErrors);
        							}
            						
            						
            						
            					});
                    		}
            	        	
            	        }
                    },
                    {
                    	xtype:'spacer',
                    	width:windowWidth*0.0266666666666667,
                    	height:windowHeight*0.0389805097451274
                    },
                    
                    {
                    	 xtype:'button',
                    	 width:windowWidth*0.18125,
                    	 height:windowHeight*0.0536971830985915,
                    	 docked:'right',
                    	 name:'activeOffButton',
                    	 cls:isDisplay ? ' activeButtonCls':'offButtonCls',
                    	 right:windowWidth*0.0163934426229508,
                    	 style:'margin-top:'+windowHeight*0.024936916041979+'px;'
                    }
                    
                    
                    
                    ]
    		};
    	return topPanel;
    	
     },
 	/*
     *  This method display loader.
     */
     showLoadMask: function(){
              Ext.Viewport.setMasked({
                     xtype: 'loadmask',
                     message: ''
              });
     },

     /*
      * This method hide loader.
     */
     hideLoadMask: function(){
              Ext.Viewport.unmask();
     },
     /**
      *Function :To set selected tab class
      *@param{tabpanel} : tab panel reference to tab panel
      *@param{selectedTabIconCls} : It is the selected tab icon css class
      * **/
     setSelectedTabCls:function(tabpanelInnerItems,selectedTabIconCls){
    	 
    
    	if(tabpanelInnerItems.length > 0 ){
    		for(var i=0;i<tabpanelInnerItems.length;i++){
    			if(tabpanelInnerItems[i].iconCls == "chatIconCls"){
    				
    				tabpanelInnerItems[i].iconCls ="chatIconPressedCls";
    				
    			}else if(tabpanelInnerItems[i].iconCls == "mapIconCls"){
    				
    				tabpanelInnerItems[i].iconCls = "mapIconPressedCls";
    				
    			}else if(tabpanelInnerItems[i].iconCls == "directionIconCls"){
    				
    				tabpanelInnerItems[i].iconCls = "directionIconPressedCls";
    				
    			}else if(tabpanelInnerItems[i].iconCls == "menuIconCls"){
    				
    				tabpanelInnerItems[i].iconCls ="menuIconPressedCls";
    				
    			}else if(tabpanelInnerItems[i].iconCls == "historyIconCls"){
    				
    				tabpanelInnerItems[i].iconCls = "historyIconPressedCls";
    				
    			}else{
    				console.log("No tab selected");
    			}
    		}
    	}
     },
     /*
      *This function is to create common message overlay for app.
      @errors: Errors to show on overlay.
      */
      showErrors : function(errors) {
              if(errors.length != 0){
	            	  var displayMessageOverlay = Ext.getCmp('messageBoxOverlayId');
	            	  if(displayMessageOverlay){
	            		  displayMessageOverlay.hide();
	            		  displayMessageOverlay.destroy();
	            	  }
                      var errorMessageWindow = Ext.create('Eatzy.view.widget.MessageBoxOverlay');
                      Ext.Viewport.add(errorMessageWindow);
                      var displayMessageOverlay = Ext.ComponentQuery.query('panel[name=messageBoxOverlay]')[0];
                      displayMessageOverlay.show();
                      errorMessageWindow.showErrorMessages(errors,false);
                      Eatzy.util.CommonUtil.hideLoadMask();
                      return true;
              }else{
                      return false;
              }
      },
      /*
       *This function is to convert messages to errorMessage.
       @errors: Error object which contains all error messages.
       */
       convertToErrorMessages: function(errors){
          var messages = [];
          messages.push(this.createErrorMessage(errors));
          return messages;
       },

       /*
       *This function is to create errorMessage Labels.
       *@errorMessage:Error message to show on overlay.
       */
       createErrorMessage:function(errorMessage){
    	   var windowHeight = Ext.Viewport.getWindowHeight() ;
           var errorMessageLabel = Ext.create("Ext.Label",
           {
              xtype:'label',
              width:'92.958%',
              html:'<div style="color:#585858; font-size:'+windowHeight*0.030+'px; text-align: center; overflow:auto;">'+errorMessage+'</div>'
           });
           return errorMessageLabel;
       },
	    removePreviousTabSelectedCls:function(tabArray,seletedTabCls){
	    	var arrayOfCls = ["mapIconCls","directionIconCls","historyIconCls","chatIconCls","menuIconCls"];
	    	var arrayOfPressedCls = ["mapIconPressedCls","directionIconPressedCls","historyIconPressedCls","chatIconPressedCls","menuIconPressedCls"];
	    	var index= arrayOfCls.indexOf(seletedTabCls);
	    	for(var i=0;i<tabArray.items.length;i++){
	    		
		    		if(index!= i){
		    			tabArray.items[i].setIconCls(arrayOfCls[i]);
		    		}
	    		
	    	}
	    },
	    /**
	      * Function: to retrieve periodically checking for current driver's order run list
	      * @param {currentObject} currentObject reference to the controller from which it is called .
	      * @param {callBackFunction} function used to process further
	      * */
	     periodicallyCheckInDriverCurrentDriversOrder:function(currentObject,callBackFunction){
	    	  
	    	  var loginStore = Ext.getStore('loginStoreId');
		      var loginUserRecordObject = loginStore.getAt(0);
		      var requestUrl = Eatzy.util.GlobalUtil.getRefreshStatus();
		      var lat = Eatzy.util.CommonUtil.getUserLatitude();
		      var userLongitude = Eatzy.util.CommonUtil.getUserLongitude();
		      //alert("lat== "+lat+"long== "+long);
		      if(loginUserRecordObject!=undefined){
		    	  var paramsObject = { 
				          	'id' : loginUserRecordObject.get('userId'),
				          	'token' : loginUserRecordObject.get('userToken'),
				          	'request': requestUrl,
				          	'lat':lat,
				          	'lng':userLongitude
				            };
		    	  currentObject.commonWebServiceCall( 'POST', paramsObject, callBackFunction, currentObject );
		      }
		     
	     },
	     /**
	      * Function: To handle periodically check in of drivers success data
	      * @params: serviceResponseStatus- Webservice call response either success or fail.
	      * @params: responseData- Json data object as a response.
	      * @params: currentObject- Current object of controller.
	      * **/
	     onCheckInCurrentDriversOrderSuccessCallback:function(serviceResponseStatus, responseData, currentObject){
	    	 
	    	 var responseData = Ext.JSON.decode(responseData.responseText);
	    	 Eatzy.util.CommonUtil.setDriverCheckInFlagData(responseData);
	     },
	     /**
	     * Function: To retrieve messages for driver.
	     * 
	     * ***/
	    getMessagesForDriver:function(currentObject,callBackFunction){
	    	  var loginStore = Ext.getStore('loginStoreId');
	    	  if(loginStore.getAllCount() > 0){
			      var loginUserRecordObject = loginStore.getAt(0);
			   
			      var requestURL =  Eatzy.util.GlobalUtil.getUserMessages(); 
			      var paramsObject = { 
									   'id' : loginUserRecordObject.get('userId'),
									   'token' : loginUserRecordObject.get('userToken'),
									   'request': requestURL
		         };
			    
			      currentObject.commonWebServiceCall( 'POST', paramsObject,callBackFunction,currentObject);
	    	  }
	    },
	    /**
	     * Function: To handle get messages data.
	     * @params: serviceResponseStatus- Webservice call response either success or fail.
	     * @params: responseData- Json data object as a response.
	     * @params: currentObject- Current object of controller.
	     * **/
	    onSoccessCallbackOfGetMessagesOfDriver:function(serviceResponseStatus, responseData, currentObject){
	    	//console.log("In onSoccessCallbackOfGetMessagesOfDriver 0000000000",responseData);
	    	    var validationErrors = [];
	    		var chatStore = Ext.getStore('chatdStoreId');
	    	    //chatStore.removeAll();
	    		//console.log("chatStore.getAllCount() :=== "+chatStore.getAllCount());
	    		if(responseData.error!= undefined){
	    			var description = (responseData.description==undefined) ? "no data found." : responseData.description;
		            validationErrors.push(responseData.description);
		            if( Ext.getCmp('messageBoxOverlayId')!=undefined){
		            	Ext.getCmp('messageBoxOverlayId').destroy();
		            }
		            Eatzy.util.CommonUtil.showErrors(validationErrors);
	    			
	    		}else{
	    			if(responseData.length > 0 ){
	    				if(responseData.length > chatStore.getAllCount() ||chatStore.getAllCount() == 0 ){
	    					chatStore.removeAll();
	    					for(var intI=0;intI<responseData.length;intI++){
		        				 var chatModel = Ext.create('Eatzy.model.ChatModel',{
		         	    			date:( responseData[intI].date==undefined ||responseData[intI].date=="")?"":responseData[intI].date, 
		         	    			text:( responseData[intI].text==undefined ||responseData[intI].text=="")?"":responseData[intI].text, 
		         	    			type:( responseData[intI].type==undefined ||responseData[intI].type=="")?"":responseData[intI].type
		         	    			
		         	            });
		         	    		 chatModel.setDirty(true);
		         	             chatStore.add(chatModel);
		        			}
		        			chatStore.sync();
		        			chatStore.sort('date','ASC');
		        			var list = Ext.getCmp('chatMessageListId');
		        			if(list != undefined){
		        				//console.log("In scroll down ");
		        				list.getScrollable().getScroller().scrollToEnd(false);
		        			}
	    				}
	        			
	        			//
	        		}else{
	        			
	        			if(responseData!=undefined || responseData!=null){
	        				if(responseData.error =="clockin_notyet"){
	    	            		Eatzy.util.CommonUtil.setIsClockInFirst(true);
	    	            		if(Ext.getCmp('doClockInFirstBtn')!=undefined){
	    	            			Ext.getCmp('doClockInFirstBtn').setHidden(false);
	    	            		}else{
	    	            			if(Ext.getCmp('doClockInFirstBtn')!=undefined){
	    	            				Ext.getCmp('doClockInFirstBtn').setHidden(true);
	    	            			}
	    	            			
	    	            		}
	    	            		
	    	            	}
	    	            		    	            	
	    	           	   
	    	            }else{
	    	           	  validationErrors.push("No messages data found.");
	    	           	  //Eatzy.util.CommonUtil.showErrors(validationErrors);
	    	            }
	    	            if( Ext.getCmp('messageBoxOverlayId')!=undefined){
	    	            	Ext.getCmp('messageBoxOverlayId').destroy();
	    	            }
	    	            
	    	            
	        		}
	    		}
	    		//console.log("chatStore.getAllCount()",chatStore);
	    		 if(Eatzy.util.CommonUtil.getIsCalledFromStatusView()==false){
	    			//To check driver is clocked in
	 	    		Eatzy.util.CommonUtil.periodicallyCheckInDriverCurrentDriversOrder(currentObject,Eatzy.util.CommonUtil.onSuccessOfPeriodicCheckIn);
	    		 }else{
	    			 Eatzy.util.CommonUtil.toSetStatusViewChatBubbleTextAndMessageCount();
	    		 }
	    		
	    	
	    },
	    
	     /**
	      * Function: To save exit time of chat screen
	      * */
	     doSaveChatScreenExitTime:function(){
	    	//Insert data into chat screen exit store
	     	var chatdScreenExitTimeStore = Ext.getStore('chatScreenExitTimeStoreId');
	     	chatdScreenExitTimeStore.removeAll();
	     	
	     	//console.log("in doSaveChatScreenExitTime new Date() :=== ",new Date());
	     	var currentDate = new Date();
	     	var chatdScreenExitTimeModel  = Ext.create('Eatzy.model.ChatScreenExitTimeModel',{
	     		//Date.UTC(year,month,day,hours,minutes,seconds,millisec)
	     		
	     		        exitTime:currentDate.toUTCString()
	  	    			
	  	            });
	     	chatdScreenExitTimeModel.setDirty();
	     	chatdScreenExitTimeStore.add(chatdScreenExitTimeModel);
	     },
	     /**
	      * Function:To set latest message on message bubble and it's unread message count.
	      * 
	      * 
	      * */
	     toSetStatusViewChatBubbleTextAndMessageCount:function(){
	    	 var chatMessageStore = Ext.getStore('chatdStoreId');
	    	 var chatScreenExitTimeStore = Ext.getStore('chatScreenExitTimeStoreId');
	    	 //console.log("chatScreenExitTimeStore :=== ",chatScreenExitTimeStore);
             var messageStoreCount = chatMessageStore.getAllCount();
             var latestMessagesArray =[];
             var latestMessage ='';
             if(messageStoreCount > 0){
            	 for(var i=0;i<messageStoreCount;i++){
	            		var record = chatMessageStore.getAt(i);
	            		//console.log("record :=== ",record.get('date'));
            	
	            	    var dateTimeSplit = record.get('date').split(" ");
	 	          		var dateSplit = dateTimeSplit[0].split("-");
	 	          		var timeSplit = dateTimeSplit[1].split(":");
	 	          		var offset = new Date().getTimezoneOffset() / 60;
	 	          		var offsetNew = (3600000*(offset+0)*-1); // 0 for utc date time offset
	 	          		var d = new Date(dateSplit[0], dateSplit[1]-1, dateSplit[2], timeSplit[0], timeSplit[1], timeSplit[2]);
	 	          		//console.log("offset:=== ",offsetNew);
	 	          		var nd = new Date(d.getTime() + offsetNew);
	 	          		
	 	          		
	        		 	 var exitDateTimeRecord = chatScreenExitTimeStore.getAt(0);
	            		 var d2 = new Date(exitDateTimeRecord.get('exitTime'));
	            		 //console.log("record.get message :=== "+d2);
	            		 //console.log("record.get message :=== "+record.get('text'));
	            		 //console.log("d1 time==="+nd.getTime());
	            		 //console.log("d2 time==="+d2.getTime());
	            		 if ((nd.getTime() > d2.getTime())&& record.get('type')=="R") {
	            		     //console.log ("Check!" ,record.get('type'));
	            		     latestMessagesArray.push(record);
	            		 }
            		             		 
            	 }
            	 latestMessageRecord= chatMessageStore.getAt(messageStoreCount-1);
            	 //console.log("latestMessages Length:=== ",latestMessagesArray.length);
            	 //console.log("latestMessages :=== ",latestMessagesArray);
            	 var windowHeight  = Eatzy.util.GlobalUtil.getScreenHeight(); //added by #1044
            	 var windowWidth   = Eatzy.util.GlobalUtil.getScreenWidth();  //added by #1044
            	 if(latestMessagesArray.length > 0 ){
            		 //console.log("In latest message array  :=== ");
            		 Ext.ComponentQuery.query('panel[name=messageBubblePanel]')[0].setHtml('<div align="center" class="chatBadgeDivCls" style="width:'+windowWidth*0.071875+'px;height:'+windowWidth*0.071875+'px;font-family:Roboto-Light;font-size:'+windowHeight*0.0220070422535211+'px;top:-'+windowHeight*0.0176056338028169+'px;padding:'+windowHeight*0.0003961265625+'px;line-height:'+windowWidth*0.071875+'px;">'+latestMessagesArray.length+'</div>');
            		 Ext.ComponentQuery.query('label[name=statusChatBubbleLabel]')[0].setHtml('<div style="padding-top:1px;padding-left:20px;font-size:'+windowHeight*0.022887323943662+'px;color:#000;white-space: nowrap; width: '+windowWidth * 0.634375+'px; overflow: hidden;text-overflow: ellipsis;">'+latestMessagesArray[latestMessagesArray.length-1].get('text')+'<div style="font-size:'+windowHeight*0.0140845070422535+'px;color:#000;">'+this.getFormattedMessageDate(latestMessagesArray[0].get('date'))+'</div></div>');
            	 }else{
            		 Ext.ComponentQuery.query('panel[name=messageBubblePanel]')[0].setHtml('<div align="center" class="chatBadgeDivCls" style="font-family: Roboto-Light;width:'+windowWidth*0.071875+'px;height:'+windowWidth*0.071875+'px;font-size:'+windowHeight*0.0220070422535211+'px;top:-'+windowHeight*0.0176056338028169+'px;padding:'+windowHeight*0.0003961265625+'px;line-height:'+windowWidth*0.071875+'px;">0</div>');
            		 Ext.ComponentQuery.query('label[name=statusChatBubbleLabel]')[0].setHtml('<div style="padding-top:1px;padding-left:20px;white-space: nowrap; width: '+windowWidth * 0.634375+'px; overflow: hidden;text-overflow: ellipsis;font-size:'+windowHeight*0.022887323943662+'px;color:#000;">No Data Available.<div style="font-size:'+windowHeight*0.0140845070422535+'px;color:#000;"></div></div>');
            	 }
	     }
	 },
	 messageFunction:function(currentObject){
		 //console.log("in test",currentObject);
		 Eatzy.util.CommonUtil.getMessagesForDriver(currentObject,Eatzy.util.CommonUtil.onSoccessCallbackOfGetMessages);
	 },
	 onSoccessCallbackOfGetMessages:function(serviceResponseStatus, responseData, currentObject){
		 //console.log("onSoccessCallbackOfGetMessagesOfDriver1");
		 setTimeout(function(){
			 Eatzy.util.CommonUtil.onSoccessCallbackOfGetMessagesOfDriver(serviceResponseStatus, responseData, currentObject);
		 },1000);
	 },
	 getFormattedMessageDate:function(date){
		
	    var dateTimeSplit = date.split(" ");
   		var dateSplit = dateTimeSplit[0].split("-");
   		var timeSplit = dateTimeSplit[1].split(":");
   		//var offset = new Date(date).getTimezoneOffset() / 60;
   		var offset = new Date(date.replace(/-/g, '/')).getTimezoneOffset() / 60;   //to resolve date issue in IOS devices
   		var offsetNew = (3600000*(offset+0)*-1); // 0 for utc date time offset
   		var d = new Date(dateSplit[0], dateSplit[1]-1, dateSplit[2], timeSplit[0], timeSplit[1], timeSplit[2]);
   		
   		var nd = new Date(d.getTime() + offsetNew);
   		return Ext.Date.format(nd, 'M d, h:i a');
	 },
	 
	 /*
     * Function: used to get Current Lat Long.
     * */  
     getCurrentLatLong : function(){
    	var me = this;
    	var validationErrors = [];
    	if(navigator.geolocation){
	    	navigator.geolocation.getCurrentPosition(   		
	  		      function(position) {
	  		    	 
	  		    	 if(position.coords.latitude != undefined || position.coords.latitude != null || position.coords.latitude != "" || position.coords.longitude != undefined || position.coords.longitude != null || position.coords.longitude != "" ){
	  		    		Eatzy.util.CommonUtil.setUserLatitude(""+position.coords.latitude);
		  		    	Eatzy.util.CommonUtil.setUserLongitude(""+position.coords.longitude);
		  		    	
					 }else{
						//Eatzy.util.CommonUtil.setUserLatitude(0);
			  		    //Eatzy.util.CommonUtil.setUserLongitude(0);
	                    validationErrors.push('Unable to get your current location. Please turn on GPS from device settings.');
	                    Eatzy.util.CommonUtil.showErrors(validationErrors);
					 }
	  		    	 //Eatzy.util.CommonUtil.periodicallyCheckInDriverCurrentDriversOrder(currentObject,callbackFunction);*/
	  		    	 
	  		      },
	  		      function(error) {
	  		    	  /*Eatzy.util.CommonUtil.setUserLatitude(0);
		  		      Eatzy.util.CommonUtil.setUserLongitude(0);*/
	  		    	  validationErrors.push('Unable to get your current location. Please turn on GPS from device settings.');
                      Eatzy.util.CommonUtil.showErrors(validationErrors);
                      //Eatzy.util.CommonUtil.periodicallyCheckInDriverCurrentDriversOrder(currentObject,callbackFunction);
	  		      },
	  		      {
	  		    	 maximumAge : Infinity,
	     	         timeout : 10000,
	     	         enableHighAccuracy: true
	     	      }
			);
    	}
     },
     /**Function: To create top toolbar panel with back button**/
     createTopToolbar:function(){
    	 var windowHeight = Ext.Viewport.getWindowHeight();
    	 var windowWidth = Ext.Viewport.getWindowWidth();
    	 var topToolbarPanel= {
        	 xtype:'panel',
        	 width: '100%',//windowWidth * 0.8405797101449275,
        	 height: windowHeight*0.0783450704225352,
        	 style:'background-color: #127182;',
        	 layout: {
		             type: 'hbox',
		             pack: 'center',
		             align: 'center'
        	 },
        	 items:[
        	        
        	        {
        	        	xtype: 'button',
        	        	name: 'bakButtonName',
        	        	action:'externalBrowserPageBackButton',
        	        	width: '15%',
        	        	height:'95%',
        	        	padding:'0 0 0 0',
        	        	cls:'backButtonCls',
        	        	style:'margin-top:'+windowHeight*0.0290492957746479+'px;',
        	        	left:0
        	        },	
        	        {
						xtype: 'label',
						width:'54%',
						height: windowHeight * 0.04375,
						margin:'0 0 0 0',
        	        	padding:'0 0 0 0',
        	        	cls:'chatScreenTitleCls',
        	        	html:'<div align="center">In App Browser</div>',
			        	style: 'font-size:'+windowWidth * 0.0563607085346216+'px'
					}
		    ]
	     };
    	 return  topToolbarPanel;
     },
     /**
      * Function: To retrive device token for android and IOS
      * @{param} : platform i.e Android IOS
      * */
     deviceRegisterationForPushNotification:function(platform){
    	 var me = this;
    	 onNotificationGCM = function(e) {
             switch( e.event )
             {
                 case 'registered':
                     if ( e.regid.length > 0 )
                     {
                             console.log('REGISTERED -> REGID:' + e.regid );
                             var deviceTokenStore = Ext.getStore('deviceTokenStoreId');
                             deviceTokenStore.removeAll();
                             var deviceTokenModel = Ext.create('Eatzy.model.DeviceTokenModel',{
                                  
                                    deviceToken:e.regid
                             });
                             deviceTokenModel.setDirty();
                             deviceTokenStore.add(deviceTokenModel)
                     		
                     		 Eatzy.util.CommonUtil.setDeviceToken(e.regid);
                     	
                     }
                     break;
                 case 'message':
                     console.log('gcm: on message ');
                     break;

                 case 'error':
                     console.log( "gcm error: "+e.msg );
                     var validationErrors = [];
                     validationErrors.push(e.msg);
                     Eatzy.util.CommonUtil.showErrors(validationErrors);
                     break;
                 default:
                     break;
             }
         };
         onNotificationAPN = function(e) {
         	 if ( event.alert )
         	    {
         	        navigator.notification.alert(event.alert);
         	    }

         	    if ( event.sound )
         	    {
         	        var snd = new Media(event.sound);
         	        snd.play();
         	    }

         	    if ( event.badge )
         	    {
         	       // pushNotification.setApplicationIconBadgeNumber(successHandler, errorHandler, event.badge);
         	    }
         };


         tokenHandler = function(status) {
//                 console.log("on register device for ios token handler...." + status);
                 alert("Device token:"+status);
                 var deviceTokenStore = Ext.getStore('deviceTokenStoreId');
                 deviceTokenStore.removeAll();
                 var deviceTokenModel = Ext.create('Eatzy.model.DeviceTokenModel', {
                         deviceToken: status
                     });
                 deviceTokenModel.setDirty();
                 deviceTokenStore.add(deviceTokenModel);
                 Eatzy.util.CommonUtil.setDeviceToken(status);
         };
       
         registerDeviceFailureCallback = function(error) {
                 console.log("Error for register device " + error.message);
         };
         
         
    	 pushNotification = window.plugins.pushNotification;
         if (platform == 'android' || platform == 'Android' || platform == "amazon-fireos") {
             try {
                 pushNotification.register(function(response){
                 	console.log("In register device success  "+response);
                 	
                 }, function(error){
                 	console.log("In register device failure "+JSON.stringify(error));
                 }, {
                     "senderID": "8967377732",
                     "ecb":"onNotificationGCM"
                 });
               
             } catch (err) {
                 txt = "There was an error on this page.\n\n";
                 txt += "Error description: " + err.message + "\n\n";
                 //alert(txt);
                 var validationErrors = [];
  	            validationErrors.push(txt)
 	            Eatzy.util.CommonUtil.showErrors(validationErrors);
             }
         }else {

             pushNotification.register(
             	    tokenHandler,
             	    registerDeviceFailureCallback,
                     {
                         "badge":"true",
                         "sound":"true",
                         "alert":"true",
                         "ecb":"onNotificationAPN"
                     }
             	    );
             	}
     },
     reduceListItemHeight:function(){
    	 
    	 //console.log("reduceListItemHeight")
         var dom = Ext.select('.x-list-item');
         for( var i=0; i<dom.elements.length;i++){
             dom.elements[i].style.cssText = "30px";
         }
     },
     
     /**
      * used to clear all local store data
      * @param: store used to handle store object.  
      */
     removeStoreInfo:function(store){
  	   if(store){
  		   store.removeAll(true);
  	   }
     },
     
     /**
      * used to clear all local store data  
      */
     clearUsersBasicInfo:function(){
  	   var me = this;
  	   var messageInterval = Eatzy.util.CommonUtil.getMessageInterval();
  	   clearInterval(messageInterval);
  	   var checkInDriverInterval = Eatzy.util.CommonUtil.getCheckInDriverInterval();
  	   clearInterval(checkInDriverInterval);
  	   Eatzy.util.CommonUtil.setIsDriverStatusServiceCall(false);
  	   me.removeStoreInfo(Ext.getStore('loginStoreId'));
	   me.removeStoreInfo(Ext.getStore('chatdStoreId'));
	   me.removeStoreInfo(Ext.getStore('clockInOptionsStoreId'));
  	   Ext.Viewport.getActiveItem().destroy();
  	   if(Ext.getCmp('menuButtonDropDownOverlayViewId')!=undefined){
	 		 Ext.getCmp('menuButtonDropDownOverlayViewId').destroy();
  	   }
  	   var LoginView = Ext.create('Eatzy.view.LoginView');
  	   Ext.Viewport.add(LoginView);
  	   Ext.Viewport.setActiveItem(LoginView);
     },
     
     /*
      *This function is to show alert messages in app.       
      @message: Error message to display in overlay.
	   @isYesNoPresent: condition to check whether both yes and no buttons resent or not.
	   @buttonActionName: button action to handle button click event.
      */
      showAlertMessage : function(message, isYesNoPresent, buttonActionName) {
          if(message!= undefined && message.length != 0){
              var errorMessageWindow = Ext.create('Eatzy.view.widget.MessageBoxOverlay', { buttonAction: buttonActionName });
              Ext.Viewport.add(errorMessageWindow);
              var displayMessageOverlay = Ext.getCmp('messageBoxOverlayId');
              displayMessageOverlay.show();
              errorMessageWindow.showErrorMessages(message , isYesNoPresent);
              Eatzy.util.CommonUtil.hideLoadMask();
              return true;
          }else{
              return false;
          }

      },
      
      /*
       *  showToastMessage : function to show toast message
       *  @param{string} timeout- timeout value in milliseconds.
       */
      showToastMessage:function(message, timeout){
      	Ext.toast({message: message, timeout: timeout, cls:'commonToastCls'});
      },
      
      /**
       * Function: To periodic check in data.
       * @params: serviceResponseStatus- Webservice call response either success or fail.
       * @params: responseData- Json data object as a response.
       * @params: currentObject- Current object of controller.
       * **/
      onSuccessOfPeriodicCheckIn:function(serviceResponseStatus, responseData, currentObject){
      	if(serviceResponseStatus){
      		console.log("In success of get message periodic checkin status.");
      	}else{
  			try{
	  			var validationErrors = [];
	              responseData = Ext.JSON.decode(responseData.responseText);
	              if(responseData!=undefined){
	             	       //validationErrors.push(responseData.error);
	             	      //console.log("periodic checkin exception:: ",e.message);
	              }else{
	             	        //validationErrors.push("No data found.");
	              }
  			}catch(e){
  				console.log("periodic checkin exception:: ",e.message);
  			}
             
  		}
      }
});