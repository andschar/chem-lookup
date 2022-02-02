# Script to build R package

# setup -------------------------------------------------------------------
source('R/setup.R')

# package -----------------------------------------------------------------
devtools::build(pkgdir)
devtools::document(pkgdir)
devtools::install(pkgdir)
devtools::check(pkgdir)
