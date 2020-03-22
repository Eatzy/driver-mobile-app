/**  Created by 1010
  *  July 7 2015
  *  Used to handle user match friends list 
**/
Ext.define('Eatzy.controller.ChatController',{
	extend:'Eatzy.controller.GenericController',
	config:{
		control:{
            'button[name = chatBackBtn]':{
                tap:'onBackButtonClick'
            },
            'button[name = chatOptionsBtn]':{
                tap:'showOptionOverlay'
            },
            'image[name = chatViewProfilePic]':{
                tap:'showMatchFriendsProfile'
            },
            'button[action = matchFriendsProfileAction]':{
                tap:'showMatchFriendsProfile'
            },
            'button[action = friendUnmatchAction]':{
                tap:'showUnmatchOverlayView'
            },
            'button[action = friendReportAction]':{
                tap:'showReportMatchView'
            },
            'button[action = closeMatchOptionOverlayView]':{
                tap:'closeCommonOverlayView'
            },
            'button[action = conformFriendUnmatchAction]':{
                tap:'conformFriendUnmatch'
            },
            'button[action = closeConformUnmatchOverlayView]':{
                tap:'closeConformUnmatchOverlay'
            },
            'button[name = chatMessageSendBtn]':{
                tap:'sendChatMessage'
            },
            'button[action = loadEarlierChatAction]':{
                tap:'doLoadEarlierChatMessage'
            },
            'panel[action = chatPanelAction]':{
                initialize:'onChatPanelInitialize'
            },
            'panel[name = chatView]':{
                initialize:'onInitializeOfChatView'
            },
            'button[action = doClockInFirst]':{
                tap:'doClockInFirst'
            },
            'list[name = chatMessageList]':{
            	initialize: 'pullDownChatList',
            	itemtap: 'onMessageLinkClick'
            }
            
            
                        
		}
			
	},
	
	/**
     * Function :  used to open Edit Itinerary View.
     *  
     * */
	showOptionOverlay : function(btnObj){
		var me = this;
	   	var buttons = [];
	   	
		btnObj.setDisabled(true);
		setTimeout(function(){
			btnObj.setDisabled(false);
		},2000);
		
	   	var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight(); 
	   	var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
	   	var buttonWidth = maxScreenWidth * 0.8733870967741935;
	   	var buttonHeight = buttonWidth * 0.1772853185595568;
	   	
	   	var cancelButtonBottomMargin = windowHeight * 0.0688405797101449;
	   	var otherButtonBottomMargin = windowHeight * 0.0108695652173913; 
	   	var userName=Ext.getCmp('chatFriendNameId').getHtml();
	   	
	   	var cancelbuttonStyle ="background: url('resources/images/3x/common_overlay_button_bg.png');margin-bottom:"+cancelButtonBottomMargin+"px;font-size:"+(maxScreenWidth * 0.05)+"px;color:#0095da";
	   	var otherButtonStyle ="background: url('resources/images/3x/common_overlay_button_bg.png');margin-bottom:"+otherButtonBottomMargin+"px;font-size:"+(maxScreenWidth * 0.05)+"px;color:#0095da";
   		
	   	buttons.push({xtype:'button', id:'matchProfile', text:'Show '+ userName +"'s"+' Profile',width:buttonWidth, height:buttonHeight, action:'matchFriendsProfileAction', cls:'commonOverlayBtnWithTextCls', style:otherButtonStyle});
	   	buttons.push({xtype:'button', id:'unmatchMatch', text:'Unmatch '+ userName ,width:buttonWidth, height:buttonHeight, action:'friendUnmatchAction', cls:'commonOverlayBtnWithTextCls', style:otherButtonStyle});
	   	buttons.push({xtype:'button', id:'reportMatch',  text:'Report '+ userName ,width:buttonWidth, height:buttonHeight, action:'friendReportAction', cls:'commonOverlayBtnWithTextCls', style:otherButtonStyle});
	   	buttons.push({xtype:'button', id:'cancel',       text:'Cancel', width:buttonWidth, height:buttonHeight, action:'closeMatchOptionOverlayView', cls:'commonOverlayBtnWithTextCls', style:cancelbuttonStyle});
	   	Eatzy.util.CommonUtil.showCommonOverlay(buttons);
		
		//Ext.Msg.alert("Eatzy","This functionality is not implemented."); 
    },
	
	/**
     * Function : used to show match friends list.
     */
    showMatchFriendsList : function(){
    	
    	/*if(SoftKeyboard != undefined){
    		SoftKeyboard.hide(); 
    	}*/
    	Eatzy.util.UserChatUtil.updateChatLastSeenTimeWebService();
    	var userChatFriendsStore = Ext.getStore("userChatFriendsStoreId");
    	userChatFriendsStore.clearFilter(true);
    	
    	// Start :- To save only last 15 message.
        var chatFriendId = parseInt(Eatzy.util.UserChatUtil.getChatFriendId());
    	var userChatFriendsRecord = userChatFriendsStore.findRecord( 'friendId', chatFriendId, 0, false, true, true); 
    	var userChatMessagesStore = userChatFriendsRecord.chatList();
    	userChatMessagesStore.sort('chatId','DESC');
    	var lastNChat=null;
    	if(userChatMessagesStore.getAllCount()>15){
    		lastNChat = userChatMessagesStore.getRange( 0, 14 ); 
    		userChatMessagesStore.removeAll();
        	userChatMessagesStore.setData(lastNChat);
        	userChatFriendsRecord.set('previousChatPresent',1);
        	//userChatMessagesStore.sort('chatId','ASC');
    	}
    	// End :- To save only last 15 message.
    	
    	
    	Eatzy.util.CommonUtil.showActiveView('Eatzy.view.userFriends.MatchFriendsListView');
    	if(Eatzy.util.UserChatUtil.getUnseenChatCount() > 0 || Eatzy.util.UserChatUtil.getUnSeenFriendCount() > 0){							
			var matchFriendListBubbleIcon = Ext.ComponentQuery.query("button[name=matchFriendListBubbleIcon]")[0];
			if(matchFriendListBubbleIcon){
				matchFriendListBubbleIcon.removeCls("matchFriendBubbleIconWithoutMessage");
				matchFriendListBubbleIcon.addCls("matchFriendBubbleIconWithMessage");
			}
		}
    },
    
    /**
     * Function : used to close Common OverlayView.
     */
    closeCommonOverlayView : function(){
  	   Ext.getCmp('commonOverlayId').hide();
  	   Ext.getCmp('commonOverlayId').destroy();
  	   /*if($("#chatTextField")){
  		   $("#chatTextField").blur();
  	   }*/
     },
     
     /**
      * Function : used to show match friend profile.
      */
     showMatchFriendsProfile : function(){
    	 //Eatzy.util.UserProfileUtil.getEatzyProfile();
		 Eatzy.util.UserProfileUtil.showMatchFriendsProfile();
    	 /*Ext.Msg.alert("Eatzy","This functionality is not implemented.");*/ 
     },
     
     /**
      * Function : used to show report match View.
      */
     showReportMatchView : function(){
    	 if(Ext.getCmp('commonOverlayId') != undefined){
    		 Ext.getCmp('commonOverlayId').hide();
        	 Ext.getCmp('commonOverlayId').destroy();
    	 }
    	 
    	 //Eatzy.util.UserChatUtil.updateChatLastSeenTimeWebService();
    	 var fromView;
    	 if(Ext.Viewport.getActiveItem().getId() == "EatzyProfileView"){
    		 fromView = "EatzyProfileView";
    	 }else if(Ext.Viewport.getActiveItem().getId() == "chatView"){
    		 fromView = "chatView";
    	 }
    	 Ext.Viewport.getActiveItem().destroy();
  	     var reportMatchView = Ext.create('Eatzy.view.ReportMatchView',{fromView:fromView});
  	     Ext.Viewport.add(reportMatchView);
  	     Ext.Viewport.setActiveItem(reportMatchView);
  	     
  	     //Ext.Msg.alert("Eatzy","This functionality is not implemented."); 
     },
     
     /**
      * Function : used to show Unmatch overlay View.
      */
     showUnmatchOverlayView: function(){
    	 Ext.getCmp('commonOverlayId').hide();
    	 Ext.getCmp('commonOverlayId').destroy();
    	 var buttons = [],labels = [];
    	 var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight(); 
 	   	 var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
 	   	 var buttonWidth = maxScreenWidth * 0.8733870967741935;
 	   	 var buttonHeight = buttonWidth * 0.1772853185595568;
 	   	
 	   	 var cancelButtonBottomMargin = windowHeight * 0.0688405797101449;
 	   	 var unmatchButtonBottomMargin = windowHeight * 0.0108695652173913; 
 	   	 
 		 var messageMarginBottom=windowHeight*0.0249094202898551;
 	   	 var messageWidth=maxScreenWidth*0.70;
 	   	
 	   	 var cancelbuttonStyle ="background: url('resources/images/3x/common_overlay_button_bg.png');margin-bottom:"+cancelButtonBottomMargin+"px;font-size:"+(maxScreenWidth * 0.05)+"px;color:#0095da";
 	   	 var unmatchButtonStyle ="background: url('resources/images/3x/common_overlay_button_bg.png');margin-bottom:"+unmatchButtonBottomMargin+"px;font-size:"+(maxScreenWidth * 0.05)+"px;color:#0095da";
    		
 	   	 buttons.push({xtype:'button', id:'conformUnmatch',  text:'Unmatch',width:buttonWidth, height:buttonHeight, action:'conformFriendUnmatchAction', cls:'commonOverlayBtnCls', style:unmatchButtonStyle});
 	   	 buttons.push({xtype:'button', id:'cancel',       text:'Cancel', width:buttonWidth, height:buttonHeight, action:'closeConformUnmatchOverlayView', cls:'commonOverlayBtnCls', style:cancelbuttonStyle});
 	   	
 	     labels.push({width:messageWidth, html:"Are you sure you want to unmatch your Eatzy?",style:"margin-bottom:"+messageMarginBottom+"px;font-size:"+maxScreenWidth * 0.05+"px"});
	   	 Eatzy.util.CommonUtil.showCommonOverlayWithMessage(labels, buttons);
     },
     
     /**
      * Function : used to close Common OverlayView.
      */
     closeConformUnmatchCommonOverlayView : function(){
    	 var me = this;
    	 Ext.getCmp('commonOverlayId').hide();
   	   	 Ext.getCmp('commonOverlayId').destroy();
   	   	 me.showOptionOverlay();
     },
     
     /**
      * Function : used to unmatch friend.
      */
     conformFriendUnmatch : function(){
    	 var me = this;
    	 Ext.Viewport.setMasked({xtype:'loadmask',message:'Loading please wait.', indicator:true});
    	 var jsonData = {
			"login_user_id": Eatzy.util.CommonUtil.getLoginUserId(),
			"friend_user_id" : Eatzy.util.UserChatUtil.getChatFriendId()
    	 };
	     var unMatchFriendUrl = Eatzy.util.GlobalUtil.getWebServiceDomain() + Eatzy.util.GlobalUtil.getUnMatchFriendUrl();
	     Eatzy.util.GlobalUtil.commonWebServiceCall('POST', unMatchFriendUrl, me.conformFriendUnmatchCallBack, this, jsonData, false);
     },
     
     conformFriendUnmatchCallBack : function(serviceResponseStatus, responseData, currentObject){
    	 Ext.Viewport.unmask();
    	 Ext.getCmp('commonOverlayId').hide();
    	 Ext.getCmp('commonOverlayId').destroy();
    	 if(responseData.success){
    		 //Start :- Send unmatch friend notification to friend.
    		 var message= {
    				"type":"unmatch",
	 				"sender_id":parseInt(Eatzy.util.CommonUtil.getLoginUserId()),
	 				"receiver_id":Eatzy.util.UserChatUtil.getChatFriendId()
	 				
	 		}; 
	 		Eatzy.util.UserChatUtil.sentMessageToWebSocket(message);
	 		//End :- Send unmatch friend notification to friend.
	 		
    		 var userChatFriendsStore = Ext.getStore('userChatFriendsStoreId');
    		 var userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', Eatzy.util.UserChatUtil.getChatFriendId(), 0, false, true, true); 
    		 userChatFriendsStore.remove(userChatFriendsModel);
    		 Eatzy.util.CommonUtil.showActiveView('Eatzy.view.userFriends.MatchFriendsListView');
    		 if(Eatzy.util.UserChatUtil.getUnseenChatCount() > 0 || Eatzy.util.UserChatUtil.getUnSeenFriendCount() > 0){							
    				var matchFriendListBubbleIcon = Ext.ComponentQuery.query("button[name=matchFriendListBubbleIcon]")[0];
    				if(matchFriendListBubbleIcon){
    					matchFriendListBubbleIcon.removeCls("matchFriendBubbleIconWithoutMessage");
    					matchFriendListBubbleIcon.addCls("matchFriendBubbleIconWithMessage");
    				}
    			}
    	 }else{
    		 Eatzy.util.GlobalUtil.showApplicationMessage("Eatzy", responseData.error_message);
    	 }
     },
     
     	
 	/**
     * Function : used to close ConformUnmatch Overlay.
     */
 	closeConformUnmatchOverlay : function(){
 		var me = this;
 		if(Ext.getCmp('commonOverlayId')){
 			Ext.getCmp('commonOverlayId').hide();
 	 		Ext.getCmp('commonOverlayId').destroy();
 		}
 		me.showOptionOverlay();
 	},

 	/**
     * Function : used to send chat message.
     */
 	sendChatMessage: function(btnObj){
 		var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
 		var content = document.getElementById('chatTextField').value.trim();
 		var sendButtonOriginalStyle;
		var sendButton = Ext.ComponentQuery.query("button[name=chatMessageSendBtn]")[0];
		var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
		var panelHeight = windowHeight - ((windowHeight*0.0783450704225352) + (windowHeight * 0.0985915492957746) + (windowHeight * 0.0988671875));
		
		//below code added by #1044 for resize chat screen components after message send
		
		Ext.getCmp('chattingParentPanelId').setHeight(panelHeight);
		Ext.getCmp('sendButtonParentPanelId').setHeight(windowHeight * 0.0984915492957746);
		$("#chatTextField").css('height',windowHeight * 0.0480072463768116);
		Ext.getCmp('chatMessageListId').setHeight(panelHeight); //added by #1044
		
		$("#chatTextField").css('overflow', 'hidden');
		$("#hiddenDivId").html('');
		
		sendButton.setDisabled(true);

		
		var loginStore = Ext.getStore('loginStoreId');
	    var loginUserRecordObject = loginStore.getAt(0);
	    var paramsObject = { 
  	          	'id' : loginUserRecordObject.get('userId'),
  	          	'token' : loginUserRecordObject.get('userToken'),
  	          	'request': 'sendmessage',
  	          	'm':content
  	          
  	            };
	    this.commonWebServiceCall( 'POST', paramsObject, this.onSuccessCallBackOfMessageSend, this );
	    document.getElementById('chatTextField').value="";
	  
	    
	    
 		
 	},
 	/**
     * Function: To handle clock in user data
     * @params: serviceResponseStatus- Webservice call response either success or fail.
     * @params: responseData- Json data object as a response.
     * @params: currentObject- Current object of controller.
     * **/
 	onSuccessCallBackOfMessageSend:function(serviceResponseStatus, responseData, currentObject){
 		if(serviceResponseStatus){
 			
 		    Eatzy.util.CommonUtil.getMessagesForDriver(currentObject,currentObject.onSoccessCallbackOfGetMessages);
 		}else{
 			 Eatzy.util.CommonUtil.hideLoadMask();
             var validationErrors = [];
             responseData = Ext.JSON.decode(responseData.responseText);
             if(responseData.description){
            	 validationErrors.push(responseData.description);
             }else{
            	 validationErrors.push(responseData.error);
             }
             
           
 		}
 		
 	},
 	doLoadEarlierChatMessage:function(){
 		
 		/*var scrollable = Ext.getCmp('chatPanelId').getScrollable().getScroller();
	    var height = Ext.getCmp('chatPanelId').getMaxHeight().toFixed(0);
		var scrollerYPosition = scrollable.getSize().y;	
		
 		var me=this;
 		var lastChatObject=Ext.getCmp('chatPanelId').getAt(1);
 		if(lastChatObject==undefined){
 			//Alert message
 			return;
 		}
 		var lastChatId = lastChatObject.getId( );
 		var userCredentialsStore = Ext.getStore('userCredentialsStoreId');
		var loginUser = userCredentialsStore.getAt(0);
 		var jsonData = {
 				"login_user_id": parseInt(Eatzy.util.CommonUtil.getLoginUserId()),
 				"friend_user_id" : Eatzy.util.UserChatUtil.getChatFriendId(),
 				"chat_id" : parseInt(lastChatId),
 				"Access-Token" : loginUser.get("access_token")
 	    	 };*/
 		//Ext.Viewport.setMasked({xtype:'loadmask',message:'Loading...', indicator:true});
 		//var previousChatHistoryUrl = Eatzy.util.GlobalUtil.getWebServiceDomain() + Eatzy.util.GlobalUtil.getPreviousChatHistoryUrl();
	    //Eatzy.util.GlobalUtil.commonWebServiceCall('POST', previousChatHistoryUrl, me.getPreviousChatHistoryCallBack, me, jsonData, true);
 	},
 	getPreviousChatHistoryCallBack: function(serviceResponseStatus, responseData, currentObject){
 		
 		if(responseData != null && responseData.success){
			Eatzy.util.UserChatUtil.updateDetailsInUserChatFriendStore(responseData);
			Eatzy.util.UserChatUtil.showPreviousChatMessageView(responseData);
    	}else{
	   		 Eatzy.util.GlobalUtil.showApplicationMessage("Eatzy", responseData.error_message);
	   	}
 		
 		Ext.Viewport.unmask();
 	},
 	
 	onChatPanelInitialize:function(self, eOpts){
        var me = this;
       /* var scroller = self.getScrollable().getScroller();
        scroller.on('scroll',function(scroller, x, y, eOpts){
            var scrollerObj = document.getElementsByClassName("x-inner x-panel-inner x-vertical x-align-start x-pack-start x-layout-box x-scroll-scroller-vertical x-size-monitored x-paint-monitored x-scroll-scroller");
            
            if(y <= 0){
            	scrollerObj[0].style.transform = "translate3d(0px, 0px, 0px)";
        		scrollerObj[0].style.webkitTransform = "translate3d(0px, 0px, 0px)";
        		scrollerObj[0].style.MozTransform = "translate3d(0px, 0px, 0px)";
        		scrollerObj[0].style.msTransform = "translate3d(0px, 0px, 0px)";
        		scrollerObj[0].style.OTransform = "translate3d(0px, 0px, 0px)";
        		scrollerObj[0].style.transform = "translate3d(0px, 0px, 0px)";
            }else{
            	scrollerObj[0].style.transform = "translate3d(0px, "+(-y)+"px, 0px)";
        		scrollerObj[0].style.webkitTransform = "translate3d(0px, "+(-y)+"px, 0px)";
        		scrollerObj[0].style.MozTransform = "translate3d(0px, "+(-y)+"px, 0px)";
        		scrollerObj[0].style.msTransform = "translate3d(0px, "+(-y)+"px, 0px)";
        		scrollerObj[0].style.OTransform = "translate3d(0px, "+(-y)+"px, 0px)";
        		scrollerObj[0].style.transform = "translate3d(0px, "+(-y)+"px, 0px)";
            }
        });*/
    },
    /***
     * Function: To display status view .
     * 
     * */
    onBackButtonClick:function(buttonObj){
    	
    	var loginStore = Ext.getStore('loginStoreId');
    	//Insert data into chat screen exit store
    	var chatScreenExitTimeStore = Ext.getStore('chatScreenExitTimeStoreId');
    	chatScreenExitTimeStore.removeAll();
    	
    	console.log("new Date() :=== ",new Date());
    	var chatScreenExitTimeModel  = Ext.create('Eatzy.model.ChatScreenExitTimeModel',{
    		        exitTime:new Date()
 	    			
 	            });
    	chatScreenExitTimeModel.setDirty();
    	chatScreenExitTimeStore.add(chatScreenExitTimeModel);
    	var loginRecord = loginStore.getAt(0);
    	if(Ext.ComponentQuery.query('panel[name=statusView]')[0]!=undefined ||Eatzy.util.CommonUtil.getIsDriverClockIn() ){
    		Ext.getCmp('chatContainer').removeAt(0);
    		Ext.getCmp('chatContainer').add({xtype:'statusView'});
    		if(Eatzy.util.CommonUtil.getIsStatusViewDisplay()){
    			Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("activeButtonCls");
               	Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signOutButtonCls");
               	Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("ACTIVE");
    		}else{
    			Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("offButtonCls");
    		    Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signInButtonCls");
    		    Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("NOT ACTIVE");
    		}
    		
    	}else{
    		
    		Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
    		
    	}
	    Ext.ComponentQuery.query('panel[name=chatView]')[0].setHidden(true);
	    //To set messgae unread count and 
	    Eatzy.util.CommonUtil.toSetStatusViewChatBubbleTextAndMessageCount();

		Ext.ComponentQuery.query('button[name=ridersName]')[0].setText(loginRecord.get('rds_name').toUpperCase());
	
    },
    /**
     * Function: This function get called on init of chat view
     * 
     * */
    onInitializeOfChatView:function(){
    	var me =this;
    	
        var messageInterval = setInterval(function(){
	    	
        	Eatzy.util.CommonUtil.getMessagesForDriver(me,me.onSoccessCallbackOfGetMessages);
	    	
	     },7000);
       
        Eatzy.util.CommonUtil.setMessageInterval(messageInterval);
    },  /**
    /**
      * Function: To handle ger messages of driver success data
      * @params: serviceResponseStatus- Webservice call response either success or fail.
      * @params: responseData- Json data object as a response.
      * @params: currentObject- Current object of controller.
      * **/
    onSoccessCallbackOfGetMessages:function(serviceResponseStatus, responseData, currentObject){
    	// console.log("responseData :==== ",responseData);
    	 Eatzy.util.CommonUtil.onSoccessCallbackOfGetMessagesOfDriver(serviceResponseStatus, responseData, currentObject);
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
			
			var validationErrors = [];
            responseData = Ext.JSON.decode(responseData.responseText);
            if(responseData!=undefined){
           	       validationErrors.push(responseData.error);
            }else{
           	        validationErrors.push("No data found.");
            } 
           
		}
    },
    doClockInFirst:function(){
    	var loginStore = Ext.getStore('loginStoreId');
    	var loginRecord = loginStore.getAt(0);
    	
    	if(Ext.ComponentQuery.query('panel[name=statusView]')[0]!=undefined || Eatzy.util.CommonUtil.getIsDriverClockIn() ){
    		//Ext.getCmp('chatContainer').removeAt(0);
    		Ext.getCmp('chatContainer').add({xtype:'statusView'});
    		Ext.ComponentQuery.query('button[name=activeOffButton]')[0].setCls("offButtonCls");
		    Ext.ComponentQuery.query('button[name=commonButtonForSignInOut]')[0].setCls("signInButtonCls");
		    Ext.ComponentQuery.query('button[name=commonActiveNotActiveButton]')[0].setText("NOT ACTIVE");
    	}else{
    		
    		Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
    		
    	}
	        Ext.ComponentQuery.query('panel[name=chatView]')[0].setHidden(true);
		
		    Ext.ComponentQuery.query('button[name=ridersName]')[0].setText(loginRecord.get('rds_name').toUpperCase());
    	    Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
	    	Ext.getCmp('mainTabPanel').setActiveItem(3);
	    	
	         
    },
    /**
	 * Function: Used to on apply scroll event to load chat message on pull down.
	 * @param{object} componentObject: component object
	 * @param{object} eOpts: event object.
	 */
     pullDownChatList:function(self, eOpts){
    	 var me = this;
         var scroller = self.getScrollable().getScroller();
         /*var loadEarlierChatBtn = Ext.ComponentQuery.query('button[name=loadEarlierChatBtnName]')[0];
         var chatMessageList = Ext.ComponentQuery.query('list[name=chatMessageList]')[0];*/
         //scroller.setInitialOffset(0);
        
         scroller.on('refresh',function(){
        	
        		 scroller.scrollToEnd(false); 
        
         });
     },
     onMessageLinkClick:function( chatList, index, target, record, e, eOpts){
    	 //console.log("List item click ",e.target.id);
    	 //console.log("List item click ",record.data.text);
    	 if(e.target.id.match(/link/g)){
    		 /*if(record.data.text.length<=20 ||record.data.text.length>20 ){
    			//|| record.data.text.length<=20 || e.target.id.match(/ext-element/g)||e.target.id.match(/ext-simplelistitem/g) 
    		 var urlText="";
    		 var urlRegex = /(((https?:\/\/)|(www\.)|(http:?:\/\/))[^\s]+)/g;
             //var urlRegex = /(https?:\/\/[^\s]+)/g;
             var textMessageWithLinks = record.data.text.replace(urlRegex, function(url,b,c) {
                 var url2 = (c == 'www.') ?  'http://' +url : url;
                 var id = record.data.id;
                 if(c == 'www.'){
                	 urlText='http://' +url ;
                 }
                 //return '<a id="link_'+id+'">' + url + '</a>';
                 if(urlText.length>0){
                	  var externalBrowserPageView = Ext.create('Eatzy.view.ExternalBrowserPageView',{requestedURL:urlText });
                      Ext.Viewport.add(externalBrowserPageView);
                      Ext.Viewport.setActiveItem(externalBrowserPageView);
                 }
               
             }) ;
            
    	 }else{*/
    		 var externalBrowserPageView = Ext.create('Eatzy.view.ExternalBrowserPageView',{requestedURL:e.target.innerHTML });
             Ext.Viewport.add(externalBrowserPageView);
             Ext.Viewport.setActiveItem(externalBrowserPageView);
    	 
             
    		
    	 }
    	/* var externalBrowserPageView = Ext.create('Eatzy.view.ExternalBrowserPageView',{requestedURL: });
         Ext.Viewport.add(externalBrowserPageView);
         Ext.Viewport.setActiveItem(externalBrowserPageView);*/
     }
});