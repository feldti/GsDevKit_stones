/**
 * Created by mf on 15.12.2015.
 */
Ext.define('smgrui.guihelpers.GUIHelpers', {
    requires: [
        'Ext.window.MessageBox',
        'smgrui.model.Enums'
    ],
    statics: {
        CUSTOMERNAME: 'Marten Feldtmann',
        PGMNAME: 'SurveyJS Spielwiese',
        LOGLVL: {
            LOG: 0,
            WARN: 1,
            ERROR: 2
        },
        EVENTS: {
            EvRoombeforeChanged: "evroombeforechanged",
            EvRoomHasChanged: "evroomhaschanged",
            EvCurrentGalleryHasChanged: "evcurrentgalleryhaschanged"
        },
        CurrentPictureGallery: "currentSelectedPageGallery",
        ApplicationSession: "applicationSession",
        SelectedPictureFormat: "selectedPictureFormat",
        SeletedPageLayout: "selectedPageLayout",
        CurrentDDXMLSetting: "currentDDXMLSetting",
        CurrentRoom: "currentRoom",
        CurrentRoomName: "currentRoomName",
        UserPermission: "userPermission",
        CurrentRoomGop: "currentRoomGop",
        CurrentCustomer: "currentCustomer",
        CurrentUser: "currentUser",
        CurrentPictureSetting: "currentPictureSetting",
        CurrentVideoSetting: "currentVideoSetting",
        CurrentLayoutHandler: "currentLayoutHandler",
        CloseWindow: 'closeAfterProduction',
        ImgWidth: 'imgWidth',
        ImgHeight: 'imgHeight',
        ShowMessage: function (title, msg, pLevel = smgrui.guihelpers.GUIHelpers.LOGLVL.LOG) {
            let icon = Ext.MessageBox.INFO;
            switch (pLevel) {
                case    1:
                    icon = Ext.MessageBox.WARNING;
                    break;
                case    2:
                    icon = Ext.MessageBox.ERROR;
                    break;
            }
            Ext.MessageBox.show({
                title,
                msg,
                buttons: Ext.MessageBox.OK,
                icon: smgrui.guihelpers.GUIHelpers.LOGLVL[pLevel]
            });
        },
        GetBackgroundView: function () {
            let
                bgAppViewQueryResult = Ext.ComponentQuery.query('#app_background');

            return (bgAppViewQueryResult.length > 0) ?  bgAppViewQueryResult[0] : null;
        },

        GetEditorBackgroundView: function () {
            let
                bgAppViewQueryResult = Ext.ComponentQuery.query('#editor_background');

            return (bgAppViewQueryResult.length > 0) ?  bgAppViewQueryResult[0] : null;
        },





    }
});
