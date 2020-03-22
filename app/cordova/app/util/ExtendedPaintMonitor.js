/**  Created by 1010
  *  27 July 2015
  *  Used to handle google chrome contents not scroll block issue
**/
Ext.define('Eatzy.util.ExtendedPaintMonitor', {
	override : 'Ext.util.PaintMonitor',
	
	constructor: function(config) {
		try{
			if (Ext.browser.is.Firefox || (Ext.browser.is.WebKit && Ext.browser.engineVersion.gtEq('536') && !Ext.browser.engineVersion.ltEq('600.1.3') && !Ext.os.is.Blackberry)) {
	            return new Ext.util.paintmonitor.OverflowChange(config);
	        }else {
	            return new Ext.util.paintmonitor.CssAnimation(config);
	        }
		}catch(error){
			return new Ext.util.paintmonitor.CssAnimation(config);
		}
	}
});