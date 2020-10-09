from flask import Flask , request , jsonify
import requests
import json

app = Flask(__name__)


@app.route('/',methods=['GET'])
def API():
    if request.method == 'GET':
        uri = 'https://api.spoonacular.com/recipes/complexSearch?apiKey=912ea99860d24fe7a3373136214a0f3d'

        query = str(request.args['query'])
        print(query)
        if " " in query:
            query = str(query).replace(" ","+")
        else:
            pass

        search = '&query=' + query
        ready_uri = uri + search
        print(ready_uri)
        content = requests.get(ready_uri).content
        jsn_ret = json.loads(content)
        return jsonify(jsn_ret)


if __name__ == '__main__':
    app.run()
