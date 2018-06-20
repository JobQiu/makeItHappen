#!/usr/bin/python

import datetime
import os
import re
import sys
import urllib
import urllib2
from datetime import timedelta

from string import ascii_lowercase

now = datetime.datetime.now()

# %%
print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List: ', str(sys.argv)

# %%
URL = "http://localhost:8081"
yesterday = now - timedelta(1)
test = True
if test:
    userId = 1
    token = "05c99a65-6c8e-4944-8cc2-7df534687bfb"
    location = "/Users/xavier.qiu/Documents/keylogger/Data/Key/"
else:
    location = sys.argv[1]
    userId = (int)(sys.argv[2])
    token = sys.argv[3]


def removeYesterdayFolder():
    top = location + (str)(yesterday.day) + "-" + (str)(yesterday.month) + "-" + (str)(yesterday.year)
    for root, dirs, files in os.walk(top, topdown=False):
        for name in files:
            os.remove(os.path.join(root, name))
        for name in dirs:
            os.remove(os.path.join(root, name))


removeYesterdayFolder()

location = location + (str)(now.day) + "-" + (str)(now.month) + "-" + (str)(now.year)


def sendProblem(problem):
    params = urllib.urlencode({'q': problem, 'userId': (str)(userId), 'token': token})
    contents = urllib2.urlopen(URL + '/api/addQ?' + params)
    return contents


def sendTodo(todo):
    params = urllib.urlencode({'todo': todo, 'userId': (str)(userId), 'token': token})
    contents = urllib2.urlopen(URL + '/api/addT?' + params)
    return contents


files = os.listdir(location)

# %% tested in test.py
print location
shift_dict = {
    ",": "<",
    ".": ">",
    "/": "?",
    ";": ":",
    "'": "\"",
    "[": "{",
    "]": "}",
    "\\": '|',
    "=": "+",
    "-": "_",
    "0": ")",
    "9": "(",
    "8": "*",
    "7": "&",
    "6": "^",
    "5": "%",
    "4": "$",
    "3": "#",
    "2": "@",
    "1": "!",
    "`": "~"  # ,
}
"""
    "<": ",",
    ">": ".",
    "?": "/",
    ":": ";",
    "\"": "'",
    "{": "[",
    "}": "]",
    '|': "\\",
    "+": "=",
    "_": "-",
    ")": "0",
    "(": "9",
    "*": "8",
    "&": "7",
    "^": "6",
    "%": "5",
    "$": "4",
    "#": "3",
    "@": "2",
    "!": "1",
    "~": "`"
}"""

for c in ascii_lowercase:
    shift_dict.__setitem__(c, c.upper())
    # shift_dict.__setitem__(c.upper(), c)

weekday_to_string = {
    0: "Monday",
    1: "Tuesday",
    2: "Wednesday",
    3: "Thursday",
    4: "Friday",
    5: "Saturday",
    6: "Sunday",
}
month_to_string = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "June",
    7: "July",
    8: "Aug",
    9: "Sept",
    10: "Oct",
    11: "Nov",
    12: "Dec"

}

files = os.listdir(location)
filter_start = weekday_to_string.get(now.weekday()) + ", " + month_to_string.get(now.month)


def cleanLine(line):
    """
    remove space, \n etc.
    :param line:
    :return:
    """
    return line.replace("\n", "").replace("\F2", "").replace("\F3", "").replace("\F4", "") \
        .replace("\F5", "").replace("\F6", "").replace("\F7", "").replace("\F8", "") \
        .replace("\F9", "").replace("\F10", "").replace(
        "\F11", "").replace("\F12", "").replace("\F1", "").replace("\ESCAPE", "")
    strip()


def dealWithBackSpace(line):
    count = 0
    while (line.find("\DELETE") != -1):
        index_ = line.find("\DELETE")
        if index_ == 0:
            line = line[17:]
        line = line[:index_ - 1] + line[index_ + 17:]
        count += 1
        if count > 10:
            break
    return line


