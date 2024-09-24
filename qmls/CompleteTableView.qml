import QtQuick 2.15
import QtQuick.Controls 2.0
import CompleteListModel 1.0

Item {
    property int rowHeight: 35 * dpi
    property int currIndex: 0

    ListView {
        id:listView
        anchors.fill: parent
        clip: true
        spacing: 1
        focus: true
        currentIndex: -2
        model: CompleteListModel
        delegate: Rectangle {
            width: listView.width
            height: rowHeight
            color: "transparent"
            Row {
                visible: true
                spacing: 1
                anchors.centerIn: parent
                Rectangle {
                    id:rectCheckAll
                    width: 80 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    Button {
                        id:btnCheck
                        width: imageIcon.implicitWidth
                        height: imageIcon.implicitHeight
                        anchors.centerIn:parent
                        checkable:true
                        background: Rectangle {
                            color: "transparent"
                            Image {
                                id:imageIcon
                                source: btnCheck.checked ?  "../res/icon_check_sel.png" :
                                                            "../res/icon_check_unsel.png"
                                fillMode: Image.PreserveAspectFit
                                scale: dpi
                            }
                        }
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            btnCheck.checked = !btnCheck.checked
                            //AllFilesListModel.addSelectItem(currIndex, btnCheck.checked)
                        }

                        onEntered:{
                            currIndex = index
                        }

                        onExited: {
                            currIndex = -1
                        }
                    }
                }

                Rectangle {
                    id:rectFileName
                    width: listView.width - rectFileSize.width - rectStatus.width -
                           rectOperation.width - rectCheckAll.width
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true

                    Rectangle {
                        id:rectIcon
                        width: 32 * dpi
                        height: 32 * dpi
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * dpi
                        Image {
                            anchors.centerIn: parent
                            source: fileIcon
                            fillMode: Image.PreserveAspectFit
                            scale: 0.3  * dpi
                        }
                    }


                    Text {
                        id:textFileName
                        text:fileName
                        width: parent.width - rectIcon.width - 11 * dpi
                        height: parent.height
                        font.pixelSize: 14 * dpi
                        color: "white"
                        anchors.left: rectIcon.right
                        anchors.leftMargin: 5 * dpi
                        verticalAlignment: Text.AlignVCenter
                        clip: true
                        elide: Text.ElideRight

                        ToolTip {
                            id:toolTipsFileName
                            delay: 700
                            timeout: 3000
                            visible: false
                            text: textFileName.text
                            font.pixelSize: 12 * dpi
                        }
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onDoubleClicked: {
                            if (!isFolder)
                            {
                                return
                            }

                            FtpClient.getDirList(false, false, false, fileName)
                        }

                        onEntered:{
                            currIndex = index
                            toolTipsFileName.visible = true
                        }

                        onExited: {
                            currIndex = -1
                            toolTipsFileName.visible = false
                        }
                    }
                }

                Rectangle {
                    id:rectFileSize
                    width: 160 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true
                    Text {
                        text:fileSize
                        font.pixelSize: 14 * dpi
                        color: "white"
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * dpi
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered:{
                            currIndex = index
                        }

                        onExited: {
                            currIndex = -1
                        }
                    }
                }


                Rectangle {
                    id:rectStatus
                    width: 150 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true

                    Text {
                        text:fileStatus
                        font.pixelSize: 14 * dpi
                        color: "white"
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin:  5 * dpi
                        clip: true
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered:{
                            currIndex = index
                        }

                        onExited: {
                            currIndex = -1
                        }
                    }
                }

                Rectangle {
                    id:rectOperation
                    width: 100 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true

                    Row {
                        spacing: 10 * dpi
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * dpi
                        anchors.verticalCenter: parent.verticalCenter
                        Button {
                            width: 18 * dpi
                            height: 18 * dpi
                            background: Image {
                                id:imageCancel
                                source: "../res/icon_clear.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    CompleteListModel.removeCompleteItem(index)
                                }

                                onEntered:  {
                                    imageCancel.source = "../res/icon_clear_hover.png"
                                }

                                onExited: {
                                    imageCancel.source = "../res/icon_clear.png"
                                }
                            }
                        }

                        Button {
                            width: 18 * dpi
                            height: 18 * dpi
                            background: Image {
                                id:imagePath
                                source: "../res/icon_path.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    FtpClient.openLocalPath(localPath)
                                }

                                onEntered:  {
                                    imagePath.source = "../res/icon_path_hover.png"
                                }

                                onExited: {
                                    imagePath.source = "../res/icon_path.png"
                                }
                            }
                        }
                    }

                }

            }
        }
    }
}
