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
  2). Variable construction
  3). Bivariate visualization & variable transformation
  4). Descriptive statistics (graphs and tables)
  5). OLS modeling (single level)
  6). Export data for HLM Analysis (main models; 2-levels)
    - analysis done in HLM software
  7). Residuals test/Predicted values (graphs and tables)
  8). Export data for sensitivity analysis (axillary models)
    - analysis done in HLM software
  9). Sensitivity test
  */

  man log

cmdlog using master.do
log using masterlog, text

*Variable exploration
  **dependent variables - subjective wellbeing
  ***happiness
  browse *happy*
  codebook happy
  tabulate happy, missing
    ta happy, nolabel m
  histogram happy if happy<77, discrete frequency
    kdensity happy if happy<77, normal
  summarize happy if happy<77, detail
    display as text "average happiness = " as result round(r(mean),0.1)
    /*comments:
    `happy' measures "how happy are you"
    happiness is a continous variable (OLS preferred it's simpler,
      the scale is numeric and continous);
    happiness may be a discrete/ordinal variable
      (not preferred, b/c it has too many categories).
    More on measurement for happiness see:
    <https://worlddatabaseofhappiness.eur.nl/hap_quer/introtext_measures3.pdf>
    */

  ***life satisfaction
  br stflife
  codebook stflife
  ta stflife, m
    ta stflife, nol m
  hist stflife if stflife<77, dis freq
    kdensity stflife if stflife<77, nor
  su stflife if stflife<77, d
    display as text "average satisfaction = " as result round(r(mean),0.1)
    /*
    `stflife' measures "how satisfied with life as a whole"
    stflife is also considered a constinous variable.
    stflife measure life satisfaction - an indication of subjective well-being (swb).
    happy & stflife will be modeled seperately;
      together they improve robustness for measuring swb.
    */
  **end

  **group level variables (cohort & period) [CONSTRUCTED]
    /*
    save a new copy for constucting new variables for group level data.
    The data will import manually, because observations are small.
    */
  save "/Users/wanleaf/Documents/Projects/QP/Data/ess_uk_newvars.dta", replace
    use "ess_uk_newvars.dta", clear
  ***cohort id
    /*this is the main cohort id; the time period for generations is dirived from BBC.com
    and ONS annual reports
    Construct cohortid var using age or yrbrn.
    */

  ****age
    br *age*
    codebook age
    su age, d
      di as text "average age =" as result round(r(mean),0.1)
    hist age, freq
      kdensity age, nor
    ta age, m
      ta age, nol m

  ****year born
    br *yr*
    codebook yrbrn
    ta yrbrn, m
      ta yrbrn, nol m
    su yrbrn if yrbrn<7777, d
      di as text "average birth year =" as result round(r(mean),0.1)

  ***cohort id
  recode yrbrn (1909/1913 = 100 "1: Edwardian 09-13") (1914/1918 = 101 "2: WW1 14-18") /*
    */(1919/1925 = 102 "3: Interwar 19-25") (1926/1932 = 103 "4: Interwar 26-32")/*
    Silence, anti communist, children are withdrawn and cautious.
    */(1933/1939 = 104 "5: Interwar 33-39") (1940/1945 = 105 "6: WW2 40-45")/*
    */(1946/1952 = 106 "7: Boomers 46-52") (1953/1958 = 107 "8: Boomers 53-58")/*
    late 40s UK continue rationing to rebuild, royal marriage, Olympics.
    */(1959/1965 = 108 "9: Boomers 59-65") (1966/1972 = 109 "10: Gen X 66-72")/*
    De-ration, late 50s true consumer Boom. Labour party lost its seat.
    UK deregulated market. 3% Econ growth rate. Wages increases. Taxes on gentry, more equality.
    */(1973/1978 = 110 "11: Gen X 73-78") (1979/1985 = 111 "12: Gen X 79-85")/*
    1961 has a small recession.
    */(1986/1989 = 112 "13: Millennials 86-89") (1990/1992 = 113 "14: Millennials 90-92")/*
    73 Oil crisis. Moderate recession 73 to 75. Government controlled by Labour
    */(1993/1996 = 114 "15: Millennials 93-96")  (1997/2001 = 115 "16: Gen Z: 97/01") if yrbrn<7777 & yrbrn>1908, generate(cohortid) test
    /*UK switched from manufacture to services economy,
    since 1985 population increase onto until 2010. UK won Falklands War.
      1997 New Labour, regulate interest rate.
    comments:
      1996-2001 may belong to a new generation, but this generation has not been defined yet,
      and they are too small to be a seperate generation or cohorts
      the two individuals from 1885 & 1904 are excluded,
      because they are too small to be their own catergories*/
    tab cohortid, m
      label variable cohortid "Birth Periods of United Kingdom Cohorts from 1909 to 2001"

  recode yrbrn (1909/1915 = 100 "1: 11/15") (1916/1920 = 101 "2: 16/20") /*
      */(1921/1925 = 102 "3: 21/25") (1926/1930 = 103 "4: 26/30") (1931/1935 = 104 "5: 31/35")/*
      */(1936/1940 = 105 "6: 36/40") (1941/1945 = 106 "7: 41/45") (1946/1950 = 107 "8: 46/50")/*
      */(1951/1955 = 108 "9: 51/55") (1956/1960 = 109 "10: 56/60") (1961/1965 = 110 "11: 61/65")/*
      */(1966/1970 = 111 "12: 66/70") (1971/1975 = 112 "13: 71/75") (1976/1980 = 113 "14: 76/80")/*
      */(1981/1985 = 114 "15: 81/85") (1986/1990 = 115 "16: 86/90") (1991/1995 = 116 "17: 91/95")/*
      */(1996/2001 = 117 "18: 96/01") if yrbrn<7777 & yrbrn>1908, gen (cohortid_5y) test
      /*
      This cohortid var divides years into 5-year periods.
        This division is the same in Yang (2008).
        #rename cohortid_5y old_cohortid
      comments:
        Year 1908 and 1910 are grouped into the "11/15" cohort, because they are too small to
        a own cohort and the value are close to "11/15" cohort.
        Year 2001 is grouped into the last cohort.
      */
      tab cohortid_5y, m
        label variable cohortid_5y "Birth Periods of United Kingdom Cohorts from 1909 to 2001 (5-year periods)"

  ***cohort size
    /* The raw cohort size or relative cohort size (see Macunovich & Easterlin 2010)
    is the average number of new births in that birth cohort*/
  gen int cohortsize=.
    replace cohortsize=1.043 if cohortid==101
    replace cohortsize=0.897 if cohortid==102
    replace cohortsize=0.926 if cohortid==103
    replace cohortsize=0.771 if cohortid==104
    replace cohortsize=0.717 if cohortid==105
    replace cohortsize=0.775 if cohortid==106
    replace cohortsize=0.892 if cohortid==107
    replace cohortsize=0.809 if cohortid==108
    replace cohortsize=0.941 if cohortid==109
    replace cohortsize=0.944 if cohortid==110
    replace cohortsize=0.731 if cohortid==111
    replace cohortsize=0.734 if cohortid==112
    replace cohortsize=0.781 if cohortid==113
    replace cohortsize=0.763 if cohortid==114
    replace cohortsize=0.781 if cohortid==115
    replace cohortsize=0.781 if cohortid==116
    /* comments:
    The cohort sizes are based on data from ONS and Statista.com
    <https://www.statista.com/statistics/281956/live-births-in-the-united-kingdom-uk-1900-1930/>
    */
    tab cohortsize, m
      tab cohortsize cohortid, m all exact

  ***relative cohort size (average crude birth rates of a cohort)
  gen int r_cohortsize=.
    replace r_cohortsize=2.408 if cohortid==100
    replace r_cohortsize=2.192 if cohortid==101
    replace r_cohortsize=2.098 if cohortid==102
    replace r_cohortsize=1.685 if cohortid==103
    replace r_cohortsize=1.523 if cohortid==104
    replace r_cohortsize=1.656 if cohortid==105
    replace r_cohortsize=1.758 if cohortid==106
    replace r_cohortsize=1.609 if cohortid==107
    replace r_cohortsize=1.803 if cohortid==108
    replace r_cohortsize=1.659 if cohortid==109
    replace r_cohortsize=1.269 if cohortid==110
    replace r_cohortsize=1.302 if cohortid==111
    replace r_cohortsize=1.365 if cohortid==112
    replace r_cohortsize=1.376 if cohortid==113
    replace r_cohortsize=1.284 if cohortid==114
    replace r_cohortsize=1.199 if cohortid==115
    /* comments:
    Crude birth rate (cdr) definition:
    According to OECD & United Nations Studies in Methods, Glossary
     the number of live births occurring among the population of a given geographical area
      during a given year, per 1,000 mid-year total population of the given geographical
      area during the same year.
    In other word, cbr = average cohort size (new births) / avg. mid-year pop. size in 1k.
    https://stats.oecd.org/glossary/detail.asp?ID=490
    */
    tab r_cohortsize, m
      lab var r_cohortsize "Relative Cohort Size: Average Crude Birth Rates per Cohort"

  gen int cohortsize_5y=.
    replace cohortsize_5y=.847 if cohortid_5y==100
    replace cohortsize_5y=.753 if cohortid_5y==101
    replace cohortsize_5y=.766 if cohortid_5y==102
    replace cohortsize_5y=.66 if cohortid_5y==103
    replace cohortsize_5y=.605 if cohortid_5y==104
    replace cohortsize_5y=.608 if cohortid_5y==105
    replace cohortsize_5y=.669 if cohortid_5y==106
    replace cohortsize_5y=.781 if cohortid_5y==107
    replace cohortsize_5y=.675 if cohortid_5y==108
    replace cohortsize_5y=.74 if cohortid_5y==109
    replace cohortsize_5y=.849 if cohortid_5y==110
    replace cohortsize_5y=.817 if cohortid_5y==111
    replace cohortsize_5y=.686 if cohortid_5y==112
    replace cohortsize_5y=.609 if cohortid_5y==113
    replace cohortsize_5y=.637 if cohortid_5y==114
    replace cohortsize_5y=.686 if cohortid_5y==115
    replace cohortsize_5y=.675 if cohortid_5y==116
    replace cohortsize_5y=.631 if cohortid_5y==117
    /*comments:
    Aux. cohortsize variable, using 5-year period.
    */
    tab cohortsize_5y, m
      tab cohortsize_5y cohortid_5y, m all exact
      tab cohortsize_5y cohortsize, m all exact
  *End

  *Bivariate visualization & variable transformation
  ** Bivariate visualization

  *** Happiness by cohortid_5y
  tab cohortid happy, row col all exact

  bysort cohortid: sum happy
    bysort cohortid: egen avg_happy = mean(happy)
      tab avg_happy, m

  log off masterlog.txt

  log on masterlog

log close _all
