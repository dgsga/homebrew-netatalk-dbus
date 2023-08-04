class DbusGlib < Formula
  desc "GLib bindings for the D-Bus message bus system"
  homepage "https://wiki.freedesktop.org/www/Software/DBusBindings/"
  url "https://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.112.tar.gz"
  sha256 "7d550dccdfcd286e33895501829ed971eeb65c614e73aadb4a08aeef719b143a"

  livecheck do
    url "https://dbus.freedesktop.org/releases/dbus-glib/"
    regex(/href=.*?dbus-glib[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "dgsga/netatalk-dbus/dbus"
  depends_on "gettext"
  depends_on "glib"
  
  # Patch dbus-binding-tool to fix deprecation warning on macOS
  patch do
    url "https://raw.githubusercontent.com/dgsga/homebrew-netatalk-dbus/main/binding-tool.patch"
    sha256 "96a21fd9018ef39d4cf5fef3117d543dc01cc6d586b302159dfa0f0cede6f2fd"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"dbus-binding-tool", "--help"
  end
end
