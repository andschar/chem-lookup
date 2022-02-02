# Script to store compressed data to the R-package sub-directory
# TODO this can be automated via GitHub actions
# TODO use more general compression (gzip?)

# setup -------------------------------------------------------------------
source('R/setup.R')

# data --------------------------------------------------------------------
cl_id = fread2(file.path(datadir, 'cl_id.tsv'))
cl_class = fread2(file.path(datadir, 'cl_class.tsv'))

# prep --------------------------------------------------------------------
# list columns
cl_class = cl_class[ ,
                     .(class_array = strsplit(class_array, '|', fixed = TRUE)),
                     cl_id ]
# list
l = list(cl_id = cl_id,
         cl_class = cl_class)

# write -------------------------------------------------------------------
saveRDS(l, file.path(datadir, 'chemlook.rds'))
