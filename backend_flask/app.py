from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, Flask onsss EC2! nsdaa n3ddd3ew fss11213lask new dddfd2dflaks flnew !"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
