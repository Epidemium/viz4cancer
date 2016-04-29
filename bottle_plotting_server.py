# coding: utf8
# from __future__ import unicode_litterals
import bottle
from bottle import route, run, get, response
import json
from random import random

# the decorator used for cross-domain-origin
def enable_cors(fn):
    def _enable_cors(*args, **kwargs):
        # set CORS headers
        response.headers['Access-Control-Allow-Origin'] = 'http://localhost:8000'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token'
        # response.headers['Content-type'] = 'text/plain'
        if bottle.request.method != 'OPTIONS':
            # actual request; reply with the actual response
            return fn(*args, **kwargs)

    return _enable_cors

# app = bottle.app()

@get('/get_paragraph/<text>')
@enable_cors
def some_text(text):
	to_return = {
		'element_type': "p",
		'element_html': "du texte qui vient de python"
	}
	if text:
		to_return['element_html'] = text
	print('Fonction Appelee')

	response.headers['Content-type'] = 'application/json'
	return to_return

@get('/get_default_plot')
@enable_cors
def default_plot():
	n_pts = 5 + int(20*random())
	xs = [2*random() for _ in range(n_pts)]
	pente = 10*(random()-0.5)
	trace = {
		"x": xs,
		"y": [pente*x + random() for x in xs],
		"type": "scatter",
		'marker': {
			"size": [20 + 20*random() for _ in range(n_pts)]
		},
		'mode':'markers'
	}
	data = [trace]
	layout = {
		"height": 400,
		# "width": "100%",
		"margin" : {
			"t": 20,
			'b': 20
		}
	}

	to_return = {
		'data': data,
		'layout': layout
	}
	response.headers['Content-type'] = 'application/json'
	return to_return


if __name__ == "__main__":
	print('Starting Bottle Server..')
	run(host='localhost', port=8080, reloader=True)
	print('Server Closed.')


