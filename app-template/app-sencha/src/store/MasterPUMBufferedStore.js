Ext.define( 'smgrui.store.MasterPUMBufferedStore', { 
	extend: 'smgrui.store.MasterBufferedStore',
	alias: 'store.masterpumbufferedstore',
	requires: [
		'Ext.data.identifier.Uuid',
		'Ext.data.reader.Json',
		'Ext.data.writer.Json',
		'smgrui.PUMProxy'
	],
	config: { limited: false  }, 
	constructor: function(cfg) {
		const me = this;
		cfg = cfg || {};
		me.callParent([Ext.apply({
			storeId: Ext.data.identifier.Uuid.Global.generate(),
			proxy: {
				type: 'pumproxy',
				api: me.getApiDef(),
				reader:{ 
					type: 'json', 
					rootProperty: me.getRootProperty(), 
					responseType: null 
				}, 
				writer: { 
					type: 'json', 
					rootProperty: me.getRootProperty(), 
					writeAllFields: true,
					clientIdProperty: 'syscid',
					allowSingle: false
				} 
			}
		}, cfg)]);
	},
	// Framework Attribute. Answer the maximum number of objects in the returned list
	setParmLimit: function (pVal) {
		this.getProxy().setExtraParam("limit", pVal);
	},
	// Framework Attribute. Returns the offset of the first element in the returned list within the total result list
	setParmStart: function (pVal) {
		this.getProxy().setExtraParam("start", pVal);
	},
	// Framework Attribute. Returns the total number of entries in the list 
	setParmPage: function (pVal) {
		this.getProxy().setExtraParam("page", pVal);
	},
	// When set, this helds a complete gsquery string
	setParmGsquery: function (pVal) {
		this.getProxy().setExtraParam("gsquery", pVal);
	},
	// Sorting description as a json based string - definition follows extjs definition
	setParmSort: function (pVal) {
		this.getProxy().setExtraParam("sort", pVal);
	},
	// Filter description as a json based string - definition follows extjs definition
	setParmFilter: function (pVal) {
		this.getProxy().setExtraParam("filter", pVal);
	}
});
