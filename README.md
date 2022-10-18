
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidynlx

<!-- badges: start -->
<!-- badges: end -->

The goal of tidynlx is to allow users a simple way to interface with NLX
API’s and return tidyverse-ready tibbles.

## NLx Research Hub Overview

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

## Getting Started

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
