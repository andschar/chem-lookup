#' Download compressed database.
#'
#' @author Andreas Scharmueller \email{andschar@@proton.me}
#'
#' @noRd
#'
fl_download = function(force_download = FALSE) {
  destfile_gz = file.path(tempdir(), 'chemlook.sqlite3.gz')
  destfile = file.path(tempdir(), 'chemlook.sqlite3')
  if (!file.exists(destfile_gz) &&
      !file.exists(destfile) || force_download) {
    message('Downloading data..')
    # HACK this has to done, because doi.org is the only permanent link between versions
    qurl_permanent = 'https://doi.org/10.5281/zenodo.5947274'
    req = httr::GET(qurl_permanent)
    cont = httr::content(req, as = 'text')
    qurl = regmatches(
      cont,
      regexpr(
        'https://zenodo.org/record/[0-9]+/files/chemlook.sqlite3.gz',
        cont
      )
    )
    utils::download.file(qurl,
                         destfile = destfile_gz,
                         quiet = TRUE)
    R.utils::gunzip(destfile_gz, destname = destfile)
  }
  
  return(destfile)
}

#' Read compressed database.
#'
#' @author Andreas Scharmueller \email{andschar@@proton.me}
#'
#' @noRd
#'
fl_read = function(fl,
                   from = NULL,
                   what = 'id',
                   query = NULL,
                   query_match = 'exact') {
  con = DBI::dbConnect(RSQLite::SQLite(), fl)
  # basequery
  q = paste0("SELECT * FROM (SELECT ", paste0(c('cl_id', from), collapse = ', '), " FROM cl_id) t1")
  if ('id' %in% what) {
    q = paste(q, "LEFT JOIN cl_id t_id USING (cl_id)", sep = '\n')
    q = sub(paste0(", ", from), '', q) # HACK
  }
  if ('class' %in% what) {
    q = paste(q, "LEFT JOIN cl_class t_class USING (cl_id)", sep = '\n')
  }
  if ('prop' %in% what) {
    q = paste(q, "LEFT JOIN cl_prop t_prop USING (cl_id)", sep = '\n')
  }
  if (!is.null(query)) {
    if (query_match == 'exact') {
      q = paste(q, paste0("WHERE ", from, " IN ('", paste0(query, collapse = "', '"), "') "), sep = '\n')
    }
    if (query_match == 'fuzzy') {
      q = paste(q, paste0("WHERE ", paste0(from, " LIKE '%", query, "%'", collapse = " OR ")), sep = '\n')
    }
  }
  out = DBI::dbGetQuery(con, q)
  data.table::setDT(out)
  DBI::dbDisconnect(con)
  
  return(out)
}

#' Query the chemical lookup up database..
#'
#' @import data.table
#'
#' @param query A query string.
#' @param query_match Should the query be matched exactly (default) or fuzzily?
#' @param from Which identifier should the query string be matched against? See
#' details for more information.
#' @param what What should be returned? Can be one of 'id' (default), 'class'
#' and 'prop'.
#' @param force_download Force download anyway? Helpful if downloaded file is corrupt.
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
#' @return Returns a data.table.
#'
#' @author Andreas Scharmueller \email{andschar@@proton.me}
#'
#' @export
#'
#' @examples
#' query = c('1071-83-6', '100-00-5')
#' cl_query(query, from = 'cas')
#' query = 'glyph'
#' cl_query(query, query_match = 'fuzzy')
#'
cl_query = function(query = NULL,
                    query_match = 'exact',
                    from = NULL,
                    what = 'id',
                    force_download = FALSE) {
  # download
  fl = fl_download(force_download = force_download)
  # fl = '~/Downloads/chemlook.sqlite3' # DEBUG
  # checks
  if (!is.null(query) && is.null(from)) {
    stop('Please provide a from argument.')
  }
  query_match = match.arg(query_match, choices = c('fuzzy', 'exact'))
  from = match.arg(
    from,
    choices =
      c(
        'cl_id',
        'name',
        'bvl_id',
        'cas',
        'chebiid',
        'chemspiderid',
        'dtxsid',
        'formula',
        'inchi',
        'inchikey',
        'norman_susdat_id',
        'pubchem_cid',
        'smiles'
      )
  )
  what = match.arg(what,
                   choices = c('id', 'class', 'prop'),
                   several.ok = TRUE)
  if (query_match == 'fuzzy' && from != 'name') {
    stop("Fuzzy matching only works with from = 'name'.")
  }
  # read
  out = fl_read(fl = fl,
                from = from,
                what = what,
                query = query,
                query_match = query_match)
  
  return(out)
}
