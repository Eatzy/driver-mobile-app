/*
 * Created by 1010
 * July 27,2015
 * This class define fields to store chat data.
 */

Ext.define('Eatzy.model.ChatScreenExitTimeModel', {
	extend : 'Ext.data.Model',

	config : {
		identifier: {
	        type: 'uuid',
	        isUnique : true
	    },
		fields : [
				   
		            {name: 'exitTime',type: 'string'}
				
			   
		]
    }
});