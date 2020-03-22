
/* Created by 1010
 * June 22, 2015
 * To design login screen.
 */
Ext.define('Eatzy.view.LoginView',{
    extend: 'Ext.Panel',
    alias: 'widget.loginView',
    requires:[
        'Ext.form.Panel',
        'Ext.Label',
        'Ext.field.Text',
        'Ext.field.Password',
        'Ext.Img',
        'Ext.Button'
    ],
    config: {
        name: 'loginView',
        cls: 'loginScreenBgCls',
        layout:{
             type:'vbox',
             pack:'center',
             align:'center'
        }
    },

   /*
    *  To initialize login screen by loading components.
    */
    initialize: function(){
    	
            this.callParent(arguments);
            var windowHeight = Eatzy.util.GlobalUtil.getScreenHeight();
            var isTablet = Eatzy.util.CommonUtil.isTablet();
            var mainFormPanel = {
                    xtype: 'formpanel',
                    width: '100%',
                    scrollable: false,
                    height: windowHeight,
                    layout: {
                        type: 'vbox',
                        pack: 'center',
                        align: 'center'
                    },
                    items:[
                             {
                                     xtype: 'panel',
                                     width: '100%',
                                     height: windowHeight*(0.10)
                             },

                             {
                                    xtype: 'panel',
                                    width: '100%',
                                    height: windowHeight*(0.60),
                                    layout: {
                                           type: 'vbox',
                                           align: 'center'
                                    },
                                    items: [
                                            {
                                                    xtype: 'panel',
                                                    width: '90%',
                                                    height: windowHeight*0.20,
                                                    name: 'logoPanel',
                                                    layout: {
                                                        type: 'vbox',
                                                        pack: 'center',
                                                        align: 'center'
                                                    },
                                                    items: [
                                                            {
                                                                   xtype: 'image',
                                                                   width: windowHeight*0.11,
                                                                   height: windowHeight*0.28,
                                                                   src: 'resources/images/logo.png',
                                                                   mode: '',
                                                                   padding: 2
                                                            }
                                                    ]
                                            },

                                            {

                                                 xtype: 'panel',
                                                 width: '90%',
                                                 height: windowHeight*0.40,
                                                 cls: 'loginTextFieldPanelCls',
                                                 layout: {
                                                    type: 'vbox',
                                                    pack: 'center',
                                                    align: 'center'
                                                 },
                                                 items: [
                                                        {
                                                                xtype: 'textfield',
                                                                width: '100%',
                                                                name: 'userName',
                                                                placeHolder: 'Username',
                                                                cls: isTablet? 'loginTextFieldCls fontSize20PxCls' : 'loginTextFieldCls',
                                                                clearIcon: false
                                                        },

                                                        {
                                                                 xtype: 'panel',
                                                                 width: '99%',
                                                                 height: 3,
                                                                 cls: 'loginWhiteLineBgCls',
																 margin: '4% 0 4% 0'
                                                        },
                                                        {
                                                                xtype: 'passwordfield',
                                                                width: '100%',
                                                                name: 'password',
                                                                placeHolder: 'Password',
                                                                cls: isTablet? 'loginTextFieldCls fontSize20PxCls' : 'loginTextFieldCls',
                                                                clearIcon: false
                                                        },

                                                        {
                                                                xtype: 'label',
                                                                width: '90%',
                                                                height: 40,
                                                                html: 'Please enter correct credentials and try again',
                                                                name: 'errorLabel',
                                                                margin: '5% 0 0 0',
                                                                cls: isTablet? 'errorLabelCls fontSize20PxCls' : 'errorLabelCls',
                                                                hidden: true
                                                        },

                                                        {
                                                                xtype: 'button',
                                                                width: '100%',
                                                                height: windowHeight*0.08,
                                                                margin: '6% 0 0 0',
                                                                cls:'loginSignInBtnBgCls',
                                                                action: 'onLoginClick'
                                                        }

                                                 ]
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