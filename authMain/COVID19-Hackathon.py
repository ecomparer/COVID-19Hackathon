#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 13 10:48:48 2020

@author: mishaalkandapath
"""

from firebase import firebase
import datetime as dtt
import json
firebase = firebase.FirebaseApplication("https://hackathon-db284.firebaseio.com/")
patientDictDATES = {}
patientDictMonth = {}
patientDictMain = {}
"""
result = firebase.get("/delete","")
print(result)"""
date = int(input("Enter number of days to search from including including today: "))
adhno = int(input("Enter adhn no: "))
outputName = input("Enter output file name: ")
no = adhno
count=0
while no:
    count+=1
    no=no//10
if count!=12:
    print("incorrect Aadhar Number")
else:
    now = dtt.datetime.now()
    x = now.strftime("%Y-%m-%d %H-%M-%S")
    #print(x)
    list=x.split()
    listdate = list[0].split("-")
    listTime = list[1].split("-")
    #print(listdate,listTime)
    year = listdate[0]
    month,day = int(listdate[1]),int(listdate[2])
    #print(month,day)
    listmonths=["January","February","March","April","May","June","July","August","September","October","November","Decemeber"]
    thismonth = listmonths[month-1]
    lastmonth = listmonths[month-2]
    #print(thismonth,lastmonth)
    day31=31
    day30=30
    day29=29
    def dayfunc(monthindex,today):
        thisMonthDates = []
        lastMonthDates = []
        for i in range(date):
            diff = today -i
            if diff>0:
                thisMonthDates.append(diff)
            else:
                if monthindex in [0,2,4,6,7,9,11]:
                    global day31
                    global day30
                    global day29
                    day31+=diff
                    lastMonthDates.append(day31)
                elif monthindex == 1:
                    day29+=diff
                else:
                    day30+=diff
                    lastMonthDates.append(day30)
           # print(thisMonthDates,lastMonthDates)
        return [thisMonthDates,lastMonthDates]
    
    #print(dayfunc(month-1,day))
    listDays = dayfunc(month-1,day)
    listThisMonth = listDays[0]
    listLastMonth = listDays[1]
    placesDict = firebase.get("/Places","")
    exit1=1
    entry1=1
    
    #person data initialisation starts here
    patientPlaces = {}
    patientThisMonth = {}
    patientThisMonth[thismonth]=""
    patientLastMonth = {}
    patientLastMonth[lastmonth]=""
    patientDatesThisMonth = {}
    for i in listThisMonth:
        i=str(i)
        patientDatesThisMonth[i] = ""
    #print(patientDatesThisMonth)
    patientDatesLastMonth = {}
    for i in listLastMonth:
        i=str(i)
        patientDatesLastMonth[i] = ""
    #print(patientDatesLastMonth)
    patientExitEntry = {"exit":1,"entry":1,"diff":1}
    #persondata initialisation stops here
    
    #print(placesDict)
    for place in placesDict:
        datesDict = placesDict[place]
       # print(datesDict)
        for date in datesDict:
            realDate=date.split("-")
            #print(realDate)
            if int(realDate[0]) == month and int(realDate[1]) in listThisMonth:
               # print("yes this months")
                peopleDict = datesDict[date]
                #print(peopleDict)
                for person in peopleDict:
                    #print(peopleDict[person])
                    if int(person) == adhno:
                       # print(person)
                        stagesDict = peopleDict[person]
                        entry1 = stagesDict["entry"]
                        exit1 = stagesDict["exit"]
                        #print(entry1,exit1)
                        patientExitEntry["entry"] = entry1
                        patientExitEntry["exit"] = exit1
                        patientExitEntry["diff"] = float(exit1)-float(entry1)
                        realDate = int(realDate[1])
                        realDate = str(realDate)
                        patientDatesThisMonth[realDate]= patientExitEntry
                        patientThisMonth[thismonth] = patientDatesThisMonth
                        patientPlaces[place]=[patientThisMonth,patientLastMonth]
                        #print(patientPlaces)
                        
            elif int(realDate[0]) == month-1 and int(realDate[1]) in listLastMonth:
                #print("yes last month")
                peopleDict = datesDict[date]
                #print(peopleDict)
                for person in peopleDict:
                    #print(peopleDict[person])
                    if int(person) == adhno:
                       # print("in")
                        stagesDict = peopleDict[person]
                        #print(stagesDict)
                        entry1 = stagesDict["entry"]
                        exit1 = stagesDict["exit"]
                        #print(exit1,entry1)
                        patientExitEntry["entry"] = entry1
                        patientExitEntry["exit"] = exit1
                        realDate = int(realDate[1])
                        realDate = str(realDate)
                        patientDatesLastMonth = patientExitEntry
                        patientLastMonth[thismonth] = patientDatesLastMonth
                        patientPlaces[place]=[patientThisMonth,patientLastMonth]
                        #print(patientPlaces)
    placesVisited = []
    for i in patientPlaces.keys():
        placesVisited.append(i)
            
    print("person visited: ",placesVisited)
    #obtaining person info finished
    #now gonna check for others in same place while he was there
    placesVisited = patientPlaces.keys()
    potentialPeopleList = []
    for place in patientPlaces:
        validDatesDict = placesDict[place]
        for date in validDatesDict:
            realDate=date.split("-")
           # print(realDate)
            if int(realDate[0])==month and int(realDate[1]) in listThisMonth:
                #valid date for this month
                """dateToCheck = int(realDate[1])
                dateToCheck = str(dateToCheck)"""
                dateToCheck = str(int(realDate[1]))
                peopleDict = validDatesDict[date]
                for person in peopleDict:
                    if int(person) != adhno:
                        #print("in")
                        stagesDict = peopleDict[person]
                        entryP = stagesDict["entry"]
                        exitP = stagesDict["exit"]
                        """print("checkfromnow")
                        print(patientPlaces[place][0][thismonth][dateToCheck]["exit"])"""
                        print("datetocheck ",dateToCheck)
                        print(patientPlaces[place][0][thismonth])
                        refExit=patientPlaces[place][0][thismonth][dateToCheck]["exit"]
                        refEntry = patientPlaces[place][0][thismonth][dateToCheck]["entry"]
                        if float(exitP)>refEntry or float(entryP)<refExit:
                            potentialPeopleList.append(person)
            elif int(realDate[0]) == month-1 and int(realDate[1]) in listLastMonth:
                #valid date for las month
                dateToCheck = int(realDate[1])
                dateToCheck = str(dateToCheck)
                peopleDict = validDatesDict[date]
                for person in peopleDict:
                    if int(person) != adhno:
                        #print("in")
                        stagesDict = peopleDict[person]
                        entryP = stagesDict["entry"]
                        exitP = stagesDict["exit"]
                        refExit=patientPlaces[place][lastmonth][dateToCheck]["exit"]
                        refEntry = patientPlaces[place][lastmonth][dateToCheck]["entry"]
                        if exitP>refEntry or entryP<refExit:
                            potentialPeopleList.append(person)

                
            
    print("potentially infected people",potentialPeopleList)

    with open(outputName,"a") as outf:
        for person in potentialPeopleList:
            rec = str(person)+"\n"
            outf.write(rec)