def getProblemsFromLine(line):
    result = set()
    lines = re.split("\.|!", line)
    for l in lines:
        count = 0
        while (l.find('?') != -1):
            index_ = l.find('?')
            temp = l[:index_ + 1].strip()
            l = l[index_ + 1:]
            if len(temp) < 255:
                result.add(temp)
            count += 1
            if count > 15:
                break
    return result


def getTodosFromLine(line):
    result = set()
    lines = line.split(".todo")
    for i in range(len(lines) - 1):
        sentences = re.split("\.|!?", lines[i])
        if len(sentences) == 1:
            result.add(sentences[0])
            continue
        todo = sentences.pop()
        if todo.strip() == "" and len(sentences >= 1):
            todo = sentences.pop()
        result.add(todo)
    return result


def replaceWithShiftValue(beforeShift):
    s = set(beforeShift)
    for c in s:
        if c in shift_dict.keys():
            beforeShift = beforeShift.replace((str)(c), shift_dict.get(c))
    return beforeShift


def dealWithShift(line):
    """

    :param line:
    :return:
    """
    testLine = line.replace("\LS", "\RS")
    testLines = testLine.split("\RS(")
    result = testLines[0]
    for i in range(1, len(testLines)):
        lineSubStr = testLines[i]
        index_ = lineSubStr.find(')')

        result += replaceWithShiftValue(lineSubStr[:index_]) + lineSubStr[index_ + 1:]
    return result


def containQuestion(line):
    if "?" in line:
        return True
    if "\RS(/)" in line:
        return True
    if "\LS(/)" in line:
        return True
    if "/" in line and "\RS(" in line:
        if "?" in dealWithShift(line):
            return True
    if "/" in line and "\LS(" in line:
        if "?" in dealWithShift(line):
            return True
    return False


def containTodo(line):
    return ".todo" in line


def removeOthers(line):
    line = line.replace("\RCMD(", "\LCMD(")
    return line.replace("\ESCAPE", "") \
        .replace("\RCMD(", "\LCMD(") \
        .replace("\RIGHTARROW", "") \
        .replace("\UPARROW", "") \
        .replace("\DOWNARROW", "") \
        .replace("\LEFTARROW", "") \
        .replace("\LCMD(v)", "") \
        .replace("\LCMD(c)", "") \
        .replace("\LCMD(x)", "") \
        .replace("\LCMD(z)", "") \
        .replace("\LCMD(s)", "") \
        .replace("\LCMD()", "") \
        .replace("\LCMD(", "") \
        .replace("\TAB", "")


def readFilePringProblems(path):
    result = set()
    todos = set()
    with open(path) as fp:

        index_ = 1

        for line in fp:
            if line.strip() == "" or line.startswith(filter_start):
                continue
            if containQuestion(line):
                print (str)(index_) + "\t" + (cleanLine(line))
                after = removeOthers(dealWithBackSpace(dealWithShift(cleanLine(line))))
                # print (str)(index_) + "\t" + after

                sss = getProblemsFromLine(after)
                for ss in sss:
                    print "\t" + ss
                index_ = index_ + 1
                result = result.union(sss)

            if containTodo(line):
                print (str)(index_) + "\t" + (cleanLine(line))
                after = removeOthers(dealWithBackSpace(dealWithShift(cleanLine(line))))
                # print (str)(index_) + "\t" + after
                sss2 = getTodosFromLine(after)
                for ss2 in sss2:
                    print "\t" + ss2
                index_ += 1
                todos = todos.union(sss2)
    return result, todos


# %%
for file_ in files:
    print file_
    if file_ == "python":
        continue
    problems, todos = readFilePringProblems(location + "/" + file_)
    for p in problems:
        sendProblem(p)
    for t in todos:
        sendTodo(t)

print "done"

# %%
# testLine="\RS(erg/)\RS(fewg.)\RS(gweg,)\RS(;'gewgew[]\=-)\LS(09876gfeg54321`)this is a test"
# testLine="qqqqqqqq\DELETE|BACKSPACE\DELETE|BACKSPACEqqqqqqq\DELETE|BACKSPACE\DELETE|BACKSPACE"
# print dealWithShift(testLine)
# print dealWithBackSpace(testLine)
