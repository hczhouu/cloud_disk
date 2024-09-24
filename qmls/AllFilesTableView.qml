import QtQuick 2.15
import QtQuick.Controls 2.0
import AllFilesListModel 1.0

Item {
    property int rowHeight: 35 * dpi
    property int currIndex: 0

    function selectAllItem(selAll)
    {
        //网格全选
        // for (var i = 0; i < allFileGridView.contentItem.children.length; ++i)
        // {

        //     var item = allFileGridView.contentItem.children[i];
        //     item.color = "transparent"
        //     item.children[2].visible = false
        //     item.children[2].checked = selAll
        // }

        //列表全选
        for (var k = 0; k < listView.contentItem.children.length; ++k)
        {
            var listItem = listView.contentItem.children[k];
            for (var j = 0; j < listItem.children.length; ++j)
            {
                listItem.children[0].children[0].children[0].checked = selAll
            }
        }

        AllFilesListModel.addSelectAllItem(selAll);
    }

    function listSelectAll(selAll)
    {
        //列表界面全选反选
        for (var k = 0; k < listView.contentItem.children.length; ++k)
        {
            var listItem = listView.contentItem.children[k];
            for (var j = 0; j < listItem.children.length; ++j)
            {
                listItem.children[0].children[0].children[0].checked = selAll
            }
        }
    }


    ListView {
        id:listView
        anchors.fill: parent
        clip: true
        spacing: 1
        focus: true
        currentIndex: -2
        model: AllFilesListModel
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
                            AllFilesListModel.addSelectItem(currIndex, btnCheck.checked)
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
                    width: listView.width - rectCreateTime.width - rectFileSize.width -
                           rectFileType.width - rectCheckAll.width
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
                        width: parent.width - rectIcon.width - 11 * dpi
                        height: parent.height
                        text:fileName
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
                            text: fileName
                            font.pixelSize: 12 * dpi
                        }
                    }

                    MouseArea{
                        id:mouseAreaFileName
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
                    id:rectCreateTime
                    width: 200 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true
                    Text {
                        text:fileTime
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
                    id:rectFileType
                    width: 150 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true
                    Text {
                        text:fileDesc
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
                    id:rectFileSize
                    width: 100 * dpi
                    height: rowHeight
                    color: currIndex === index ? "#3D414B" : "#2A2E35"
                    clip: true

                    Text {
                        text:fileSizeFormat
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
