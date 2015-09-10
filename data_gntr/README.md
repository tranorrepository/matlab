# ygomi_matlab

---------------------------------------
August 06, 2015
File description

Folders

  data_fd - ford GPS data
  data_hd - honda GPS data
  data_vw - volkswagen GPS data
  data_parser - parser used to generate GPS matrix from text file

Files

  dotLineBlockIndex.m - return dotted line index and block start/stop info
                        from input data

  drawAllGPSData.m    - plot all GPS data
  drawGPSData.m       - plot dotted line data

  getDotLineParams.m  - return dotted line parameters
                        (x, y, cnt, length, width, theta)
  getPaintIndex.m     - return painted line column index and x, y column 
                        index of painted line

  getSolidLineMovedData.m - return solid line moved data from dotted line 
                            moveing vector. (x, y, matchedIndex)
  getSolidLineParams.m    - return solid line parameters
                            (x, y, cnt, length, width, theta)

  linSample.m             - linear resample process for merged dotted line

  mergeDotLineParams.m    - merge two dotted lines according to parameters
                            (x, y, cnt, length, widht, theta)
  mergeSolidLinePaintData.m - merge two solid lines according to closest 
                              point match. (x, y, paint)
  mergeTwoDataset.m         - merge two dataset

  plotMergedLine.m          - plot merged dotted line parameters

  roadDBDemo.m              - demo for merge process
  solidLineBlockIndex.m     - return dotted line index and block start/stop
                              info from input data

  test_*.m                  - test matlab files

---------------------------------------
August 05, 2015
MATLAB source of YGOMI

setup GIT source base!
