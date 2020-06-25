import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls 1.4 as QQ14
import QtQuick.Layouts 1.3
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
                msgPopup.msgText = "Whoooooooooo!"
                msgPopup.open()
            }
        }
        ToolButton {
            id: cancelButton
            visible: editOverlay.visible
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Set"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                var i = usersListView.currentIndex
                editGroupsListView.setGroups()
                usersListView.model = UGMan.getUsers()
                usersListView.currentIndex = i
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
                    editGroupsListView.model = UGMan.getAllGroups(usersListView.model[usersListView.currentIndex].username)
                    editOverlay.visible = true
                }
            }
        }
    }
    QQ14.SplitView{
        anchors.fill: parent
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
                height: toolBar.height
                anchors{
                    left: parent.left
                    right: parent.right
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
                boundsBehavior: Flickable.StopAtBounds
                delegate: Item {
                    id: gDelegate
                    width: parent.width
                    height: checkBox.height
                    anchors.margins: height/5
                    CheckBox{
                        id: checkBox
                        enabled: false
                        checked: modelData.checked
                    }
                    Label{
                        id: lbl
                        width: parent.width
                        height: parent.height
                        text: modelData.name
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
                    checked: modelData.checked
                    onClicked: editGroupsListView.sync(index, checked)
                }
                Label{
                    id: geLbl
                    width: parent.width
                    height: parent.height
                    text: modelData.name
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
            }

            function sync(index, check){
                var newM = editGroupsListView.model
                newM[index].checked = check
                editGroupsListView.model = newM
                editGroupsListView.positionViewAtIndex(index, ListView.Center)
            }

            function setGroups(){
                console.log(editGroupsListView.model)
                var res = UGMan.updateUserGroups(usersListView.model[usersListView.currentIndex].username, editGroupsListView.model)
                if(res != ""){
                    msgPopup.msgText = res
                    msgPopup.open()
                }
            }
        }
    }

    Component.onCompleted: {
        usersListView.model = UGMan.getUsers()
    }

    Popup{
        id: msgPopup
        property alias msgText: msgLbl.text
        width: parent.width * 0.95
        height: contentsCol.height + padding * 2 + closBtn.height
        x: (parent.width - width)/2
        y: (parent.height - height)/2
        background: Rectangle{
            radius: 5
            border.color: "lightsteelblue"
        }
        ColumnLayout{
            id: contentsCol
            width: parent.width * 0.8
            anchors{
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: closBtn.height
            }
            spacing: 10
            Label{
                id: emptyLbl
                text: " "
                visible: false
            }
            Label{
                id: msgLbl
                width: parent.width
                wrapMode: Text.Wrap
            }

            Button{
                id: closBtn
                text: qsTr("Close")
                font.pointSize: msgPopup.gfps
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: implicitWidth * 2
                onClicked: msgPopup.close()
            }
        }
        onClosed: msgLbl.text = ""
    }


}
