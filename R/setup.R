# Setup script for chem-lookup project

# project (root) directory ------------------------------------------------
# prj = '~/Projects/chem-lookup'
prj = getwd()

# variables ---------------------------------------------------------------
zenodo_id = 5947275

datadir = file.path(prj, 'data')
srcdir = file.path(prj, 'R')
pkgdir = file.path(prj, 'chemlook')

# packages ----------------------------------------------------------------
if (!suppressWarnings(require('pacman'))) {
  install.packages('pacman'); require(pacman)
}

pkg_cran = c('data.table',
             'devtools',
             'jsonlite',
             'tinytest',
             'fst')

p_load(char = pkg_cran)

pkg_gh = c('andschar/andmisc',
           'andschar/zenodo')

p_load_current_gh(char = pkg_gh)
