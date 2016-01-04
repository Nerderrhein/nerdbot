class Cinch::Moin
  include Cinch::Plugin

  set :prefix, /^/
  match "moin"

  set :help, <<-EOF
moin
  Response on a single, lowercase moin in the channel with a moin.
   EOF

  def execute(m)
    m.reply "moin #{m.user.nick}"
  end
end
