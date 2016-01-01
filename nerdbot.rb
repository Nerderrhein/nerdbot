require 'open-uri'
require 'cinch'
require 'json'
require 'yaml'
require_relative 'plugins/moin'
require_relative 'plugins/seen'
require_relative 'plugins/yourls'

bot = Cinch::Bot.new do
  configure do |c|
    config = YAML.load_file("config.yml")
    config["config"].each { |key, value| instance_variable_set("@#{key}", value) }

    c.server   = @server
    c.nick     = @nick
    c.password = @password
    c.channels = ["#nerderrhein"]
    c.plugins.plugins = [Cinch::Yourls, Cinch::Moin, Cinch::Seen]

    c.plugins.options[Cinch::Yourls] = {
     :yourlsserver => @yourlsserver,
     :yourlssig => @yourlssig
   }
  end
end

bot.start
