/*
 * Created by 1010
 * June 23,2015
 * To save the loggedIn user details.
 */

Ext.define('Eatzy.store.LoginStore', {
    extend: 'Ext.data.Store',
	requires: "Ext.data.proxy.LocalStorage",
	config: {
            model: 'Eatzy.model.LoginModel',
            storeId: 'loginStoreId',
            autoLoad: true,
            autoSync: true ,
            proxy: {
                    type: 'localstorage',
                    id: 'loginStore'
            }
	}
});