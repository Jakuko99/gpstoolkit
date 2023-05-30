import QtLocation 5.9
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.2
import QtQuick.Layouts 1.3
import QtSensors 5.9
import Ubuntu.Components 1.3

Page {
    id: compassPage
    property real marginVal: units.gu(1)
    property var coord1

    function updateScreen(lat, lon) {
        compassPage.coord1 = QtPositioning.coordinate(parseFloat(lat), parseFloat(lon))
        var distance = Math.round(positionSource.position.coordinate.distanceTo(compassPage.coord1)) + "m"
        var azimuth = positionSource.position.coordinate.azimuthTo(compassPage.coord1)

        locText.text = lat + " - " + lon
        distanceText.text = distance
        degreeText.text = Math.round(azimuth) + "°"
        compassui.setBearing(Math.round(azimuth))
        compassui.setDirection(Math.round(azimuth))
        curlocText.text = positionSource.position.coordinate.latitude + " - " + positionSource.position.coordinate.longitude
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
                text: i18n.tr("Compass navigation")
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
                        onTriggered: setPositionDialog.open()
                    }
                }
            }
        }
    }

    Column {
        anchors.fill: parent

        Label{
            horizontalAlignment: Qt.AlignHCenter
            id: locText
            text: "Loc Test"
            font.pixelSize: units.gu(3)
        }

        Label {
            horizontalAlignment: Qt.AlignHCenter
            id: dtsText
            text: "DTS Test"
            font.pixelSize: units.gu(3)
        }

        Row {
            Label {
                horizontalAlignment: Qt.AlignLeft
                id: degreeText
                text: "degree Test"
                font.pixelSize: units.gu(5)
            }

            Label {
                horizontalAlignment: Qt.AlignRight
                id: distanceText
                text: "dist Test"
                font.pixelSize: units.gu(5)
            }
        }
    }

    CompassUi {
        id: compassui
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(40)
        height: units.gu(40)
    }

    Label {
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
        id: compass
        active: true
        alwaysOn: true

        onReadingChanged: {
            console.log("Compass.azimuth: " + reading.azimuth)
        }
    }

    Component.onCompleted: {
        var types = QmlSensors.sensorTypes()
        console.log(types.join(", "))
    }

    PositionSource {
        id: positionSource
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
    }

    Dialog {
        id: setPositionDialog
        x: Math.round((root.width - width) / 2)
        y: (root.height - height) / 2 - header.height
        width: units.gu(32)  //250
        height: units.gu(30) //500
        modal: true
        focus: true
        title: i18n.tr("Set destination")
        standardButtons: Dialog.Ok
        onAccepted: {
            updateScreen(latEntry.text, lonEntry.text);
            setPositionDialog.close()
        }
        Component.onCompleted: {
            setPositionDialog.standardButton(Dialog.Ok).text = qsTrId(i18n.tr("Set")); // rename dialog button
        }

        contentItem: ColumnLayout {
            spacing: 0
            Row {
                Layout.fillWidth: true

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("Lat: ")
                }

                TextField {
                    id: latEntry
                    placeholderText: i18n.tr("Latitude")
                    text: ""
                }
            }

            Row {
                Layout.fillWidth: true

                Label {
                    text: i18n.tr("Lng:")
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: lonEntry
                    placeholderText: i18n.tr("Longitude")
                    text: ""
                }
            }
        }
    }
}
