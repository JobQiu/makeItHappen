#!/usr/bin/python

import sys
import os    
import re
import datetime
from datetime import timedelta
import urllib2
import urllib


now = datetime.datetime.now()
 
#%%
print 'Number of arguments:' , len(sys.argv), 'arguments.'
print 'Argument List: ', str(sys.argv)


#%%
URL = "http://localhost:8081"
yesterday = now - timedelta(1)
if sys.argv == None or len(sys.argv)==0 or sys.argv[1] == 'll':
    userId = 1
    token = "05c99a65-6c8e-4944-8cc2-7df534687bfb"
    location = "/Users/xavier.qiu/Documents/keylogger/Data/Key/"
else:
    location = sys.argv[1]
    userId = (int)(sys.argv[2])
    token = sys.argv[3]    
def removeYesterdayFolder():
    top = location + (str)(yesterday.day)+"-"+(str)(yesterday.month)+"-"+(str)(yesterday.year)
    for root, dirs, files in os.walk(top, topdown=False):
        for name in files:
            os.remove (os.path.join(root,name))
        for name in dirs:
            os.remove (os.path.join(root,name))
removeYesterdayFolder()

location = location +(str)(now.day)+"-"+(str)(now.month)+"-"+(str)(now.year)


def sendProblem(problem):
    params = urllib.urlencode({'q':problem, 'userId': (str)(userId),'token':token})
    contents = urllib2.urlopen(URL+'/api/addQ?' + params)
    return contents

def sendTodo(todo):
    params = urllib.urlencode({'todo':todo, 'userId': (str)(userId),'token':token})
    contents = urllib2.urlopen(URL+'/api/addT?' + params)
    return contents

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
    count = 0
    while(line.find("\DELETE")!=-1):
        index_ = line.find("\DELETE")
        line = line[:index_-1]+line[index_+17:]
        count += 1
        if count > 10:
            break
    return line

def removeOthers(line):
    line = line.replace("\RCMD(","\LCMD(")
    return line.replace("\ESCAPE","").replace("\RCMD(","\LCMD(").replace("\RIGHTARROW","").replace("\LEFTARROW","").replace("\LCMD(v)","").replace("\LCMD(c)","").replace("\LCMD(x)","").replace("\LCMD(z)","").replace("\LCMD(s)","").replace("\LCMD()","").replace("\n","").replace("\LCMD(","")

def getProblemsFromLine(line):
    result = set()
    lines = re.split("\.|!",line)
    for l in lines:
        count = 0
        while(l.find('?')!=-1):
            index_ = l.find('?')
            result.add(l[:index_+1].strip())
            l = l[index_+1:]
            count += 1
            if count > 15:
                break
    return result

def readFilePringProblems(path):
    result = set()
    with open(path) as fp:
        for line in fp:
            if questionSymbol in line:
                print "origianl:"+line
                shifted = dealWithShift(line)
                shifted= removeOthers(shifted)
                backspaced = dealWithBackSpace(shifted)
                print "after:" + backspaced
                temp = getProblemsFromLine(backspaced)
                result = result.union(temp)
            if "?" in line:
                print "origianl:"+line
                shifted = dealWithShift(line)
                shifted= removeOthers(shifted)
                backspaced = dealWithBackSpace(shifted)
                print "after:" + backspaced
                result = result.union(getProblemsFromLine(backspaced))
            
    result.discard("?")
    return result

#%%
for file_ in files:
    print file_
    if file_ =="python":
        continue
    problems = readFilePringProblems(location+"/"+file_)
    for p in problems:
        sendProblem(p)


print "done"

#%%
#testLine="\RS(erg/)\RS(fewg.)\RS(gweg,)\RS(;'gewgew[]\=-)\LS(09876gfeg54321`)this is a test"
#testLine="qqqqqqqq\DELETE|BACKSPACE\DELETE|BACKSPACEqqqqqqq\DELETE|BACKSPACE\DELETE|BACKSPACE"
#print dealWithShift(testLine)
#print dealWithBackSpace(testLine)