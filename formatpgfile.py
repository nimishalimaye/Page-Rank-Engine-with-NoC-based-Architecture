import sys, csv

# class defintion

class node(object):
	item_index={}
	#def __init__():
	#	pass
	def add_item(self, ky, index):
		self.item_index[ky] = index


#initialise all the variable

temp		= 1
i 			= 0
k 			= 0			#denotes the last item
nodes 		= node()

#open file to read and find the index

file 		= open(sys.argv[1],'r')
csv_file 	= csv.reader(file)


for items in csv_file:
	if(int(temp) <> int(items[0])):
		nodes.add_item(str(items[0]),i)
		if(int(items[0]) == 417728):
			print items[0]
		i +=1
		temp = items[0]

k=i
file.close()

# open the file again to re write

file 		= open(sys.argv[1],'r')
csv_file 	= csv.reader(file);

# open the new file re w
file_wr		= open(sys.argv[2],'w')
csv_file_wr	= csv.writer(file_wr)

for items in csv_file:
	try:
		csv_file_wr.writerow([nodes.item_index[str(items[0])],nodes.item_index[str(items[1])]])
	except KeyError:
		nodes.add_item(str(items[1]),i)
		i +=1
		csv_file_wr.writerow([nodes.item_index[str(items[0])],nodes.item_index[str(items[1])]])
		if (nodes.item_index[str(items[0])] == 68):
			print items[0],nodes.item_index[str(items[0])]

file.close()

for j in range(k,i):
	csv_file_wr.writerow([j,"",1.2])

file_wr.close()