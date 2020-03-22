/*
 * Created by 1010
 * Nov 19,2015
 * To save the device token.
 */

Ext.define('Eatzy.store.DeviceTokenStore', {
    extend: 'Ext.data.Store',
	requires: "Ext.data.proxy.LocalStorage",
	config: {
            model: 'Eatzy.model.DeviceTokenModel',
            storeId: 'deviceTokenStoreId',
            autoLoad: true,
            autoSync: true ,
            proxy: {
                    type: 'localstorage',
                    id: 'deviceTokenStore'
            }
	}
});