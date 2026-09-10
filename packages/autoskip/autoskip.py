# !/usr/bin/env python3

import sys
import os
import re
import argparse
from typing import Optional, List
import dbus
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

try:
    import tomllib
except ModuleNotFoundError:  # Python < 3.11
    import tomli as tomllib

DBusGMainLoop(set_as_default=True)


class MPRISAutoSkip:
    def __init__(
        self,
        title_words: List[str],
        artist_words: List[str],
        case_sensitive: bool = False,
    ):
        self.bus = dbus.SessionBus()
        self.players: dict = {}
        self.title_words = title_words
        self.artist_words = artist_words
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

    def get_track_artist(self, metadata: dict) -> Optional[str]:
        if "xesam:artist" not in metadata:
            return None
        artists = metadata["xesam:artist"]
        if isinstance(artists, (list, tuple)):
            names = [str(a) for a in artists if str(a)]
            return ", ".join(names) if names else None
        return str(artists) or None

    def should_skip(
        self, title: Optional[str], artist: Optional[str]
    ) -> bool:
        flags = 0 if self.case_sensitive else re.IGNORECASE
        for word in self.title_words:
            if title and re.search(rf"\b{re.escape(word)}\b", title, flags):
                return True
        for word in self.artist_words:
            if artist and re.search(rf"\b{re.escape(word)}\b", artist, flags):
                return True
        return False

    def describe_track(self, title: str, artist: Optional[str]) -> str:
        return f"{artist} - {title}" if artist else title

    def check_current_track(self, bus_name: str):
        metadata = self.get_metadata(bus_name)
        title = self.get_track_title(metadata)
        artist = self.get_track_artist(metadata)

        if title:
            print(self.describe_track(title, artist))
            if self.should_skip(title, artist):
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
            artist = self.get_track_artist(metadata)

            if title:
                print(self.describe_track(title, artist))
                if self.should_skip(title, artist):
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


def xdg_config_paths() -> List[str]:
    base = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    return [
        os.path.join(base, "autoskip", "config.toml"),
        os.path.join(base, "autoskip.toml"),
    ]


def load_config(path: str) -> dict:
    with open(path, "rb") as f:
        try:
            return tomllib.load(f)
        except tomllib.TOMLDecodeError as e:
            raise SystemExit(f"[Error] Invalid TOML in {path}: {e}") from e


def word_list(value, key: str, path: str) -> List[str]:
    if not isinstance(value, list) or not all(
        isinstance(word, str) for word in value
    ):
        raise SystemExit(
            f"[Error] {path}: '{key}' must be a list of strings"
        )
    return [word for word in value]


def read_config(path: str) -> dict:
    cfg = load_config(path)
    if not isinstance(cfg, dict):
        raise SystemExit(f"[Error] {path}: top level must be a TOML table")
    return cfg


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Auto-skip tracks whose title or artist matches configured "
            "words; words may come from the command line and a TOML config"
        )
    )
    parser.add_argument(
        "words",
        nargs="*",
        help="Words to skip in the track title (e.g. remix cover live)",
    )
    parser.add_argument(
        "-t",
        "--title-words",
        nargs="+",
        metavar="WORD",
        help="Additional words to skip in the track title",
    )
    parser.add_argument(
        "-a",
        "--artist-words",
        nargs="+",
        metavar="WORD",
        help="Words to skip in the artist name",
    )
    parser.add_argument(
        "--config",
        metavar="PATH",
        help=(
            "TOML config file to merge with command-line words "
            "(default: $XDG_CONFIG_HOME/autoskip/config.toml, "
            "falling back to $XDG_CONFIG_HOME/autoskip.toml)"
        ),
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
        help="Show effective skip words and exit",
    )

    args = parser.parse_args()

    config_path = None
    if args.config:
        if not os.path.isfile(args.config):
            parser.error(f"config file not found: {args.config}")
        config_path = args.config
    else:
        for candidate in xdg_config_paths():
            if os.path.isfile(candidate):
                config_path = candidate
                break

    cfg = read_config(config_path) if config_path else {}

    title_words = list(args.words) + list(args.title_words or [])
    artist_words = list(args.artist_words or [])
    case_sensitive = args.case_sensitive

    if config_path:
        if "title_words" in cfg:
            title_words += word_list(
                cfg["title_words"], "title_words", config_path
            )
        elif "skip_words" in cfg:
            title_words += word_list(
                cfg["skip_words"], "skip_words", config_path
            )
        if "artist_words" in cfg:
            artist_words += word_list(
                cfg["artist_words"], "artist_words", config_path
            )
        if "case_sensitive" in cfg:
            if not isinstance(cfg["case_sensitive"], bool):
                raise SystemExit(
                    f"[Error] {config_path}: 'case_sensitive' must be "
                    "true or false"
                )
            case_sensitive = case_sensitive or cfg["case_sensitive"]

    if args.list:
        print(f"Config:       {config_path or '(none)'}")
        print(f"Title words:  {', '.join(title_words) or '(none)'}")
        print(f"Artist words: {', '.join(artist_words) or '(none)'}")
        print(
            f"Case:         {'sensitive' if case_sensitive else 'insensitive'}"
        )
        return

    if not title_words and not artist_words:
        parser.error(
            "no skip words given; pass words or create a config in "
            "$XDG_CONFIG_HOME/autoskip/"
        )

    if config_path:
        print(f"[Config] {config_path}", file=sys.stderr)
    print(
        f"[Words] title: {len(title_words)}, artist: {len(artist_words)}",
        file=sys.stderr,
    )

    autoskip = MPRISAutoSkip(
        title_words=title_words,
        artist_words=artist_words,
        case_sensitive=case_sensitive,
    )
    autoskip.run()


if __name__ == "__main__":
    main()
