class NoopDownloadStrategy < AbstractDownloadStrategy
  def cached_location
    Pathname "#{HOMEBREW_PREFIX}"
  end
end

class Supervisor < Formula
  url "https://github.com/ento/homebrew-daemons/blob/master/supervisor.rb", :using => NoopDownloadStrategy
  version "1.0.0"
  
  option "with-config=", "Path to your custom supervisord.conf"

  def default_conf_path
    share / 'supervisord.conf'
  end

  def install
    if default_conf_path == conf_path
      begin
        default_conf = `echo_supervisord_conf`
        default_conf_path.write default_conf
        ohai "Default configuration available at #{default_conf_path}"
      rescue Errno::ENOENT => e
        opoo "echo_supervisord_conf not found, not writing default config file. Specify --env=std to disable superenv."
      end
    end
  end
  
  def conf_path
    ARGV.value("with-config") || default_conf_path
  end
  
  def plist; <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>Label</key>
    <string>#{plist_name}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/supervisord</string>
        <string>-n</string>
        <string>-c</string>
        <string>#{conf_path}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOS
  end

  def startup_plist
    plist_path
  end
end
