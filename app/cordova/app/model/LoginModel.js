/*
 * Created by 1010
 * June 23,2015
 * This class define fields to store loggedIn user data.
 */

Ext.define('Eatzy.model.LoginModel',{
	extend : 'Ext.data.Model',
    config :{
            identifier: {
                    type: 'uuid'
            },
            fields: [
                    { name: 'userId', type: 'string' },
                    { name: 'userToken', type: 'string' },
                    { name: 'job_assignment_id', type: 'string' },
                    { name: 'rds_logo_delivery', type: 'string' },
                    { name: 'rds_logo_delivery', type: 'string' },
                    { name: 'rds_message', type: 'string' },
                    { name: 'rds_name', type: 'string' },
                    { name: 'rds_phone', type: 'string' },
                    { name: 'tz', type: 'string' }
                    
            ]
	}
});