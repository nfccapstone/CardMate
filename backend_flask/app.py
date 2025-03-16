from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, Flask on EC2! new code new flask new ddddflaks flnew !"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
