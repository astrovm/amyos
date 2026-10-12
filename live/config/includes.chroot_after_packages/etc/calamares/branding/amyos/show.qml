/* Calamares install slideshow for Amy OS, based on Debian's. */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Slide {
        Image {
            id: logo
            source: "welcome.png"
            width: 457; height: 300
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
        Text {
            anchors.horizontalCenter: logo.horizontalCenter
            anchors.top: logo.bottom
            text: qsTr("Installing Amy OS.<br/>"+
                  "The rest of the installation is automated and should complete in a few minutes.")
            wrapMode: Text.WordWrap
            width: 600
            horizontalAlignment: Text.Center
        }
    }
}
