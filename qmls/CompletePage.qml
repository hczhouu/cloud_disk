import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Window 2.0
import CompleteListModel 1.0

Item {
    property int headerHeight : 60 * dpi
    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: "transparent"
        border.width:1
        border.color:"#3D414B"

        Rectangle {
            id:rectCompleteNum
            width: parent.width - 2
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.leftMargin: 1
            height: 50 * dpi
            color: "#2A2E35"

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8 * dpi

                Text {
                    text:"完成传输 "
                    font.pixelSize: 14 * dpi
                    color: "white"
                }

                Text {
                    text:CompleteListModel.completeCount
                    font.pixelSize: 14 * dpi
                    color: "#E5BF97"
                }

                Text {
                    text:" 个文件"
                    font.pixelSize: 14 * dpi
                    color: "white"
                }
            }
        }

        //表头
        Rectangle {
            id:rectHeader
            width: parent.width - 2
            height: 40 * dpi
            anchors.top: rectCompleteNum.bottom
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.leftMargin: 1
            color: "transparent"
            clip: true
            Row {
                spacing: 1
                anchors.centerIn: parent
                Rectangle {
                    id:rectCheckBox
                    width: 80 * dpi
                    height: 60 * dpi
                    color: "#2A2E35"
                    Button {
                        id:btnListCheckBox
                        width: imageCheckBoxIcon.implicitWidth
                        height: imageCheckBoxIcon.implicitHeight
                        anchors.centerIn:parent
                        checkable:true
                        checked: false
                        background: Rectangle {
                            color: "transparent"
                            Image {
                                id:imageCheckBoxIcon
                                source: btnListCheckBox.checked ?  "../res/icon_check_sel.png" :
                                                            "../res/icon_check_unsel.png"
                                fillMode: Image.PreserveAspectFit
                                scale: dpi
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                 btnListCheckBox.checked = !btnListCheckBox.checked
                                // allFileListModel.selectAll(btnListCheckBox.checked)
                                // 界面全选
                                //allFilesTableView.selectAllItem(btnListCheckBox.checked)
                            }
                        }
                    }

                }

                Rectangle {
                    id:rectFileName
                    width: rectHeader.width - rectCheckBox.width - rectFileSize.width -
                           rectStatus.width - rectOperation.width
                    height:headerHeight
                    color: "#2A2E35"
                    Text {
                        text:"文件名称"
                        font.pixelSize: 14 * dpi
                        color: "#818D9D"
                        anchors.left: parent.left
                        anchors.leftMargin: 9 * dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    id:rectFileSize
                    width: 160 * dpi
                    height: headerHeight
                    color: "#2A2E35"
                    Text {
                        text:"大小"
                        font.pixelSize: 14 * dpi
                        color: "#818D9D"
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    id:rectStatus
                    width: 150 * dpi
                    height: headerHeight
                    color: "#2A2E35"
                    Text {
                        text:"传输状态"
                        font.pixelSize: 14 * dpi
                        color: "#818D9D"
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    id:rectOperation
                    width: 100 * dpi
                    height: headerHeight
                    color: "#2A2E35"
                    Text {
                        text:"操作"
                        font.pixelSize: 14 * dpi
                        color: "#818D9D"
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * dpi
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        ScrollView {
            width: parent.width - 2
            height: parent.height - rectCompleteNum.height -
                    rectSpliter.height - rectHeader.height - topPadding
            anchors.top: rectHeader.bottom
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.leftMargin: 1
            CompleteTableView {
                id:completeTableView
                anchors.fill: parent
            }
        }

    }
}
