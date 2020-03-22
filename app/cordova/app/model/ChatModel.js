/*
 * Created by 1010
 * July 9,2015
 * This class define fields to store chat data.
 */

Ext.define('Eatzy.model.ChatModel', {
	extend : 'Ext.data.Model',

	config : {
		identifier: {
	        type: 'uuid',
	        isUnique : true
	    },
		fields : [
				   /* {name: 'chatId',type: 'int'},
		            {name: 'senderUserId',type: 'int'},
		            {name: 'receiverUserId',type: 'int'},
		            {name: 'message',type: 'string'},
		            {name: 'createdTime',type: 'string'}*/
				    {name: 'date',type: 'string'},
				    {name: 'text',type: 'string'},
				    {name: 'type',type: 'string'}
			   
		]
    }
});