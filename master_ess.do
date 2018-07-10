*Master do-file for qualifying project
*Project description
  /*
  Title: EASTERLIN REVISIT: COHORT SIZE AND HAPPINESS IN THE UNITED KINGDOM
  Coauthors: Dr. Xiaoling Shu, and Mr. Yiwan Ye
  Institution: University of California, Davis
  Data set: European Social Survey: UK Subset 2002 to 2016
  Data configuration: merge all original file into "ess_uk_merge" using 'idno'.
  All original data can be found here:
  <http://www.europeansocialsurvey.org/data/country.html?c=united_kingdom>
  */

*Setting up Stata environment
  */make sure you are using your local drive:
  If not `cd' the working directory to where the ESS dataset is located.
  */
cd "/Users/wanleaf/Documents/Projects/QP/Data"

pwd

  **setting Stata allow maximun variables permanently.
set maxvar 32767, perm

version 15.1 //lastest Stata version at the beginning of this project.

  **list files in the working dir.
ls -F

set more off

use "ess_uk_merge.dta", clear

codebook compact

*end

*Analysis
  /*
  1). Variable exploration
  2). Data transformation
  3). Descriptive statistics (graphs and tables)
  4). OLS modeling (single level)
  5). Export data for HLM Analysis (main models; 2-levels)
    - analysis done in HLM software
  6). Residuals test/Predicted values (graphs and tables)
  8). Export data for sensitivity analysis (axillary models)
    - analysis done in HLM software
  9). Sensitivity test
  */

  man log

cmdlog using master.do
log using masterlog, text

*Variable exploration
  **dependent variables
  **happiness
  browse *happy*

  tabulate happy, missing
    tab happy, nolab m
    histogram happy if happy<77, discrete frequency
      kdensity happy if happy<77
      summarize happy if happy<77, detail
      display as text "average happiness = " as result round(r(mean),0.1)
    /*Note:
    happy measure "how happy are you"
    happiness is a continous variable (OLS preferred it's simpler, the scale is numeric and continous);
    happiness may be a discrete/ordinal variable (not preferred, b/c it has too many categories).

    More on measurement for happiness see:
    <https://worlddatabaseofhappiness.eur.nl/hap_quer/introtext_measures3.pdf>
    */




  log off masterlog.txt

  log on masterlog

log close _all
