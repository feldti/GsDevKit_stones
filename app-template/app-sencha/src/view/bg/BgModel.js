/**
 * Created by mf on 05.04.25.
 */
Ext.define('smgrui.view.bg.BgModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.bg',

    stores: {
        /*
        A declaration of Ext.data.Store configurations that are first processed as binds to produce an effective
        store configuration. For example:

        users: {
            model: 'Bg',
            autoLoad: true
        }
        */
    },

    data: {
        build: "Fr 28. Feb 18:44:55 CET 2025",
        git: "65ee53bThu, 30 Jan 2025 19:01:13 +0100",
        buildtype: "production",
        currentSurveyCase: null,
        currentSurveyStructure: null
    }
});