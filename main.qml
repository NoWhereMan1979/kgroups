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
                    editGroupsListView.model = []
                    editGroupsListView.newGroups = []
                }else{
                    editGroupsListView.model = UGMan.getAllGroups()
                    editGroupsListView.newGroups = groupsListView.model
                    editOverlay.visible = true
                }
            }
        }
    }
    QQ14.SplitView{
        anchors{
            fill: parent
        }
        orientation: Qt.Horizontal
        Item {
            width: parent.width * 0.5
            height: parent.height
            ListView{
                id: usersListView
                enabled: !editOverlay.visible
                width: parent.width * 0.5
                boundsBehavior: Flickable.StopAtBounds
                anchors{
                    fill: parent
                    topMargin: usersListView.currentItem.height * 0.3
                    bottomMargin: usersListView.currentItem.height * 0.3
                    leftMargin: usersListView.currentItem.height * 0.2
                    rightMargin: usersListView.currentItem.height * 0.2
                }
                spacing: 5
                highlight: highlight
                highlightFollowsCurrentItem: true

                focus: true
                delegate: Label{
                    height: toolBar.height
                    text: modelData.username
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    anchors{
                        left: parent.left
                        right: parent.right
                        margins: height/5
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            usersListView.currentIndex = index
                        }
                    }
                }
                onCurrentIndexChanged: {
                    groupsListView.model = UGMan.getGroups(usersListView.model[usersListView.currentIndex].username)
                }
            }
        }
        Component {
            id: highlight
            Rectangle {
//                anchors.margins: height/5
//                width: parent.width;
                height: toolBar.height
                anchors{
                    left: parent.left
                    right: parent.right
//                    horizontalCenter: parent.horizontalCenter
                    margins: height/5
                }
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

        Item {
            width: parent.width * 0.5
            height: parent.height
            ListView{
                id: groupsListView
                anchors{
                    fill: parent
                    topMargin: usersListView.currentItem.height * 0.3
                    bottomMargin: usersListView.currentItem.height * 0.3
                    leftMargin: usersListView.currentItem.height * 0.2
                    rightMargin: usersListView.currentItem.height * 0.2
                }
//                width: parent.width * 0.5
//                height: parent.height
//                spacing: 5
                boundsBehavior: Flickable.StopAtBounds
                delegate: Item {
                    id: gDelegate
                    width: parent.width
                    height: checkBox.height
                    anchors.margins: height/5
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
    }

    Rectangle{
        id: editOverlay
        width: parent.width * 0.5
        height: parent.height
        anchors.right: parent.right
        visible: false
        ListView{
            id: editGroupsListView
            property var newGroups: []
            spacing: 5
            boundsBehavior: Flickable.StopAtBounds
            anchors{
                fill: parent
                topMargin: usersListView.currentItem.height * 0.3
                bottomMargin: usersListView.currentItem.height * 0.3
                leftMargin: usersListView.currentItem.height * 0.2
                rightMargin: usersListView.currentItem.height * 0.2
            }
            delegate: Item {
                id: geDelegate
                width: parent.width
                height: toolBar.height
                CheckBox{
                    id: geCheckBox
                    height: parent.height
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
