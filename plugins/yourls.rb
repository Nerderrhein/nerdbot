class Cinch::Yourls
  #automaticly shorten URLS with the nerderrhein yourls
  include Cinch::Plugin
  listen_to :channel

  set :help, <<-EOF
http[s]://...
  Automaticly shortens all links with a custom yourls installation that are posted in the channel.
   EOF

  def shorten(url)
    url = open("http://#{config[:yourlsserver]}/yourls-api.php?signature=#{config[:yourlssig]}&action=shorturl&format=json&url=#{URI.escape(url)}").read
    url == "Error" ? nil : url
    url_hash = JSON.parse(url)
    url_hash["shorturl"] + " : " + url_hash["title"]
  rescue OpenURI::HTTPError
    nil
  end

  def listen(m)
    urls = URI.extract(m.message, ['https', 'http'])
    short_urls = urls.map { |url| shorten(url) }.compact
    unless short_urls.empty?
      m.reply short_urls.join(", ")
    end
  end
end
