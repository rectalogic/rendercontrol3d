import QtQuick
import QtQuick3D

View3D {
    width: 300
    height: 300

    environment: SceneEnvironment {
        clearColor: "skyblue"
        backgroundMode: SceneEnvironment.Color
        antialiasingMode: SceneEnvironment.MSAA
        antialiasingQuality: SceneEnvironment.High
    }

    PerspectiveCamera {
        property real cameraZ: 500
        id: camera
        position: Qt.vector3d(0, 200, cameraZ)
        eulerRotation.x: -30
        NumberAnimation on cameraZ { from: 500; to: 0; duration: 2000; loops: -1 }
    }

    DirectionalLight {
        eulerRotation.x: -30
        eulerRotation.y: -70
    }

    Model {
        id: cube
        position: Qt.vector3d(0, 0, 0)
        source: "#Cube"
        materials: [
            DefaultMaterial {
                diffuseColor: "red"
            }
        ]
    }

    Node {
        position: Qt.vector3d(100, 100, 0)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "yellow"
            width: 200
            height: 200
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "camZ " + camera.position.z
                color: "black"
                font.pointSize: 18
            }
        }
    }
}
