class Dbus < Formula
  # releases: even (1.12.x) = stable, odd (1.13.x) = development
  desc "Message bus system, providing inter-application communication"
  homepage "https://wiki.freedesktop.org/www/Software/dbus"
  url "https://dbus.freedesktop.org/releases/dbus/dbus-1.15.6.tar.xz"
  sha256 "f97f5845f9c4a5a1fb3df67dfa9e16b5a3fd545d348d6dc850cb7ccc9942bd8c"
  license any_of: ["AFL-2.1", "GPL-2.0-or-later"]

  livecheck do
    url "https://dbus.freedesktop.org/releases/dbus/"
    regex(/href=.*?dbus[._-]v?(\d+\.\d*?[02468](?:\.\d+)*)\.t/i)
  end

  head do
    url "https://gitlab.freedesktop.org/dbus/dbus.git"

    depends_on "autoconf" => :build
    depends_on "autoconf-archive" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "xmlto" => :build

  uses_from_macos "expat"

  def install
    # Fix the TMPDIR to one D-Bus doesn't reject due to odd symbols
    ENV["TMPDIR"] = "/tmp"
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    system "./autogen.sh", "--no-configure" if build.head?

    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--localstatedir=#{var}",
      "--sysconfdir=#{etc}",
      "--enable-xml-docs",
      "--disable-doxygen-docs",
      "--without-x",
      "--disable-tests",
      "--disable-launchd",
      "--with-dbus-user=root",
      "--with-system-pid-file=/var/run/dbus.pid",
    ]

    system "./configure", *args
    system "make", "install"
    system "rm", "-f", "#{etc}/dbus-1/session.conf"
    system "rm", "-f", "#{etc}/dbus-1/system.conf"
    system "mkdir", "-p", "#{etc}/dbus-1/system.d"
  end

  service do
    run [opt_bin/"dbus-daemon", "--nofork", "--system"]
    require_root true
    keep_alive true
    environment_variables PATH: std_service_path_env
  end

  def post_install
    # Generate D-Bus's UUID for this machine
    system "#{bin}/dbus-uuidgen", "--ensure=#{var}/lib/dbus/machine-id"
  end

  test do
    system "#{bin}/dbus-daemon", "--version"
  end
end
