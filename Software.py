import win32com.client 
import wmi
import csv

c = wmi.WMI("WD140355")

writer = csv.writer(open('C:/temp/installed_software.csv', 'wb'))
dict = [["Software Name", "Installation Date"]]

for name in c.win32_product():
	#this is to prevent encoding errors when writing to txt file 
	SoftwareName = (name.description).encode('utf-8')
	InstallDate = (name.InstallDate).encode('utf-8')
	FormattedDate = InstallDate[:4] + '/' + InstallDate[4:6] + '/' + InstallDate[6:]
	print(SoftwareName)
	dict.append([SoftwareName,FormattedDate])
	
for i in range(len(dict)):
	writer.writerow(dict[i])
