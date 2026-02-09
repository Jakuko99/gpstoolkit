import QtQuick 2.6
import Lomiri.Components 1.3
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

    function typeOf(obj) {
        return {}.toString.call(obj).split(' ')[1].slice(0, -1).toLowerCase();
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
                text: i18n.tr("Unit conversions")
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr(" ")
            }
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        //currentIndex: tabBar.currentIndex
        anchors.margins: marginVal * 2
        spacing: marginVal

        Item {
            ColumnLayout {
                Layout.fillWidth: true
                spacing: marginVal

                Label {
                    Layout.alignment: Qt.AlignCenter
                    text: i18n.tr("Coordinate conversions")
                    font.bold: true
                }

                Frame {
                    Layout.fillWidth: true
                    GridLayout {
                        columns: 3
                        Label {
                            text: i18n.tr("Latitude:")
                            font.bold: true
                        }

                        TextField {
                            Layout.columnSpan: 2
                            placeholderText: "0.00000"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }

                        Label {
                            text: i18n.tr("Longitude:")
                            font.bold: true
                        }

                        TextField {
                            Layout.columnSpan: 2
                            placeholderText: "0.00000"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }

                        Button {
                            Layout.row: 3
                            Layout.column: 2
                            text: i18n.tr("Convert")
                        }
                    }
                }

            }
        }

        Item {
            ColumnLayout {
                //Layout.fillWidth: true
                spacing: marginVal

                Label {
                    text: i18n.tr("Maidenhead (QTH) Locator Distance")
                    font.bold: true
                }

                Row {
                    Layout.fillWidth: true
                    Label {
                        text: i18n.tr("QTH from: ")
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                    }

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "QHT 1"
                        id: qthField1
                        font.capitalization: Font.AllUppercase
                    }
                }
                Row {
                    Layout.fillWidth: true
                    Label {
                        text: i18n.tr("QTH to:      ")
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                    }

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "QHT 2"
                        id: qthField2
                        font.capitalization: Font.AllUppercase
                    }
                }

                Button {
                    text: i18n.tr("Calculate")
                    onClicked: python.call("maiden.distance_between_qth", [qthField1.text, qthField2.text], function(returnVal){
                        if (typeOf(returnVal) === "string"){
                            resultLabel.text = returnVal;
                        } else {
                            resultLabel.text =  qthField1.text.toUpperCase() + " -> " + qthField2.text.toUpperCase() + ": " + roundNumber(returnVal, 2) + " km";
                        }
                    });
                }

                Label {
                    Layout.fillWidth: true
                    id: resultLabel
                    wrapMode: Label.WordWrap
                }
            }
        }

        Item {
            Label {
                text: "dddddddd"
            }
        }
    }

    footer: RowLayout {
        Layout.fillWidth: true
        PageIndicator {
            Layout.alignment: Qt.AlignHCenter
            count: swipeView.count
            currentIndex: swipeView.currentIndex
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
