
get_nlx <- function(state_or_territory,
                    start_date,
                    end_date = NULL,
                    sleep_time = 2,
                    silently= TRUE) {

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

  if (is.null(end_date)) {
    end_date = as.Date(start_date) +1
  }

  #Throw error if user selects more than 35 days of data
  if (as.numeric(difftime(end_date, start_date, units = 'days'))>35) {
    stop('You cannot request more than 35 days of data at a time. \n  Dates are midnight to midnight, so 2021-06-01 to 2021-06-02 is one day of data')
  }

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

  report_status_url <- report_request_json$data$url

  # wait for the report to complete and query the API until the report is complete
  # Sleep for 2 seconds between requests to avoid rate limitations
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

  return(report_output_df)

}


