/**
 * Created by mf on 11.11.20.
 */
Ext.define('smgrui.view.aboutdialog2.Aboutdialog2Model', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.aboutdialog2',

    requires: [
        'smgrui.model.Enums'
    ],

    data: {
        title: smgrui.model.Enums.PUM.MODEL,
        build: null,
        git: null,
        applicationSession: null
    }
});