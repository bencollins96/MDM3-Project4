#parser_sites.py
import csv
import re
from postcodes import PostCoder
import pyproj
import pandas as pd
import numpy as np
from pyproj import Proj, transform

v84 = Proj(proj="latlong",towgs84="0,0,0",ellps="WGS84")
v36 = Proj(proj="latlong", k=0.9996012717, ellps="airy",
        towgs84="446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894")
vgrid = Proj(init="world:bng")


def ENtoLL84(easting, northing):
    """Returns (longitude, latitude) tuple
    """
    vlon36, vlat36 = vgrid(easting, northing, inverse=True)
    return transform(v36, v84, vlon36, vlat36)

def LL84toEN(longitude, latitude):
    """Returns (easting, northing) tuple
    """
    vlon36, vlat36 = transform(v84, v36, longitude, latitude)
    return vgrid(vlon36, vlat36)


def get_filename(post_code):
    if post_code[:2].isalpha():
        return 'Data/' +post_code[:2].lower() + '.csv'
    else:
        return 'Data/' +post_code[0].lower() + '.csv'

filename = 'sites.csv' 

#Open the file and read out data
with open(filename, 'rb') as f:
    reader = csv.reader(f)
    name_list = []
    postcode_list = []
    for row in reader:
        pass1 = row[1].find('HOSPITAL')
        pass2 = row[1].find('DENTAL')
        pass3 = row[1].find('REHAB')
        pass4 = row[1].find('DAY')
        pass5 = row[1].find('COMMUNITY')

        if (pass1 >0):
            if pass2== -1:
                if pass3 == -1:
                    if pass4 ==-1:
                        if pass5 ==-1:
                            name_list.append(row[1].replace(',',''))
                            postcode_list.append(row[9].replace(' ',''))


print len(name_list)

            

#Here I have postcodes!
lat = []
lng = []
writefile = 'sites_Hos_dent.csv'
for i in range(len(postcode_list)):
    if postcode_list[i][:2] =='IM':
        continue
    if postcode_list[i][:2] =='JE':
        continue
    if postcode_list[i][:2] =='GY':
        continue
    df = pd.read_csv(get_filename(postcode_list[i]), sep=',',names = ["PostCode", "a", "Easting", "Northing","b","c","d","e","f","g"] ,header=None) #http://pandas.pydata.org/pandas-docs/stable/generated/pandas.read_csv.html
    A = df[df['PostCode'] == postcode_list[i]]
    # print name_list[i]
    # print postcode_list[i]
    # print get_filename(postcode_list[i])

    if A.empty:
        continue
    East =  A['Easting']
    North = A['Northing']

    loc = np.array(East)[0], np.array(North)[0]
    lat_long = ENtoLL84(loc[0], loc[1])


    with open(writefile, 'a') as f:
        writer = csv.writer(f, delimiter = ',')
        writer.writerow([name_list[i], str(lat_long[1]), str(lat_long[0])])

    print i


#print match
#print(df['PostCode'][match].value_counts())























# #Take postcodes and obtain lat long data
# pc = PostCoder()
# lat_list = []
# lng_list = []

# for postcode in postcode_list:
#     info = pc.get(postcode)
#     lat_list.append(info.get('geo').get('lat'))
#     lng_list.append(info.get('geo').get('lng'))

# #Write new data to csv
# writefile = 'site_loc.csv'
# with open(writefile, 'wb') as f:
#     writer = csv.writer(f, delimiter = ',')

#     for i in range(len(name_list)):
#         writer.writerow([name_list[i], str(lat_list[i]), str(lng_list[i])])
