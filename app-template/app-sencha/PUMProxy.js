Ext.define('smgrui.PUMProxy' , {
	extend: 'Ext.data.proxy.Ajax',
	alias: 'proxy.pumproxy',
	requires: [
		'Ext.data.reader.Json',
		'Ext.data.writer.Json'
	 ],
	actionMethods: { create: 'POST', read: 'POST', update: 'POST', destroy: 'POST'  },
	paramsAsJson: true,
	applyEncoding: function(value) { return Ext.encode(value); } ,
	reader: { type: 'json', rootProperty: 'data', responseType: null },
	writer: { type: 'json',clientIdProperty: 'syscid', writeAllFields: true, allowSingle: false, rootProperty: 'data' },
	timeout: 30 * 60 * 1000,
	onCreateRecords(records, operation, success) { if (!success) { this.rejectChanges() } },
	listeners: {
		exception: function (proxy, request) {
			var
				pData = Ext.decode(request.responseText),
				title = "SurveyManager",
				msg =  "(" + request.status +  "): " +  request.responseText;
			if ((pData.success !== undefined ) && (! pData.success)) {
				msg = pData.error.text;
			}
			Ext.Msg.show({
				title: title,
				message: msg,
				buttons: Ext.MessageBox.OK,
				icon: Ext.MessageBox.ERROR
			});
		}
	}
	});

