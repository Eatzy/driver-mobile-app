
/* Created by 1010
 * June 24, 2015
 * To design status view screen.
 */
Ext.define('Eatzy.view.StatusView',{
    extend: 'Ext.Panel',
    xtype:'statusView',
    alias: 'widget.statusView',
    requires:[
        'Ext.form.Panel',
        'Ext.Label',
        'Ext.field.Text',
        'Ext.field.Password',
        'Ext.Img',
        'Ext.Button'
    ],
    config: {
        name: 'statusView',
        cls: 'whiteBackgroundCls',
        layout:{
             type:'vbox',
             pack:'start',
             align:'center'
        }
    },

   /*
    *  To initialize status screen by loading components.
    */
    initialize: function(){
    	
            this.callParent(arguments);
            var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
            var windowWidth= Ext.Viewport.getWindowWidth();
            var isTablet = Eatzy.util.CommonUtil.isTablet();
            var isDisplay= Eatzy.util.CommonUtil.getIsStatusViewDisplay();
            
            var topPanel = Eatzy.util.CommonUtil.createTopToolbarPanel();
          
           
            var mainFormPanel = {
                    xtype: 'formpanel',
                    width: '100%',
                    scrollable: false,
                    height: windowHeight,
                    style:'background:#FFF;',
                    layout: {
                        type: 'vbox',
                        pack: 'center',
                        align: 'center'
                    },
                    items:[
                            
                             topPanel,
                             {
                            	   xtype:'panel',
                            	   width:windowWidth,
                            	   height:windowHeight*0.5262368815592204,
                            	   layout:{
                            		    type:'vbox',
                            		    align:'center'
                            	   },
                            	   items:[
												                            	              
											   {
													xtype:'spacer',
													width:'100%',
													height:windowHeight*0.1784971830985915
											   },
                            	               {
                            	            	    xtype:'button',
                                                    name:'ridersName',
                                                    width:windowWidth*0.8625,
                            	            	    height:windowHeight*0.1285211267605634,
                            	            	    text:'JOHN SMITH',
                            	            	    style:'border:none;border-radius:0;background-image:none; background:#127182;font-size:'+windowWidth * 0.0526932084309133+'px;color:#FFF;'
                            	               },
                            	               {
	                           	            	    xtype:'button',
													width:windowWidth*0.8625,
													height:windowHeight*0.1285211267605634,
	                           	            	    text:isDisplay? 'ACTIVE':'NOT ACTIVE',
	                           	            	    name:'commonActiveNotActiveButton',
	                           	            	    style:'border:none;border-radius:0;background-image:none; background:#e5e5e5;font-family: "Roboto-Light";font-size:'+windowWidth * 0.0526932084309133+'px;color:#127182;'
                           	                   },
                           	                   {
                           	                	     xtype:'spacer',
                           	                	     width:'100%',
                           	                	     height:windowHeight*0.0501760563380282
                           	                   },
                           	                   {
                           	                	    xtype:'button',
	                           	            	    width:windowWidth*0.328125,
	                           	            	    name:'commonButtonForSignInOut',
	                           	            	    height:windowHeight*0.0616197183098592,
	                           	            	    label:'JOHN SMITH',
	                           	            	    cls:isDisplay ? 'signOutButtonCls':'signInButtonCls',
	                           	            	    style:'border-radius:0;font-family:Roboto-Regular;'
                           	                   },
                            	               {
                           	                	     xtype:'spacer',
                           	                	     width:'100%',
                           	                	     height:windowHeight*0.1690140845070423
                           	                   }

                            	          
                            	          ]
                             },
                             {
                                   xtype: 'panel',
                                   width: '100%',
                                   height: windowHeight*(0.30)
                             }
                    ]
            };

            this.add( mainFormPanel );
    }

});