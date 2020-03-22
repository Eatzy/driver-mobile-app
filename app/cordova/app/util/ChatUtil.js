/*
 * Created by 1010
 * July 7, 2015.
 * Used to maintain user chat functionality.
 */

Ext.define('Eatzy.util.ChatUtil',{
	
	singleton:true,
	
	config : {
		chatFriendId:'',
		loginUserId:'',
		accessToken:'',
		webSocketConnection:'',
		isMaxHeightReached:false,
		hiddenDivInitialHeight:0,
		isClicked:false
    },
	
	constructor : function(config) {
        this.initConfig(config);
        this.callParent([config]);
    },
    
    /**
     * do Web Socket Connection
     **/
    doWebSocketConnection: function(){
    	var me=this;
    	var isConnectionOpen=false;
    	var url = 'ws://ec2-54-66-167-255.ap-southeast-2.compute.amazonaws.com:1100?user_id='+Eatzy.util.ChatUtil.getLoginUserId();
    	/* specify server url with user id */
    	var connection = new WebSocket(url);
    	connection.onopen = function () {
    		console.log("on open");
        	isConnectionOpen = true;
        	Eatzy.util.ChatUtil.setWebSocketConnection(connection);
        	Eatzy.util.ChatUtil.getFriendsListWithChatHistory();
        };

        connection.onmessage = function (event) {
        	console.log("on message==",event.data);
        	me.onMessageFunctionality(event.data);
        };

        connection.onclose = function (event) {
        	console.log('close code=' + event.code+"isConnectionOpen = "+isConnectionOpen);
        	if(isConnectionOpen){
                //Ext.Msg.alert('Connection Close', 'Click here to reconnect !',me.doWebSocketConnection,me);
        		me.doWebSocketConnection();
                isConnectionOpen = false;
            }
        };
        
        connection.onerror = function () {
        	console.log('error occurred!');
        	//Ext.Msg.alert('Connection Error', 'Error in server connection ,Please try again!');
            isConnectionOpen = false;
            if(isConnectionOpen == false){
                //Ext.Function.defer(me.doWebSocketConnection, 30000, me);
                me.doWebSocketConnection();
            }
        };
    },
    sentMessageToWebSocket :function(message){
    	var ws=Eatzy.util.ChatUtil.getWebSocketConnection();
		if(ws!=undefined && ws!=null && ws!=""){
			Eatzy.util.ChatUtil.getWebSocketConnection().send(JSON.stringify(message));
		}else{
			console.log("web socket connection lost....");
		}
    },
    
    /* 
	 * Function: call continuously web service to get chat.
	 */
    getFriendsListWithChatHistory:function(){
    	var me = this;
	    var userFriendWithChatHistoryUrl = Eatzy.util.GlobalUtil.getWebServiceDomain() + Eatzy.util.GlobalUtil.getUserFriendWithChatHistoryUrl() + Eatzy.util.ChatUtil.getLoginUserId();
		Eatzy.util.GlobalUtil.commonWebServiceCall('GET', userFriendWithChatHistoryUrl, me.userFriendsWebServiceCallBack, me, {}, true);
    },       
    
    userFriendsWebServiceCallBack: function(serviceResponseStatus, responseData, currentObject){
    
    	if(responseData != null){
    		if(responseData.success){
    			var chatFriendsStore = Ext.getStore('chatFriendsStoreId');
    			chatFriendsStore.removeAll();
    			chatFriendsStore.getProxy().clear();
    			Eatzy.util.ChatUtil.updateDetailsInUserChatFriendStore(responseData);
        	}else{
        		// do nothing
        	}
    	}else{
    		// do nothing
    	}
    },
    
    updateDetailsInUserChatFriendStore: function(responseData){
		var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
   		for (var i=0; i<responseData.friend_info.length; i++) {
   			var userFriend = responseData.friend_info[i];
   			var userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', userFriend.user_friend_id, 0, false, true, true); 
   			if(userChatFriendsModel!=null){
   				userChatFriendsModel.set('friendId',userFriend.user_friend_id);
   				userChatFriendsModel.set('imageUrl',(userFriend.photo_url == "" || userFriend.photo_url == null || userFriend.photo_url == undefined) ? "resources/images/3x/default@3x.png" : userFriend.photo_url);
   				userChatFriendsModel.set('firstName',userFriend.user_friend_name);
   				userChatFriendsModel.set('unSeenChatCount',userFriend.unseen_count);
   				userChatFriendsModel.set('unseenFriendStatus',userFriend.unseen_status);
   				userChatFriendsModel.set('latestChatId',userFriend.latest_chat_id);
   				userChatFriendsModel.set('previousChatPresent',userFriend.previous_chat_present);
   				userChatFriendsModel.set('latestChatTime',userFriend.latest_chat_time);
   			}else{
   				var userChatFriendsModel = Ext.create('Eatzy.model.ChatFriendsModel',{
	   				friendId :	userFriend.user_friend_id,
	   				imageUrl : (userFriend.photo_url == "" || userFriend.photo_url == null || userFriend.photo_url == undefined) ? "resources/images/3x/default@3x.png" : userFriend.photo_url,
	   				firstName: userFriend.user_friend_name,
	   				unSeenChatCount: userFriend.unseen_count,
	   				unseenFriendStatus: userFriend.unseen_status,
	   				latestChatId: userFriend.latest_chat_id,
	   				previousChatPresent: userFriend.previous_chat_present,
	   				latestChatTime : userFriend.latest_chat_time
   				});
   			}
   			
			if(userFriend.chat_data != null && userFriend.chat_data != undefined && userFriend.chat_data != "" && userFriend.chat_data.data != null && userFriend.chat_data.data != undefined && userFriend.chat_data.data != "" && userFriend.chat_data.data.length>0){
				var chatsData=userFriend.chat_data.data;
				for(var j=0;j<chatsData.length;j++){
					var userChatMessageModel=null;
					if(userChatFriendsModel.chatList()!=null && userChatFriendsModel.chatList()!=""){
						userChatMessageModel =userChatFriendsModel.chatList().findRecord( 'chatId', chatsData[j].id, 0, false, true, true); 
					}
					if(userChatMessageModel==null){
	    	   			userChatFriendsModel.chatList().add(
		   					Ext.create('Eatzy.model.ChatModel',{
		   						chatId :	chatsData[j].id,
		   						senderUserId : chatsData[j].sender_user_id,
		   						receiverUserId: chatsData[j].receiver_user_id,
		   						message: chatsData[j].message,
		    	   				createdTime : chatsData[j].created_at
		    	            })
		    	        );
				}
					
				}
			}
	   			
			userChatFriendsModel.setDirty();
			userChatFriendsStore.add(userChatFriendsModel);
			userChatFriendsStore.sync();
   		}
   		
   		Eatzy.util.ChatUtil.changeSearchTBChatIcon();
		//currentObject.displayChat();
    },
    /* 
	 * Function: call continuously web service to get chat.
	 */
    getNewFriendsDetails:function(friendId){
    	var me = this;
    	var jsonData = {
				"login_user_id": parseInt(Eatzy.util.ChatUtil.getLoginUserId()),
				"friend_user_id" : friendId
		    };
	    var newFriendDetailsUrl = Eatzy.util.GlobalUtil.getWebServiceDomain() + Eatzy.util.GlobalUtil.getFriendDetails();
		Eatzy.util.GlobalUtil.commonWebServiceCall('POST', newFriendDetailsUrl, me.getNewFriendsDetailsWebServiceCallBack, me, jsonData, true);
    }, 
    
    getNewFriendsDetailsWebServiceCallBack: function(serviceResponseStatus, responseData, currentObject){
    	if(responseData != null && responseData.success){
    			Eatzy.util.ChatUtil.updateDetailsInUserChatFriendStore(responseData);
        	}
    },
    
    displayChat:function(totalUnSeenChatCount){
    	var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
    	for(var k=0;k<userChatFriendsStore.getAllCount();k++){
    		var userChatFriendsModel = userChatFriendsStore.getAt(k);
    		
    		
    		for(var i=0;i<userChatFriendsModel.chatList().getAllCount();i++){
    			var chatDataModel=userChatFriendsModel.chatList().getAt(i);
    				
    		}
    	}
    },
    changeSearchTBChatIcon:function(){
    	var totalUnSeenChatCount = Eatzy.util.ChatUtil.getUnseenChatCount();
    	var unSeenFriendCount = Eatzy.util.ChatUtil.getUnSeenFriendCount();
    	if(totalUnSeenChatCount > 0 || unSeenFriendCount > 0){
    		var viewId=Ext.Viewport.getActiveItem().getId();
     		if(viewId=='searchTravelbudsViewId' || viewId=='matchTravelBudsView'){
				var chatBtn = Ext.ComponentQuery.query("button[name=toolbarChatBtn]")[0];
				if(chatBtn != undefined && chatBtn != null && chatBtn != ""){
					chatBtn.removeCls("initialChatButtonCls");
					chatBtn.addCls("chatButtonCls");
				}
     		}
			if(viewId=='matchFriendsListViewId'){
	 			Ext.getCmp('matchFriendsListId').getStore().sort('latestChatTime','DESC');
 				var matchFriendListBubbleIcon = Ext.ComponentQuery.query("button[name=matchFriendListBubbleIcon]")[0];
 				if(matchFriendListBubbleIcon != undefined && matchFriendListBubbleIcon != null && matchFriendListBubbleIcon != ""){
 					matchFriendListBubbleIcon.removeCls("matchFriendBubbleIconWithoutMessage");
 					matchFriendListBubbleIcon.addCls("matchFriendBubbleIconWithMessage");
 				}
	 		}
    	}
    },
    goToMatchFriendsListView: function(){
    	if(Ext.getCmp('commonOverlayId')!=undefined){
	    	Ext.getCmp('commonOverlayId').hide();
	   	    Ext.getCmp('commonOverlayId').destroy();
    	}
    	Eatzy.util.CommonUtil.showActiveView('Eatzy.view.userFriends.MatchFriendsListView');
		 if(Eatzy.util.ChatUtil.getUnseenChatCount() > 0 || Eatzy.util.ChatUtil.getUnSeenFriendCount() > 0){							
				var matchFriendListBubbleIcon = Ext.ComponentQuery.query("button[name=matchFriendListBubbleIcon]")[0];
				if(matchFriendListBubbleIcon){
					matchFriendListBubbleIcon.removeCls("matchFriendBubbleIconWithoutMessage");
					matchFriendListBubbleIcon.addCls("matchFriendBubbleIconWithMessage");
				}
			}
    },
    onMessageFunctionality: function(response){
    	var me=this;
        var data = JSON.parse(response);
 		
 		var chatFriendId = Eatzy.util.ChatUtil.getChatFriendId();
		var loginUserId=Eatzy.util.ChatUtil.getLoginUserId();
		
		var userChatFriendsModel =null;
		if(data.type!=undefined && data.type!=null && data.type=="unmatch"){
			var userChatFriendsStore = Ext.getStore('userChatFriendsStoreId');
   		 	var userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', data.sender_id, 0, false, true, true); 
   		 	userChatFriendsStore.remove(userChatFriendsModel);
	   		var viewId=Ext.Viewport.getActiveItem().getId();
	  		if(viewId=='chatView'){
	  			if((data.sender_id==loginUserId || data.sender_id==chatFriendId) && (data.receiver_id==loginUserId || data.receiver_id==chatFriendId)){
	  				document.getElementById('chatTextField').disabled = true;
	  				var friendName="Your friend";
	  				if(Ext.getCmp('chatFriendNameId').getHtml()!=""){
	  					friendName = Ext.getCmp('chatFriendNameId').getHtml();
	  				}
	  				Ext.Msg.alert('Oops!', friendName+' unmatched you.',me.goToMatchFriendsListView,me);
	  			}
	  		}
	  		return;
		}
		
		
		
 		if(data.sender_id==loginUserId){
			me.updateUserChatFriendStore(data.receiver_id,data);
			var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
 	    	userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', data.receiver_id, 0, false, true, true); 
		}else{
			me.updateUserChatFriendStore(data.sender_id,data);
			var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
 	    	userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', data.sender_id, 0, false, true, true); 
		} 
 		var userChatMessagesRecord = userChatFriendsModel.chatList().findRecord( 'chatId', data.chat_id, 0, false, true, true);
 		var viewId=Ext.Viewport.getActiveItem().getId();
 		if(viewId=='chatView'){
 			if((data.sender_id==loginUserId || data.sender_id==chatFriendId) && (data.receiver_id==loginUserId || data.receiver_id==chatFriendId)){
     			if(data.sender_id==loginUserId){//Image 11 work start
     				document.getElementById('chatTextField').value="";
     				
     				Ext.getCmp('chatPanelId').add(me.getUserChatView(userChatMessagesRecord));
     			}else{
     				var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
     		    	var userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', chatFriendId, 0, false, true, true); 
     				Ext.getCmp('chatPanelId').add(me.getFriendChatView(userChatFriendsModel.get('imageUrl'), userChatMessagesRecord));
     			}//Image 11 work end
     			
     			var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
 				var windowWidth = Ext.Viewport.getWindowWidth();
 				var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
     			
     			$("#chatTextField").css('height',windowHeight * 0.0480072463768116);
 				$("#chatTextField").css('overflow', 'hidden');
 				$("#hiddenDivId").html('');
 				Eatzy.util.ChatUtil.setIsMaxHeightReached(false);
 		        Eatzy.util.ChatUtil.setHiddenDivInitialHeight($("#hiddenDivId").height());
 				
 			    //Ext.getCmp('sendButtonParentPanel').setHeight(windowHeight * 0.0801630434782609);
 			    var chatPanelHeight = windowHeight - (windowHeight * 0.067481884057971) - (maxScreenWidth * 0.1167471819645733) - (windowHeight * 0.0267210144927536) - windowHeight * 0.0801630434782609;
 				Ext.getCmp('chattingParentPanelId').setHeight(chatPanelHeight);
 				
     			var scrollable = Ext.getCmp('chatPanelId').getScrollable().getScroller();
     			var height = Ext.getCmp('chatPanelId').getMaxHeight().toFixed(0);
 	 			if(height <= scrollable.getSize().y){
 	 				 if(scrollable != undefined){
 	 	                scrollable.setInitialOffset({x : 0, y : scrollable.getSize().y});
 	 	            }
 	 			}
     		}else{
     			//function for toste msg
     			me.displayToastMessage(data);
     		}
 		}else if(viewId=='matchFriendsListViewId'){
 			Ext.getCmp('matchFriendsListId').getStore().sort('latestChatTime','DESC');
 			if(Eatzy.util.ChatUtil.getUnseenChatCount() > 0 || Eatzy.util.ChatUtil.getUnSeenFriendCount() > 0 ){							
 				var matchFriendListBubbleIcon = Ext.ComponentQuery.query("button[name=matchFriendListBubbleIcon]")[0];
 				if(matchFriendListBubbleIcon){
 					matchFriendListBubbleIcon.removeCls("matchFriendBubbleIconWithoutMessage");
 					matchFriendListBubbleIcon.addCls("matchFriendBubbleIconWithMessage");
 				}
 			}
 			me.displayToastMessage(data);
     			//function for toste msg
 		}else if(viewId=='searchTravelbudsViewId' || viewId=='matchTravelBudsView'){ //for screen 2a,2b,2c
 			me.changeSearchTBChatIcon();
 			me.displayToastMessage(data);
     			//function for toste msg
 		}else{
 			//function for toste msg
 			me.displayToastMessage(data);
 		}
    },
    updateUserChatFriendStore: function(chatFriendId,data){
    	var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
    	var userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', chatFriendId, 0, false, true, true); 
    	userChatFriendsModel.set('latestChatId', data.chat_id);
    	userChatFriendsModel.set('latestChatTime', data.created_time);
    	var viewId=Ext.Viewport.getActiveItem().getId();
    	
 		if(viewId=='chatView'){
 			var currentChatFriendId = Eatzy.util.ChatUtil.getChatFriendId();
 			if(chatFriendId!=currentChatFriendId){
 				userChatFriendsModel.set('unSeenChatCount', (userChatFriendsModel.get('unSeenChatCount')+1));
     		}
 		}else{
 			userChatFriendsModel.set('unSeenChatCount', (userChatFriendsModel.get('unSeenChatCount')+1));
 		}
 		
    	userChatFriendsModel.chatList().add(
    			Ext.create('Eatzy.model.ChatModel',{
						chatId :	data.chat_id,
						senderUserId : data.sender_id,
						receiverUserId: data.receiver_id,
						message: data.message_content,
						createdTime : data.created_time
	            })
    	);
    	userChatFriendsStore.sync();
    },
    
    displayToastMessage: function(data){
    	
    	var loginUserId=Eatzy.util.ChatUtil.getLoginUserId();
    	if(data.sender_id!=loginUserId){
    		var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
        	var userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', data.sender_id, 0, false, true, true); 
        	var friendName=userChatFriendsModel.get('firstName');
        	Ext.toast('New message from '+friendName);
        }
    },
    
    getUnseenChatCount: function(){
    	var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
    	var totalUnSeenChatCount=0;
    	for(var k=0;k<userChatFriendsStore.getAllCount();k++){
    		var unSeenChatCount = userChatFriendsStore.getAt(k).get('unSeenChatCount');
    		if(unSeenChatCount != undefined && unSeenChatCount != null && unSeenChatCount != ""){
   				totalUnSeenChatCount=totalUnSeenChatCount+parseInt(unSeenChatCount);
   			}
    	}
    	return totalUnSeenChatCount;
    },
    
    getUnSeenFriendCount: function(){
    	var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
    	var totalUnSeenFriendCount=0;
    	for(var k=0;k<userChatFriendsStore.getAllCount();k++){
    		var unSeenfriendCount = userChatFriendsStore.getAt(k).get('unseenFriendStatus');
    		if(unSeenfriendCount != undefined && unSeenfriendCount != null && unSeenfriendCount != ""){
    			totalUnSeenFriendCount=totalUnSeenFriendCount+parseInt(unSeenfriendCount);
   			}
    	}
    	return totalUnSeenFriendCount;
    },
    
    showChatViewCmp: function(record){
    	var me=this;
    	var userChatMessagesStore = record.chatList();
    	userChatMessagesStore.sort('chatId','ASC');
 		Eatzy.util.CommonUtil.showActiveView('Eatzy.view.ChatView');
 	
 		Eatzy.util.ChatUtil.setChatFriendId(record.get('friendId'));
 			    
	    $("#chatTextField").bind("blur", function(event) {
	    	if(Eatzy.util.ChatUtil.getIsClicked()){
		    	$("#chatTextField").focus();
	    		event.preventDefault();
	    		Eatzy.util.ChatUtil.setIsClicked(false);
	    	}
		});
	    
	    $('#chatTextField').bind('input paste', function(event) {
	    	Eatzy.util.ChatUtil.autoResizeTextArea();
	    	Eatzy.util.ChatUtil.onChatMessageKeyUp(this);
	    });
	   
	},
	
    /*
     * Function create User chat view
     * @return: panel to add in carousal to slide image.
     * */    
    getUserChatView:function(userChatMessagesRecord){
    	var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
    	var windowWidth = Ext.Viewport.getWindowWidth();
		var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
		
		var chatPanelStyle,panelWidth;
		if(windowWidth <=500){
			chatPanelStyle = 'margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+maxScreenWidth * 0.077+'px;background:none !important;';
			panelWidth = '86.5%';
	   	}else if(windowWidth >500 && windowWidth <=600){
	   		chatPanelStyle = 'margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+windowWidth * 0.14+'px';
	   		panelWidth = '74%';
	   	}else if(windowWidth >600){
	   		chatPanelStyle = 'margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+windowWidth * 0.205+'px;border:2px solid red;background:none !important;';
	   		panelWidth = '60.5%';
	   	}
		
    	var profilePicturePanel = {
				   xtype: 'panel',
				   style:chatPanelStyle,
				   width:panelWidth,
				   layout: {
				             type: 'hbox',
				             pack: 'end',
				             align: 'center'
				    },
				    items:[
							{
								xtype : 'label',
								html : userChatMessagesRecord.get('text'),
								maxWidth:maxScreenWidth * 0.6119162640901771,
								minHeight:windowHeight * 0.05,
								style:'font-size:'+windowHeight * 0.0235507246376812+'px',
								cls:'userMessageCls'
							}
				    ]
				};
    	return profilePicturePanel;
    },
    
    /*
     * Function create User friend chat view
     * @param: user friend profile picture image url
     * @return: panel.
     * */    
    getFriendChatView:function(imageUrl, userChatMessagesRecord){
    	var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight(); 
    	var windowWidth = Ext.Viewport.getWindowWidth();
		var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
		
		var chatPanelStyle,panelWidth;
		if(windowWidth <=500){
			chatPanelStyle = 'margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+maxScreenWidth * 0.077+'px';
			panelWidth = '86.5%';
	   	}else if(windowWidth >500 && windowWidth <=600){
	   		chatPanelStyle = 'margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+windowWidth * 0.14+'px';
	   		panelWidth = '74%';
	   	}else if(windowWidth >600){
	   		chatPanelStyle = 'margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+windowWidth * 0.205+'px';
	   		panelWidth = '60.5%';
	   	}
		
    	var profilePicturePanel = {
				   xtype: 'panel',
				   style:chatPanelStyle,
				   width:panelWidth,//'85%',
				   id:userChatMessagesRecord.get('chatId')+"",
				   layout: {
				             type: 'hbox',
				             pack: 'start',
				             align: 'end'
				    },
				    items:[
							{
								xtype:'image',
								width: windowWidth > maxScreenWidth ? windowHeight * 0.043 : windowHeight * 0.040,/*changes*/
								height: windowWidth > maxScreenWidth ? windowHeight * 0.043 : windowHeight * 0.040,/*changes*/
								margin:'0 4% 0 0',/*changes*/
								src: imageUrl,
								style:'background-size:100% 100%'
							
							},
							{
								xtype : 'label',
								maxWidth:maxScreenWidth * 0.6119162640901771,
								minHeight:windowHeight * 0.05,
								style:'font-size:'+windowHeight * 0.0235507246376812+'px',
								cls:'userFriendMessageCls',
								html : userChatMessagesRecord.get('message')
							}
							
				    ]
				};
    	return profilePicturePanel;
    },
    
    showPreviousChatMessageView: function(responseData){
    	var me=this;
    	var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
    	var chatFriendId=parseInt(responseData.friend_id);
    	var userChatFriendsRecord = userChatFriendsStore.findRecord( 'friendId', chatFriendId, 0, false, true, true); 
    	var userChatMessagesStore = userChatFriendsRecord.chatList();
    	userChatMessagesStore.sort('chatId','ASC');
    	var previousChatsCount=0;
    	if(responseData.friend_info.length>0){
    		var userFriend = responseData.friend_info[0];
    		if(userFriend.chat_data != null && userFriend.chat_data != undefined && userFriend.chat_data != "" && userFriend.chat_data.data != null && userFriend.chat_data.data != undefined && userFriend.chat_data.data != "" && userFriend.chat_data.data.length>0){
   				previousChatsCount=userFriend.chat_data.count;
    		}
    	}
	    var loginUserId = Eatzy.util.ChatUtil.getLoginUserId();
	    var viewId=Ext.Viewport.getActiveItem().getId();
	    if(viewId=='chatView'){
	    	if(userChatFriendsRecord.get('previousChatPresent')!=null && userChatFriendsRecord.get('previousChatPresent')==0){
	    		Ext.getCmp('loadEarlierChatBtnId').setHidden(true);
	    	}
	    	for(var i=0; i<previousChatsCount && userChatMessagesStore.getAllCount()>0 ; i++){
	    		var userChatMessagesRecord = userChatMessagesStore.getAt(i);
	 			if(userChatMessagesRecord.get('senderUserId')==loginUserId){
	 				Ext.getCmp('chatPanelId').insert((i+1), me.getUserChatView(userChatMessagesRecord));
	 			}else{
	 				Ext.getCmp('chatPanelId').insert((i+1), me.getFriendChatView(userChatFriendsRecord.get('imageUrl'), userChatMessagesRecord));
	 			}
	    	}
 		}
	},
    
    //Call this method only when chat view is open.
    updateChatLastSeenTimeWebService:function(){
    	var me = this;
    	var chatFriendId = Eatzy.util.ChatUtil.getChatFriendId();
    	if(chatFriendId!=undefined && chatFriendId!=null){
    		
    		var userChatFriendsStore = Ext.getStore('chatFriendsStoreId');
        	var userChatFriendsModel = userChatFriendsStore.findRecord( 'friendId', chatFriendId, 0, false, true, true); 
        	userChatFriendsModel.set('unSeenChatCount', 0 );
        	userChatFriendsModel.set('unseenFriendStatus', 0 );
        	
	    	var jsonData = {
				"login_user_id": Eatzy.util.ChatUtil.getLoginUserId(),
				"friend_user_id" : chatFriendId
		    };
		    var latestChatSeenTimeUrl = Eatzy.util.GlobalUtil.getWebServiceDomain() + Eatzy.util.GlobalUtil.getLatestChatSeenTimeUrl();
			Eatzy.util.GlobalUtil.commonWebServiceCall('POST', latestChatSeenTimeUrl, me.isLatestChatSeenTimeUpdated, me, jsonData, true);
    	}else{
    	}
    },
    
    isLatestChatSeenTimeUpdated: function(serviceResponseStatus, responseData, currentObject){
    	//do nothing
    },
    
    /**
     * Function :  used to open chat View
     *  
     * */
	showChatView : function(){
		
		if(Ext.getCmp('commonOverlayId')){
 			Ext.getCmp('commonOverlayId').hide();
 	 		Ext.getCmp('commonOverlayId').destroy();
 		}
		var userChatFriendsStore = Ext.getStore('userChatFriendsStoreId');
    	var userChatFriendsRecord = userChatFriendsStore.findRecord( 'friendId', Eatzy.util.ChatUtil.getChatFriendId(), 0, false, true, true); 
    	if(userChatFriendsRecord==null){
    		Eatzy.util.ChatUtil.goToMatchFriendsListView();
    	}else{
			Eatzy.util.ChatUtil.showChatViewCmp(userChatFriendsRecord);
			var viewId=Ext.Viewport.getActiveItem().getId();
			if(viewId=='chatView'){
	 			Eatzy.util.ChatUtil.updateChatLastSeenTimeWebService();
	 		}
    	}
 		
    },
    
    onChatMessageKeyUp:function(me){
    	var maxLength = 500;
    	if(me.value.length > maxLength){
    		me.value = me.value.substr(0, maxLength);
   		}
    	
    	var sendButtonStyle;
    	var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
		
		
		var sendButton;
		if(Ext.ComponentQuery.query("button[name=chatMessageSendBtn]")[0]){
			sendButton = Ext.ComponentQuery.query("button[name=chatMessageSendBtn]")[0];
    	}
		
    	if(me.value.trim() != ""){
    		sendButton.setDisabled(false);
    		
    	}else if(me.value.trim() == ""){
    		sendButton.setDisabled(true);
    		
    	}
    	
    	Eatzy.util.ChatUtil.autoResizeTextArea(me);
    	
    },
    
    autoResizeTextArea:function(textCmp){
        var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight(); //Ext.Viewport.getWindowHeight();
		var windowWidth = Ext.Viewport.getWindowWidth();
		var maxScreenWidth = Eatzy.util.GlobalUtil.getMaxScreenWidth();
		
    	var hiddenDiv = $("#hiddenDivId");//document.getElementById("hiddenDivId");
    	var textComponent = $("#chatTextField");
    	content = textComponent.val();
        content = content.replace(/\n/g, '<br>');
        hiddenDiv.html(content + '<br class="lbr">');
        textComponent.css('height', (hiddenDiv.height()));
        if(content.length == 0){   // condition added by #1044 to avoid height resize issue after backspace
        	Eatzy.util.ChatUtil.setIsMaxHeightReached(false);
        	Eatzy.util.ChatUtil.setHiddenDivInitialHeight(0);
        }else if(content.length == 1){
        	Eatzy.util.ChatUtil.setHiddenDivInitialHeight(hiddenDiv.height());
        }
        
        var textCmpHeight = parseInt(textComponent.css('height').replace("px",""));
        var textCmpMaxHeight = parseInt(textComponent.css('max-height').replace("px",""));
        
        if(!Eatzy.util.ChatUtil.getIsMaxHeightReached()){
        	if(hiddenDiv.height() != Eatzy.util.ChatUtil.getHiddenDivInitialHeight()){
        		var newHeight= 0;
        		if(hiddenDiv.height() >= textCmpMaxHeight){
        			
        			newHeight=textCmpMaxHeight;
        		}else{
        			
        			newHeight=hiddenDiv.height();
        			
        		}
        		
	        	var padding = windowHeight * 0.0480072463768116;
	        	Ext.getCmp('sendButtonParentPanelId').setHeight(newHeight+padding);
	     		//var panelHeight = windowHeight - (windowHeight* 0.0924295774647887) - (windowHeight*0.0783450704225352)- (newHeight + padding + (0.0022644927536232 * windowHeight));
	     		var panelHeight = (windowHeight * 0.99) - windowHeight*0.0783450704225352 - windowHeight* 0.0985915492957746- (newHeight + padding);//windowHeight - (windowHeight* 0.0924295774647887) - (windowHeight*0.0783450704225352)- (newHeight + padding);
	     		//Ext.ComponentQuery.query('panel[name=chattingParentPanel]')[0].setHeight(windowHeight*0.6919014084507042);
	     		Ext.getCmp('chattingParentPanelId').setHeight(panelHeight);
	     		Ext.getCmp('chatMessageListId').setHeight(panelHeight); //added by #1044
	     		Ext.Viewport.setHeight(windowHeight);
	     		
        	}
        }
        
        Eatzy.util.ChatUtil.setHiddenDivInitialHeight(hiddenDiv.height());
        
        if(textCmpHeight >= textCmpMaxHeight){
        	Eatzy.util.ChatUtil.setIsMaxHeightReached(true);
        	textComponent.css('overflow', 'auto');
        }else {
        	Eatzy.util.ChatUtil.setIsMaxHeightReached(false);
        	textComponent.css('overflow', 'hidden');
        }
    },
    
    onKeyPress:function(me){
   		var maxLength = 500;
    	if(me.value.length == maxLength){
   			window.event.preventDefault();
   			return;
   		}
   	},
    
    onChatMessageFocus:function(me){
    	
    	var height = Eatzy.util.GlobalUtil.getScreenHeight();
	    Ext.Viewport.setHeight(height);
	      
	    /*if(Ext.os.is.Android){
        	var myVar = setInterval(function(){
	        	SoftKeyboard.isShowing(function(isShowing) {
	                if (!isShowing) {
						me.blur( );
						var height = Eatzy.util.GlobalUtil.getScreenHeight();
						Ext.Viewport.setHeight(height);
						clearInterval(myVar);
	                }
	            }, function() {
	                console.log('error in SoftKeyboard');
	            });
        	}, 1000);
    	}*/
    },
    onTextAreaBlur: function(me) {
        var height = Eatzy.util.GlobalUtil.getScreenHeight();
        Ext.Viewport.setHeight(height);
    },
    
    /**
 	 * Function to scroll chat list upto last message.
 	 **/
 	scrollChatListToEnd:function(){
 		var chatList = Ext.ComponentQuery.query('list[name=chatMessageList]')[0];
 		if(chatList){
			var scroller = chatList.getScrollable().getScroller();
			var length = chatList.getItems().items[0].innerItems.length;
			var offsetTop =  (length >0) ? chatList.getItems().items[0].innerItems[length-1].bodyElement.dom.offsetTop : chatList.getItems().items[0].bodyElement.dom.offsetTop;
			if(scroller.getSize().y > chatList.getHeight().toFixed(0)){
				scroller.scrollTo(0,offsetTop);
			}
 		}
 	},
 	
 	/**
	 * Function: Used to on apply scroll event to load chat message on pull down.
	 * @param{object} componentObject: component object
	 */
     pullDownChatList:function(self){
    	 var me = this;
    	 var windowWidth = Eatzy.util.GlobalUtil.getScreenWidth();
         var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
         var chatViewPanelHeight = windowHeight - windowHeight*0.0783450704225352 - windowHeight * 0.0985915492957746;
         //var chatViewPanelHeight = JoinOrders.util.CommonUtil.isPhoneView() ? (windowHeight-(JoinOrders.util.CommonUtil.getCustomToolbarHeight()+JoinOrders.util.CommonUtil.getFooterHeight())) : ((windowHeight * 0.98046875)-(JoinOrders.util.CommonUtil.getCustomToolbarHeight()+JoinOrders.util.CommonUtil.getFooterHeight()));
         var scroller = self.getScrollable().getScroller();
         var chattingParentPanel = Ext.getCmp('chattingParentPanelId');
         setTimeout(function(){
		    	if(self.scrollElement.dom.clientHeight > (chatViewPanelHeight- (windowHeight * 0.0888671875))){
		    		if(Ext.os.is.Desktop){
		    			self.setScrollable({direction: 'vertical',directionLock: true,indicator: false});
		    			$(".x-scroll-view").css({ "overflow":"overlay","overflow-y":"overlay","overflowX":"hidden"});
		    		}else{
		    			self.setScrollable(true);
		    			$(".x-scroll-view").css({"overflow":"hidden !important;","overflowY":"hidden !important;","overflowX":"hidden"});
		    			self.setScrollable({direction: 'vertical',directionLock: true,indicator: true});
		    		}
		    		//me.scrollChatListToEnd();
		    	}else{
		    		if(Ext.os.is.Desktop){
		    			self.setScrollable(false);
			       		//$(".x-scroll-view").css({"overflow":"hidden","overflowX":"hidden"});
		    		}else{
		    			self.setScrollable(false);
			       		//$(".x-scroll-view").css({"overflow":"hidden","overflowX":"hidden","-webkit-overflow-scrolling":"touch"});
		    		}
		    	}
		    	scroller.scrollToEnd(false);
	    	},10);
     },
     
     resetChatViewComponents: function() {
    	 var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
    	 var parentPanelHeight = windowHeight * 0.0984915492957746;
     	Ext.getCmp('sendButtonParentPanelId').setHeight(parentPanelHeight);
  		//var panelHeight = (windowHeight * 0.99) - windowHeight*0.0783450704225352 - (parentPanelHeight);
  		var panelHeight = windowHeight - ((windowHeight*0.0783450704225352) + (windowHeight * 0.0985915492957746) + (windowHeight * 0.0988671875));
  		Ext.getCmp('chattingParentPanelId').setHeight(panelHeight);
  		Ext.getCmp('chatMessageListId').setHeight(panelHeight); //added by #1044
  		Ext.Viewport.setHeight(windowHeight);
		
	}
});