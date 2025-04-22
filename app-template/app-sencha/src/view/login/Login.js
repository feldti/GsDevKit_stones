/**
 * Created by mf on 07.07.22.
 */
Ext.define('smgrui.view.login.Login', {
    extend: 'Ext.window.Window',

    requires: [
        'Ext.button.Button',
        'Ext.form.Panel',
        'Ext.form.field.Number',
        'Ext.form.field.Text',
        'Ext.layout.container.Card',
        'Ext.layout.container.VBox',
        'smgrui.view.login.LoginController',
        'smgrui.view.login.LoginModel'
    ],

    xtype: 'login',


    viewModel: {
        type: 'login'
    },

    controller: 'login',

    width: 350,
    modal: false,
    layout: 'card',
    closable: false,

    items: [
        {
            xtype: 'form',
            bodyPadding: 20,
            reference: 'loginForm',
            layout: {
                type: 'vbox',
                align: 'center'
            },
            defaults: {
                allowBlank: false,
                xtype: 'textfield',
                width: '100%'
            },
            defaultButton: 'loginButton',
            items: [
                {
                    name: 'login',
                    reference: 'loginField',
                    selectOnFocus: true,
                    fieldLabel: 'Benutzernae'
                },
                {
                    name: 'password',
                    fieldLabel: 'Kennwort',
                    inputType: 'password',
                    triggers: {
                        showPw: {
                            cls: 'fa-eye',
                            handler: function (field) {
                                const {showPw, hidePw} = field.getTriggers();
                                showPw.setHidden(true);
                                hidePw.setHidden(false);
                                field.inputEl.dom.type = "text";
                            }
                        },
                        hidePw: {
                            hidden: true,
                            cls: 'fa-eye-slash',
                            handler: function (field) {
                                const {showPw, hidePw} = field.getTriggers();
                                showPw.setHidden(false);
                                hidePw.setHidden(true);
                                field.inputEl.dom.type = "password";
                            }
                        }
                    }
                },
                {
                    xtype: 'button',
                    text: 'Anmelden',
                    height: 30,
                    autoSize: true,
                    style: {
                        'text-align': 'center',
                        'letter-spacing': '1.25px',
                        'font-size': '14px',
                        'font-weight': '500',
                        'color': '#3e3e3e'
                    },
                    handler: 'onLoginButtonClick'
                }
            ]
        }
    ]
});