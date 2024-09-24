import QtQuick 2.8
import QtQuick.Controls 2.8
import QtQuick.Window 2.8
import QtQuick.Dialogs 1.3
import SelectPathListModel 1.0

Item {
    property int headerHeight : 60 * dpi
    property bool showList: true
    property bool hoverUpload: false
    property bool hoverDownload: false
    property bool hoverAddNewFolder: false
    property bool hoverDelete: false


    FileDialog {
        id: fileDialog
        title: "选择文件"
        selectFolder:false
        selectMultiple: true
        folder: shortcuts.desktop
        nameFilters: ["所有文件 (*.*)"]
        onAccepted: {
            fileDialog.close()
            var fileList = []
            for (var i in fileDialog.fileUrls) {
                fileList.push(fileDialog.fileUrls[i])
            }

            FtpClient.uploadFile(fileList)
        }

        onRejected: {
            fileDialog.close()
        }
    }


    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: "transparent"

        Rectangle {
            id:rectBtns
            width: parent.width
            height: 40 * dpi
            color: "transparent"
            Row {
                spacing: 15 * dpi
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.top: parent.top

                Button {
                    width: 100 * dpi
                    height: 40 * dpi
                    background: Rectangle {
                        color: hoverUpload ? "#3D414B" : "#272B34"
                        border.width:1
                        border.color:"#3D414B"
                    }

                    Row {
                        spacing: 5 * dpi
                        anchors.centerIn: parent
                        Image {
                            source: hoverUpload ? "../res/icon_upload_min_hover.png" :
                                                  "../res/icon_upload_min.png"
                            fillMode: Image.PreserveAspectFit
                            scale: dpi
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:"上传"
                            font.pixelSize: 14 * dpi
                            color: hoverUpload ? "white" : "#6C707B"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            fileDialog.open()
                        }

                        onEntered: {
                            hoverUpload = true
                        }

                        onExited: {
                            hoverUpload = false
                        }
                    }
                }

                Button {
                    width: 100 * dpi
                    height: 40 * dpi
                    background: Rectangle {
                        color: hoverDownload ? "#3D414B" : "#272B34"
                        border.width:1
                        border.color:"#3D414B"
                    }

                    Row {
                        spacing: 5 * dpi
                        anchors.centerIn: parent
                        Image {
                            source: hoverDownload ? "../res/icon_download_min_hover.png" :
                                                    "../res/icon_download_min.png"
                            fillMode: Image.PreserveAspectFit
                            scale: dpi
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id:textDownload
                            text:"下载"
                            font.pixelSize: 14 * dpi
                            color: hoverDownload ? "white" : "#6C707B"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            allFilesTableView.listSelectAll(false)
                            btnListCheckBox.checked = false
                            FtpClient.downloadFile()
                        }

                        onEntered: {
                            hoverDownload = true
                        }

                        onExited: {
                            hoverDownload = false
                        }
                    }
                }

                Button {
                    width: 150 * dpi
                    height: 40 * dpi
                    background: Rectangle {
                        color: hoverAddNewFolder ? "#3D414B" : "#272B34"
                        border.width:1
                        border.color:"#3D414B"
                    }

                    Row {
                        spacing: 5 * dpi
                        anchors.centerIn: parent
                        Image {
                            source: hoverAddNewFolder ? "../res/icon_add_min_hover.png":
                                                        "../res/icon_add_min.png"
                            fillMode: Image.PreserveAspectFit
                            scale: dpi
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id:textAdd
                            text:"新建文件夹"
                            font.pixelSize: 14 * dpi
                            color: hoverAddNewFolder ? "white" : "#6C707B"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            addFolderPop.open()
                        }

                        onEntered: {
                            hoverAddNewFolder = true
                        }

                        onExited: {
                            hoverAddNewFolder = false
                        }
                    }
                }

                Button {
                    width: 100 * dpi
                    height: 40 * dpi
                    background: Rectangle {
                        color: hoverDelete ? "#3D414B" : "#272B34"
                        border.width:1
                        border.color:"#3D414B"
                    }

                    Row {
                        spacing: 5 * dpi
                        anchors.centerIn: parent
                        Image {
                            source: hoverDelete ? "../res/icon_del_min_hover.png" :
                                                  "../res/icon_del_min.png"
                            fillMode: Image.PreserveAspectFit
                            scale: dpi
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text:"删除"
                            font.pixelSize: 14 * dpi
                            color: hoverDelete ? "white" : "#6C707B"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            btnListCheckBox.checked = false
                            allFilesTableView.listSelectAll(false)
                            FtpClient.deleteSelectItem()
                        }

                        onEntered: {
                            hoverDelete = true
                        }

                        onExited: {
                            hoverDelete = false
                        }
                    }
                }

            }
        }


        Rectangle {
            id:rects
            width: parent.width
            height: parent.height - rectBtns.height - 10 * dpi
            anchors.top: rectBtns.bottom
            anchors.topMargin: 10 * dpi
            border.width: 1
            border.color: "#3D414B"
            color: "transparent"


            Rectangle {
                id:rectOperation
                width: parent.width - 2
                height: 50 * dpi
                anchors.top: parent.top
                anchors.topMargin: 1
                anchors.left: parent.left
                anchors.leftMargin: 1
                color: "#2A2E35"
                clip: true

                //后退
                Button {
                    id:btnBack
                    width: 22 * dpi
                    height: 22 * dpi
                    anchors.left: parent.left
                    anchors.leftMargin: 22 * dpi
                    anchors.verticalCenter:parent.verticalCenter
                    background: Rectangle {
                        color: "transparent"
                    }

                    Image {
                        id:imageBack
                        source: "../res/icon_back.png"
                        fillMode: Image.PreserveAspectFit
                        //scale: dpi
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            FtpClient.backDir()
                        }

                        onEntered: {
                            imageBack.source = "../res/icon_back_hover.png"
                        }

                        onExited: {
                            imageBack.source = "../res/icon_back.png"
                        }
                    }
                }

                //前进
                Button {
                    id:btnForward
                    width: 22 * dpi
                    height: 22 * dpi
                    anchors.left: btnBack.right
                    anchors.leftMargin: 20 * dpi
                    anchors.verticalCenter:parent.verticalCenter
                    background: Rectangle {
                        color: "transparent"
                    }

                    Image {
                        id:imageForward
                        source: "../res/icon_forward.png"
                        fillMode: Image.PreserveAspectFit
                        //scale: dpi
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            FtpClient.forwardDir()
                        }

                        onEntered: {
                            imageForward.source = "../res/icon_forward_hover.png"
                        }

                        onExited: {
                            imageForward.source = "../res/icon_forward.png"
                        }
                    }
                }

                //刷新
                Button {
                    id:btnRefresh
                    width: 22 * dpi
                    height: 22 * dpi
                    anchors.left: btnForward.right
                    anchors.leftMargin: 20 * dpi
                    anchors.verticalCenter:parent.verticalCenter
                    background: Rectangle {
                        color: "transparent"
                    }

                    Image {
                        id:imageRefresh
                        source: "../res/icon_refresh.png"
                        fillMode: Image.PreserveAspectFit
                        //scale: dpi
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            FtpClient.refreshDir()
                        }

                        onEntered: {
                            imageRefresh.source = "../res/icon_refresh_hover.png"
                        }

                        onExited: {
                            imageRefresh.source = "../res/icon_refresh.png"
                        }
                    }
                }


                Rectangle {
                    width: parent.width - 200 * dpi
                    height: parent.height
                    color: "transparent"
                    anchors.left: btnRefresh.right
                    anchors.leftMargin: 20 * dpi
                    clip: true
                    Row {
                        spacing: 5
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                        Repeater {
                            model:SelectPathListModel
                            delegate: Rectangle {
                                id:delRectangle
                                color: "transparent"
                                width: textDirName.width + imageArrow.width
                                height: 30 * dpi
                                clip: true
                                Text {
                                    id:textDirName
                                    height: parent.height
                                    text:dirName
                                    font.pixelSize: 14 * dpi
                                    color: "#6C707B"
                                    verticalAlignment: Text.AlignVCenter

                                }

                                Image {
                                    id:imageArrow
                                    visible: showArrow
                                    anchors.left: textDirName.right
                                    source: "../res/icon_arrow.png"
                                    fillMode: Image.PreserveAspectFit
                                    anchors.verticalCenter: parent.verticalCenter
                                }


                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        FtpClient.gotoDir(dirName)
                                    }

                                    onEntered: {
                                        textDirName.color = "white"
                                        imageArrow.source = "../res/icon_arrow_hover.png"
                                    }

                                    onExited: {
                                        textDirName.color = "#6C707B"
                                        imageArrow.source = "../res/icon_arrow.png"
                                    }
                                }
                            }
                        }

                    }
                }


                //网格
                Button {
                    id:btnGrid
                    width: 22 * dpi
                    height: 22 * dpi
                    visible: showList
                    anchors.right: parent.right
                    anchors.rightMargin: 20 * dpi
                    anchors.verticalCenter:parent.verticalCenter
                    background: Rectangle {
                        color: "transparent"
                    }

                    Image {
                        id:imageGrid
                        source: "../res/icon_grid.png"
                        fillMode: Image.PreserveAspectFit
                        //scale: dpi
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            btnGrid.visible = false
                            btnList.visible = true
                            showList = false
                        }

                        onEntered: {
                            imageGrid.source = "../res/icon_grid_hover.png"
                        }

                        onExited: {
                            imageGrid.source = "../res/icon_grid.png"
                        }
                    }
                }

                //列表
                Button {
                    id:btnList
                    width: 22 * dpi
                    height: 22 * dpi
                    visible: !showList
                    anchors.right: parent.right
                    anchors.rightMargin: 20 * dpi
                    anchors.verticalCenter:parent.verticalCenter
                    background: Rectangle {
                        color: "transparent"
                    }

                    Image {
                        id:imageList
                        source: "../res/icon_list.png"
                        fillMode: Image.PreserveAspectFit
                        //scale: dpi
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            btnGrid.visible = true
                            btnList.visible = false
                            showList = true
                        }

                        onEntered: {
                            imageList.source = "../res/icon_list_hover.png"
                        }

                        onExited: {
                            imageList.source = "../res/icon_list.png"
                        }
                    }
                }

            }


            //表头
            Rectangle {
                id:rectHeader
                width: parent.width - 2
                height: 40 * dpi
                anchors.top: rectOperation.bottom
                anchors.topMargin: 1
                anchors.left: parent.left
                anchors.leftMargin: 1
                color: "transparent"
                clip: true
                visible: showList
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
                                    allFilesTableView.selectAllItem(btnListCheckBox.checked)
                                }
                            }
                        }

                    }

                    Rectangle {
                        width: rectHeader.width - rectCheckBox.width - rectHeadFileSize.width -
                               rectHeadCreateTime.width - rectHeadFileType.width
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
                        id:rectHeadCreateTime
                        width: 200 * dpi
                        height: headerHeight
                        color: "#2A2E35"
                        Text {
                            text:"修改时间"
                            font.pixelSize: 14 * dpi
                            color: "#818D9D"
                            anchors.left: parent.left
                            anchors.leftMargin: 5 * dpi
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        id:rectHeadFileType
                        width: 150 * dpi
                        height: headerHeight
                        color: "#2A2E35"
                        Text {
                            text:"类型"
                            font.pixelSize: 14 * dpi
                            color: "#818D9D"
                            anchors.left: parent.left
                            anchors.leftMargin: 5 * dpi
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        id:rectHeadFileSize
                        width: 100 * dpi
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
                }
            }

            ScrollView {
                id:allFilesList
                width: parent.width - 2
                height: parent.height - rectHeader.height - rectOperation.height - 1
                anchors.top: rectHeader.bottom
                anchors.topMargin: 1
                anchors.left: parent.left
                anchors.leftMargin: 1
                visible: showList
                AllFilesTableView {
                    id:allFilesTableView
                    anchors.fill: parent
                }

            }

            ScrollView {
                id:allFilesGrid
                width: parent.width - 2
                height: parent.height - rectOperation.height - 1
                anchors.top: rectOperation.bottom
                anchors.topMargin: 1
                anchors.left: parent.left
                anchors.leftMargin: 1
                visible: !showList
                AllFilesGridView {
                    anchors.fill: parent
                }
            }
        }
    }
}
