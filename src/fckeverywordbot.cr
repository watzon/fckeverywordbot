require "tasker"
require "tourmaline"

# Channel ID for @fckeveryword
CHANNEL_ID = -1001494061362

# WORDS = File.read_lines("src/words.txt")
WORDS = {{ read_file("src/words.txt") }}.split('\n')

HELP_MESSAGE = <<-MARKDOWN
Welcome! This bot is majorly inspired by [@fckeveryword](https://twitter.com/fckeveryword) on Twitter \
and is directly connected to the Telegram channel @fckeveryword. Our goal is to fuck every word in the \
English language, or at least the 479k words we have at our disposal. This project is written in Crystal \
and available on Github at [watzon/fckeverywordbot](https://github.com/watzon/fckeverywordbot).

Made with ❤️ by @watzon.
MARKDOWN

# TODO: Write documentation for `Fckeverywordbot`
class Fckeverywordbot < Tourmaline::Client
  @[Command(["start", "help"], private_only: true)]
  def start_command(ctx)
    ctx.reply(HELP_MESSAGE, parse_mode: :markdown)
  end

  @[Command("random")]
  def random_word(ctx)
    count = (ctx.text.split(/\s+/).first.to_i? || 1).clamp(1, 100)
    word = WORDS.sample(count)
    ctx.reply(word.join("\n"))
  end

  {% if flag? :debug %}
  @[On(:message)]
  def on_message(ctx)
    pp ctx.update
    puts
  end
  {% end %}

  def send_next_word
    # Create the word_index file if it doesn't exist
    # TODO: Replace with SQLite
    unless ::File.file?("word_index.txt")
      ::File.write("word_index.txt", "0")
    end

    last_index = ::File.read("word_index.txt").to_i
    next_index = last_index + 1

    word = WORDS[next_index]
    send_message(CHANNEL_ID, "fuck #{word}")

    ::File.write("word_index.txt", next_index.to_s, mode: "w")
  end
end

bot = Fckeverywordbot.new(ENV["API_KEY"])

schedule = Tasker.instance
schedule.every(5.minutes) { bot.send_next_word }

bot.poll
