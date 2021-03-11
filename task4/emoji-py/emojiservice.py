from flask import Flask
from flask import request
import emoji
import random


app = Flask(__name__)

@app.route("/gretting")
def hello():
    return "<h1 style='color:blue'>Hello from Emoji Service!</h1>"

@app.route('/', methods=['GET', 'POST'])
def test_post():
    if request.method == 'POST':
        content = request.get_json(force=True)
        return emoji_provider(content)
    else:
        return "You use GET method!"

if __name__ == "__main__":
    app.run(host='0.0.0.0')

def emoji_provider(emoji_desc):

    name = emoji_desc['word']
    count = emoji_desc['count']
    emoji_name = ':' + name + ':'
    emoji_icon = emoji.emojize(emoji_name, use_aliases = True)
    if emoji_icon == emoji_name:
        emoji_icon = random.choice(list(emoji.EMOJI_UNICODE_ENGLISH.values()))
    if not isinstance(count, int):
        count = random.randint(1, 10)
    response_body = emoji_icon    
    for i in range(count):
        response_body += name + emoji_icon
    return response_body