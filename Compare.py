import xlrd
import xlwt


file1 = open("C:/Users/RBoudet1/Desktop/365Days.txt", "r")
file2 = open("C:/Users/RBoudet1/Desktop/Jan.txt", "r")

testComps = file1.readlines()
allComps = file2.readlines()
CompList = [] # this will be the list that contains all the computers from file 2

f = open('file.txt', 'w')
count =0
#Create an array with all the computers to compare to in upper case
for comp in allComps:
    CompList.append(comp.rstrip().upper())
    

# now we compare, and select the ones we want to keep
for comp in testComps:
    if (comp.rstrip().upper() in CompList):
        f.write(comp.upper())
        count += 1
    else:
        print(comp)

f.close()
print(count)

'''
f = open('file.txt', 'r')
ToKeep = f.readlines()
# we need to keep all the lines in which the name is present.
# so now we want to write in a file the information of the users of those rows 
wb = xlrd.open_workbook("C:\\Users\\RBoudet1\\Desktop\\windows server not in AD.xlsx")
wb2 = xlwt.Workbook()
sheet = wb.sheet_by_index(0)
sheet2 = wb2.add_sheet('test') #output sheet 
k = 0
r = 0

## we then remove any unnecessary carriage return 
for i in range(len(ToKeep)):
    ToKeep[i] = ToKeep[i].rstrip()
print(sheet.nrows)
while k < sheet.nrows:
    data = [sheet.cell_value(k,col) for col in range(sheet.ncols)]
    #if you want to keep the first line (column titles for example) add values if k is 0
    # otherwise remove the check in the if statement. 
    
    if(k==0 or(data[4].upper()) in ToKeep): 		# modify the '4' depending on the column you wish to compare the values with
        for index, value in enumerate(data):
            sheet2.write(r,index,value)
        r=r+1
           
    k = k+1
    


wb2.save('Output.xls')

f.close()
'''
file1.close()
file2.close()

