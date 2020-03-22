/*
 * Created by 1010
 * Nov 19,2015
 * This class define fields to store device token data.
 */

Ext.define('Eatzy.model.DeviceTokenModel',{
	extend : 'Ext.data.Model',
    config :{
            identifier: {
                    type: 'uuid'
            },
            fields: [
                   
                    { name: 'deviceToken', type: 'string' },
                  
                    
            ]
	}
});