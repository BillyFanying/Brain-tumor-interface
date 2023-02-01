import os
import json
import logging
import SimpleITK as sitk
import radiomics
from radiomics import featureextractor
import xlsxwriter
import xlrd
import operator
import scipy
import trimesh
import numpy
Eex0lis = []
Ecnt = 0

with open("D:/Postgraduate/Yang/EGFR_Primary/EGFR/T1C_EGFR.json", 'r') as load_f:
    pathlist = json.load(load_f)
    print(pathlist)
imageName = ''
maskName = ''
cnt = 0

for pathdicom in pathlist:
  PathDicom = pathdicom
  listpic = os.listdir(pathdicom)
  cnt += 1

  for listnum in listpic:
    if 'T1C_nii' in listnum and 'nrrd' in listnum:
      path_nii_nrrd = os.path.join(pathdicom, listnum)
      maskName = path_nii_nrrd
      break
  for listnum in listpic:
    if 'T1C_dcm' in listnum and 'nrrd' in listnum:
      path_dcm_nrrd = os.path.join(pathdicom, listnum)
      imageName = path_dcm_nrrd
      break
  print("正在处理第", cnt, '个样本')
  print(imageName, maskName)
  mask = sitk.ReadImage(maskName)
  image = sitk.ReadImage(imageName)

  print(image.GetSize(), mask.GetSize())

  path_fea_all = r'D:/Postgraduate/Yang/EGFR_Primary/EGFR/T1C_EGFR.xlsx'

  print('现在处理的文件夹为：', PathDicom)
  print('开始提取特征')
  radiomics.setVerbosity(logging.INFO)
  logger = radiomics.logger
  logger.setLevel(logging.DEBUG)
  handler = logging.FileHandler(filename='testLog.txt', mode='w')
  formatter = logging.Formatter("%(levelname)s:%(name)s: %(message)s")
  handler.setFormatter(formatter)
  logger.addHandler(handler)

  settings = {}
  settings['label'] = 1
  settings['binWidth'] = 25
  settings['normalize'] = True
  settings['normalizeScale'] = 100
  settings['geometryTolerance'] = 10000000
  settings['minimumROIDimensions'] = 1
  settings['minimumROISize'] = None
  settings['correctMask'] = True
  extractor = featureextractor.RadiomicsFeatureExtractor(**settings)
  extractor.enableAllFeatures()
  extractor.enableAllImageTypes()
  extractor.enableImageTypeByName('LoG', customArgs={'sigma': [1.0, 3.0, 5.0]})
  print("Calculating features")
  print('Enabled input images:')
  try:
      featureVector = extractor.execute(imageName, maskName)
      featureVector_sorted = sorted(featureVector.items(), key=operator.itemgetter(0), reverse=False)
      print("特征计算完毕")
      print("开始写入表格")
      myWorkbook = xlrd.open_workbook(path_fea_all)
      mySheet_read = myWorkbook.sheet_by_index(0)
      sheet_row = mySheet_read.nrows
      sheet_column = mySheet_read.ncols
      workbook = xlsxwriter.Workbook(path_fea_all)
      worksheet = workbook.add_worksheet()
      print(path_fea_all)
      print(sheet_row)

      if sheet_row > 0:
        for nrow in range(sheet_row):
          for ncol in range(sheet_column):
            cell_value = mySheet_read.cell_value(nrow, ncol)
            worksheet.write(nrow, ncol, cell_value)

      if sheet_row == 0:
        sheet_row = sheet_row + 1
        worksheet.write(sheet_row, 0, imageName)
      else:
        worksheet.write(sheet_row, 0, imageName)

      sheet_column = 1
      for feature_name in featureVector_sorted:
        worksheet.write(0, sheet_column, feature_name[0])
        worksheet.write(sheet_row, sheet_column, str(feature_name[1]))
        sheet_column = sheet_column + 1

      workbook.close()  # 关闭Excel文件
      print("已放进表格")
  except MemoryError:

      Ecnt+=1
      print('正在处理第', Ecnt, '个错误文件')
      Eex0lis.append(PathDicom)
      pass
  continue
#

with open("Eex0lis(提特征错误的人S1).json", 'w') as f:
    json.dump(Eex0lis, f)
    print("successful write")