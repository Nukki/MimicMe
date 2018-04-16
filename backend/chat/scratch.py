import numpy as np
import pickle
import tensorflow as tf
import model




def main():
    talk = True
    while (talk):
        message = input("Say something: ")
        print(model.prediction(message))
        message2 = input("say something else? (y/n)")
        if (message2 == 'n'):
            talk = False

if __name__ == '__main__':
    main()
