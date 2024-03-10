/*
 * Copyright 2019  Michail Vourlakos <mvourlakos@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3

PlasmoidItem {
    id: main

    Layout.minimumWidth: !vertical ? minimumLength : -1
    Layout.maximumWidth: !vertical ? minimumLength : -1

    Layout.minimumHeight: vertical ? minimumLength : -1
    Layout.maximumHeight: vertical ? minimumLength : -1

    opacity: hidden ? 0 : 1

    readonly property bool vertical: plasmoid.location === PlasmaCore.Types.Vertical
    readonly property bool hidden: plasmoid.location !== PlasmaCore.Types.Planar
                                   && (!plasmoid.containment
                                       || (plasmoid.containment && !plasmoid.containment.corona.editMode))

    readonly property int minimumLength: {
        if (hidden) {
            return 0;
        }

        return !vertical ? transparencySwitch.implicitWidth + 8 : transparencySwitch.height + 8
    }

    preferredRepresentation: fullRepresentation
    Plasmoid.status: plasmoid.containment  && hidden ? PlasmaCore.Types.HiddenStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.onActivated: switchTransparency()

    Component.onCompleted: initializeAppletTimer.start()

    /*Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: "red"
    }*/

    PlasmaComponents3.Switch{
        id: transparencySwitch
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        checked:  plasmoid.containment ? plasmoid.containment.backgroundHints === PlasmaCore.Types.NoBackground : plasmoid.configuration.transparencyEnabled
        onClicked: switchTransparency()
    }

    function applyTransparency() {
        if (plasmoid.containment) {
            var newState = plasmoid.configuration.transparencyEnabled ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground;
            plasmoid.containment.backgroundHints = newState;
        }
    }

    function switchTransparency() {
        plasmoid.configuration.transparencyEnabled = !plasmoid.configuration.transparencyEnabled;
        applyTransparency();
    }

    Timer {
        id: initializeAppletTimer
        interval: 1200

        property int step: 0

        readonly property int maxStep:4

        onTriggered: {
            if (plasmoid.containment) {
                applyTransparency();
            } else if (step<maxStep) {
                step = step + 1;
                start();
            }
        }

    }
}
