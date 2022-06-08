#' Download compressed database.
#' 
#' @author Andreas Scharmueller \email{andschar@@protonmail.com}
#' 
#' @noRd
#' 
fl_download = function() {
  destfile_gz = file.path(tempdir(), 'chemlook.sqlite3.gz')
  destfile = file.path(tempdir(), 'chemlook.sqlite3')
  if (!file.exists(destfile_gz) && !file.exists(destfile)) {
    message('Downloading data..')
    # HACK this has to done, because doi.org is the only permanent link between versions
    qurl_permanent = 'https://doi.org/10.5281/zenodo.5947274'
    req = httr::GET(qurl_permanent)
    cont = httr::content(req, as = 'text')
    qurl = regmatches(cont, regexpr('https://zenodo.org/record/[0-9]+/files/chemlook.sqlite3.gz', cont))
    utils::download.file(qurl,
                         destfile = destfile_gz,
                         quiet = TRUE)
    R.utils::gunzip(destfile_gz, destname = destfile)
  }
  con = DBI::dbConnect(RSQLite::SQLite(), destfile)
  # TODO convert the whole process to actual SQL queries at some point.
  cl_data = DBI::dbGetQuery(con, "SELECT * FROM cl_data")
  data.table::setDT(cl_data)
  DBI::dbDisconnect(con)
  
  return(cl_data)
}

#' Query the chemical lookup up database..
#' 
#' @import data.table
#' 
#' @param query A query string.
#' @param from Which identifier should the query string be matched against? See
#' details for more information.
#' @param match_query Should the query be matched exactly (default) or fuzzily?
#'
#' @details The from argument can be one of the following identifiers: 
#' \itemize{
#'   \item \code{'cl_id'} - chemlook identifier
#'   \item \code{'name'} - Chemical common name
#'   \item \code{'bvl_id'} - Identifier of the German Bundesamt für
#'   Verbraucherschutz und Lebensmittelsicherheit (BVL)
#'   \item \code{'cas'} - CAS registry number
#'   \item \code{'chebiid'} - ChEBI identifier
#'   \item \code{'chemspiderid'} - Chemspider identifier
#'   \item \code{'dtxsid'} - EPA Dashboard
#'   \item \code{'formula'} - Chemical formula
#'   \item \code{'inchi'} - Inchi identifier
#'   \item \code{'inchikey'} - Inchikey identifier
#'   \item \code{'norman_susdat_id'} - NORMAN network - Identifier
#'   \item \code{'pubchem_cid'} - Pubchem identifier
#'   \item \code{'smiles'} - Smiles
#' }
#'
#' @return Returns a data.table with matched identifiers and chemical
#' classification. The chemical classification column is of type list.
#' 
#' @author Andreas Scharmueller \email{andschar@@protonmail.com}
#' 
#' @export
#' 
#' @examples 
#' query = c('1071-83-6', '100-00-5')
#' cl_query(query, from = 'cas')
#' 
cl_query = function(query = NULL,
                    from = NULL,
                    match_query = 'exact') {
  # data
  out = fl_download()
  # checks
  if (is.null(query)) {
    message('No query string supplied. All entries are returned.')
    return(out)
  }
  if (!is.null(query) && is.null(from)) {
    stop('Please provide a from argument.')
  }
  from = match.arg(from, choices = 
                     c('cl_id', 'name', 'bvl_id', 'cas', 'chebiid',
                       'chemspiderid', 'dtxsid',  'formula', 'inchi',
                       'inchikey', 'norman_susdat_id',
                       'pubchem_cid', 'smiles'))
  match_query = match.arg(match_query, choices = c('fuzzy', 'exact'))
  # filter
  if (match_query == 'exact') {
    out = out[ get(from) %in% query ]
  }
  if (match_query == 'fuzzy') {
    out = out[ get(from) %ilike% paste0(query, collapse = '|') ]
  } 
  
  return(out)
}

