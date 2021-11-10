# Climate-Records-processor

A tool used to quantify the number of new records associated with a climate parameter year-after-year. This has been tested on daily precipitation records (Giorgi & Ciarlo`, submitted), and is based on the works of Elguindi et al. (2003), who focused on daily temperature records.


## Requirements

Requirements: NetCDF, Climate Data Operators (CDO), NetCDF Operators (NCO), NCAR Command Language (NCL)

## Usage

The input data needs to be in NetCDF format

Set up a namelist (basic namelist: INPUT.list) in the mynamelists directory (most relevant details depend project needs, but mostly up to and including 'running switches'). 

sub.sh is the main tool needed to run the entire sequence, and multuple statistics (but this can be personalized)

Additional tools are available in the tools directory.


## References

Elguindi N, Rauscher SA, Giorgi F (2013). Historical and future changes in maximum and minimum temperature records. Climatic Change, 117, 415-431.

Giorgi F, Ciarlo` J (submitted). Use of precipitation records to assess the response of extreme events to global warming: Methodology and illustrative application to the European region. International Journal of Climatology.

## Contact 

For any queries please contact jciarlo[at]ictp.it
