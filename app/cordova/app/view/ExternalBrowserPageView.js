/* Created by 1010
 * Oct 23, 2015
 * To design External Browser Page view screen.
 */

Ext.define('Eatzy.view.ExternalBrowserPageView',{
	extend:'Ext.Panel',
	alias:'widget.externalBrowserPageView',
	
   config: {
		
	    name: 'externalBrowserPageView',
		cls:'commonBackgroundCls',
		width: '100%',
		layout : {
			type : 'vbox',
			pack : 'start',
			align : 'center'
		},
		requestedURL:''
   },
   
   initialize:function(){
	    this.callParent(arguments);
	    
	    var windowHeight = Ext.Viewport.getWindowHeight();
	    //this.setHeight(windowHeight-windowHeight* 0.0924295774647887);
		var windowWidth = Ext.Viewport.getWindowWidth();
	    var mainPanelHeight = windowHeight-windowHeight* 0.0924295774647887;
		var topToolBarPanel = Eatzy.util.CommonUtil.createTopToolbar();
		var browserPanelHeight = windowHeight -windowHeight*0.0783450704225352; 
		var extrenalBrowserPageView = {
   			xtype : 'panel',
			width : windowWidth,
			height : windowHeight,
			scrollable: false,
			layout : {
				type : 'vbox',
				pack : 'start',
				align : 'center'
			},
			items:[ 
			      
				   topToolBarPanel,
				   {
	                   xtype:'panel',
	                   width:'100%',
	                   height:browserPanelHeight,
	                   scrollable:false,
	                   layout:{
	                       type:'vbox',
	                       pack:'start',
	                       align:'center'
	                   },
	                  html:'<div style="-webkit-overflow-scrolling: touch;overflow-x:hidden;overflow-y: scroll;height:'+browserPanelHeight+'px;"><iframe X-Frame-Options="SAMEORIGIN" data="*" src="'+this.getRequestedURL()+'" width="100%" height="100%"></iframe></div>'
	               }
			]   			
   	}
   	this.add(extrenalBrowserPageView);    	
   }
});