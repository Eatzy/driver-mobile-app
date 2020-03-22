/*
 * Created by 1010
 * July 9,2015
 * This class define fields to store chat data.
 */


Ext.define('Eatzy.store.ChatStore', {
    extend: 'Ext.data.Store',
    requires: "Ext.data.proxy.LocalStorage",

	config: {
		model: 'Eatzy.model.ChatModel',
        storeId: 'chatdStoreId',
		autoLoad: true,
		autoSync: true,

    	proxy: {
                type: 'localstorage',
                id  : 'chat-StoreId'
        },
        data:[
              
					/*{
						"date" : "Jul 29,3:00 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,3:01 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,3:02 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,3:03 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,21:36 pm",
						"text" : "Hello number 4 message !!!!!!",
						"type" : "S"
					}, {
						"date" : "Aug 31,1:05 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,1:06 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,1:06 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,1:07 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,1:08 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,1:09 pm",
						"text" : "Hello",
						"type" : "S"
					}, {
						"date" : "Jul 29,2:59 pm",
						"text" : "Hello",
						"type" : "S"
					}*/
  /*{
            "type" : "S",
            "date" : "Aug 31, 2:43 am",
            "text" : "My test"
        }, {
            "type" : "S",
            "date" : "Aug 31, 2:29 am",
            "text" : "Retesting text"
        }, {
            "type" : "S",
            "date" : "Aug 31, 2:30 am",
            "text" : "My test"
        }, {
            "type" : "S",
            "date" : "Aug 31, 1:30 am",
            "text" : "hey retest 123"
        }, {
            "type" : "S",
            "date" : "Aug 31, 1:04 am",
            "text" : "beta testing"
        }, {
            "type" : "S",
            "date" : "Aug 31, 12:57 pm",
            "text" : "i m not testing"
        }, {
            "type" : "S",
            "date" : "Aug 31, 12:47 pm",
            "text" : "new testing1"
        }, {
            "type" : "S",
            "date" : "Aug 31, 12:32 pm",
            "text" : "I am testing app"
        }, {
            "type" : "S",
            "date" : "Aug 31, 12:04 pm",
            "text" : "hey tested it."
        }, {
            "type" : "S",
            "date" : "Aug 31, 11:58 am",
            "text" : "im fine.."
        }, {
            "type" : "S",
            "date" : "Aug 31, 11:50 am",
            "text" : "test time"
        }, {
            "type" : "S",
            "date" : "Aug 31, 11:39 am",
            "text" : "retest"
        }, {
            "type" : "S",
            "date" : "Aug 31, 11:29 am",
            "text" : "hello whats up?"
        }, {
            "type" : "S",
            "date" : "Aug 31, 11:24 am",
            "text" : "sss"
        }, {
            "type" : "S",
            "date" : "Aug 31, 11:08 am",
            "text" : "Hello"
        }, {
            "type" : "S",
            "date" : "Aug 31, 11:07 am",
            "text" : "Testing 1234567"
        }, {
            "type" : "S",
            "date" : "Aug 31, 8:16 am",
            "text" : "sgsdgsdgsdg"
        }, {
            "type" : "S",
            "date" : "Aug 31, 8:15 am",
            "text" : "dggfdfgdfg"
        }, {
            "type" : "S",
            "date" : "Aug 31, 8:11 am",
            "text" : "dgfrdfgdfgdfgdfg"
        }, {
            "type" : "S",
            "date" : "Aug 31, 7:57 am",
            "text" : "Lirefggchcccccccc"
        }, {
            "type" : "S",
            "date" : "Aug 31, 7:42 am",
            "text" : "Lorem epsum"
        }, {
            "type" : "S",
            "date" : "Aug 31, 7:42 am",
            "text" : "jkvkvvjkvgghhhbbbbbbbbbbbbnnn"
        }, {
            "type" : "S",
            "date" : "Aug 31, 7:37 am",
            "text" : "Hxhcjchccccccvv"
        }, {
            "type" : "S",
            "date" : "Aug 31, 7:36 am",
            "text" : "Ret"
        }, {
            "type" : "S",
            "date" : "Aug 31, 6:58 am",
            "text" : "Testggxhcn"
        }, {
            "type" : "S",
            "date" : "Aug 31, 6:56 am",
            "text" : "Hccvvbhhjjnnn"
        }*/
                           
              
              ]
	}
});