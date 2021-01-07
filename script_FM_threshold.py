import sys, getopt
import editdistance
import time
import concurrent.futures

def main(argv):
  threshold = 0.6
  start = time.time()
  srcfile = ''
  tarfile = ''
  outfile = ''
  saperate = " || "
  try:
    opts, args = getopt.getopt(argv,"st:o:",["srcfile=","tarfile=","outfile="])
  except getopt.GetoptError:
    print('example: python3 script_FM.py --srcfile train500.en --tarfile train500.vi --outfile train_ok')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print('test.py -src <srcfile> -tar <tarfile> -out <outfile>')
      sys.exit()
    elif opt in ("-s", "--srcfile"):
      srcfile = arg
    elif opt in ("-t", "--tarfile"):
      tarfile = arg
    elif opt in ("-o", "--outfile"):
      outfile = arg

  print('=== Starting Calculate editdistance')
  print('source file is ', srcfile)
  print('target file is ', tarfile)
  print('output file is ', outfile)

  # IMPORT TO ARRAY
  lst_srcfile = open(srcfile, "r").readlines()
  lst_tarfile = open(tarfile, "r").readlines()

  def best_simi(str):
    dis = 0
    index = 0
    best_sent = ""
    for i in range(len(lst_srcfile)):
      str_file = lst_srcfile[i]
      ed  = editdistance.eval(str, str_file)
      if ed !=0:
        tmp = 1-(ed/max(len(str), len(str_file)))
        if tmp > dis:
          dis = tmp
          best_sent = cnt
          index = i
    return best_sent, index , dis

  out_file_write = open(outfile, 'w')
  out_file_write_fm = open(outfile+"_fm", 'w')
  for cnt in lst_srcfile:
    best_sent, index, dis = best_simi(cnt)

    # Get and save content
    if dis > threshold:
      out_file_write.writelines(cnt.strip() + saperate + lst_tarfile[index])
    else:
      out_file_write.writelines(cnt)
    out_file_write_fm.writelines(str(dis)+"\n")


  out_file_write.close()


  done = time.time()
  elapsed = done - start
  print('=== Ending, Total time: ', elapsed)

if __name__ == "__main__":
   main(sys.argv[1:])

