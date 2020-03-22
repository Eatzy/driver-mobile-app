/*
 * Created by 1010
 * 22 June 2015
 * To define global variables.
 */
Ext.define('Eatzy.util.GlobalUtil',{
    singleton : true,
    config : {
            windowHeight: '',
            baseUrl: 'http://dev2.bos.eatsy.net/api/mobileapp/',   //http://dev.bos.eatsy.net/api/mobileapp/   //New URL http://dev2.bos.eatsy.net/api/mobileapp/
            apiKey: 'a85e1b9cdafb3479477e9277dea97a31',
            apiVersion: '1',
            sandboxValue: '1',
            loginUrl: 'login',
            clockInOptionsUrl:'getclockinoptions',
            clockInUrl:'clockin',
            clockOutUrl:'clockout',
            userMessages:'getmessages',
            refreshStatus:'refresh',
            screenWidth:'',
    	    maxScreenWidth: '',
            screenHeight:''
    },

    constructor : function(config) {
            this.initConfig(config);
            this.callParent([config]);
    },
    
    /**
     * Function: used to get MaxScreenWidth
     */
    getMaxScreenWidth:function(){
   	 var screenWidth=Ext.Viewport.getWindowWidth();
   	 var maxScreenWidth=screenWidth;
   	 
   	 if(screenWidth <=500){
   		 maxScreenWidth= screenWidth;
   	 }else if(screenWidth >500 && screenWidth <=600){
   		 maxScreenWidth= screenWidth* 0.85;
   	 }else if(screenWidth >600){
   		 maxScreenWidth= screenWidth* 0.70;
   	 }
   	 return maxScreenWidth;
    }
});