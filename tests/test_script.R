# script to run some tests

# setup -------------------------------------------------------------------
require(data.table)

# meta table --------------------------------------------------------------
cl_id = fread(file.path(prj, 'cl_identifiers.tsv'), na.strings = '')

# empty string ------------------------------------------------------------
# any ''
testthat::expect_false(
  any(sapply(cl_id, function(x) any(x == '', na.rm = TRUE))),
  info = 'No empty space.'
)

# InChI string
testthat::expect_false(
  all(na.omit(unique(substr(cl_id$inchi, 1, 6))) == 'InChI='),
  info = 'All InChI strings start with <InChI=>.'
)
# CHEBI string
testthat::expect_true(
  all(na.omit(unique(substr(cl_id$che_id, 1, 6))) == 'CHEBI:'),
  info = 'All CHEBI strings start with <CHEBI:>.'
)
# CHEBI string
testthat::expect_true(
  all(na.omit(unique(substr(cl_id$chl_id, 1, 6))) == 'CHEMBL'),
  info = 'All CHEBI strings start with <CHEMBL>.'
)

# variables ---------------------------------------------------------------
# Checking variable type and names
meta = fread(file.path(prj, 'cl_identifiers_meta.tsv'))
cl_id_type = data.table(variable = names(sapply(cl_id, class)),
                        class = sapply(cl_id, class))
cl_id_type[meta, class_meta := i.class, on = 'variable' ]

# names
testthat::expect_true(
  all(names(cl_id) %in% meta$variable),
  info = 'All variables also in the meta table.'
)

# class
testthat::expect_true(
  all(cl_id_type$class == cl_id_type$class_meta),
  info = 'All variables are of the appropriate class.'
)









