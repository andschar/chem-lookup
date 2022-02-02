# Script to upload data changes to Zenodo

# Create Upload -----------------------------------------------------------
# Run only once
# upl = zen_upload(
#   title = "Chem Lookup",
#   upload_type = c("dataset"),
#   author = list(list(name = 'Andreas Scharmüller',
#                      affiliation = 'University Koblenz-Landau',
#                      orcid = '0000-0002-1825-0097')),
#   description = 'The Chem Lookup database contians information and classificaiton on chemicals. Use the R-package chemlook to directly access the data. The data can also be downloaded here.',
#   version = '0.0.1',
#   keywords = list('chemistry', 'classification', 'lookup')
# )

# Upload files ------------------------------------------------------------
# TODO don't know yet how to handle a NEW VERSION
fl_l = list.files('data', full.names = TRUE)

for (i in fl_l) {
  zen_put(id = zenodo_id,
          file_name = basename(i),
          file_disk = i)
}


