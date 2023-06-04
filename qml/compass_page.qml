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

    Settings {
        id: settings
        property string default_coord_0a
        property string default_coord_1a
        property string default_coord_2a
        property string default_coord_2b
        property string default_coord_2c
        property string default_coord_2d
        property string default_coord_3a
        property string default_coord_3b
        property string default_coord_3c
        property string default_coord_3d
    }

    function updateScreen(lat, lon) {
        compassPage.coord1 = QtPositioning.coordinate(parseFloat(lat), parseFloat(lon))
        var distance = Math.round(positionSource.position.coordinate.distanceTo(compassPage.coord1)) + " m"
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
    
    GridLayout {
        anchors.fill: parent
        columns: 2
        columnSpacing: marginVal * 2.5
        rowSpacing: marginVal
        //spacing: marginVal
        anchors {
            margins: units.gu(2)
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Column {
            Label {
                id: locTextLat
                text: i18n.tr("Not set")
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Destination latitude")
                font.bold: true
            }
        }

        Column {
            Label {
                text: i18n.tr("Not set")
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
                text: "-"
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
                text: "- m"
                font.pointSize: marginVal * 3
            }

            Label {
                text: i18n.tr("Destination distance")
                font.bold: true
            }
        }       

        CompassUi {
            Layout.alignment: Qt.AlignCenter
            Layout.columnSpan: 2
            Layout.rowSpan: 2
            width: units.gu(40)
            height: units.gu(40)
            id: compassui
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
        width: units.gu(38)
        height: units.gu(40)
        modal: true
        focus: true
        title: i18n.tr("Set destination")
        standardButtons: Dialog.Ok
        onAccepted: {
            setPositionDialog.close()
        }
        Component.onCompleted: {
            setPositionDialog.standardButton(Dialog.Ok).text = qsTrId(i18n.tr("Close")); // rename dialog button
        }

        contentItem: Item {
            id: coordPage
            //anchors.top: parent.top
            //anchors.horizontalCenter: parent.horizontalCenter

            Row {
                anchors { bottom: coordinateLoader.top; horizontalCenter: coordinateLoader.horizontalCenter; bottomMargin: units.gu(2) }
                height: abstractButton.height

                AbstractButton {
                    id: abstractButton
                    width: buttonLabel.implicitWidth + units.gu(3)
                    height: buttonLabel.implicitHeight + units.gu(2)
                    Label {
                        id: buttonLabel
                        text: i18n.tr("Decimal")
                        anchors.centerIn: parent
                        color: coordinateLoader.sourceComponent === colCoordDecComponent ? theme.palette.normal.activity : theme.palette.normal.backgroundTertiaryText
                    }
                    onClicked: coordinateLoader.sourceComponent = colCoordDecComponent
                }

                AbstractButton {
                    width: buttonLabel2.implicitWidth + units.gu(3)
                    height: buttonLabel2.implicitHeight + units.gu(2)
                    Label {
                        id: buttonLabel2
                        text: i18n.tr("Sexagesimal")
                        anchors.centerIn: parent
                        color: coordinateLoader.sourceComponent === colCoordPolarComponent ? theme.palette.normal.activity : theme.palette.normal.backgroundTertiaryText
                    }
                    onClicked: coordinateLoader.sourceComponent = colCoordPolarComponent
                }
            }

            Loader {
                id: coordinateLoader
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: abstractButton.height + marginVal
                }
                height: units.gu(10)
                width: coordinateLoader.sourceComponent === colCoordDecComponent ? units.gu(28) : units.gu(35)
                Component.onCompleted: sourceComponent = colCoordDecComponent
            }

            Component {
                id: colCoordDecComponent
                Column {
                    id: colCoordDec
                    spacing: units.gu(2)

                    onVisibleChanged: {
                        if (visible && !lat1.text)
                            lat1.focus = true
                    }

                    Row {
                        spacing: units.gu(1)

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: i18n.tr("Lat:")
                            width: units.gu(5)
                        }

                        TextField {
                            id: lat1
                            maximumLength: 15
                            width: units.gu(22)
                            placeholderText: settings.default_coord_0a
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                    }

                    Row {
                        spacing: units.gu(1)
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: i18n.tr("Long:")
                            width: units.gu(5)
                        }

                        TextField {
                            id: lng1
                            maximumLength: 15
                            width: units.gu(22)
                            placeholderText: settings.default_coord_1a
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                    }

                    Button {
                        id: showCoordDec
                        text: i18n.tr("Set destination")
                        width: units.gu(26)
                        anchors.topMargin: units.gu(5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        // color: theme.palette.normal.positive
                        onClicked: {
                            lat1.text === "" ? lat1.text = lat1.placeholderText : undefined;
                            lng1.text === "" ? lng1.text = lng1.placeholderText : undefined;

                            settings.default_coord_0a = lat1.text;
                            settings.default_coord_1a = lng1.text;

                            try {
                                var aux_lat = lat1.text;
                                var aux_lng = lng1.text;
                                if (!isNaN(aux_lat) && aux_lat.toString().indexOf('.') != -1 && !isNaN(aux_lng) && aux_lng.toString().indexOf('.') != -1 && aux_lat >= -90 && aux_lat <= 90 && aux_lng >= -180 && aux_lng <= 180) { // It's a float
                                    updateScreen(aux_lat, aux_lng);
                                }
                            }
                            catch(e){
                                console.log("Error when entering coordinates: " + e)
                            }
                        }
                    }
                }
            }

            Component {
                id: colCoordPolarComponent

                Column {
                    id: colCoordPolar
                    spacing: units.gu(2)

                    Row {
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: i18n.tr("Lat:")
                            width: units.gu(5)
                        }

                        TextField {
                            id: lat2a
                            width: units.gu(6)
                            placeholderText: settings.default_coord_2a
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                        Label {
                            anchors.top: parent.top
                            text: "º"
                            width: units.gu(1)
                        }

                        TextField {
                            id: lat2b
                            width: units.gu(8)
                            placeholderText: settings.default_coord_2b
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                        Label {
                            anchors.top: parent.top
                            text: "'"
                            width: units.gu(1)
                        }

                        TextField {
                            id: lat2c
                            width: units.gu(8)
                            placeholderText: settings.default_coord_2c
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                        Label {
                            anchors.top: parent.top
                            text: "\""
                            width: units.gu(1)
                        }

                        UbuntuShape {
                            width: units.gu(4)
                            height: lat2c.height
                            backgroundColor: lat2dMouseArea.pressed ? theme.palette.normal.activity : theme.palette.normal.foreground

                            Label {
                                id: lat2d
                                anchors.centerIn: parent
                                text: settings.default_coord_2d
                                color: lat2dMouseArea.pressed ? theme.palette.normal.foreground :  theme.palette.normal.backgroundSecondaryText
                            }

                            MouseArea {
                                id: lat2dMouseArea
                                anchors.fill: parent
                                onClicked: {
                                    if (lat2d.text === "N")
                                        lat2d.text = "S"
                                    else
                                        lat2d.text = "N"
                                }
                            }
                        }
                    }

                    Row {
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: i18n.tr("Long:")
                            width: units.gu(5)
                        }

                        TextField {
                            id: lng2a
                            width: units.gu(6)
                            placeholderText: settings.default_coord_3a
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                        Label {
                            anchors.top: parent.top
                            text: "º"
                            width: units.gu(1)
                        }

                        TextField {
                            id: lng2b
                            width: units.gu(8)
                            placeholderText: settings.default_coord_3b
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                        Label {
                            anchors.top: parent.top
                            text: "'"
                            width: units.gu(1)
                        }

                        TextField {
                            id: lng2c
                            width: units.gu(8)
                            placeholderText: settings.default_coord_3c
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }
                        Label {
                            anchors.top: parent.top
                            text: "\""
                            width: units.gu(1)
                        }

                        UbuntuShape {
                            width: units.gu(4)
                            height: lng2c.height
                            backgroundColor: lng2dMouseArea.pressed ? theme.palette.normal.activity : theme.palette.normal.foreground

                            Label {
                                id: lng2d
                                anchors.centerIn: parent
                                text: settings.default_coord_3d
                                color: lng2dMouseArea.pressed ? theme.palette.normal.foreground :  theme.palette.normal.backgroundSecondaryText
                            }

                            MouseArea {
                                id: lng2dMouseArea
                                anchors.fill: parent
                                onClicked: {
                                    if (lng2d.text === "W")
                                        lng2d.text = "E"
                                    else
                                        lng2d.text = "W"
                                }
                            }
                        }
                    }

                    Button {
                        id: showCoordPolar
                        text: i18n.tr("Set destination")
                        width: units.gu(26)
                        anchors.topMargin: units.gu(5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            lat2a.text === "" ? lat2a.text = lat2a.placeholderText : undefined;
                            lng2a.text === "" ? lng2a.text = lng2a.placeholderText : undefined;
                            lat2b.text === "" ? lat2b.text = lat2b.placeholderText : undefined;
                            lng2b.text === "" ? lng2b.text = lng2b.placeholderText : undefined;
                            lat2c.text === "" ? lat2c.text = lat2c.placeholderText : undefined;
                            lng2c.text === "" ? lng2c.text = lng2c.placeholderText : undefined;

                            settings.default_coord_2a = lat2a.text;
                            settings.default_coord_2b = lat2b.text;
                            settings.default_coord_2c = lat2c.text;
                            settings.default_coord_2d = lat2d.text.toUpperCase();
                            settings.default_coord_3a = lng2a.text;
                            settings.default_coord_3b = lng2b.text;
                            settings.default_coord_3c = lng2c.text;
                            settings.default_coord_3d = lng2d.text.toUpperCase();

                            try {
                                var aux_lat_day = parseInt(lat2a.text);
                                var aux_lat_min = parseFloat(lat2b.text);
                                var aux_lat_sec = lat2c.text === "" ? 0 : parseFloat(lat2c.text);
                                var aux_lat_dir = lat2d.text.toUpperCase();
                                var aux_lng_day = parseInt(lng2a.text);
                                var aux_lng_min = parseFloat(lng2b.text);
                                var aux_lng_sec = lng2c.text === "" ? 0 : parseFloat(lng2c.text);
                                var aux_lng_dir = lng2d.text.toUpperCase();

                                if ((!isNaN(aux_lat_day) && !isNaN(aux_lat_min) && !isNaN(aux_lat_sec) && (aux_lat_dir === 'S' || aux_lat_dir === 'N')) &&
                                        (!isNaN(aux_lng_day) && !isNaN(aux_lng_min) && !isNaN(aux_lng_sec) && (aux_lng_dir === 'W' || aux_lng_dir === 'E'))) {
                                    var aux_lat = aux_lat_day + aux_lat_min/60 + aux_lat_sec/(60*60);
                                    if (aux_lat_dir === "S" || aux_lat_dir === "W")
                                        aux_lat = aux_lat * -1;

                                    var aux_lng = aux_lng_day + aux_lng_min/60 + aux_lng_sec/(60*60);
                                    if (aux_lng_dir === "S" || aux_lng_dir === "W")
                                        aux_lng = aux_lng * -1;

                                    if (aux_lat >= -90 && aux_lat <= 90 && aux_lng >= -180 && aux_lng <= 180) {
                                        updateScreen(aux_lat, aux_lng);
                                    }
                                }
                            }
                            catch(e){
                                console.log("Error when entering coordinates: " + e)
                            }
                        }
                    }
                }
            }
        }
    }
}
