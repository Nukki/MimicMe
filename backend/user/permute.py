



def permute(bag,string):
	if bag.empty():
		print(string)
		return
	else
		for i in range(len(bag)):
			string += bag[i]
			del bag[i]
			permute(bag,string)


bag = ['a','b','c']
string = ''
permute(bag,string)

