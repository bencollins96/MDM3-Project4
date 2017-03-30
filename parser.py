import csv
import re
from postcodes import PostCoder

filename = 'trusts.csv' 

#Open the file and read out data
with open(filename, 'rb') as f:
    reader = csv.reader(f)
    name_list = []
    postcode_list = []

    for row in reader:
        name_list.append(row[1].replace(',',''))
        postcode_list.append(row[9])

#Take postcodes and obtain lat long data
pc = PostCoder()
lat_list = []
lng_list = []

for postcode in postcode_list:
    info = pc.get(postcode)
    lat_list.append(info.get('geo').get('lat'))
    lng_list.append(info.get('geo').get('lng'))





#Write new data to csv
writefile = 'trust_loc.csv'
with open(writefile, 'wb') as f:
    writer = csv.writer(f, delimiter = ',')

    for i in range(len(name_list)):
        writer.writerow([name_list[i], str(lat_list[i]), str(lng_list[i])])
