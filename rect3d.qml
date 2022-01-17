import QtQuick
import QtQuick3D

Rectangle {
    width: 200
    height: 200
    color: "steelblue"
    View3D {
        width: 200
        height: 180

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
    }
    Text {
        text: "position=" + cube.position.z
        height: 20
        width: 200
        y: 180
    }
}
