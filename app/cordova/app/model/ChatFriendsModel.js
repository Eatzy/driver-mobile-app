/*
 * Created by 1010
 * July 9,2015
 * This class define fields to store friend data.
 */


Ext.define('Eatzy.model.ChatFriendsModel', {
	extend : 'Ext.data.Model',

	config : {
		identifier: {
	        type: 'uuid',
	        isUnique : true
	    },
		fields : [
		    {name: 'friendId',type: 'int'},
            {name: 'imageUrl',type: 'string'},
            {name: 'firstName',type:'string'},
            {name: 'unSeenChatCount',type:'int'},
            {name: 'unseenFriendStatus',type:'int'},
            {name: 'latestChatId',type:'int'},
            {name: 'previousChatPresent',type:'int'},
            {name: 'latestChatTime', type:'date'}
		],
		hasMany:[{model: 'Eatzy.model.ChatModel',name:'chatList',associationKey:'chatList'}]
    }
});