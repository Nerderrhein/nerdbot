# -*- coding: utf-8 -*-
#
# = Cinch Seen plugin
#
# == Configuration
# Add the following to your bot’s configure.do stanza:
#
#   config.plugins.options[Cinch::History] = {
#     :file => "/var/cache/seenlog.dat"
#   }
#
# [file]
#   Where to store the message log. This is a required
#   argument.
#
# == Author
# Marvin Gülker (Quintus)
#
# == License
# An seen info plugin for Cinch.
# Copyright © 2014 Marvin Gülker
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Cinch::Seen
  require 'daybreak'
  include Cinch::Plugin

  SeenInfo = Struct.new(:time, :nick, :message)

  match /seen (.*)/
  listen_to :connect, :method => :on_connect
  listen_to :channel, :method => :on_channel

  set :help, <<-EOF
!seen nick
  Response with the last time and messsage the nick send in the channel.
   EOF

  def on_connect(*)
    @db = Daybreak::DB.new config[:file] || raise("Missing required argument: :file")

    at_exit{@db.close}
  end

  def on_channel(msg)
    return if msg.message.start_with?("\u0001") # ACTION

    @db.synchronize do
      @db[msg.user.nick] = "#{msg.time.to_i}\0#{msg.message.strip}"
    end
    @db.compact
    @db.flush
  end

  def execute(msg, nick)
    if nick == bot.nick
      msg.reply "Self-reference err err tilt BOOOOM"
      return
    end

    if nick == msg.user.nick
      msg.reply "That's you!"
      return
    end

    if info = find_last_message(nick)
      msg.reply("I have last seen #{nick} on #{info.time} saying: #{info.message}")
    else
      msg.reply("I have not yet seen #{nick} saying something.")
    end
  end

  private

  def find_last_message(nick)
    @db.load
    @db.synchronize do
      line = @db[nick]
      if line
        parts = line.split("\0")
        return SeenInfo.new(Time.at(parts[0].to_i), nick, parts[1])
      end
    end

    nil
  end

end
