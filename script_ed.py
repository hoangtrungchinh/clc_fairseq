import sys, getopt
import editdistance
import time
import concurrent.futures

def main(argv):
  start = time.time()
  srcfile = ''
  tarfile = ''
  outfile = ''
  saperate = "@@@"
  try:
    opts, args = getopt.getopt(argv,"st:o:",["srcfile=","tarfile=","outfile=", "thread="])
  except getopt.GetoptError:
    print('example: python3 script_ed.py --srcfile train.en --tarfile train.vi --outfile ok.txt --thread 1 ')
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
    elif opt in ("-m", "--thread"):
      thread = arg

  print('=== Starting Calculate editdistance')
  print('source file is ', srcfile)
  print('target file is ', tarfile)
  print('output file is ', outfile)

  def best_simi(str):
    dis = 10000000
    index = 0
    best_sent = ""
    with open(srcfile) as src_f2:
      for j, cnt in enumerate(src_f2):
        tmp = editdistance.eval(str, cnt)
        if tmp !=0 and tmp < dis:
          dis = tmp
          best_sent = cnt
          index = j
      return best_sent, index


  def best_simi_multi(str):
    dis = 10000000
    index = 0
    best_sent = ""
    with open(srcfile) as src_f2:
      for j, cnt in enumerate(src_f2):
        tmp = editdistance.eval(str, cnt)
        if tmp !=0 and tmp < dis:
          dis = tmp
          best_sent = cnt
          index = j
      a_file = open(tarfile)
      for position, line in enumerate(a_file):
        if position == index:
          return str.strip() + saperate + line
          # return str.strip() + saperate + best_sent.strip()  + saperate + line




# 1 thread
  if thread=="1":
    out_file_write = open(outfile, 'w')
    with open(srcfile) as src_f:
      for i, cnt1 in enumerate(src_f):
        best_sent, index = best_simi(cnt1)

        # Get and save content
        a_file = open(tarfile)
        for position, line in enumerate(a_file):
          if position == index:
            out_file_write.writelines(cnt1.strip() + saperate + line)
            # out_file_write.writelines(cnt1.strip() + saperate + best_sent.strip()  + saperate + line)
            break

    out_file_write.close()
  else:
    dict=[]
    file1 = open(srcfile, 'r')
    Lines = file1.readlines()
    out_file_write = open(outfile, 'w')

    with concurrent.futures.ThreadPoolExecutor(max_workers = int(thread)) as executor:
      res = {executor.submit(best_simi_multi, e): e for e in Lines}
      # Get and save content
      # a_file = open(tarfile)
      # for position, line in enumerate(a_file):
      #   if position == index:
      #     out_file_write.writelines(cnt1.strip() + saperate + best_sent.strip()  + saperate + line)
      #     break


      for future in concurrent.futures.as_completed(res):
        out_file_write.writelines(future.result())
        # dict.append(future.result())
        # print(future.result())
    # print(dict)

    out_file_write.close()


  done = time.time()
  elapsed = done - start
  print('=== Ending, Total time: ', elapsed)

if __name__ == "__main__":
   main(sys.argv[1:])

