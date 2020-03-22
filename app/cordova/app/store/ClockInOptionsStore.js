/*
 * Created by 1010
 * July 8,2015
 * To save the clock in options for user.
 */

Ext.define('Eatzy.store.ClockInOptionsStore', {
    extend: 'Ext.data.Store',
	requires: "Ext.data.proxy.LocalStorage",
	config: {
            model: 'Eatzy.model.ClockInOptionsModel',
            storeId: 'clockInOptionsStoreId',
            autoLoad: true,
            autoSync: true ,
            proxy: {
                    type: 'localstorage',
                    id: 'clockInOptionsStore'
            }
	}
});