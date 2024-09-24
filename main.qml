import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import "./qmls"


Window {
    id:mainWindow
    width: 1100 * dpi
    height: 650 * dpi
    visible: true
    color: "transparent"
    title: qsTr("Hello World")
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.MSWindowsFixedSizeDialogHint

    property real dpi: 1.25
    property int selPageIndex : 0
    // 支持窗体拖拽
    MouseArea {
        anchors.fill:parent
        property point clickPos:"0,0"
        onPressed: {
            clickPos = Qt.point(mouse.x,mouse.y)
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
            mainWindow.setX(mainWindow.x + delta.x)
            mainWindow.setY(mainWindow.y + delta.y)
        }
     }

    //标题栏
    Rectangle {
        id:wndTitle
        width: parent.width
        height: 60 * dpi
        anchors.top: parent.top
        color: "#2A2E35"

        // Image {
        //     id:imageLogo
        //     source: "res/logo.png"
        //     fillMode: Image.PreserveAspectFit
        //     anchors.verticalCenter: parent.verticalCenter
        //     anchors.left: parent.left
        //     anchors.leftMargin: 15 * dpi
        // }

        //最小化
        Rectangle {
            id:rectMinBtn
            width: 24 * dpi
            height:24 * dpi
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: rectCloseBtn.left
            anchors.rightMargin: 5 * dpi
            Button {
                anchors.fill: parent
                background: Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    Image {
                        anchors.centerIn: parent
                        source: "res/icon_min.png"
                        fillMode: Image.PreserveAspectFit
                    }

                ToolTip {
                    id:tooltipMin
                    delay: 700
                    timeout: 3000
                    visible: false
                    text: "最小化"
                    font.pixelSize: 14 * dpi
                    }
                 }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        rectMinBtn.color="#48FFFFFF"
                        tooltipMin.visible = true
                    }

                    onExited: {
                        rectMinBtn.color="transparent"
                        tooltipMin.visible = false
                    }

                    onClicked: {
                        mainWindow.visibility = Window.Minimized
                    }
                }
            }
        }

        //关闭
        Rectangle {
            id:rectCloseBtn
            width: 24 * dpi
            height:24 * dpi
            anchors.right: parent.right
            anchors.rightMargin: 20 * dpi
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            Button {
                anchors.fill: parent
                background: Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    Image {
                        anchors.centerIn: parent
                        source: "res/icon_close.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    ToolTip {
                        id:tooltipClose
                        delay: 700
                        timeout: 3000
                        visible: false
                        text: "关闭"
                        font.pixelSize: 14  * dpi
                    }
                 }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        rectCloseBtn.color="red"
                        tooltipClose.visible = true
                    }

                    onExited: {
                        rectCloseBtn.color="transparent"
                        tooltipClose.visible = false
                    }

                    onClicked: {
                        Qt.quit()
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: parent.height - wndTitle.height
        anchors.bottom: parent.bottom
        color: "#1C1F23"

        Rectangle {
            id:rectSpliter
            width: 230 * dpi
            height: 1
            color: "#3D414B"
            anchors.top: parent.top
            anchors.left: parent.left
        }

        Rectangle {
            id:leftRect
            width: 230 * dpi
            height: parent.height - 1
            color: "#2A2E35"
            anchors.left: parent.left
            anchors.top: rectSpliter.bottom

            LeftMenus {
                id:leftMenus
            }
        }

        Rectangle {
            width: parent.width - leftRect.width
            height: parent.height
            anchors.right: parent.right
            color: "transparent"
            StackLayout {
                anchors.fill: parent
                currentIndex: selPageIndex
                clip: true
                AllFilesPage {
                    id:allFilesPage
                }

                DownloadPage {

                }

                UploadPage {

                }

                CompletePage {

                }
            }
        }
    }

    AddFolderPopup {
        id:addFolderPop
    }

    MessagePopup {
        id:messagePop
    }
}
