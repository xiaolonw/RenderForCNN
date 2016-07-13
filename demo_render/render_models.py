import os
import subprocess
import sys
import tempfile
import matplotlib.pyplot as plt
import numpy as np
from skimage.measure import regionprops

modelsdir = '/nfs.yoda/xiaolonw/grasp/dataset/ycb/'
modelslistfpath = '/nfs.yoda/xiaolonw/grasp/RenderForCNN/demo_render/list.txt'
outdir = '/nfs.yoda/xiaolonw/grasp/dataset/ycb_rendered'

render_code = 'render_class_view.py'

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
def genRender(mpath, az, el, outfpath = None, render_dist = 0.5):
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
  sys.path.append('./python')
  from locker import lock, unlock
  with open(modelslistfpath) as f:
    modelslist = f.read().splitlines()

  for i in range(1, len(modelslist)):
    fname =  modelslist[i - 1]
    flen = len(fname)
    fname = fname[0: flen - 4]
    mpath = os.path.join(modelsdir,fname, 'textured_meshes/optimized_tsdf_texture_mapped_mesh2.obj')
    outfpath = os.path.join(outdir, fname)
    if not lock(outfpath):
      continue
    try:
      os.makedirs(outfpath)
    except:
      pass
    for el in range(0, 360, 120):
      for az in range(0, 360, 120):
        for  '_' + str(light_id) in range(3):
          genRender(mpath, az, el, os.path.join(outfpath, str(az) + '_' + str(el) + '_' + str(light_id) '.png'), render_dist=0.5)
    unlock(outfpath)
