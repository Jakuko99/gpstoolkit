/*
 * Copyright (C) 2023  Jakub Krsko
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * gpstoolkit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Window 2.3
import Ubuntu.Components 1.3 as Ubuntu
import QtPositioning 5.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4


ApplicationWindow {
    id: root
    objectName: 'mainView'
    width: units.gu(45)
    height: units.gu(75)
    property real marginVal: units.gu(1)

    Component.onCompleted: function(){
        Qt.application.name = "gpstoolkit.jakub";
        locTimer.running = true;
    }

    Component.onDestruction: locTimer.running = false; // stop timer when closing page

    StackView{
        id: stack
        initialItem: mainPage
        anchors.fill: parent
    }

    Timer { // timer for updating maiden locator every 2.5 seconds
        id: locTimer
        interval: 2500
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            python.call("maiden.to_maiden", [geoposition.position.coordinate.latitude, geoposition.position.coordinate.longitude], function(returnVal){
                maidenLabel.text = returnVal;
            });
        }
    }

    Page {
        id: mainPage
        //anchors.fill: parent //maybe StackView sets fill for all pages

        header: ToolBar {
            id: toolbar
            RowLayout {
                anchors.fill: parent
                ToolButton{
                    //text: qsTr("‹")
                    text: qsTr(" ") // invisible for now
                    //onClicked: stack.pop()
                }
                Label {
                    text: "GPS Toolkit"
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
                            text: i18n.tr("Maiden locator")
                            onTriggered: stack.push(Qt.resolvedUrl("maiden_locator.qml"))
                        }
                        MenuItem {
                            text: i18n.tr("Compass navigation")
                            onTriggered: stack.push(Qt.resolvedUrl("compass_page.qml"))
                        }
                        MenuItem {
                            text: i18n.tr("Map")
                            onTriggered: stack.push(Qt.resolvedUrl("optionsPage.qml"))
                        }
                        MenuItem {
                            text: i18n.tr("About")
                            onTriggered: stack.push(Qt.resolvedUrl("aboutPage.qml"))
                        }
                    }
                }
            }
        }

        Column {
            spacing: units.gu(1)
            anchors {
                margins: units.gu(2)
                fill: parent
            }

            Row {
                id: latRow
                Layout.fillWidth: true
                spacing: marginVal * 5

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    Label {
                        id: latLabel
                        text: geoposition.position.coordinate.latitude || "No fix" + " º"
                        font.pointSize: 50
                    }

                    Label {
                        text: i18n.tr("Latitude")
                        //color: "blue"
                        font.pointSize: 25
                        font.bold: true
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    Label {
                        id: lonLabel
                        text: geoposition.position.coordinate.longitude || "No fix" + " º"
                        font.pointSize: 50
                    }

                    Label {
                        text: i18n.tr("Longitude")
                        //color: "blue"
                        font.pointSize: 25
                        font.bold: true
                    }
                }
            }

            Row {
                spacing: marginVal
                Label{
                    text: i18n.tr("Altitude (m): ")
                    font.bold: true
                }
                Label {
                    text: geoposition.position.coordinate.altitude || 'No fix'
                }
                Label{
                    text: i18n.tr("Accuracy (m): ")
                    font.bold: true
                }
                Label {
                    text: "± " + geoposition.position.horizontalAccuracy || 'No fix'
                }
            }

            Row{
                Label{
                    text: i18n.tr("Speed (m/s): ")
                    font.bold: true
                }
                Label {
                    text: geoposition.position.speed === -1 ? 'No fix' : geoposition.position.speed
                }
            }

            Row {
                Label{
                    text: i18n.tr("Current maiden locator: ")
                    font.bold: true
                }
                Label {
                    id: maidenLabel
                }
            }

            Row {
                Label{
                    text: i18n.tr("Last updated: ")
                    font.bold: true
                }
                Label{
                    text: geoposition.position.timestamp ? geoposition.position.timestamp : '—'
                }
            }

            PositionSource {
                id: geoposition
                active: true
                preferredPositioningMethods: PositionSource.SatellitePositioningMethods
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
