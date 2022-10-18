
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidynlx

<!-- badges: start -->
<!-- badges: end -->

The goal of tidynlx is to allow users a simple way to interface with NLX
API’s and return tidyverse-ready tibbles.

# NLx Research Hub Overview

The NLx Research Hub API provides access to job posting data provided by
the National Labor Exchange in partnership with DirectEmployers. The NLx
has recently completed a migration of its historical data warehouse to a
new data warehouse that improves data processing, reliability, and
availability.

Data from the NLx Research Hub is provided through two APIs: \*
Synchronous API: REST API for paging through data 50 records at a time.
\* Asynchronous API: REST API for downloading large quantities of data
from the NLx Research Hub (i.e. an entire month of jobs data from a
single state or territory).

## Installation

You can install the development version of tidynlx from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ebottatlabor/tidynlx")
```

Note: You must be a collaborator on this project and generate a Personal
Access Token (PAT). For more information on how to download from a
private repo refer to
<https://remotes.r-lib.org/reference/install_github.html> and
<https://usethis.r-lib.org/articles/git-credentials.html>

##Getting Started

Before getting started, you will need to receive an API key. If you have
not received an API key but expect to have received one, please reach
out to <admin@nlxresearchhub.org>.To get started working with
**tidynlx**, users should load the package and set their DOL API key.

``` r
library(tidydol)
library(tidyverse)
nlx_api_key("YOUR API KEY GOES HERE", install=TRUE)
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tidynlx)


## Returns 50 records of job postings data from Kentucky using the synchronous NLX API
df <- get_nlx_synch(state_or_territory = 'ky', page = 1)
#> No encoding supplied: defaulting to UTF-8.


## Returns records of Ohio job postings created betweeen the dates of 2021-06-05 and 2021-06-10 (inclusive). Query leverages the asynchronous NLX API
df <- get_nlx(state_or_territory='OH', start_date = '2021-06-05', end_date = '2021-06-10')
#> Warning: One or more parsing issues, see `problems()` for details
#> Rows: 10865 Columns: 51
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr  (18): file_name, file_id, fein, title, description, link, city, state, ...
#> dbl   (5): system_job_id, job_id, expired, zipcode, application_zipcode
#> lgl  (23): source_state, fedcontractor, parameters_positions_max, parameters...
#> dttm  (5): expired_date, date_compiled, created_date, last_updated_date, dat...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```
