/**
 * Created by mf on 07.07.22.
 */
Ext.define('smgrui.view.login.LoginController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.login',

    requires: [
        'smgrui.api',
        'smgrui.apiLinks',
        'smgrui.model.SMAPIParNewSession',
        'smgrui.model.Enums'
    ],

    /**
     * Called when the view is created
     */
    init: function() {

    },

    onLoginButtonClick: function() {
        const
            timeoutMS = 5000,
            me = this,
            myView = me.getView(),
            msgTitle = 'Anmeldung';

        var
            aSMAPIParNewSession = Ext.create('smgrui.model.SMAPIParNewSession', me.lookup('loginForm').getValues());
        aSMAPIParNewSession.setLoginField( aSMAPIParNewSession.getLoginField().trim());
        aSMAPIParNewSession.setPasswordField(aSMAPIParNewSession.getPasswordField().trim());

        smgrui.api.NewSession(aSMAPIParNewSession)
            .then(aCTMAPIResSingleSession => {
                    if (aCTMAPIResSingleSession.getSuccessField()) {
                        const
                            aCTMAPIAppSession = aCTMAPIResSingleSession.getSessionField(),
                            aCTMAppUser = aCTMAPIResSingleSession.getUserField(),
                            aCISAppCustomer = aCTMAPIResSingleSession.getCustomerField();

                        /* Dieses ist wichtig, damit die Session ID auch bei den weiteren Calls genutzt werden kann */
                        smgrui.apiLinks.RequestSessionID = aCTMAPIAppSession.getGopField();
                        Ext.Ajax.setTimeout(30 * 60 * 1000); // 30 Minute Timeout
                        myView.fireEvent("onLoginSuccess", aCTMAPIAppSession, aCTMAppUser, aCISAppCustomer, myView);
                    } else {
                        smgrui.api.HandlePUMAjaxErrorResult( msgTitle, nulll, null, aCTMAPIResSingleSession);
                    }
                },
                resp => {
                    smgrui.api.HandlePUMAjaxErrorResult( msgTitle, resp.response, resp.options, resp.result);
                })
            .done();

    }
});