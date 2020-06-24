import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls 1.4 as QQ14
import QtQuick.Window 2.12

ApplicationWindow {
    visible: true
    width: 480
    height: 640
    title: qsTr("KGroups")
    header: ToolBar {
        id: toolBar
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: "::"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
            }
        }
        ToolButton {
            id: cancelButton
            visible: editOverlay.visible
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Set"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                editGroupsListView.setGroups()
                editGroupsListView.model = UGMan.getAllGroups()
                editGroupsListView.newGroups = groupsListView.model
                usersListView.model = UGMan.getUsers()
                groupsListView.model = UGMan.getGroups(usersListView.model[usersListView.currentIndex].username)
                editOverlay.visible = false
            }
        }
        ToolButton {
            id: editButton
            text: editOverlay.visible?"Cancel":"Edit"
            anchors.right: parent.right
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if(editOverlay.visible){
                    editOverlay.visible = false
                }else{
                    editGroupsListView.model = UGMan.getAllGroups()
                    editGroupsListView.newGroups = groupsListView.model
                    editOverlay.visible = true
                }
            }
        }
    }
    QQ14.SplitView{
        anchors.fill: parent
        orientation: Qt.Horizontal
        ListView{
            id: usersListView
            width: parent.width * 0.5
            height: parent.height
            spacing: 5
            highlight: highlight
            highlightFollowsCurrentItem: true
            focus: true
            delegate: Label{
                width: parent.width
                height: 50
                text: modelData.username
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        usersListView.currentIndex = index
                        groupsListView.model = UGMan.getGroups(modelData.username)
                    }
                }
            }
        }
        Component {
            id: highlight
            Rectangle {
                width: parent.width; height: usersListView.currentItem.height
                color: "lightsteelblue"; radius: 5
                y: usersListView.currentItem.y
                Behavior on y {
                    SpringAnimation {
                        spring: 3
                        damping: 0.2
                    }
                }
            }
        }

        ListView{
            id: groupsListView
            width: parent.width * 0.5
            height: parent.height
            spacing: 5
            delegate: Item {
                id: gDelegate
                width: parent.width
                height: checkBox.height
                CheckBox{
                    id: checkBox
                    enabled: false
                    checked: true
                }
                Label{
                    id: lbl
                    width: parent.width
                    height: parent.height
                    text: modelData
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
            }

        }
    }

    Rectangle{
        id: editOverlay
        anchors.fill: parent
        visible: false
        ListView{
            id: editGroupsListView
            property var newGroups: []
            anchors.fill: parent
            spacing: 5
            delegate: Item {
                id: geDelegate
                width: parent.width
                height: geCheckBox.height
                CheckBox{
                    id: geCheckBox
                    enabled: modelData !== usersListView.model[usersListView.currentIndex].username
                    checked: editGroupsListView.isInUserG(modelData)
                    onClicked: {
                        editGroupsListView.sync(modelData, !checked)
                    }
                }
                Label{
                    id: geLbl
                    width: parent.width
                    height: parent.height
                    text: modelData
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
            }
            function sync(gName, remove){
                var found = false
                for(var k in newGroups){
                    if(newGroups[k] == gName){
                        found = true
                        if(remove){
                            newGroups.splice(k,1)
                        }
                    }
                }
                if(!found && !remove){
                    newGroups.push(gName)
                }
            }

            function isInUserG(gName){
                var modl = groupsListView.model
                for(var ug in modl){
                    if (modl[ug] == gName){
                        return true
                    }
                }
                return false
            }

            function setGroups(){
                console.log(editGroupsListView.newGroups)
                UGMan.updateUserGroups(usersListView.model[usersListView.currentIndex].username, newGroups)
            }
        }
    }

    Component.onCompleted: {
        usersListView.model = UGMan.getUsers()
    }




}
