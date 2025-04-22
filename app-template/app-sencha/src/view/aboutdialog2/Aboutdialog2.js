/**
 * Created by mf on 11.11.20.
 */
Ext.define('smgrui.view.aboutdialog2.Aboutdialog2', {
    extend: 'Ext.window.Window',
    requires: [
        'Ext.container.Container',
        'Ext.form.Label',
        'Ext.layout.container.Absolute',
        'Ext.layout.container.HBox',
        'smgrui.view.aboutdialog2.Aboutdialog2Model',
        'smgrui.guihelpers.GUIHelpers',
        'smgrui.model.Enums',
        'smgrui.view.aboutdialog2.Aboutdialog2Model'
    ],

    viewModel: {
        type: 'aboutdialog2'
    },

    xtype: 'Aboutdialog2',

    width: 530,
    title: "Media Dashboard : Über dieses Programm",
    resizable: false,
    dockedItems: [
        {
            xtype: 'container',
            layout: {
                type: 'hbox',
                align: 'fit'
            },
            items: [
                {
                    xtype: 'label',
                    style: {
                        'font-weight': 'bold',
                        'font-size': '24px',
                        'font-style': 'italic',
                        'line-height': '120px',
                        'text-align': 'center'
                    },
                    width: 250,
                    height: 140,
                    text: 'Entwickelt von'
                },
                {
                    xtype: 'image',
                    displayed : true,
                    centered : true,
                    src: 'resources/bild.png',
                    width: 240,
                }
            ]
        }],
    items:  [
        {
        xtype: 'component',
        padding: '10px',
        bind:{
            data: {
                git:'{git}',
                build: '{build}',
                applicationSession: {
                    userLogin: '{applicationSession.userLogin}',
                    location: ' {applicationSession.location}'
                }
            }
        },
        tpl: `<ul style="list-style: none;padding: 0px;">
<li>Modelname: ${smgrui.model.Enums.PUM.MODEL}</li>
<li>Modelversion: ${smgrui.model.Enums.PUM.MODELVERS}</li>
<li>Codegenerator: ${smgrui.model.Enums.PUM.CODEGENNAME} (PUM-Modelling Tool)</li>
<li>Codegenerator Version: ${smgrui.model.Enums.PUM.CODEGENVERS}-${smgrui.model.Enums.PUM.CODEGENDATE}</li>
<li>ExtJS Version: ${Ext.getVersion("ext")}, Sencha ExtJS Bibliothek</li>
<li>System: OODBMS-Gemstone/S 3.7.2 + RabbitMQ</li>
<li>GIT: {git}</li>
<li>Build: {build}</li>
<li>Login: {applicationSession.userLogin}</li>
<li>Ort: {applicationSession.location}</li>
</ul>`
    }
    ]
});