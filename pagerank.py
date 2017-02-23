import csv, sys
import matplotlib.pyplot as plt

class pagerank(object):
	def __init__(self, node_id, links, weight, rank, aprx_rank):
		self.node_id	=	node_id
		self.links 		= 	links
		self.weight		=	weight
		self.rank		= 	rank
		self.aprx_rank 	= 	aprx_rank

	def add_links(self,link):
		self.links.append(link)
	def add_weight(self,weight):
		self.weight = weight

#N 			= 875712
N 			= 265213
nodes 		= []
links_tmp 	= []
tmp_rank	= 0.0
tmp_aprx_rank = 0.0
tmp 		= 0
tmp_weight	= [0] * (N+1)
k			= 0
ovrfl_flg	= 0
prv_rnk		= 0
t 			= 0
j			= 0
x			= []
y			= []
z			= []
w 			= []
least_value	= []

file 		= open(sys.argv[1],'r')
csv_file 	= csv.reader(file)


for items in csv_file:
	if(tmp <> int(items[0])):
		nodes.append(pagerank(int(tmp), [], 0.0, 1.0/(N+1), 1.0/(N+1)))
		if (int(items[0]) - tmp >= 2):
			print items[0]
		for l in links_tmp:
			nodes[t].add_links(l)
		t+=1
		del links_tmp[:]
		tmp = int(items[0])
	try:
		links_tmp.append(int(items[1]))
	except ValueError:
		pass
		#print "link",items[0], items[1]
	try:
		tmp_weight[int(items[1])] += 1
	except ValueError:
		pass
		#print "weight",items[0]

nodes.append(pagerank(int(tmp), [], 0.0, 1.0/(N+1), 1.0/(N+1)))
for l in links_tmp:
	nodes[t].add_links(l)

file.close()

for i in range(0,N+1):
		try:
			nodes[i].add_weight(0.85/tmp_weight[i])
		except ZeroDivisionError:
			nodes[i].add_weight(0.0)
			#print "zero divisiom",i,nodes[i].node_id

	#print 'nodes ID: %d\t nodes weight: %f\t rank: %f\t' % (nodes[703606].node_id, nodes[703606].weight, nodes[703606].rank)
	#print nodes[i].links

while(ovrfl_flg == 0):
	for i in range(0,N+1):
		tmp_rank = 0.0
		tmp_aprx_rank = 0.0
		if (nodes[i].links == []):
			tmp_rank == 0
		else:
			for j in nodes[i].links:
				tmp_rank += nodes[j].weight * nodes[j].rank
				if(nodes[j].weight * nodes[j].rank > 0.239e-9):
					tmp_aprx_rank += nodes[j].weight * nodes[j].rank
				#print nodes[j].weight, nodes[j].rank, tmp_rank
		prv_rnk =nodes[i].rank
		nodes[i].rank = 0.15/(N+1) + tmp_rank
		nodes[i].aprx_rank = 0.15/(N+1) + tmp_aprx_rank
		if ((abs(prv_rnk - nodes[i].rank) < 1e-12) and (ovrfl_flg == 1 or i == 1)):
			ovrfl_flg = 1
		else:
			ovrfl_flg = 0
	"""if(k ==	12):
		for i in range(0,N+1):
			x.append(nodes[i].node_id)
			y.append(nodes[i].rank)
			z.append(nodes[i].aprx_rank)
			err= (abs(nodes[i].aprx_rank - nodes[i].rank))*100/nodes[i].rank
			w.append(err)"""

	k+=1
	print k


for i in range(0,N+1):
	x.append(nodes[i].node_id)
	y.append(nodes[i].rank)
	z.append(nodes[i].aprx_rank)
	err= (abs(nodes[i].aprx_rank - nodes[i].rank))*100/nodes[i].rank
	w.append(err)

plt.figure(1,figsize=(10,5))
plt.subplot(211)
plt.plot(x,y,'B',x,z,'ro')
plt.xlabel('nodes')
plt.ylabel('page rank')
plt.subplot(212)
plt.plot(x,w,'G')
plt.xlabel('nodes')
plt.ylabel('error')
plt.grid(True)
plt.show()
