import os
import subprocess
import sys
import tempfile
import matplotlib.pyplot as plt
import numpy as np
from skimage.measure import regionprops

modelsdir = '/home/rgirdhar/Work/Data/016_3DModels/3D/3DModels/ShapeNet/Data/03001627'
modelslistfpath = '/home/rgirdhar/Work/Data/016_3DModels/Lists/ShapeNet/03001627.txt'
outdir = '/home/rgirdhar/Work/Data/016_3DModels/Scratch/0001_TrainingData/008_StanfordRenderLarge/snapshots'

render_code = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../../libs/RenderForCNN/demo_render/render_class_view.py')

def crop_center(im):
  # image with alpha channel - remove white parts
  # To do it using the alpha chanel, use crop_center_tight
  sz = np.shape(im)
  return im[sz[0]/2 - 200 : sz[0]/2 + 200, sz[1]/2 - 200 : sz[1]/2 + 200, :]

def crop_center_tight(im, pad=10):
  if np.shape(im)[2] <= 3:
    print 'ERROR: Need im with alpha channel'
    return im
  alpha = im[...,3]
  alpha[alpha > 0] = 1
  region = regionprops(alpha.astype('bool'))[0] # just assume one
  (ymin,xmin,ymax,xmax) = region.bbox
  return im[max(0, ymin - pad) : min(np.shape(im)[0], ymax + pad), max(0, xmin - pad) : min(np.shape(im)[1], xmax + pad), ...]

# specify the outfpath if you want to store the file
# else, the function will return the rendering
def genRender(mpath, az, el, outfpath = None, render_dist = 3.0):
  SAVE_OUTPUT = True
  if not outfpath:
    SAVE_OUTPUT = False # only return the image
    (fid, outfpath) = tempfile.mkstemp()
    os.close(fid)
  cmd = 'python %s -a %f -e %f -t 0.0 -d %f -m %s -o %s' % (render_code, 
      az, el, render_dist, mpath, outfpath)
  subprocess.call(cmd, shell=True)
  if not SAVE_OUTPUT:
    I = plt.imread(outfpath)
    os.remove(outfpath)
    return I

if __name__ == '__main__':
  sys.path.append('../utils/python')
  from locker import lock, unlock
  with open(modelslistfpath) as f:
    modelslist = f.read().splitlines()

  for i in range(1, len(modelslist)):
    mpath = os.path.join(modelsdir, modelslist[i - 1])
    outfpath = os.path.join(outdir, str(i))
    if not lock(outfpath):
      continue
    try:
      os.makedirs(outfpath)
    except:
      pass
    for el in [30]:
      for az in range(0, 360, 15):
        genRender(mpath, az, el, os.path.join(outfpath, str(az) + '_' + str(el) + '.png'), render_dist=2.0)
    unlock(outfpath)
