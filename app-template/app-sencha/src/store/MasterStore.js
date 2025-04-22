/**
 * Created by mf on 19.11.18.
 */
Ext.define('smgrui.store.MasterStore', {
    extend: 'Ext.data.Store',
    alias: 'store.masterstore',

    config:{
      limited: false
    },
    onCreateRecords: function (records, operation, success) {
        if (!success) {
            this.rejectChanges();
        }
    },
    onUpdateRecords: function (records, operation, success) {
        if (!success) {
            this.rejectChanges();
        }
    },
    onDestroyRecords: function (records, operation, success) {
        if (!success) {
            this.rejectChanges();
        }
    },
    listeners: {
        beforeload: function (store) {
            const index = store.getCount()-1;
            if(index >= 0){
                const lastRecord = store.getAt(index);
                const firstRecord = store.getAt(0);
                const proxy = store.getProxy();
                const extraParams = Ext.Object.merge(proxy.getExtraParams(),{
                    lastRecordGop: lastRecord.data.gop || 0,
                    firstRecordGop: firstRecord.data.gop || 0,
                    currentPage: store.lastPage || 1
                });
                proxy.setExtraParams(extraParams);
            }
            if(this.getLimited()){
                const sorters = store.getSorters();
                const filters = store.getFilters();
                if ((sorters && sorters.count() > 0) || (filters && filters.count() > 0)) {
                    store.switchToLimitedLinks();
                }
                else {
                    store.restoreApiLinks();
                }
            }
        }
    }
});