import os, csv

#2nd row, 11th column
root='/home/jherwig1/npmap-species/backend/maxent/results/maxent_results'
#root='/home/jherwig1/npmap-species/backend/maxent/maxent_results'
etypes = '/home/jherwig1/npmap-species/environmentallayers/environmentallayertypes.txt'

def read_csv(filename, csvwriter, species):
   start = 11
   end = 0
   line = -1
   num = 0
   s = []
   with open(filename, 'r') as f:
      csvreader = csv.reader(f, delimiter=',')
      for row in csvreader:
         line += 1 
         if line == 0:
            end = row.index('Entropy')
            auc1 = row.index('Training AUC')
            auc2 = row.index('Test AUC')
            auc3 = row.index('AUC Standard Deviation')
            for i in xrange(0, (end - start + 3)):
               s.append(0.0)
            continue
         pos = 0
         s[pos] += float(row[auc1])
         s[pos + 1] = float(row[auc2])
         s[pos + 2] = float(row[auc3])
         for col in row[start:end]:
            s[pos + 3] += float(col)
            pos += 1
         num += 1
      for i in xrange(0, len(s)):
         s[i] = s[i] / num


      s.insert(0, species)
      csvwriter.writerow(s)

def make_csv(csvwriter):
   level = 0
   for subdirs, dirs, files in os.walk(root):
      if level == 0:
         for d in dirs:
            path = os.path.join(root, d, 'maxentResults.csv')
            if os.path.isfile(path):
               read_csv(path, csvwriter, d)
       

if __name__ == "__main__":
   with open('species_stats.csv', 'w') as f:
      csvwriter = csv.writer(f)
      header = ['Species']
      with open(etypes, 'r') as f1:
         for row in f1:
            header.append(str(row).strip('\n')[:-4])
         csvwriter.writerow(header)
      make_csv(csvwriter)
