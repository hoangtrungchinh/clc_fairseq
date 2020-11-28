#!/usr/bin/python

import sys, getopt
import editdistance
import time


def main(argv):
  start = time.time()
  inputfile = ''
  outputfile = ''
  saperate = "@@@"
  try:
    opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
  except getopt.GetoptError:
    print('test.py -i <inputfile> -o <outputfile>')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print('test.py -i <inputfile> -o <outputfile>')
      sys.exit()
    elif opt in ("-i", "--ifile"):
      inputfile = arg
    elif opt in ("-o", "--ofile"):
      outputfile = arg

  print('=== Starting Calculate editdistance')
  print('Input file is ', inputfile)
  print('Output file is ', outputfile)

  file_read = open(inputfile, 'r')
  Lines1 = file_read.readlines()

  file_write = open(outputfile, 'w')
  for l1 in Lines1:
    dis = 10000000
    best_sent = ""
    for l2 in Lines1:
      tmp = editdistance.eval(l1, l2)
      if tmp !=0 and tmp < dis:
        dis = tmp
        best_sent = l2

    file_write.writelines(l1.strip() + saperate + best_sent)
  file_write.close()


  done = time.time()
  elapsed = done - start
  print('=== Ending, Total time: ', elapsed)

if __name__ == "__main__":
   main(sys.argv[1:])

