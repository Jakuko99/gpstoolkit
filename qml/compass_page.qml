import QtQuick 2.6
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtPositioning 5.2
import QtSensors 5.9
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

Page {
    id: compassPage
    property var coord1
    property real marginVal: units.gu(1)

    function roundNumber(num, dec) {
        return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
    }

    function updateScreen(lat, lon) {
        compassPage.coord1 = QtPositioning.coordinate(parseFloat(lat), parseFloat(lon))
        var distance = Math.round(positionSource.position.coordinate.distanceTo(compassPage.coord1)) + "m"
        var azimuth = positionSource.position.coordinate.azimuthTo(compassPage.coord1)

        locTextLat.text = lat + "º"
        locTextLon.text = lon + "º"
        distanceText.text = distance
        degreeText.text = Math.round(azimuth) + "°"
        compassui.setBearing(Math.round(azimuth))
        compassui.setDirection(Math.round(azimuth))
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
    
    Grid {
        anchors.fill: parent
        columns: 2
        columnSpacing: marginVal * 2.5
        spacing: marginVal
        anchors {
            margins: units.gu(2)
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Column {
            Label {
                id: locTextLat
                text: "Loc Test"
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Destination latitude")
                font.bold: true
            }
        }

        Column {
            Label {
                text: "Loc Test"
                id: locTextLon
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Destination longitude")
                font.bold: true
            }
        }

        Column {
            Label {
                id: degreeText
                text: "degree Test"
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Destination azimuth")
                font.bold: true
            }
        }

        Column {
            Label {
                id: distanceText
                text: "dist Test"
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Destination distance")
                font.bold: true
            }
        }

        Column {
            Label {
                id: curlocTextLat
                text: roundNumber(positionSource.position.coordinate.latitude, 5) + "º"
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Current latitude")
                font.bold: true
            }
        }


        Column {
            Label {
                id: curlocTextLon
                text: roundNumber(positionSource.position.coordinate.longitude, 5) + "º"
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Current longitude")
                font.bold: true
            }
        }

        CompassUi {
            Layout.columnSpan: 2
            Layout.rowSpan: 2
            id: compassui
        }
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

            var distance = Math.round(positionSource.position.coordinate.distanceTo(compassPage.coord1)) + " m"
            var azimuth = Math.round(positionSource.position.coordinate.azimuthTo(compassPage.coord1))

            compassui.setBearing(azimuth)
            distanceText.text = distance
            degreeText.text = Math.round(azimuth) + "°"

            compassui.setDirection(Math.floor(azimuth))
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
