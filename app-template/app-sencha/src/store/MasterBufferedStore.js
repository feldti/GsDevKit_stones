/**
 * Created by Sebastian on 19.11.2018.
 */
Ext.define('smgrui.store.MasterBufferedStore', {
    extend: 'Ext.data.BufferedStore',
    alias: 'store.masterbufferedstore',
    onCreateRecords: function (records, operation, success) {
        if (!success) {
            this.rejectChanges();
        }
    },
    onDestroyRecords: function (records, operation, success) {
        if (!success) {
            this.cleanRemoved();
        }
        else {
            this.rejectChanges();
        }
    },
   /* listeners: {
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
            const sorters = store.getSorters();
            const filters = store.getFilters();
            if ((sorters && sorters.count() > 0) || (filters && filters.count() > 0)) {
                store.switchToLimitedLinks();
            }
            else {
                store.restoreApiLinks();
            }
        }
    }*/
});