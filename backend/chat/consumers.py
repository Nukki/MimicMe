from django.conf import settings
import numpy as np
import pickle
import tensorflow as tf
import chat.model as cm


from channels.generic.websocket import JsonWebsocketConsumer


class MyConsumer(JsonWebsocketConsumer):
    groups = ["broadcast"]

    def connect(self):
        # with open("chat/data/wordList.txt", "rb") as fp:
        #     wordList = pickle.load(fp)
        # wordList.append('<pad>')
        # wordList.append('<EOS>')
        #
        # # Load in hyperparamters
        # vocabSize = len(wordList)
        # batchSize = 24
        # maxEncoderLength = 15
        #
        # maxDecoderLength = 15
        # lstmUnits = 112 #48
        # numLayersLSTM = 3
        #
        # # Create placeholders
        # encoderInputs = [tf.placeholder(tf.int32, shape=(None,)) for i in range(maxEncoderLength)]
        # decoderLabels = [tf.placeholder(tf.int32, shape=(None,)) for i in range(maxDecoderLength)]
        # decoderInputs = [tf.placeholder(tf.int32, shape=(None,)) for i in range(maxDecoderLength)]
        # feedPrevious = tf.placeholder(tf.bool)
        #
        # encoderLSTM = tf.nn.rnn_cell.BasicLSTMCell(lstmUnits, state_is_tuple=True)
        # #encoderLSTM = tf.nn.rnn_cell.MultiRNNCell([singleCell]*numLayersLSTM, state_is_tuple=True)
        # decoderOutputs, decoderFinalState = tf.contrib.legacy_seq2seq.embedding_rnn_seq2seq(encoderInputs, decoderInputs, encoderLSTM,
        #                                                             vocabSize, vocabSize, lstmUnits, feed_previous=feedPrevious)
        #
        # decoderPrediction = tf.argmax(decoderOutputs, 2)
        #
        # # Start session and get graph
        # sess = tf.Session()
        # #y, variables = model.getModel(encoderInputs, decoderLabels, decoderInputs, feedPrevious)
        #
        # # Load in pretrained model
        # saver = tf.train.Saver()
        # saver.restore(sess, tf.train.latest_checkpoint('chat/models'))
        # zeroVector = np.zeros((1), dtype='int32')

        # Called on connection. Either call
        self.accept()
        # Or to reject the connection, call
        # self.close()


    def receive_json(self, content):
        message = content["message"]
        response =  cm.pred(str(message))
        self.send_json({
            "type": "websocket.message",
            "message" : response,
            })


    def disconnect(self, close_code):
        print('close')
        # Called when the socket closes






# Load in data structures


#    def pred(inputString):
#        inputVector = model.getTestInput(inputString, wordList, maxEncoderLength)
#        feedDict = {encoderInputs[t]: inputVector[t] for t in range(maxEncoderLength)}
#        feedDict.update({decoderLabels[t]: zeroVector for t in range(maxDecoderLength)})
#        feedDict.update({decoderInputs[t]: zeroVector for t in range(maxDecoderLength)})
#        feedDict.update({feedPrevious: True})
#        ids = (sess.run(decoderPrediction, feed_dict=feedDict))
#        return model.idsToSentence(ids, wordList)

#    def getTestInput(inputMessage, wList, maxLen):
#        encoderMessage = np.full((maxLen), wList.index('<pad>'), dtype='int32')
#        inputSplit = inputMessage.lower().split()
#        for index,word in enumerate(inputSplit):
#            try:
#                encoderMessage[index] = wList.index(word)
#            except ValueError:
#                continue
#        encoderMessage[index + 1] = wList.index('<EOS>')
#        encoderMessage = encoderMessage[::-1]
#        encoderMessageList=[]
#        for num in encoderMessage:
#            encoderMessageList.append([num])
#        return encoderMessageList

#    def idsToSentence(ids, wList):
#        EOStokenIndex = wList.index('<EOS>')
#        padTokenIndex = wList.index('<pad>')
#        myStr = ""
#        listOfResponses=[]
#        for num in ids:
#            if (num[0] == EOStokenIndex or num[0] == padTokenIndex):
#                listOfResponses.append(myStr)
#                myStr = ""
#            else:
#                myStr = myStr + wList[num[0]] + " "
#        if myStr:
#            listOfResponses.append(myStr)
#        listOfResponses = [i for i in listOfResponses if i]
#        listOfResponses = list(set(listOfResponses))
        #chosenString = max(listOfResponses, key=len)
#        return chosenString
