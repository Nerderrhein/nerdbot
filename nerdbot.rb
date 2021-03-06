require 'open-uri'
require 'cinch'
require 'json'
require 'yaml'
require_relative 'plugins/moin'
require_relative 'plugins/seen'
require_relative 'plugins/yourls'
require_relative 'plugins/channel_record'
require_relative 'plugins/help'

bot = Cinch::Bot.new do
  configure do |c|
    config = YAML.load_file("config.yml")
    config["config"].each { |key, value| instance_variable_set("@#{key}", value) }

    c.server   = @server
    c.nick     = @nick
    c.password = @password
    c.channels = ["#nerderrhein"]
    c.plugins.plugins = [Cinch::Yourls, Cinch::Moin, Cinch::Seen, Cinch::ChannelRecord, Cinch::Help]

    c.plugins.options[Cinch::Yourls] = {
     :yourlsserver => @yourlsserver,
     :yourlssig => @yourlssig
   }

    c.plugins.options[Cinch::ChannelRecord] = {
     :file => @record_file
   }
   c.plugins.options[Cinch::Seen] = {
     :file => @seen_file
   }
   c.plugins.options[Cinch::Help] = {
     :intro => "%s at your service."
   }
  end

  trap "SIGINT" do
    bot.quit
  end
end

bot.start
