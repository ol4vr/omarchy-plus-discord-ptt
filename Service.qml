import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  readonly property string helperPath: Quickshell.env("HOME")
    + "/.config/omarchy/plugins/io.github.ol4vr.discord-ptt/omarchy-plus-discord-ptt"

  Process {
    id: reconcileProcess
    command: [root.helperPath, "reconcile"]
    running: false

    stdout: StdioCollector {
      id: reconcileOutput
      waitForEnd: true
    }

    stderr: StdioCollector {
      id: reconcileError
      waitForEnd: true
    }

    onExited: function(exitCode) {
      if (exitCode === 0) {
        console.info("Discord PTT reconciled: " + reconcileOutput.text.trim())
      } else {
        console.error("Discord PTT reconciliation failed: "
          + (reconcileError.text.trim() !== "" ? reconcileError.text.trim() : "exit " + exitCode))
      }
    }
  }

  Component.onCompleted: reconcileProcess.running = true
}
