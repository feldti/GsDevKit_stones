/**
 * Created by mf on 05.04.25.
 */
Ext.define('smgrui.view.bg.BgController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.bg',

    requires: [
        'smgrui.view.login.Login',
        'smgrui.view.main.Main'
    ],

    component: {
        'login': {
            onLoginSuccess: "onLoginSuccess"
        },
        '*': {
            evLogout: "onEvLogout"
        }
    },

    /**
     * Called when the view is created
     */
    init: function() {
        const
            me = this,
            loginWindow = Ext.create('smgrui.view.login.Login',{
                title: 'Anmeldung'
            });
           // newCurrentApplication = Ext.create('smgrui.view.main.Main');
        loginWindow.show();

        // me.switchApplication(newCurrentApplication);
    },

    onLoginSuccess(aCTMAPIAppSession, aCTMAPIAppUser, aCISAPIAppCustomer, loginWindow) {

    }
    ,switchApplication( newCurrentApplcation) {
        var
            me = this,
            vm = me.getViewModel(),
            bgPanel =  me.getView();

        if (bgPanel)
        {
            bgPanel.removeAll();
            bgPanel.add(newCurrentApplcation);
        }
        else {
            console.log("Kein Background Panel gefunden");
        }
    }

    ,startIntervalFunction: function() {
        var
            me = this,
            vm = me.getViewModel();

        vm.set("intervalID",
            setInterval(() => {
                cis.api.Noop()
                    .then(aCISAPIGeneralResult => {

                    })
                    .done();
            }, 60000));
    },
});