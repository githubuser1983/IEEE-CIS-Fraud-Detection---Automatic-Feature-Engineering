#!/usr/bin/python3
import os,csv,re,math,random
from scipy.spatial import distance

from bourgain import BourgainEmbedding as BE

nFeat = 20
nCat = 7
numFeat = range(2+nFeat,2+nFeat+nCat)
catFeat = range(2,2+nCat)
classFeat = 1

f = open("dist-class.csv","w")
cw = csv.writer(f,dialect=csv.excel)

PREDICT = { 'pr': 0}

def jaccardDist(set1,set2):
    return 1-len(set1.intersection(set2))/(len(set1.union(set2)))*1.0

def dist(prod1,prod2):
    vec1 = [ float(prod1[i]) for i in numFeat]
    vec2 = [ float(prod2[i]) for i in numFeat]
    ds = [1-(prod1[cf]==prod2[cf]) for cf in catFeat]
    ds.extend([ abs(vec1[i]-vec2[i]) for i in range(len(vec1))])
    d = math.sqrt(sum([dd**2 for dd in ds]))
    row = [ 1-(prod1[0]==prod2[0])]
    row.extend( ds )
    if PREDICT['pr'] == 1:
        cw.writerow(row)
    return d
    #return dj
    #return max(ds)

filename = "./tt1000.csv"

def main():
    csvFile = open(filename,"r")
    csvReader = csv.reader(csvFile,dialect=csv.excel)
    newFile = open("./tt1000-50-features.csv","w")
    newCW = csv.writer(newFile,dialect=csv.excel)
    N0 = 30
    N1 = 30
    N = N0+N1
    lines = []
    count1 = 0
    count0 = 0
    for line in csvReader:
        lines.append(line)

    random.seed(12345)
    randomsubset = random.sample(lines,len(lines))
    rndSbSt = []
    for line in randomsubset:
        if count0 < N0 and line[0]=='0':
            count0 +=1
            rndSbSt.append(line)
        if count1 < N1 and line[0]=='1':
            count1 +=1
            rndSbSt.append(line)

    print(len(rndSbSt))   
    csvFile.close()

    be = BE(dist)
    PREDICT['pr'] = 0
    featureVectors = be.fit(rndSbSt,verbose=True)
    PREDICT['pr'] = 1
    featureVectors = be.predict(lines,verbose=True)
    for i in range(len(lines)):
        fv = featureVectors[i]
        fv.insert(0,lines[i][1]) # classFeature (T,0,1)
        fv.insert(0,lines[i][0]) # isFraud (0,1)
        print(fv)
        newCW.writerow(fv)
    newFile.close()
    f.close()

if __name__ == '__main__':
    main()