# Chemical Lookup

Chemical Lookup is a database and repository containing tabular information on
chemicals, such as names, identifiers (e.g. CAS, InChI) as well as identifiers
to other databases (e.g. Pubchem CID).

## Usage

You can download the R-package `{chemlook}` to query the database directly from
R __OR__ you can download the data from its [Zenodo-Repository](https://zenodo.org/record/5947275).

### From R

#### Installation

```r
remotes::install_github('andschar/chem-lookup', subdir = 'chemlook')
```

#### Example

You can query the database by different identifiers. For a detailed list see
`?chemlook::cl_query()`. Some examples are shown below.

```r
require(chemlook)

cl_query('1071-83-6', from = 'cas')
cl_query('WSFSSNUMVMOOMR-UHFFFAOYSA-N', from = 'inchikey')
cl_query('DTXSID8020961', from = 'dtxsid')
```

### Raw Data only

All the data tables are stored on the [Zenodo-Respository](https://zenodo.org/record/5947275)
as tab-separated (i.e. .tsv) and non-quoted files and one compressed R archive
(.rds) file.

| table     | description |
|:----------|:------------|
| cl_class.tsv  | Containing chemical classification information |
| cl_id.tsv     | Table of identifiers |
| chemlook.rds  | Compressed R archive |

The tables can be merged via the unique key column `cl_id`.

## Contribute

The information here is by no means complete and users are highly encouraged to
contribute information to this database. Missing entries, wrong
entries, more detailed information, you name it. Please signal issues via the [Issue](https://github.com/andschar/chem-lookup/issues) tracker.
