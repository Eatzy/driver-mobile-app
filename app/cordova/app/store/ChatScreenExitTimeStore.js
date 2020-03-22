/*
 * Created by 1010
 * July 27,2015
 * This class define fields to store chat exit time data.
 */


Ext.define('Eatzy.store.ChatScreenExitTimeStore', {
    extend: 'Ext.data.Store',
    requires: "Ext.data.proxy.LocalStorage",

	config: {
		model: 'Eatzy.model.ChatScreenExitTimeModel',
        storeId: 'chatScreenExitTimeStoreId',
		autoLoad: true,
		autoSync: true,

    	proxy: {
                type: 'localstorage',
                id  : 'chatScreenExitTime-StoreId'
        }/*,
        
        data:[
{"exitTime":"Tue Jul 30 2015 12:11:03 GMT+0530 (India Standard Time)","id":"ea137c9d-dfa4-4ffa-a5ed-d10ef01f2286"}
              
              
              ]*/
        
	}
});