import tensorflow as tf
import numpy as np
import pickle
from multiprocessing import Lock
lock = Lock()

# ddf = dd.read_hdf(file_path, 'df', lock=lock)

# model folder numbers
# Michael : 0
# Jesse : 1
numbots = 2


# Load in data structures
# with open("chat/data/wordList_0.txt", "rb") as fp:
#     wordList = pickle.load(fp)
# wordList.append('<pad>')
# wordList.append('<EOS>')
wordLists = []
# for i in range(numbots):
batchSize = 24
maxEncoderLength = 15
maxDecoderLength = 15

lstmUnits = 112

numLayersLSTM = 3
vocabSize = []

# Create placeholders
encoderInputs = [[tf.placeholder(tf.int32, shape=(None,)) for i in range(maxEncoderLength)]]* 2
decoderLabels = [[tf.placeholder(tf.int32, shape=(None,)) for i in range(maxDecoderLength)]]* 2
decoderInputs = [[tf.placeholder(tf.int32, shape=(None,)) for i in range(maxDecoderLength)]]* 2
feedPrevious = [tf.placeholder(tf.bool)]* 2

encoderLSTM = [tf.nn.rnn_cell.BasicLSTMCell(lstmUnits, state_is_tuple=True)]* 2
#encoderLSTM = tf.nn.rnn_cell.MultiRNNCell([singleCell]*numLayersLSTM, state_is_tuple=True)
decoderOutputs = []
decoderFinalState = []
decoderPrediction = []
sess = []
savers = []
fp = []
for i in range(numbots):
    print(i)
    fp.append(open("chat/data/wordList_"+str(i)+".txt", "rb"))
    wordLists.append(pickle.load(fp[i]))

# fp2 = open("chat/data/wordList_1.txt", "rb")
# wordLists.append(pickle.load(fp2))

    wordLists[i].append('<pad>')
    wordLists[i].append('<EOS>')

# Load in hyperparamters
    vocabSize.append(len(wordLists[i]))
    decoderOutputs.append(None)
    decoderFinalState.append(None)
    decoderOutputs[i], decoderFinalState[i] = tf.contrib.legacy_seq2seq.embedding_rnn_seq2seq(encoderInputs[i], decoderInputs[i], encoderLSTM[i], vocabSize[i], vocabSize[i], lstmUnits, feed_previous=feedPrevious[i])
    # decoderOutputs.append(decodeOut)
    # decoderFinalState.append(decodeFinal)
    decoderPrediction.append(tf.argmax(decoderOutputs[i], 2))

    sess.append(tf.Session())
#y, variables = model.getModel(encoderInputs, decoderLabels, decoderInputs, feedPrevious)

# Load in pretrained model
# saver = tf.train.Saver()
# Turned saver into a list to hold savers of multiple models

    savers.append(tf.train.Saver())
    savers[i].restore(sess[i], tf.train.latest_checkpoint('chat/models/'+str(i)))
    fp[i].close()

    zeroVector = np.zeros((1), dtype='int32')




def getTestInput(inputMessage, wList, maxLen):
	encoderMessage = np.full((maxLen), wList.index('<pad>'), dtype='int32')
	inputSplit = inputMessage.lower().split()
	for index,word in enumerate(inputSplit):
		try:
			encoderMessage[index] = wList.index(word)
		except ValueError:
			continue
	encoderMessage[index + 1] = wList.index('<EOS>')
	encoderMessage = encoderMessage[::-1]
	encoderMessageList=[]
	for num in encoderMessage:
		encoderMessageList.append([num])
	return encoderMessageList

def idsToSentence(ids, wList):
    EOStokenIndex = wList.index('<EOS>')
    padTokenIndex = wList.index('<pad>')
    myStr = ""
    listOfResponses=[]
    for num in ids:
        if (num[0] == EOStokenIndex or num[0] == padTokenIndex):
            listOfResponses.append(myStr)
            myStr = ""
        else:
            myStr = myStr + wList[num[0]] + " "
    if myStr:
        listOfResponses.append(myStr)
    listOfResponses = [i for i in listOfResponses if i]
    listOfResponses = list(set(listOfResponses))
    #chosenString = ''.join(listOfResponses)
    chosenString = listOfResponses[0]
    #chosenString = max(listOfResponses, key=len)
    return chosenString

def pred(inputString, botId):
    inputVector = getTestInput(inputString, wordLists[botId], maxEncoderLength)
    feedDict = {encoderInputs[t]: inputVector[t] for t in range(maxEncoderLength)}
    feedDict.update({decoderLabels[t]: zeroVector for t in range(maxDecoderLength)})
    feedDict.update({decoderInputs[t]: zeroVector for t in range(maxDecoderLength)})
    feedDict.update({feedPrevious: True})
    ids = (sess[botId].run(decoderPrediction[botId], feed_dict=feedDict))
    return idsToSentence(ids, wordLists[botId])

# def prediction(msg):
# 	response = pred(m)
