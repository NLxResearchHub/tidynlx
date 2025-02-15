% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_nlx.R
\name{get_nlx}
\alias{get_nlx}
\title{Asynchronous NLX API Wrapper}
\usage{
get_nlx(
  state_or_territory,
  start_date,
  end_date = NULL,
  date_column = "created_date",
  sleep_time = 2,
  silently = TRUE
)
}
\arguments{
\item{state_or_territory}{Two digit state or territory code. This parameter
is not case sensitive.}

\item{start_date}{The start date for the creation_date of job postings
returned by the query (inclusive).}

\item{end_date}{The end date for the creation_date of job postings returned
by the query (inclusive). If no end_date is included the query defaults to
one full day beginning on the start_date.Please note that you cannot
request more than 35 days of data at a time Dates are midnight to midnight,
so 2021-06-01 to 2021-06-02 is one day of data, for 2021-06-01}

\item{date_column}{The date field that start_date and end_date filter by
Options are created_date, date_compiled, last_updated_date, or
date_acquired. Defaults to created_date.}

\item{sleep_time}{The amount of time in seconds between queries to the NLX
API. Avoids rate limitations. Defaults to two seconds.}

\item{silently}{Provides updates on status on the progress of the report
between queries if true. Defaults to `FALSE`}
}
\value{
a tibble
}
\description{
`get_nlx()` generates a report request from the NLX REST API and downloads it
into a tidy tibble. The asynchronous API is intended for downloading large
quantities of data from the NLX Research Hub (i.e. an entire month of jobs
data from a single state or territory).
}
\examples{
df <- get_nlx(state_or_territory='OH', start_date = '2021-06-05', end_date =
'2021-06-10', sleep_time = 10, silently = FALSE)

df <- get_nlx(state_or_territory='ky', start_date = '2021-06-05')
}
