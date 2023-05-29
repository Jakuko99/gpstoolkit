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

    function roundNumber(num, dec) {
        return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
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

        Grid{
            id: contentGrid
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
                //                Layout.fillWidth: true
                Label {
                    id: latLabel
                    text: roundNumber(geoposition.position.coordinate.latitude, 5)  + "º"
                    font.pointSize: marginVal * 3
                }

                Label {
                    text: i18n.tr("Latitude")
                    //color: "blue"
                    font.bold: true
                }
            }

            Column {
                //                Layout.fillWidth: true
                Label {
                    id: lonLabel
                    text: roundNumber(geoposition.position.coordinate.longitude,5) + "º"
                    font.pointSize: marginVal * 3
                }

                Label {
                    text: i18n.tr("Longitude")
                    //color: "blue"
                    font.bold: true
                }
            }

            Column {
                Label {
                    text: roundNumber(geoposition.position.coordinate.altitude, 1) + " m"
                    font.pointSize: marginVal * 3
                }

                Label{
                    text: i18n.tr("Altitude")
                    font.bold: true
                }
            }

            Column {
                Label {
                    text: "± " + roundNumber(geoposition.position.horizontalAccuracy, 1) + " m"
                    font.pointSize: marginVal * 3
                }

                Label{
                    text: i18n.tr("Accuracy")
                    font.bold: true
                }
            }

            Column {
                Label {
                    text: geoposition.position.speed === -1 ? 'No fix' : roundNumber(geoposition.position.speed, 1) + " m/s"
                    font.pointSize: marginVal * 3
                }

                Label{
                    text: i18n.tr("Speed")
                    font.bold: true
                }
            }

            Column {
                Label {
                    id: maidenLabel
                    font.pointSize: marginVal * 3
                }

                Label{
                    text: i18n.tr("QTH Locator")
                    font.bold: true
                }
            }
        }

        Row {
            anchors.top: contentGrid.bottom
            anchors.topMargin: marginVal
            anchors.leftMargin: marginVal
            anchors.left: parent.left
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
