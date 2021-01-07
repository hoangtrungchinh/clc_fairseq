import sys, getopt
import editdistance
import time
import concurrent.futures
import sent2vec
from sklearn.metrics.pairwise import cosine_similarity

def main(argv):
  threshold = 0.8
  start = time.time()
  srcfile = ''
  tarfile = ''
  outfile = ''
  saperate = " || "
  try:
    opts, args = getopt.getopt(argv,"st:o:",["srcfile=","tarfile=","outfile=","binfile="])
  except getopt.GetoptError:
    print('example: python3 script_FM.py --srcfile train500.en --tarfile train500.vi --outfile train_ok --binfile model.bin')
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
    elif opt in ("-b", "--binfile"):
      binfile = arg

  print('=== Starting Calculate editdistance')
  print('source file is ', srcfile)
  print('target file is ', tarfile)
  print('output file is ', outfile)
  print('bin file is ', binfile)

  # IMPORT TO ARRAY
  lst_srcfile = open(srcfile, "r").readlines()
  lst_tarfile = open(tarfile, "r").readlines()

  model = sent2vec.Sent2vecModel()
  model.load_model(binfile)

  def best_simi(str):
    dis = -1
    index = 0
    best_sent = ""
    str_vector = model.embed_sentence(str)
    for i in range(len(lst_srcfile)):
      tar_vector = model.embed_sentence(lst_srcfile[i])

      ed  = cosine_similarity(str_vector, tar_vector)[0][0]
      if ed !=1:
        if ed > dis:
          dis = ed
          best_sent = lst_srcfile[i]
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
  print('=== Ending, Total time (minutes): ', elapsed/60)
  print('=== Ending, Total time (hourse): ', elapsed/3600)

if __name__ == "__main__":
   main(sys.argv[1:])

