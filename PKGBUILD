# Maintainer: Vega Desktop (Omarchy)
# Arch PKGBUILD for Vega - Tauri + MPV desktop streaming app
pkgname=vega-desktop
pkgver=2.0.5
pkgrel=1
pkgdesc="Native desktop app for streaming media (MPV powered, ad-free) - Omarchy/Hyprland optimized"
arch=('x86_64')
url="https://github.com/vega-org/vega-desktop"
license=('MIT')
depends=(
  'webkit2gtk-4.1'
  'gtk3'
  'libsoup3'
  'mpv'
  'libmpv'
  'openssl'
  'cairo'
  'gdk-pixbuf2'
  'glib2'
  'hicolor-icon-theme'
)
makedepends=(
  'npm'
  'nodejs'
  'rust'
  'cargo'
  'base-devel'
)
optdepends=(
  'vlc: external player support'
)
source=(
  "vega-desktop-${pkgver}.tar.gz::https://github.com/vega-org/vega-desktop/archive/refs/tags/v${pkgver}.tar.gz"
  "vega.desktop"
)
sha256sums=('SKIP' 'SKIP')

build() {
  cd "vega-desktop-${pkgver}"
  # Use local omarchy desktop file if building from git checkout
  if [[ -f "$srcdir/../omarchy/desktop/vega.desktop" ]]; then
    cp "$srcdir/../omarchy/desktop/vega.desktop" ./vega.desktop
  fi
  npm ci
  npm run build
  npm run tauri -- build --config src-tauri/tauri.linux.conf.json
}

package() {
  cd "vega-desktop-${pkgver}"
  # binary
  install -Dm755 "src-tauri/target/release/vega" "$pkgdir/usr/bin/vega-desktop"
  # alternative AppImage binary name fallback
  if [[ ! -f "src-tauri/target/release/vega" && -f "src-tauri/target/release/bundle/appimage"/*.AppImage ]]; then
    install -Dm755 src-tauri/target/release/bundle/appimage/*.AppImage "$pkgdir/usr/bin/vega-desktop"
  fi
  # desktop
  install -Dm644 "omarchy/desktop/vega.desktop" "$pkgdir/usr/share/applications/vega-desktop.desktop"
  # icons
  install -Dm644 "src-tauri/icons/128x128.png" "$pkgdir/usr/share/icons/hicolor/128x128/apps/vega-desktop.png"
  install -Dm644 "src-tauri/icons/32x32.png" "$pkgdir/usr/share/icons/hicolor/32x32/apps/vega-desktop.png"
  install -Dm644 "src-tauri/icons/icon.png" "$pkgdir/usr/share/icons/hicolor/256x256/apps/vega-desktop.png"
  # hyprland example (docs)
  install -Dm644 "omarchy/hypr/vega.lua" "$pkgdir/usr/share/doc/vega-desktop/hypr-vega.lua.example"
}

# To build: makepkg -si  (in vega-desktop root with PKGBUILD)
# Or: yay -S vega-desktop (if published to AUR)
