import os, math
import numpy as np
import nibabel as nib
import json
from nibabel.testing import data_path
import matplotlib.pyplot as plt
from skimage import measure, draw
import SimpleITK as sitk
Errorlis = []
Ecnt = 0
with open("C:\\Users\\Administrator\\Desktop\\Aliyun\\T790M_model\\T1C_T790M.json", 'r') as load_f:
    pathlist = json.load(load_f)
    print(pathlist)

class spacing_not_equal(Exception):
    def __init__(self):
        print("nii文件spaing的 x和y 不一致，需重新编写代码")

def if_spacing_equal(x, y):
    flag = (x == y)
    if not flag:
        raise spacing_not_equal()
    else:
        pass

def expansion(nii_path, mm_num):
    img = nib.load(nii_path)
    img_data = img.get_fdata()
    [img_x, img_y, img_num] = img_data.shape
    file = sitk.ReadImage(nii_path)
    spacing = file.GetSpacing()
    [x_spacing, y_spacing, z_spacing] = spacing
    if_spacing_equal(x_spacing, y_spacing)
    expan_num = math.ceil(mm_num / x_spacing)
    img_minus = np.zeros((img_x, img_y, img_num))
    img_expan = np.zeros((img_x, img_y, img_num))
    count_nii = 0
    while count_nii < img_num:
        img_expan[:, :, count_nii] = img_data[:, :, count_nii]
        count_nii = count_nii + 1

    for num in range(img_num):
        img_tmp = img_data[:, :, num].reshape((img_x, img_y))
        if (img_tmp.max()):
            contours = measure.find_contours(img_tmp, 0.5)
            for contour_x, contour_y in contours[0]:
                rr, cc = draw.ellipse(contour_x, contour_y, expan_num, expan_num, shape = None)
                img_expan[rr, cc, num] = 1
                img_expan[rr, cc, num] = -1
            img_minus[:, :, num] = img_expan[:, :, num] - img_data[:, :, num]

    return img_minus
    print("成功外扩")

def save_new_nii(nii_path, new_nii_path, mm_num):
    img = nib.load(nii_path)
    header = img.header
    affine = img.affine
    image_data = img.get_fdata()

    expan_data = expansion(nii_path, mm_num=mm_num)
    print("成功加载expand_data")

    expan_img = nib.Nifti1Image(expan_data, affine=affine, header=header)
    print("成功加载expend_img")
    nib.save(expan_img, new_nii_path)  #
    print("成功加载nib_save")

if __name__ == '__main__':
    Ccnt = 0
    cnt = 0

    for path_patient in pathlist:
        cnt += 1
        print("正在处理第：", cnt, "个样本")
        print("路径为:", path_patient)
        PathDicom = path_patient
        subdirnii = os.listdir(PathDicom)
        for niinum in subdirnii:

            if 'nii' in niinum and 'nrrd' not in niinum and 'ex' not in niinum:
                nii_path = os.path.join(PathDicom, niinum)
                new_nii_path = PathDicom + r'\ex2.nii.gz'
                try:
                    save_new_nii(nii_path, new_nii_path, mm_num=5)
                    Ccnt += 1
                except IndexError:
                    Errorlis.append(path_patient)
                    Ecnt += 1

                    print("第", Ecnt, "个错误样例")
                    pass
                continue

    with open("Errorlis(4mm).json", 'w') as f:
        json.dump(Errorlis, f)
        print("successful write")
    print("成功外扩", Ccnt, "个样例")
    print("共有", Ecnt, "个失败样例")


