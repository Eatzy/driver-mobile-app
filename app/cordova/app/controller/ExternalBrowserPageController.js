/** Created by 1010
 *  Oct 23, 2015
 *  Used to handle user match friends list 
 **/
Ext.define('Eatzy.controller.ExternalBrowserPageController',{
	extend:'Eatzy.controller.GenericController',
	config:{
		control:{
			'button[action = externalBrowserPageBackButton]':{
                tap:'doOpenExternalBrowserPageView'
            }
		}
     },
     doOpenExternalBrowserPageView:function(){
    	 //console.log("**************doOpenExternalBrowserPageView **************************");
    	 var loginStore = Ext.getStore('loginStoreId');
    	 if(loginStore.getAllCount() > 0){
			 var loginRecordObj = loginStore.getAt(0);
			 Ext.ComponentQuery.query('panel[name=externalBrowserPageView]')[0].destroy();
			 //console.log("Ext.ComponentQuery.query('panel[name=chatView]')[0] :=== ",Ext.ComponentQuery.query('panel[name=chatView]')[0])
	    	 if(Ext.ComponentQuery.query('panel[name=chatView]')[0]!=undefined){
					Ext.ComponentQuery.query('panel[name=chatView]')[0].destroy();
					Ext.getCmp('chatContainer').add({xtype:'chatView'});
					Eatzy.util.CommonUtil.reduceListItemHeight();
					Ext.ComponentQuery.query('label[name=chatFriendName]')[0].setHtml('<div align="center">'+loginRecordObj.get('rds_name')+'</div>');
			 }else{
					//console.log("In else");
					Ext.getCmp('chatContainer').add({xtype:'chatView'});
					Eatzy.util.CommonUtil.reduceListItemHeight();
					Ext.ComponentQuery.query('label[name=chatFriendName]')[0].setHtml('<div align="center">'+loginRecordObj.get('rds_name')+'</div>');
					
			 }
    	 }
     }
});