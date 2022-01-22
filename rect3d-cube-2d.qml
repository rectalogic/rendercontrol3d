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
        id: camera
        position: Qt.vector3d(0, 200, 500)
        eulerRotation.x: -30
    }

    DirectionalLight {
        eulerRotation.x: -30
        eulerRotation.y: -70
    }

    Model {
        property real cubeZ: 0
        id: cube
        position: Qt.vector3d(0, 0, cubeZ)
        source: "#Cube"
        materials: [
            DefaultMaterial {
                diffuseColor: "red"
            }
        ]
        NumberAnimation on cubeZ { from: 0; to: 500; duration: 2000; loops: -1 }
    }

    Node {
        position: Qt.vector3d(100, 100, 0)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "yellow"
            width: 100
            height: 100
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "cubeZ " + cube.position.z
                color: "black"
                font.pointSize: 18
            }
        }
        }
    }
}