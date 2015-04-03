logged\_connection = Faraday.new do |builder|
> builder.response :logger, Logger.new('client.log')
> builder.adapter  :net\_http
end
client.execute({
> :api\_method => plus.activities.list,
> :parameters => {'userId' => 'me', 'collection' => 'public'},
> :connection => logged\_connection
})   }}}
  * I'm getting `SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed` on Windows.
   Download http://curl.haxx.se/ca/cacert.pem and put it someplace sensible. If you used the Rails Installer project, this would typically be `C:\RailsInstaller\cacert.pem`. Then set the `SSL_CERT_FILE` environment variable (found in "Advanced Systems Settings" in the Control Panel) to the location of the root certificate file you just downloaded. Note that you'll need to restart any open terminal windows before this setting will take effect.
  * Rails 2.3.5 causes `can't activate rack` errors.
   You should update your app to Rails 2.3.14, which is the lastest 2.3.x version. Rails 2.3.5 has a dependency on an outdated version of Rack which is incompatible with the dependencies required by all recent versions of Faraday.
  * Ruby 1.8.6 doesn't work.
   The minimum supported version of Ruby is 1.8.7. Ruby 1.9.3 is strongly recommended.
  * Some dependencies don't install with versions of !RubyGems before 1.3.6.
   The minimum supported version of !RubyGems is 1.3.6. This is true of a very large number of Ruby projects at this point. Some older distributions of Linux provide only versions of !RubyGems prior to 1.3.6, making an upgrade difficult. In this case, using `rvm` is recommended.```