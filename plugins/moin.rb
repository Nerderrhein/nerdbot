class Cinch::Moin
  include Cinch::Plugin

  set :prefix, /^/
  match "moin"

  def execute(m)
    m.reply "moin #{m.user.nick}"
  end
end
