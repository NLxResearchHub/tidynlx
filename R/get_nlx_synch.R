#' Synchronous NLX API Wrapper
#'
#' `get_nlx_synch()` accesses the synchronous NLX REST API for paging through data 50 records at a time.
#'
#' @param state_or_territory two digit state or territory code. This parameter is not case sensitive.
#' @param page the page number of results to return.
#'
#' @return a tibble
#' @export
#'
#' @examples
#' get_nlx_synch(state_or_territory = 'ky', page = 1)
#'
#'

get_nlx_synch <- function(state_or_territory,
                          page = 1) {


  # Checks to see if the user has supplied an NLX API key to the nlx_api_key function
  if (Sys.getenv('NLX_API_KEY') != '') {
    api_key <- Sys.getenv('NLX_API_KEY')
  } else if (is.null(key)) {
    stop('An NLX API key is required. If you have not received an API key but
         expect to have received one, please reach out to admin@nlxresearchhub.org.,
         and then supply the key to the `nlx_api_key` function to use it throughout your tidynlx sessions.')
  }

  #Error if user uses invalid state or territory code
  if (!(toupper(state_or_territory) %in% c('AL','AK','AS','AZ','AR','CA','CO','CT','DE','DC','FL','GA','GU','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','PR','RI','SC','SD','TN','TX','UT','VT','VA','VI','WA','WV','WI','WY'))) {
    stop('You must enter a valid two letter state or territory abbreviation')
  }

  params = list(
    #Use an upper-case two digit code for the state or territory you intend to query
    state_or_territory = toupper(state_or_territory),
    # Start date of the results (inclusive)
    page = page)

  r <- httr::GET('https://api.nlxresearchhub.org/api/jobs/',
                 httr::add_headers('X-API-KEY' = api_key,
                                   'Content-Type' = 'application/json'),
                 query=params)

  r_content <- jsonlite::fromJSON(httr::content(r, as = "text", encoding = "UTF-8"))

  df <- tibble::as_tibble(r_content$data)

  return(df)

}
