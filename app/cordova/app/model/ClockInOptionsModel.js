/*
 * Created by 1010
 * July 8,2015
 * This class define fields to store clock in options for user.
 */

Ext.define('Eatzy.model.ClockInOptionsModel',{
	extend : 'Ext.data.Model',
    config :{
            identifier: {
                    type: 'uuid'
            },
            fields: [
                    { name: 'selected', type: 'auto' },
                    { name: 'shifts', type: 'auto' },
                    { name: 'offices', type: 'auto' },
                    { name: 'territories', type: 'auto' }
                    
            ]
	}
});