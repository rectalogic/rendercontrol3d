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
}
