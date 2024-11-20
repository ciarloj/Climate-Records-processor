# Climate-Records-processor

A tool used to quantify the number of new records associated with a climate parameter year-after-year. This has been tested on daily precipitation records (Giorgi & Ciarlo`, 2022), and is based on the works of Elguindi et al. (2003), who focused on daily temperature records. 


## Requirements

Requirements: NetCDF, Climate Data Operators (CDO), NetCDF Operators (NCO), NCAR Command Language (NCL)

## Usage

The input data needs to be in NetCDF format

Set up a namelist (basic namelist: INPUT.list) in the mynamelists directory (most relevant details depend project needs, but mostly up to and including 'running switches'). 

sub.sh is the main tool needed to run the entire sequence, and multuple statistics (but this can be personalized)

Additional tools are available in the tools directory. The NCL scripts that plot spatial maps are configured to recognise RegCM and REMO model data, as well as any data used in the analysis of Giorgi & Ciarlo' (2022), Belleri et al. (2023), and Ciarlo' & Giorgi (2024).

Usage of these scripts and method should cite the studies below. 

## References

Elguindi, N., Rauscher, S.A. & Giorgi, F. Historical and future changes in maximum and minimum temperature records over Europe. Climatic Change 117, 415–431 (2013). https://doi.org/10.1007/s10584-012-0528-z

Giorgi, F., & Ciarlò, J. M. (2022). Use of daily precipitation records to assess the response of extreme events to global warming: Methodology and illustrative application to the European region. International Journal of Climatology, 42(14), 7061–7070. https://doi.org/10.1002/joc.7629

Belleri, L., Ciarlo, J. M., Maugeri, M., Ranzi, R., & Giorgi, F. (2023). Continental-scale trends of daily precipitation records in late 20th century decades and 21st century projections: An analysis of observations, reanalyses and CORDEX-CORE projections. International Journal of Climatology, 1–15. https://doi.org/10.1002/joc.8248

Ciarlo', J. M., & Giorgi, F. (2024). An increase in global daily precipitation records in response to global warming based on reanalysis and observations [version 2; peer review: 2 approved]. Open Research Europe. https://doi.org/10.12688/openreseurope.17674.1

## Contact 

For any queries please contact james.ciarlo[at]um.edu.mt
