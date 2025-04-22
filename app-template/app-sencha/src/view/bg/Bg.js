/**
 * Created by mf on 05.04.25.
 */
Ext.define('smgrui.view.bg.Bg', {
    extend: 'Ext.Container',

    requires: [
        'Ext.layout.container.Fit',
        // Nicht den Viewport rausnehmen - ansonsten geht der Production Build nicht mehr
        'Ext.plugin.Viewport',
        'smgrui.view.bg.BgController',
        'smgrui.view.bg.BgModel'
    ],

    xtype: 'bg',

    viewModel: {
        type: 'bg'
    },

    controller: 'bg',
    itemId: 'app_background',
    layout: {
        type: 'fit'
    },

    items: [
        {
            xtype: 'image',
            displayed : true,
            style: 'max-width: 100%;object-position: top;',
            centered : true,
            cls: 'x-unselectable',
            bind: {
                src: 'resources/images/background.jpg'
            }
        }
    ]
});