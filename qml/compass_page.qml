import QtLocation 5.9
import QtPositioning 5.9
import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtSensors 5.9
import QtSensors 5.9 as Sensors
import Ubuntu.Components 1.3

Page {
    id: compassPage

    header: ToolBar {
        id: compassHeader
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: i18n.tr("Compass")
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr("⋮")
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    transformOrigin: Menu.TopRight
                    x: parent.width - width
                    y: parent.height

                    MenuItem {
                        text: i18n.tr("Set position")
                        onTriggered: contentTrainList.model.clear()
                    }
                    MenuItem{
                        text: i18n.tr('Settings')
                        onTriggered: settingsDialog.open()
                    }
                }
            }
        }
    }

    property var coord1

    Text {
        width: parent.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        id: locText
        text: "Loc Test"
        font.pixelSize: units.gu(3)
    }

    Text {
        width: parent.width
        anchors.top: locText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        id: dtsText
        text: "DTS Test"
        font.pixelSize: units.gu(3)
    }

    Text {
        horizontalAlignment: Text.AlignLeft
        anchors.top: sepRect.bottom
        anchors.left: parent.left
        id: degreeText
        text: "degree Test"
        font.pixelSize: units.gu(5)
    }

    Text {
        horizontalAlignment: Text.AlignRight
        anchors.top: sepRect.bottom
        anchors.right: parent.right
        id: distanceText
        text: "dist Test"
        font.pixelSize: units.gu(5)
    }

    CompassUi {
        id: compassui
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(40)
        height: units.gu(40)
    }

    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        id: curlocText
        text: "curloc Test"
        font.pixelSize: units.gu(3)
    }

    Timer {
        id: compassTimer
        running: true
        repeat: true
        interval: 1000

        onTriggered: {
            if(isNaN(positionSource.position.coordinate.longitude) || isNaN(positionSource.position.coordinate.latitude))
                return

            if(positionSource.position.coordinate.latitude == 0 && positionSource.position.coordinate.longitude == 0)
                return

            var distance = Math.round(positionSource.position.coordinate.distanceTo(compassPage.coord1)) + "m"
            var azimuth = Math.round(positionSource.position.coordinate.azimuthTo(compassPage.coord1))

            compassui.setBearing(azimuth)
            distanceText.text = distance
            degreeText.text = Math.round(azimuth) + "°"

            compassui.setDirection(Math.floor(direction))
            curlocText.text = from_decimal(positionSource.position.coordinate.latitude, "lat") + " - " +
                    from_decimal(positionSource.position.coordinate.longitude, "lon")
        }
    }

    Compass {
        id:compass
        active: true
        alwaysOn: true

        onReadingChanged: {
            console.log("Compass.azimuth: " + reading.azimuth)
        }
    }

    Component.onCompleted: {
        var types = Sensors.QmlSensors.sensorTypes()
        console.log(types.join(", "))
    }

    PositionSource {
        id: positionSource
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
    }
}
