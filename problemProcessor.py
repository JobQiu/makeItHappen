#!/usr/bin/python

import sys
import os    
import requests
import re
 
#%%
print 'Number of arguments:' , len(sys.argv), 'arguments.'
print 'Argument List: ', str(sys.argv)

location = sys.argv[1]
userId = sys.argv[2]
token = sys.argv[3]
#%%
location = "/Users/xavier.qiu/Documents/keylogger/Data/Key/12-6-2018"
print location
userId = 1
token = "05c99a65-6c8e-4944-8cc2-7df534687bfb"
URL = "http://localhost:8081"


def sendProblem(problem):
    PARAMS = {'q':problem, 
              'userId':userId, 
              'token':token}
    r = requests.get(url = URL+"/api/addQ", params = PARAMS)     
    # extracting data in json format
    data = r.json()
    return data
#%%
questionSymbol = "\RS(/)"

files = os.listdir(location)
def replaceWithShiftValue(beforeShift):
    return beforeShift.strip().replace(",","<").replace(".",">").replace("/","?").replace(";",":").replace("'","\"").replace("[","{").replace("]","}").replace("\\",'|').replace("=","+").replace("-","_").replace("0",")").replace("9","(").replace("8","*").replace("7","&").replace("6","^").replace("5","%").replace("4","$").replace("3","#").replace("2","@").replace("1","!").replace("`","~").upper()

def dealWithShift(line):
    testLine = line.replace("\LS","\RS")
    testLines = testLine.split("\RS(")
    result = testLines[0]
    for i in range(1,len(testLines)):
        lineSubStr = testLines[i]
        index_ = lineSubStr.find(')')
        
        result += replaceWithShiftValue(lineSubStr[:index_])+lineSubStr[index_+1:]
    return result

def dealWithBackSpace(line):
    while(line.find("\DELETE")!=-1):
        index_ = line.find("\DELETE")
        line = line[:index_-1]+line[index_+17:]
    return line

# todo how to deal with command c and command v?
# todo deal with arrows?
# todo deal with uncorrelerated contents?
# using the first method seems to be a more accurate way.
# select a problem and using a short cut to send them out.
def removeOthers(line):
    line = line.replace("\RCMD(","\LCMD(")
    return line.replace("\ESCAPE","").replace("\RCMD(","\LCMD(").replace("\RIGHTARROW","").replace("\LEFTARROW","").replace("\LCMD(v)","").replace("\LCMD(a)","").replace("\LCMD(c)","").replace("\LCMD(x)","").replace("\LCMD(z)","").replace("\LCMD(s)","").replace("\LCMD()","").replace("\n","").replace("\LCMD(","")

def getProblemsFromLine(line):
    result = set()
    lines = re.split("\.|!",line)
    for l in lines:
        while(l.find('?')!=-1):
            index_ = l.find('?')
            result.add(l[:index_+1].strip())
            l = l[index_+1:]
    return result

def readFilePringProblems(path):
    result = set()
    with open(path) as fp:
        for line in fp:
            if questionSymbol in line:
                shifted = dealWithShift(line)
                shifted= removeOthers(shifted)
                backspaced = dealWithBackSpace(shifted)
                result = result.union(getProblemsFromLine(backspaced))
    result.discard("?")
    for reee in result:
        print reee
for file_ in files:
    if file_ =="python":
        continue
    readFilePringProblems(location+"/"+file_)
    #readFilePringProblems(location+"/钉钉")

#%%
testLine="\RS(erg/)\RS(fewg.)\RS(gweg,)\RS(;'gewgew[]\=-)\LS(09876gfeg54321`)this is a test"
testLine="qqqqqqqq\DELETE|BACKSPACE\DELETE|BACKSPACEqqqqqqq\DELETE|BACKSPACE\DELETE|BACKSPACE"
print dealWithShift(testLine)
print dealWithBackSpace(testLine)