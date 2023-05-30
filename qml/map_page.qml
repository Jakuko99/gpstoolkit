import QtQuick 2.6
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

Page {
    id: locatorPage
    property real marginVal: units.gu(1)

    function roundNumber(num, dec) {
        return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
    }

    header: ToolBar {
        id: toolbar
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: i18n.tr("Map")
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr(" ")
                //                onClicked: optionsMenu.open()

                //                Menu {
                //                    id: optionsMenu
                //                    transformOrigin: Menu.TopRight
                //                    x: parent.width - width
                //                    y: parent.height

                //                    MenuItem {
                //                        text: "Clear list"
                //                        onTriggered: contentTrainList.model.clear()
                //                    }
                //                    MenuItem{
                //                        text: 'Settings'
                //                        onTriggered: settingsDialog.open()
                //                    }
                //                }
            }
        }
    }
    Column {
        anchors.fill: parent

        Label {
            text: "Coming soon"
        }
    }
}

