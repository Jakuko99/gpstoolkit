import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Page {
    id: aboutPage
    property real marginVal: units.gu(1)

    header: ToolBar {
        id: toolbar
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: "About"
                elide: Label.ElideRight                
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                //text: qsTr("⋮")
                text: qsTr(" ")
                //onClicked: optionsMenu.open()
            }
        }
    }

    Column {
        id: aboutCloumn
        anchors.top: parent.top
        anchors.topMargin: marginVal
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: marginVal
        width: parent.width

        Image {
            id: appLogo
            property bool rounded: true
            property bool adapt: true
            source: Qt.resolvedUrl("../assets/icon.png")
            width: Suru.units.gu(15)
            height: Suru.units.gu(15)
            anchors.horizontalCenter: parent.horizontalCenter

            layer.enabled: rounded
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: appLogo.width
                    height: appLogo.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: appLogo.adapt ? appLogo.width : Math.min(appLogo.width, appLogo.height)
                        height: appLogo.adapt ? appLogo.height : width
                        //radius: Math.min(width, height)
                        radius: units.gu(2.5) // adaptive radius
                    }
                }
            }
        }

        Label {
            text: i18n.tr("GPS Toolkit")
            font.pixelSize: units.gu(3)
            horizontalAlignment: Text.AlignHCenter
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Label {
            id: versionLabel
            text: "version placeholder"
            Component.onCompleted: function(){
                var versionString = i18n.tr("Version %1").arg(Qt.application.version);
                versionLabel.text = versionString;
            }
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: units.gu(1.75)
        }     

        Button {
            anchors.left: parent.left
            anchors.rightMargin: marginVal
            anchors.leftMargin: marginVal
            anchors.right: parent.right
            text: "Get the source"
            onClicked: Qt.openUrlExternally("https://github.com/Jakuko99/gpstoolkit")
        }

        Button {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: marginVal
            anchors.leftMargin: marginVal
            text: " Report issues  "
            onClicked: Qt.openUrlExternally("https://github.com/Jakuko99/gpstoolkit/issues")
        }
    }
}
