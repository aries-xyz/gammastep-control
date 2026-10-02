#!/bin/sh
# Instala gammastep-control en ~/.local (o en $PREFIX) sin sudo.
set -eu

SRC_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PREFIX=${PREFIX:-"$HOME/.local"}
BIN_DIR="$PREFIX/bin"
APPS_DIR="$PREFIX/share/applications"

command -v gammastep >/dev/null 2>&1 || {
	echo "Error: no se encontró el ejecutable 'gammastep'." >&2
	exit 1
}

python3 - <<'EOF' || exit 1
import sys
try:
    import gi
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk  # noqa: F401
except (ImportError, ValueError) as error:
    sys.exit("Error: falta PyGObject con GTK 3 ({})".format(error))
EOF

install -d "$BIN_DIR" "$APPS_DIR"
install -m 0755 "$SRC_DIR/gammastep-control" "$BIN_DIR/gammastep-control"
sed "s|@EXEC@|$BIN_DIR/gammastep-control|" \
	"$SRC_DIR/gammastep-control.desktop" > "$APPS_DIR/gammastep-control.desktop"

if command -v update-desktop-database >/dev/null 2>&1; then
	update-desktop-database "$APPS_DIR" >/dev/null 2>&1 || true
fi

echo "Instalado en $BIN_DIR/gammastep-control"
echo "Búscalo en el menú de aplicaciones como 'Luz cálida (Gammastep)'."