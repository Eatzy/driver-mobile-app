/* Created by 1010
 * July9, 2015
 * To design chat view screen.
 */

Ext.define('Eatzy.view.ChatView',{
	extend:'Ext.Panel',
	alias:'widget.chatView',
	requires:['Ext.dataview.List'],
   config: {
		
	    name: 'chatView',
		cls:'commonBackgroundCls',
		width: '100%',
		layout : {
			type : 'vbox',
			pack : 'start',
			align : 'center'
		}
   },
   
   initialize:function(){
	    this.callParent(arguments);
	    
	    var windowHeight = Ext.Viewport.getWindowHeight();
	    this.setHeight(windowHeight-windowHeight* 0.0924295774647887);
		var windowWidth = Ext.Viewport.getWindowWidth();
		var maxScreenWidth = Ext.Viewport.getWindowWidth();
		var cancelBtnWidth;
		
		if(windowWidth > maxScreenWidth){
			cancelBtnWidth = 0.20 * maxScreenWidth;
		}else{
			cancelBtnWidth = 0.18 * maxScreenWidth;
		}
		
		var profilePicturePanelWidth = maxScreenWidth * 0.8405797101449275 - cancelBtnWidth - (maxScreenWidth * 0.0611916264090177);
		//var chatPanelHeight = windowHeight - windowHeight*0.0783450704225352 - windowHeight* 0.0959507042253521-windowHeight* 0.0924295774647887-windowHeight * 0.0267210144927536;
		var chatPanelHeight = windowHeight - windowHeight*0.0783450704225352 - windowHeight * 0.0985915492957746;
		//console.log("chatPanelHeight :=== "+chatPanelHeight)
		var chatMessageComponentMaxHeight = 5.5 * (windowHeight * 0.0480072463768116);
//		/var friendProfilePicUrl = this.getFriendProfilePicUrl();
		var loginUserId =7;// Eatzy.util.CommonUtil.getLoginUserId();
		var chatLeftPanelStyle,chatRightPanelStyle;
		//below changes made by: #1044 as last chat message not properly visible
		if(windowWidth <=500){
			//chatRightPanelStyle = 'width:85%;margin-top:'+windowHeight * 0.0267991004497751+'px;margin-left:'+maxScreenWidth * 0.077+'px;float:left';
			chatRightPanelStyle = 'width:85%;margin-top:'+windowHeight * 0.0207991004497751+'px;margin-left:'+maxScreenWidth * 0.077+'px;margin-bottom:'+windowHeight * 0.0147991004497751+'px;float:left';
	   	}else if(windowWidth >500 && windowWidth <=600){
	   		//chatRightPanelStyle = 'width:75.5%;margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+maxScreenWidth * 0.24+'px;float:left';
	   		chatRightPanelStyle = 'width:75.5%;margin-top:'+windowHeight * 0.010304347826087+'px;margin-bottom:'+windowHeight * 0.008304347826087+'px;margin-left:'+maxScreenWidth * 0.24+'px;float:left';
	   	}else if(windowWidth >600){
	   		//chatRightPanelStyle = 'width:66.5%;margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+maxScreenWidth * 0.205+'px;float:left';
	   		chatRightPanelStyle = 'width:66.5%;margin-top:'+windowHeight * 0.010304347826087+'px;margin-bottom:'+windowHeight * 0.008304347826087+'px;margin-left:'+maxScreenWidth * 0.205+'px;float:left';
	   	}
		
		if(windowWidth <=500){
			//chatLeftPanelStyle = 'width:86.5%;margin-top:'+windowHeight * 0.0267083333333333+'px;float:left;margin-left:'+maxScreenWidth * 0.077+'px;float:left';
			chatLeftPanelStyle = 'width:86.5%;margin-top:'+windowHeight * 0.0207083333333333+'px;margin-bottom:'+windowHeight * 0.0147083333333333+'px;margin-left:'+maxScreenWidth * 0.077+'px;float:left';
	   	}else if(windowWidth >500 && windowWidth <=600){
	   		//chatLeftPanelStyle = 'width:74%;margin-top:'+windowHeight * 0.016304347826087+'px;margin-left:'+maxScreenWidth * 0.24+'px;float:left';
	   		chatLeftPanelStyle = 'width:74%;margin-top:'+windowHeight * 0.010304347826087+'px;margin-bottom:'+windowHeight * 0.008304347826087+'px;margin-left:'+maxScreenWidth * 0.24+'px;float:left';
	   	}else if(windowWidth >600){
	   		//chatLeftPanelStyle = 'width:67.5%;margin-top:'+windowHeight * 0.03681216015625+'px;margin-left:'+maxScreenWidth * 0.205+'px;float:left';
	   		chatLeftPanelStyle = 'width:67.5%;margin-top:'+windowHeight * 0.02481216015625+'px;margin-bottom:'+windowHeight * 0.01881216015625+'px;margin-left:'+maxScreenWidth * 0.205+'px;float:left';
	   	}
		
		
		var imagePaneWidth =  windowWidth > maxScreenWidth ? windowHeight * 0.043 : windowHeight * 0.040;
		var imagePaneHeight =  windowWidth > maxScreenWidth ? windowHeight * 0.043 : windowHeight * 0.040;
		
		//var imagePanelStyle = "width:"+imagePaneWidth+"px; height:"+imagePaneHeight+"px; margin: 0px 4% 0px 0px !important; background-image: url("+friendProfilePicUrl+"); background-size: 100% 100%;";
		var labelPanelStyle = 'max-width: '+maxScreenWidth * 0.6119162640901771+'px; min-height: '+windowHeight * 0.05+'px; font-size: '+windowHeight * 0.0235507246376812+'px;  ';
		
		var chatListTpl = new Ext.XTemplate(
 	           '<tpl for=".">',
 	               '<div style="width:100%; height:100%;float:left">',
	 	           '<tpl if="this.isReceiverUserPanel(values)">',
	 	           		'<div style="'+chatLeftPanelStyle+';position:relative;">',
	 	           		'<tpl if="type == \'R\'">',
	           		   		//'<div style="'+imagePanelStyle+';float:left;position:absolute;bottom:0;left:'+maxScreenWidth * -0.1146666666666667+'px;"></div>',
	           		   		'<div class="userFriendMessageCls" style="'+labelPanelStyle+';float:left;">{[this.replaceLinks(values)]}<div style="font-size:'+windowHeight*0.0194902548725637+'px;">{[this.getFormattedDate(values)]}</div></div>',
	           		   		'</tpl>',
	 	           	   '</div>',
                   '</tpl>',
                   '<tpl if="this.isSenderUserPanel(values)">',
                   		'<div style="'+chatRightPanelStyle+'">',
                   			//'<div id="{id}"  class="userMessageCls" style="'+labelPanelStyle+';float:right;text-align: right !important;">{[this.replaceLinks(values)]}</div>',
               			'<div  class="userMessageCls" style="'+labelPanelStyle+';float:right;text-align: right !important;">{[this.replaceLinks(values)]}<div style="font-size:'+windowHeight*0.0194902548725637+'px;">{[this.getFormattedDate(values)]}</div></div>',
                   		'</div>',
                   '</tpl>',
                   '</div>',
               	'</tpl>',
               	{
 	        	  isSenderUserPanel: function(values) {
 	                 // return parseInt(loginUserId) === parseInt(value.senderUserId)?true:false;
 	        		// console.log("values :=== "+values.type)
	                 if(values.type == "S"){
	                	 return true;
	                 }
 	        		  //return true;
 	              },
 	              isReceiverUserPanel: function(values) {
 	            	  //console.log("values :=== "+values.type)
	                 if(values.type == "R"){
	                	 return true;
	                 }
 	            	
	              },
	              /**
	               *  getFormattedDate : function to get a formatted date with and without AMPM by #1062
	               *  @param{string} date- date
	          	 *  @param{boolean} for date format- true or false
	               */
	              getFormattedDate: function(values){
	            	    //console.log("Date of message :=== ",values.date);
		          		var dateTimeSplit = values.date.split(" ");
		          		var dateSplit = dateTimeSplit[0].split("-");
		          		var timeSplit = dateTimeSplit[1].split(":");
		          		var offset = new Date().getTimezoneOffset() / 60;
		          		var offsetNew = (3600000*(offset+0)*-1); // 0 for utc date time offset
		          		var d = new Date(dateSplit[0], dateSplit[1]-1, dateSplit[2], timeSplit[0], timeSplit[1], timeSplit[2]);
		          		//console.log("offset:=== ",offsetNew);
		          		var nd = new Date(d.getTime() + offsetNew);
		                //console.log("in else at 118",nd);
		          	    return Ext.Date.format( nd,'M d, h.i a' );
	          	  },
	             
	                /**
		             *  convertUTCDateToLocalDate : function convert UTC Date To Local Date.
		             *  @param{string} date- date
		             */
	                convertUTCDateToLocalDate: function(date, dateArray) {
	                    var me = this;
	                    var offset = date.getTimezoneOffset() / 60;
	                    var offsetNew = (3600000 * (offset -6) * -1);
	                    // -6 for Central time US date offset
	                    var dateString = dateArray[1].replace(",", " ").trim();
	                    //year				 //month	 				//date				//hours         	//minutes	 
	                    var d = new Date(date.getFullYear(), date.getMonth(), parseInt(dateString), date.getHours(), date.getMinutes());
	                    var nd = new Date(d.getTime() + offsetNew);
	                    //console.log("Formatted date :=== "+Ext.Date.format(nd, 'M d, h:i a'));
	                    return Ext.Date.format(nd, 'M d, h:i a');
	                },
	                replaceLinks :function( values ){
	                	 var urlRegex = /(((https?:\/\/)|(www\.)|(http:?:\/\/))[^\s]+)/g;
		                    //var urlRegex = /(https?:\/\/[^\s]+)/g;
		                    var textMessageWithLinks = values.text.replace(urlRegex, function(url,b,c) {
		                        var url2 = (c == 'www.') ?  'http://' +url : url;
		                        var id = values.id;
		                        if(c == 'www.'){
		                        	url='http://' +url ;
		                        }
		                        return '<a id="link_'+id+'">' + url + '</a>';
		                    }) ;
		                    return textMessageWithLinks;
	                }
	                 
	        	
	        	
               	}
		);
		var chatMessageStore=Ext.getStore('chatdStoreId');
		chatMessageStore.sort('date','ASC');
		var chatListHeight = chatPanelHeight- (windowHeight * 0.0988671875);
		var chatList = ({
        	xtype: 'list',
        	id:'chatMessageListId',
        	name:'chatMessageList',
        	cls:'chatListPanelCls',
        	width : windowWidth > maxScreenWidth ? windowWidth : maxScreenWidth,
			height : parseInt(chatListHeight),
			itemTpl: chatListTpl,
			store: chatMessageStore,
			scrollToTopOnRefresh:false,
			action:'onListMessageTap',
			margin: '0 0 0 0',
			padding: 0
			
		});
		var mainPnelHeight = windowHeight-windowHeight* 0.0924295774647887;
		
		var mainPanel = {
   			xtype : 'panel',
			width : windowWidth,
			height : mainPnelHeight,
			scrollable: false,
			layout : {
				type : 'vbox',
				pack : 'start',
				align : 'center'
			},
			items:[ 
			      
				   {
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
			        	        	name: 'chatBackBtn',
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
									name:'chatFriendName',
									height: windowHeight * 0.04375,
									margin:'0 0 0 0',
			        	        	padding:'0 0 0 0',
			        	        	cls:'chatScreenTitleCls',
			        	        	html:'<div align="center">Test Friend</div>',
						        	style: 'font-size:'+windowWidth * 0.0563607085346216+'px'
								}
					    ]
				   },
				   {
						xtype:'spacer',
						width: maxScreenWidth * 0.8405797101449275,
						height:windowHeight * 0.0267210144927536
				   },
				   {
						xtype : 'panel',
						width : windowWidth > maxScreenWidth ? windowWidth : maxScreenWidth,
						height:chatPanelHeight- (windowHeight * 0.0985915492957746),
						name:'chattingParentPanel',
						id:'chattingParentPanelId',
						cls:'whiteBackgroundCls',
						padding : '0 0 0 0',
						style:'border-bottom:1px solid #dbdbdb;',
						layout : {
							type : 'hbox',
							pack : 'start',
							align : 'start'
						},
						items : 
							  [
								{
									xtype : 'panel',
									width : '100%',
									height : '100%',
									maxHeight:chatPanelHeight,
									id:'chatPanelId',
									name:"chatPanel",
									/*scrollable: {
									    direction: 'vertical',
									    directionLock: true
									},*/
									cls:'chatPanelCls',
									action:'chatPanelAction',
									style:'padding-bottom:10px;overflow:scroll;',
									layout : {
										type : 'vbox',
										pack : 'start',
										align : 'left'
									},
									items :[
												/*{
													   xtype: 'button',
													   id: 'loadEarlierChatBtnId',
													   name: 'loadEarlierChatBtnName',
													   width:'100%',
													   height:windowHeight * 0.06,//'10%',
													   margin:'0 0 0 0',
													   padding:'0 0 0 0',
													   text:'Load prior messages',
													   action:'loadEarlierChatAction',
													   cls:'loadEarlierButtonCls',
													   ui:'plain'
												},*/
												{
													   xtype: 'button',
													   id: 'doClockInFirstBtn',
													   name: 'doClockInFirstBtn',
													   width:'100%',
													   height:windowHeight * 0.06,
													   margin:'0 0 0 0',
													   padding:'0 0 0 0',
													   text:'Please clock in first',
													   action:'doClockInFirst',
													   hidden:true,
													   ui:'plain'
												},
												chatList
									]
								}
						]
					},
					{
					    xtype:'panel',
					    width:'100%',
					    height:windowHeight * 0.0985915492957746,
					    cls:'sendButtonPanelCls',
					    name:'sendButtonParentPanel',
					    id:'sendButtonParentPanelId',
					    layout : {
							type : 'hbox',
							pack : 'center',
							align : 'center'
						},
						items:[
						    {
						    	xtype:'panel',
						    	width:maxScreenWidth * 0.6682769726247987,
							    height: '100%',
							    cls:'whiteBackgroundCls',
							    layout : {
									type : 'hbox',
									pack : 'center',
									align : 'center'
								},
								items:[
									{
										xtype : 'panel',
										width :maxScreenWidth * 0.6682769726247987,
										layout : {
											type : 'vbox',
											pack : 'center',
											align : 'center'
										},
										html:'<div id="hiddenDivId" class="hiddendiv chatMessageFieldCls" style="width:'+maxScreenWidth * 0.6682769726247987+'px;font-size:'+windowHeight*0.022887323943662+'px;min-height:'+windowHeight * 0.0480072463768116+'px;line-height:'+windowHeight * 0.0480072463768116+'px;"></div><textarea id="chatTextField" rows="1" placeholder="Message" style="width:'+maxScreenWidth * 0.6682769726247987+'px;font-size:'+windowHeight*0.022887323943662+'px;max-height:'+chatMessageComponentMaxHeight+'px;min-height:'+windowHeight * 0.0480072463768116+'px;line-height:'+windowHeight * 0.0480072463768116+'px; padding:0 0 0 0.4em;" class="chatMessageFieldCls" onKeyUp="Eatzy.util.ChatUtil.onChatMessageKeyUp(this)" onKeyPress="Eatzy.util.ChatUtil.onKeyPress(this)" onfocus="Eatzy.util.ChatUtil.onChatMessageFocus(this)"></textarea>'
									}
									
								]
						    },
						    {
						    	xtype: 'button',
								name : 'chatMessageSendBtn',
								width: windowWidth* 0.1515625,// maxScreenWidth,
								height:windowHeight * 0.0985915492957746,
								disabled:true,
								text:'Send',
							  	cls:'chatSendButtonCls',
							   	style:'font-size:'+windowWidth * 0.0563607085346216+'px',
							   	padding: '0 0 0 0',
							   	margin:'0 0 0 0.4em'
							}
						]
				    }
			]   			
   	}
   	this.add(mainPanel);    	
   }
});