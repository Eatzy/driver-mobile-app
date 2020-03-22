/**  Created by 1010
  *  27 July 2015
  *  Used to handle google chromecontents not scroll block issue
**/
Ext.define('Eatzy.util.ExtendedSizeMonitor', {
	override : 'Ext.util.SizeMonitor',
	
	constructor: function(config) {
		try{
			var namespace = Ext.util.sizemonitor;
			if (Ext.browser.is.Firefox) {
				return new namespace.OverflowChange(config);
			}else if (Ext.browser.is.WebKit) {
				if (!Ext.browser.is.Silk && Ext.browser.engineVersion.gtEq('535') && !Ext.browser.engineVersion.ltEq('600.1.3')) {
					return new namespace.OverflowChange(config);
				} else {
					return new namespace.Scroll(config);
				}
			}else if (Ext.browser.is.IE11) {
				return new namespace.Scroll(config);
			}else {
				return new namespace.Scroll(config);
			}
		}catch(error){
			return new namespace.Scroll(config);
		}
	}
});