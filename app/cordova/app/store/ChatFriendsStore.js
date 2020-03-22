/*
 * Created by 1010
 * July 9,2015
 * This class define fields to store friends data.
 */

Ext.define('Eatzy.store.ChatFriendsStore', {
    extend: 'Ext.data.Store',
    requires: "Ext.data.proxy.LocalStorage",

	config: {
		model: 'Eatzy.model.ChatFriendsModel',
        storeId: 'chatFriendsStoreId',
		autoLoad: true,
		autoSync: true,

    	proxy: {
                type: 'localstorage',
                id  : 'chatFriends-StoreId'
        }
	}
});