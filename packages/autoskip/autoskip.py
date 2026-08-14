# !/usr/bin/env python3

import sys
import re
import argparse
from typing import Optional, List
import dbus
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

DBusGMainLoop(set_as_default=True)


class MPRISAutoSkip:
    def __init__(self, skip_words: List[str], case_sensitive: bool = False):
        self.bus = dbus.SessionBus()
        self.players: dict = {}
        self.skip_words = skip_words
        self.case_sensitive = case_sensitive

        self.scan_players()
        self.bus.add_signal_receiver(
            self.handle_name_owner_changed,
            signal_name="NameOwnerChanged",
            dbus_interface="org.freedesktop.DBus",
        )

    def scan_players(self):
        names = self.bus.list_names()
        for name in names:
            if name.startswith("org.mpris.MediaPlayer2."):
                self.add_player(name)

    def add_player(self, bus_name: str):
        if bus_name in self.players:
            return

        try:
            player = self.bus.get_object(bus_name, "/org/mpris/MediaPlayer2")
            self.players[bus_name] = player

            self.bus.add_signal_receiver(
                lambda *args, bn=bus_name: self.handle_properties_changed(
                    bn, *args
                ),
                signal_name="PropertiesChanged",
                dbus_interface="org.freedesktop.DBus.Properties",
                bus_name=bus_name,
                path="/org/mpris/MediaPlayer2",
            )

            self.check_current_track(bus_name)

            print(
                f"[Connected] {bus_name.split('.')[-1]}", file=sys.stderr
            )
        except Exception as e:
            print(
                f"[Error] Failed to connect to {bus_name}: {e}",
                file=sys.stderr,
            )

    def handle_name_owner_changed(
        self, name: str, old_owner: str, new_owner: str
    ):
        if name.startswith("org.mpris.MediaPlayer2."):
            if new_owner:
                self.add_player(name)
            elif name in self.players:
                del self.players[name]
                print(
                    f"[Disconnected] {name.split('.')[-1]}", file=sys.stderr
                )

    def get_metadata(self, bus_name: str) -> dict:
        try:
            player = self.players[bus_name]
            props = dbus.Interface(player, "org.freedesktop.DBus.Properties")
            metadata = props.Get("org.mpris.MediaPlayer2.Player", "Metadata")
            return dict(metadata)
        except Exception:
            return {}

    def get_track_title(self, metadata: dict) -> Optional[str]:
        if "xesam:title" in metadata:
            return str(metadata["xesam:title"])
        return None

    def should_skip(self, title: str) -> bool:
        flags = 0 if self.case_sensitive else re.IGNORECASE
        for word in self.skip_words:
            if re.search(rf"\b{re.escape(word)}\b", title, flags):
                return True
        return False

    def check_current_track(self, bus_name: str):
        metadata = self.get_metadata(bus_name)
        title = self.get_track_title(metadata)

        if title:
            print(f"{title}")
            if self.should_skip(title):
                self.skip_track(bus_name)
                print("Skipped")

    def handle_properties_changed(
        self, bus_name: str, interface: str, changed: dict, invalidated: list
    ):
        if interface != "org.mpris.MediaPlayer2.Player":
            return

        if "Metadata" in changed:
            metadata = dict(changed["Metadata"])
            title = self.get_track_title(metadata)

            if title:
                print(f"{title}")
                if self.should_skip(title):
                    self.skip_track(bus_name)
                    print("Skipped")

    def skip_track(self, bus_name: str):
        try:
            player = self.players[bus_name]
            player_interface = dbus.Interface(
                player, "org.mpris.MediaPlayer2.Player"
            )
            player_interface.Next()
        except Exception as e:
            print(f"[Error] Failed to skip: {e}", file=sys.stderr)

    def run(self):
        loop = GLib.MainLoop()
        try:
            loop.run()
        except KeyboardInterrupt:
            print("\n[Stopped]", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        description="Auto-skip tracks containing specified words in title"
    )
    parser.add_argument(
        "words",
        nargs="+",
        help="Words to skip (e.g., remix cover live)",
    )
    parser.add_argument(
        "-c",
        "--case-sensitive",
        action="store_true",
        help="Case-sensitive matching (default: ignore case)",
    )
    parser.add_argument(
        "-l",
        "--list",
        action="store_true",
        help="Show current skip words and exit",
    )

    args = parser.parse_args()

    autoskip = MPRISAutoSkip(
        skip_words=args.words, case_sensitive=args.case_sensitive
    )
    autoskip.run()


if __name__ == "__main__":
    main()
