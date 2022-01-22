import QtQuick
import QtQuick3D

View3D {
    width: 200
    height: 200

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
        id: cube
        position: Qt.vector3d(0, 0, 0)
        source: "#Cube"
        materials: [
            DefaultMaterial {
                diffuseColor: "red"
            }
        ]
        NumberAnimation on position.z { from: 0; to: 400; duration: 5000; loops: -1 }
    }

    Node {
        position: Qt.vector3d(100, 100, 0)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "yellow"
            width: 100
            height: 100
        }
    }
}
