/**
*  Created by 1010
*  Date: July 8,2015
*  MessageBoxOverlay.js
*  This view is used as common component to display message box.
**/
Ext.define("Eatzy.view.widget.MessageBoxOverlay", {
	extend: 'Ext.Panel',
	alias: 'widget.messageBoxOverlay',

    config: {
           zIndex:13,
           modal: true,
           hideOnMaskTap: false,
           id:'messageBoxOverlayId',
           name:'messageBoxOverlay',
           buttonAction : '',
           showAnimation: {
                        type: 'slide',
                        duration: 1000,
                        direction:'down'
           },
           centered: true,
           width: '',
           height: '',
           baseCls:'alertLongListPopupCls'
    },
    /**
    *  Load UI on initialize of DisplayMessageOverlay.
    */
    initialize: function () {

        this.callParent(arguments);

        var windowHeight = Ext.Viewport.getWindowHeight() ;
        var windowWidth = Ext.Viewport.getWindowWidth() ;
        var messageBoxWidth = Eatzy.util.GlobalUtil.getScreenWidth() * 0.7765625;
        var messageBoxHeight = Eatzy.util.GlobalUtil.getScreenWidth() * 0.7765625 * 0.82;
        Ext.ComponentQuery.query('panel[name=messageBoxOverlay]')[0].setWidth(messageBoxWidth);
        Ext.ComponentQuery.query('panel[name=messageBoxOverlay]')[0].setHeight(Eatzy.util.GlobalUtil.getScreenWidth() * 0.7765625 * 0.82);
        var messageBoxTitlePanel= Ext.create('Ext.Toolbar',{
            width:'100%',
            height: windowWidth * 0.71875 * 0.1522,
            docked: 'top',
            name: 'messageBoxTitlebar',
            cls: 'messageBoxTitlebarBgCls',
            layout:{
                type: 'vbox',
                pack:'center',
                align:'center'
            } ,
            items: [
                 {
                     xtype:'label',
                     name:'alertBoxTitle',
                     html:'<div align="center" > <div style="width:'+messageBoxWidth * 0.92958+'px; height:'+messageBoxHeight * 0.05868 +'px;"></div> <div class="alertBoxTitleCls" style="width:'+windowWidth * 0.28125+'px; height:'+windowWidth * 0.28125 * 0.1611 +'px;"></div><div style="width:'+messageBoxWidth * 0.92958+'px; height:'+messageBoxHeight * 0.03423 +'px; border-bottom: 1px solid #585858;"></div></div>'
                 }
            ]
        });

        this.messagePanel = ({
            xtype:'panel',
            width: '100%',
            height:messageBoxHeight * 0.5379,
            cls: 'messageBoxMessagePanelCls',
            name:'messageBoxMessagePanel',
            layout:{
                type:'vbox',
                align:'center',
                pack:'center'
            },
            items:[
            ]
        });
        var buttonPanel =({
            xtype:'panel',
            width:'100%',
            height: (messageBoxWidth * 0.4225/3) +(messageBoxHeight * 0.1149),
            docked:'bottom',
            layout:{
                type:'hbox',
                align:'center',
                pack:'center'
            },
            items:[
                {
                    xtype:'button',
                    name: 'alertBoxYesBtn',
                    width: messageBoxWidth * 0.4225,
                    height: messageBoxWidth * 0.4225/3,
                    cls:'alertBoxYesBtnCls',
                    zIndex:5000,
                    handler: function(btn, e){
                         var config = btn.up('panel[name=messageBoxOverlay]');
                     	 if(config!=undefined){
 		                      if(config.getButtonAction() == 'logoutButton' ){
 		                    	 Eatzy.util.CommonUtil.clearUsersBasicInfo();
 		                      }
 		                      container = btn.up('panel');
 		                      parentContainer = container.up('panel');
 		                      parentContainer.hide();
 		                      parentContainer.destroy();
                     	}
                    }
                },
                {
           			xtype: 'spacer',
           			width: windowWidth * 0.03125,
           			height: messageBoxHeight * 0.17115
           		},
                {
                    xtype:'button',
                    name: 'alertBoxNoBtn',
                    width: messageBoxWidth * 0.4225,
                    height: messageBoxWidth * 0.4225/3,
                    cls:'alertBoxNoBtnCls',
                    zIndex:5000,
                    handler: function(btn, e){
                      container = btn.up('panel');
                      parentContainer = container.up('panel');
                      parentContainer.hide();
                      parentContainer.destroy();
                    }
                }
            ]
        });
       this.add([messageBoxTitlePanel, this.messagePanel,buttonPanel]);
    },
    /**
    * Function: This function is to show  error message
    * @errors: errors object
    **/
    showErrorMessages: function(errors, isYesNoPresent){
    	var alertBoxYesBtn = this.down('button[name=alertBoxYesBtn]');
    	var alertBoxNoBtn = this.down('button[name=alertBoxNoBtn]');
    	if(isYesNoPresent == false){
      	  alertBoxYesBtn.setCls('alertBoxOkBtnCls');
      	  alertBoxNoBtn.setHidden(true);
        }else{
        	alertBoxYesBtn.setCls('alertBoxYesBtnCls');
        	alertBoxNoBtn.setHidden(false);
        }
      var panel = this.down('panel[name=messageBoxMessagePanel]');
      panel.add(Eatzy.util.CommonUtil.convertToErrorMessages(errors));
    }

});