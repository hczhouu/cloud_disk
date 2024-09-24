import QtQuick 2.5
import QtQuick.Controls 2.5
import AllFilesListModel 1.0

Item {
    property real itemWidth : parent.width / 7
    property real itemHeight : parent.width / 7
    GridView {
        anchors.fill: parent
        clip: true
        cellHeight:itemHeight
        cellWidth: itemWidth
        model: AllFilesListModel
        delegate: Rectangle {
            id:rectBk
            width: itemHeight - 5
            height: itemHeight - 5
            color: "transparent"
            radius: 10

            Column {
                spacing: 5 * dpi
                anchors.centerIn: parent
                clip: true
                Image {
                    source: fileIcon
                    fillMode: Image.PreserveAspectFit
                    scale: dpi * 0.7
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text:fileName
                    font.pixelSize: 14 * dpi
                    color: "white"
                    width: parent.parent.width - 10
                    height: contentHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    clip: true
                }

            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    toolTips.y = mouseY
                    toolTips.visible = true
                    if (!btnCheckBox.checked)
                    {
                        rectBk.color = "#3D414B"
                        //if (!isFolder)
                        {
                            btnCheckBox.visible = true
                        }
                    }
                }

                onExited: {
                    toolTips.y = mouseY
                    toolTips.visible = false
                    if (!btnCheckBox.checked)
                    {
                        rectBk.color = "transparent"
                        //if (!isFolder)
                        {
                            btnCheckBox.visible = false
                        }
                    }
                }

                onDoubleClicked: {
                    if (!isFolder)
                    {
                        return
                    }

                    FtpClient.getDirList(false, false, false, fileName)
                }

                ToolTip {
                    id:toolTips
                    timeout: 3000
                    delay: 1500
                    contentItem: Text {
                        text:fileName+"\n文件大小: "+fileSize+"\n修改时间: "+fileTime
                        font.pixelSize: 12 * dpi
                        color: "#6C707B"
                    }

                    background: Rectangle {
                        color: "#2A2E35"
                        radius: 5
                        border.width: 1
                        border.color: "white"
                    }
                }
            }

            Button {
                id:btnCheckBox
                implicitHeight: imageCheckIcon.height
                implicitWidth: imageCheckIcon.width
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 5 * dpi
                anchors.topMargin: 5 * dpi
                checkable:true
                checked: false
                visible: false
                background: Rectangle {
                    color: "transparent"
                    Image {
                        id:imageCheckIcon
                        source: btnCheckBox.checked ?  "../res/icon_check_sel.png" :
                                                    "../res/icon_check_unsel.png"
                        fillMode: Image.PreserveAspectFit
                        scale: dpi * 0.9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        if (!btnCheckBox.checked)
                        {
                            rectBk.color = "#3D414B"
                            //if (!isFolder)
                            {
                                btnCheckBox.visible = true
                            }
                        }
                    }

                    onExited: {
                        if (!btnCheckBox.checked)
                        {
                            rectBk.color = "transparent"
                            //if (!isFolder)
                            {
                                btnCheckBox.visible = false
                            }
                        }
                    }

                    onClicked: {
                        btnCheckBox.checked = !btnCheckBox.checked
                        AllFilesListModel.addSelectItem(index, btnCheckBox.checked)
                    }
                }
            }
        }

        DropArea {
            anchors.fill: parent
            onDropped: {
                if(!drop.hasUrls)
                {
                    return
                }

                var fileList = []
                for (var i in drop.urls)
                {
                    fileList.push(drop.urls[i])
                }

                FtpClient.uploadFile(fileList)
            }
        }
    }
}
