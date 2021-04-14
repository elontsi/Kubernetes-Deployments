from flask import Flask, jsonify

app = Flask(__name__)
@app.route('/<string:name>/')

def hello(name):
    return jsonify (Response = "Hello, " + name)

if __name__ == '__main__':
#    context = ( '/var/www/FlaskApp/webapp-cert.pem', '/var/www/FlaskApp/webapp-key.pem')
    context = ('webapp-cert.pem', 'webapp-key.pem')
    app.run(host='0.0.0.0', debug=True, ssl_context=context)
#    app.run(host='0.0.0.0', debug=True)
