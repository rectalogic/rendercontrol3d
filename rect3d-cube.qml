import QtQuick
import QtQuick3D
import QtQuick.Timeline

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

    Timeline {
        startFrame: 0
        endFrame: 1000
        enabled: true
        NumberAnimation on currentFrame { from: 0; to: 1000; duration: 5000; loops: -1 }

        KeyframeGroup {
            target: cube
            property: "position.z"

            Keyframe {
                frame: 0
                value: 0
            }
            Keyframe {
                frame: 1000
                value: 500
            }
        }
    }
}
