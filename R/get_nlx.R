#' Asynchronous NLX API Wrapper
#'
#' `get_nlx()` generates a report request from the NLX REST API and downloads it
#' into a tidy tibble. The asynchronous API is intended for downloading large
#' quantities of data from the NLX Research Hub (i.e. an entire month of jobs
#' data from a single state or territory).
#'
#' @param state_or_territory Two digit state or territory code. This parameter
#'   is not case sensitive.
#' @param start_date The start date for the creation_date of job postings
#'   returned by the query (inclusive).
#' @param end_date The end date for the creation_date of job postings returned
#'   by the query (inclusive). If no end_date is included the query defaults to
#'   one full day beginning on the start_date.Please note that you cannot
#'   request more than 35 days of data at a time Dates are midnight to midnight,
#'   so 2021-06-01 to 2021-06-02 is one day of data, for 2021-06-01
#' @param date_column The date field that start_date and end_date filter by
#'   Options are created_date, date_compiled, last_updated_date, or
#'   date_acquired. Defaults to created_date.
#' @param sleep_time The amount of time in seconds between queries to the NLX
#'   API. Avoids rate limitations. Defaults to two seconds.
#' @param silently Provides updates on status on the progress of the report
#'   between queries if true. Defaults to `FALSE`
#'
#' @return a tibble
#' @export
#'
#' @examples
#' df <- get_nlx(state_or_territory='OH', start_date = '2021-06-05', end_date =
#' '2021-06-10', sleep_time = 10, silently = FALSE)
#'
#' df <- get_nlx(state_or_territory='ky', start_date = '2021-06-05')
get_nlx <- function(state_or_territory,
                    start_date,
                    end_date = NULL,
                    date_column = 'created_date',
                    sleep_time = 2,
                    silently= TRUE) {


  report_status_url <- nlx_report_request(state_or_territory = state_or_territory,
                                          start_date = start_date,
                                          end_date = end_date,
                                          date_column = date_column)


  report_output_df <- nlx_download_report(report_status_url = report_status_url,
                                       sleep_time = sleep_time,
                                       silently = silently)

  return(tibble::as_tibble(report_output_df))

}



nlx_report_request <- function(state_or_territory,
                        start_date,
                        end_date = NULL,
                        date_column = 'created_date') {


  ## Error handling

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

  #Error if invalid date_column selection
  if (!(date_column %in% c('created_date', 'date_compiled', 'last_updated_date', 'date_acquired'))) {
    stop('Not a valid date_column choice. Please input either created_date, date_compiled, last_updated_date, or date_acquired')
  }

  # If no end date is provided the function defaults to returning one day's worth of data
  if (is.null(end_date)) {
    end_date = as.Date(start_date) +1
  }

  #Throw error if user selects more than 35 days of data
  if (as.numeric(difftime(end_date, start_date, units = 'days'))>35) {
    stop('You cannot request more than 35 days of data at a time. \n  Dates are midnight to midnight, so 2021-06-01 to 2021-06-02 is one day of data')
  }

  #Throw error if user does not select end date that is greater than start date
  if (!(end_date>start_date)) {
    stop('End date must be strictly greater than start date')
  }

  #Throw error if user does not select end date that is greater than start date
  if (end_date>=Sys.Date()) {
    stop("end_date must occur before today's date")
  }


  ## Query logic
  query_params = list(
    #Use an upper-case two digit code for the state or territory you intend to query
    state_or_territory = toupper(state_or_territory),
    # Start date of the results (inclusive)
    start = start_date,
    end = end_date,
    format = 'csv'
  )


  report_request_response <- httr::POST('https://api.nlxresearchhub.org/api/job_reports/',
                                        httr::add_headers('X-API-KEY' = api_key,
                                                          'Content-Type' = 'application/json'),
                                        body = query_params,
                                        encode = 'json')

  report_request_json <- jsonlite::fromJSON(httr::content(report_request_response, as = "text", encoding = "UTF-8"))

  return(report_request_json$data$url)
}



nlx_download_report <- function(report_status_url,
                                sleep_time = 2,
                                silently = TRUE) {




  if (Sys.getenv('NLX_API_KEY') != '') {
    api_key <- Sys.getenv('NLX_API_KEY')
  } else if (is.null(key)) {
    stop('An NLX API key is required. If you have not received an API key but
           expect to have received one, please reach out to admin@nlxresearchhub.org.,
           and then supply the key to the `nlx_api_key` function to use it throughout your tidynlx sessions.')
  }

  not_done <- TRUE

  while (not_done) {

    Sys.sleep(sleep_time)

    report_status_response <- httr::GET(report_status_url,
                                        httr::add_headers('X-API-KEY' = api_key,
                                                          'Content-Type' = 'application/json'))

    report_status_json <-jsonlite::fromJSON(httr::content(report_status_response, as="text", encoding = "UTF-8"))

    if(!silently) {
      print("Report processing...")
    }

    try(
      if(report_status_json$data$status == 'done') {
        not_done = FALSE
      } else {
        if (!silently) {
          print(paste("Status: ", report_status_json$data$status))
        }
      },
      silent = TRUE
    )
  }

  if(!silently) {
    print('Report is done. Downloading...')
  }

  Sys.sleep(sleep_time)

  report_output_df <- readr::read_csv(report_status_json$data$resource$link)

  return(tibble::as_tibble(report_output_df))
}
