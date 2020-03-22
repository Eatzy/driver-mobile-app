/**  Created by 1010
  *  July 16, 2015
  *  MenuButtonDropDownOverlayView to show menu options to user 
 **/

Ext.define("Eatzy.view.MenuButtonDropDownOverlayView", {
  extend : "Ext.Panel",
  alias : "widget.menuButtonDropDownOverlayView",

  requires : [ 'Ext.Panel',  'Ext.MessageBox'],

  config : {
      layout : {
        type : 'card',
        pack : 'center',
        align : 'middle'

      },
     id:'menuButtonDropDownOverlayViewId',
     width: 200,
     height: 100,
     bottom:0,
     modal : true,
     centered: false,
     hideOnMaskTap: true,
     baseCls:'menuBtnOverlayCls',
     style:'border:1px solid black;'
  },

  /**
      *  Load UI on initialize of MoreButtonOverlayView.
      */
  initialize : function() {

    this.callParent(arguments);

    var dropDownMenuPanel = Ext.create('Ext.Panel', {
                                          width:'100%',
                                          height:'100%',
                                          style:'background:none;',
                                          cls:'dropDownMenuPanelCls',
                                          layout: {
                                                type: 'vbox',
                                                pack: 'center',
                                                align: 'center'
                                          },
                                          items: [
                                                 
                                                  {
                                                      xtype:'button',
                                                      text:'Logout',
                                                      width:'100%',
                                                      height:'25%',
                                                      cls:'cursorPointerCls menuButtonOverlayButtonCls',
                                                      style:'border-top:none!important;border-bottom:none;',
                                                      action:'logoutBtnClick'
                                                  }

                                          ]
     });

     this.add([dropDownMenuPanel]);
  }

});