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
        property string default_qth
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
                text: i18n.tr("Maidenhead (QTH) Locator")
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


    Item {
        id: coordPage
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

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

            AbstractButton {
                width: buttonLabel.implicitWidth + units.gu(3)
                height: buttonLabel.implicitHeight + units.gu(2)
                Label {
                    id: buttonLabel3
                    text: i18n.tr("QTH Locator")
                    anchors.centerIn: parent
                    color: coordinateLoader.sourceComponent === colLocatorComponent ? theme.palette.normal.activity : theme.palette.normal.backgroundTertiaryText
                }
                onClicked: coordinateLoader.sourceComponent = colLocatorComponent
            }
        }

        Loader {
            id: coordinateLoader
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: abstractButton.height + units.gu(4)
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
                    text: i18n.tr("Convert to QTH Locator")
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
                                python.call("maiden.to_maiden", [parseFloat(aux_lat), parseFloat(aux_lng)], function(returnVal){
                                    resultLabel1.text = returnVal;
                                });
                            }
                        }
                        catch(e){
                            console.log("Error when entering coordinates: " + e)
                        }
                    }
                }
                Label {
                    text: i18n.tr("QTH Locator:")
                    font.bold: true
                }

                Label {
                    id: resultLabel1
                    font.pointSize: marginVal * 2.5
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
                    text: i18n.tr("Convert to QTH Locator")
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
                                    python.call("maiden.to_maiden", [aux_lat, aux_lng], function(returnVal){
                                        resultLabel2.text = returnVal;
                                    });
                                }
                            }
                        }
                        catch(e){
                            console.log("Error when entering coordinates: " + e)
                        }
                    }
                }
                Label {
                    text: i18n.tr("QTH Locator:")
                    font.bold: true
                }

                Label {
                    id: resultLabel2
                    font.pointSize: marginVal * 2.5
                }
            }
        }
        Component {
            id: colLocatorComponent
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
                        text: i18n.tr("QTH:")
                        width: units.gu(5)
                    }

                    TextField {
                        id: qthLoc
                        maximumLength: 15
                        width: units.gu(22)
                        placeholderText: settings.default_qth
                    }
                }

                Button {
                    id: showCoordDec
                    text: i18n.tr("Convert to coordinates")
                    width: units.gu(26)
                    anchors.topMargin: units.gu(5)
                    anchors.horizontalCenter: parent.horizontalCenter
                    // color: theme.palette.normal.positive
                    onClicked: {
                        qthLoc.text === "" ? qthLoc.text = qthLoc.placeholderText : undefined;

                        settings.default_qth = qthLoc.text;
                        python.call("maiden.to_location", [qthLoc.text], function(returnVal){
                            resultLat.text = roundNumber(returnVal[0], 5) + "º";
                            resultLon.text = roundNumber(returnVal[1], 5) + "º";
                        });
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n.tr("Latitude:")
                    font.bold: true
                }

                Label {
                    id: resultLat
                    font.pointSize: marginVal * 2.5
                }

                Label {
                    Layout.alignment: Qt.AlignCenter
                    text: i18n.tr("Longitude:")
                    font.bold: true
                }

                Label {
                    id: resultLon
                    font.pointSize: marginVal * 2.5
                }
            }
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            importModule('maiden', function() {
            });
        }
        onError: {
            console.log('python error: ' + traceback);
        }
    }
}

