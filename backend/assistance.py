from flask import Flask, request, jsonify, render_template
import os
#import cv2 as cv
import pandas as pd
from tensorflow import keras
import tensorflow as tf
#import tensorflow.compat.v1.keras.backend as tb
import matplotlib.pyplot as plt
from keras.models import load_model
from skimage.transform import resize
import numpy as np

app = Flask(__name__)

THIS_FOLDER = os.path.abspath(os.path.dirname(__file__))
my_file = os.path.join(THIS_FOLDER, 'model_weight.h5')
print(my_file)

global sess
sess = tf.compat.v1.Session()
tf.compat.v1.keras.backend.set_session(sess)
global model
model = load_model(my_file)
global graph
graph = tf.compat.v1.get_default_graph()


@app.route('/predict', methods=['POST'])
def prediction():

    file = request.files['file']
    print(file)
    file.save(r'test.jpg')
    my_image = plt.imread(r'test.jpg')
    my_image_re = resize(my_image, (48, 48))

    x = np.expand_dims(my_image_re, axis=0)
    = resize(1, 48, 48, 3)
    pro = model.predict(x)
    pro = pro * 100

    mat = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',' ','']
    mat_annos = pd.DataFrame(mat)

    ll = []

    for i, mat in enumerate(list(mat_annos.iloc[:, 0])):
        element = {"mat": mat, "prob": pro[0][i]}
        ll.append(element)

    save = sorted(ll, key=lambda i: i['prob'], reverse=True)
    class1 = save[0]["mat"]
    pro = {
        "class1": save[0]["mat"],
        "prob1": save[0]["prob"],
    }
    msg = {'class': class1}
    os.remove(r'test.jpg')
    return jsonify(msg)