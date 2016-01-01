require 'open-uri'
require 'cinch'
require 'json'
require 'yaml'

class Yourls
  #automaticly shorten URLS with the nerderrhein yourls
  include Cinch::Plugin
  listen_to :channel

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

class Moin
  include Cinch::Plugin

  set :prefix, /^/
  match "moin"

  def execute(m)
    m.reply "moin #{m.user.nick}"
  end
end

class Seen
  class SeenStruct < Struct.new(:who, :where, :what, :time)
    def to_s
      "[#{time.asctime}] #{who} was seen in #{where} saying #{what}"
    end
  end

  include Cinch::Plugin
  listen_to :channel
  match /seen (.+)/

  def initialize(*args)
    super
    @users = {}
  end

  def listen(m)
    @users[m.user.nick] = SeenStruct.new(m.user, m.channel, m.message, Time.now)
  end

  def execute(m, nick)
    if nick == @bot.nick
      m.reply "That's me!"
    elsif nick == m.user.nick
      m.reply "That's you!"
    elsif @users.key?(nick)
      m.reply @users[nick].to_s
    else
      m.reply "I haven't seen #{nick}"
    end
  end
end

puts @server

bot = Cinch::Bot.new do
  configure do |c|
    config = YAML.load_file("config.yml")
    config["config"].each { |key, value| instance_variable_set("@#{key}", value) }

    c.server   = @server
    c.nick     = @nick
    c.password = @password
    c.channels = ["#nerderrhein"]
    c.plugins.plugins = [Yourls, Moin, Seen]

    c.plugins.options[Yourls] = {
     :yourlsserver => @yourlsserver,
     :yourlssig => @yourlssig
   }
  end
end

bot.start
