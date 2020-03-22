/* Created by 1010
 * June 25, 2015
 * To design bottom tab screen.
 */
Ext.define('Eatzy.view.BottomTabPanelView',{
	
	    extend: 'Ext.Panel',
	    xtype: 'bottomTabPanelView',
	    requires: [
	        'Ext.TitleBar',
	        'Ext.Video'
	    ],
	    config: {
	        tabBarPosition: 'bottom',
	        name:'bottomTabPanel',
	        confirm: true,
			 listeners: {
	            activeitemchange: {
	                order: 'before',

	                fn: function (list, value, oldValue, eOpts) {
	                    var me = this;
	                    var oldTabIdx = me.getInnerItems().indexOf(oldValue);
	                    var newTabIdx = me.getInnerItems().indexOf(value);


	                    if (oldTabIdx == 2 && me.getConfirm()) {
	                        Ext.Msg.confirm("Leave Screen?", "Are you sure you?", function (response) {
	                          
	                            if (response === 'no') {
	                                console.log("User says stay.");
	                            } else {
	                                console.log("User says leave.");
	                                me.setConfirm(false);
	                                me.setActiveItem(newTabIdx);
	                            }
	                        });
	                        return false;
	                    } else {
	                        me.setConfirm(true);
	                    }
	                }
	            }
	        }
	    },
	    initialize:function(){
	    	this.callParent(arguments);
	    	var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
            var windowWidth= Ext.Viewport.getWindowWidth();
            var me= this;
	    	var tabPanel = Ext.create('Ext.TabPanel', {
				docked : 'bottom',
				width:'100%',
				height:'100%',
				styleHtmlContent : true,
				cls:'tabPanelCls',
				id:'mainTabPanel',
				tabBar : {
					 docked: 'bottom',
					 height:windowHeight* 0.0924295774647887,//0.096830985915493,
					 id: 'tabBarId',
					 cls:'tabBarCls'
				},
				items : [

							{
							    layout: 'fit',
							    xtype: 'panel',
							    iconCls: 'mapIconCls',
							    iconAlign:'center',
							    items: [
							            {html: '<div style="padding-left:20px;padding-top:20px;">Not Available</div>'}
							    ]
							}, {
							    layout: 'fit',
							    xtype: 'container',
							    iconCls: 'directionIconCls',
							    iconAlign:'center',
							    items: [
							            {html: '<div style="padding-left:20px;padding-top:20px;">Not Available</div>'}
							    ]
							}, {
							    layout: 'fit',
							    xtype: 'container',
							    iconCls: 'historyIconCls',
							    iconAlign:'center',
							    items: [
							            {html: '<div style="padding-left:20px;padding-top:20px;">Not Available</div>'}
							    ]
							},
							{
							    layout: 'fit',
							    xtype: 'container',
							    iconCls: 'chatIconCls',
							    iconAlign:'center',
							    id:'chatContainer',
							    tabName:'chatTab',
							    items: [
											{
												xtype:'statusView'
											}
							    ],
							    listeners:{
							    	
							    	tap:function(button){
							    		//console.log("on chat click");
							    		Eatzy.util.CommonUtil.setIsStatusViewDisplay(false);
							    		var loginStore = Ext.getStore('loginStoreId');
	        							var loginRecordObj = loginStore.getAt(0);
	        							//console.log("11111111111111111",Eatzy.util.CommonUtil.getIsStatusViewDisplay());
	            						if(Eatzy.util.CommonUtil.getIsStatusViewDisplay()== false){
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
	            						}
							    	}
						    	    
							    }
							   
							},
							{
							    layout: 'fit',
							    xtype: 'container',
							    iconCls: 'menuIconCls',
							    iconAlign:'center',
							    name:'menuButton'
							    
							}
									
											         
											         
				         
				         
			    ],
			    listeners:{
			    	activeitemchange:function( tabpanel, value, oldValue, eOpts ){
			    		var me= this;
			    		 //Eatzy.util.CommonUtil.setIsStatusViewDisplay(true);
			    		if(Ext.getCmp('tabBarId')!= undefined){
			    			var tabArray = Ext.getCmp('tabBarId').getItems();
			    			
				    		if(tabpanel.getTabBar().getActiveTab().getIconCls()=="mapIconCls"){
				    			   
				    			    tabpanel.getTabBar().getActiveTab().setIconCls("mapIconPressedCls");
					    	    	var selectedIconCls = tabpanel.getTabBar().getActiveTab().getIconCls();
					    	    	Eatzy.util.CommonUtil.removePreviousTabSelectedCls(tabArray,"mapIconCls");
					    	    	if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
					    	    		Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
					    	    	}
					    	    	
				    	    	
				    	    }else if(tabpanel.getTabBar().getActiveTab().getIconCls()=="directionIconCls"){
				    	    	    tabpanel.getTabBar().getActiveTab().setIconCls("directionIconPressedCls");
					    	    	
					    	    	Eatzy.util.CommonUtil.removePreviousTabSelectedCls(tabArray,"directionIconCls");
					    	    	if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
					    	    		Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
					    	    	}
					    	    	
				    	    }else if(tabpanel.getTabBar().getActiveTab().getIconCls()=="historyIconCls"){
				    	    	    tabpanel.getTabBar().getActiveTab().setIconCls("historyIconPressedCls");
				    	    	    Eatzy.util.CommonUtil.removePreviousTabSelectedCls(tabArray,"historyIconCls");
				    	    	    if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
					    	    		Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
					    	    	}

				    	    }else if(tabpanel.getTabBar().getActiveTab().getIconCls()=="chatIconCls"){
					    	    	tabpanel.getTabBar().getActiveTab().setIconCls("chatIconPressedCls");
					    	    	Eatzy.util.CommonUtil.removePreviousTabSelectedCls(tabArray,"chatIconCls");
					    	    	
					    	    	var loginStore = Ext.getStore('loginStoreId');
					    	    	if(loginStore.getAllCount() > 0){
	        							var loginRecordObj = loginStore.getAt(0);
	        							//console.log("11111111111111111",Eatzy.util.CommonUtil.getIsStatusViewDisplay());
	            						if(Eatzy.util.CommonUtil.getIsStatusViewDisplay()== true){
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
	            						}
					    	    	}
					    	    	
				    	    }else if(tabpanel.getTabBar().getActiveTab().getIconCls()=="menuIconCls"){
				    	    	    //console.log("In menu button click")
				    	    	    tabpanel.getTabBar().getActiveTab().setIconCls("menuIconPressedCls");
					    	    	
					    	    	Eatzy.util.CommonUtil.removePreviousTabSelectedCls(tabArray,"menuIconCls");
					    	    	//console.log("Ext.getCmp('menuButtonDropDownOverlayViewId')",Ext.getCmp('menuButtonDropDownOverlayViewId'));
						    		if(Ext.getCmp('menuButtonDropDownOverlayViewId')!=undefined){
						    			Ext.getCmp('menuButtonDropDownOverlayViewId').destroy();
						    			//var menuButtonDropDownOverlayView = Ext.create('Eatzy.view.MenuButtonDropDownOverlayView');
						    			var menuButtonDropDownOverlayView = Ext.create('Eatzy.view.MenuButtonDropDownOverlayView');
						                   
						    	    	menuButtonDropDownOverlayView.showBy(tabpanel.getTabBar().getActiveTab());
						    		}else{
						    			var menuButtonDropDownOverlayView = Ext.create('Eatzy.view.MenuButtonDropDownOverlayView');
						                   
						    	    	menuButtonDropDownOverlayView.showBy(tabpanel.getTabBar().getActiveTab());
						    		}
					    	    	
						    		if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
					    	    		Eatzy.util.CommonUtil.doSaveChatScreenExitTime();
					    	    	}
					    	    
				    	    }else{
				    	    	console.log("Not selected any tab");
				    	    }	
			    		}
			    		    	    
			    	    
			    	    }

			    }
			});

			this.add([tabPanel]);
			tabPanel.addListener({
			    // Ext.Buttons have an xtype of 'button', so we use that are a selector for our delegate
			    delegate: 'button',

			    tap: function(button) {
			     //console.log('Button tapped!',button._iconCls);
			     if(button.getIconCls()=="chatIconPressedCls"){
			    	 me.showChatMessageView();
			     }
			     if(button.getIconCls()=="menuIconPressedCls"){
			    	 if(Ext.getCmp('menuButtonDropDownOverlayViewId')!=undefined){
		    			Ext.getCmp('menuButtonDropDownOverlayViewId').destroy();
		    			var menuButtonDropDownOverlayView = Ext.create('Eatzy.view.MenuButtonDropDownOverlayView');
		    			var menuTab = Ext.getCmp('mainTabPanel').getTabBar().getActiveTab();
		    			menuButtonDropDownOverlayView.setBottom(0);
		    	    	menuButtonDropDownOverlayView.showBy(menuTab);
		    		}
			     }
			     
			    }
			});
	    },
	    //To show chatview on click of chat tab
	    showChatMessageView:function(){
	    	if(Eatzy.util.CommonUtil.getIsDriverClockIn()){
	    		var loginStore = Ext.getStore('loginStoreId');
	    		if(loginStore.getAllCount() > 0){
					var loginRecordObj = loginStore.getAt(0);
					//console.log("11111111111111111",Eatzy.util.CommonUtil.getIsStatusViewDisplay());
					//if(Eatzy.util.CommonUtil.getIsStatusViewDisplay()== false){  //commented by #1044 to avoid clock in status mismatch issue
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
					//}
	    		}
	    	}else{
				/// In case of user is not clock in
				Eatzy.util.CommonUtil.showToastMessage("Please clock in first",40000);
			}
	    }

});