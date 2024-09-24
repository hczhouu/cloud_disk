import QtQuick 2.15
import QtQuick.Controls 2.0
import DownloadListModel 1.0

Item {
    property int rowHeight: 35 * dpi
    property int currIndex: 0

    function selectAllItem(selAll)
    {
        //列表全选
        for (var k = 0; k < listView.contentItem.children.length; ++k)
        {
            var listItem = listView.contentItem.children[k];
            for (var j = 0; j < listItem.children.length; ++j)
            {
                listItem.children[0].children[0].children[0].checked = selAll
            }
        }

        //UploadListModel.addSelectAllItem(selAll);
    }

    ListView {
        id:listView
        anchors.fill: parent
        clip: true
        spacing: 1
        focus: true
        currentIndex: -2
        model: DownloadListModel
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
                    width: listView.width - rectFileSize.width - rectProgress.width -
                           rectSpeed.width - rectOperation.width - rectCheckAll.width
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
                        text:fileDownSize
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
                    id:rectProgress
                    width: 150 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true

                    Text {
                        text:"等待中"
                        font.pixelSize: 14 * dpi
                        color: "white"
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin:  5 * dpi
                        clip: true
                        visible: model.index !== 0
                    }

                    ProgressBar {
                        id:progressBar
                        width: parent.width  - 10
                        height: 12 * dpi
                        from: 0
                        to:fileSize
                        value: downloadProgress
                        anchors.centerIn: parent
                        visible: model.index === 0
                        background: Rectangle {
                            implicitHeight: progressBar.height
                            implicitWidth: progressBar.width
                            color: "#AEBBCC"
                            //radius: 10
                        }

                        contentItem: Item {
                            Rectangle {
                                implicitHeight: progressBar.height
                                implicitWidth: progressBar.visualPosition * progressBar.width
                                color: "#F67D04"
                                //radius: 10
                            }
                        }
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
                    id:rectSpeed
                    width: 100 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true

                    Text {
                        text:downloadSpeed
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
                        spacing: 15 * dpi
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * dpi
                        anchors.verticalCenter: parent.verticalCenter
                        Button {
                            width: 18 * dpi
                            height: 18 * dpi
                            background: Image {
                                id:imageCancel
                                source: "../res/icon_cancel.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    FtpClient.removeDownloadItem(index)
                                }

                                onEntered:  {
                                    imageCancel.source = "../res/icon_cancel_hover.png"
                                }

                                onExited: {
                                    imageCancel.source = "../res/icon_cancel.png"
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
