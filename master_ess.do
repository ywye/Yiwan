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
  1). Variable exploration & construction
  2). Bivariate visualization & variable transformation
  3). Descriptive statistics (graphs and tables)
  4). OLS modeling (single level)
  5). Export data for HLM Analysis (main models; 2-levels)
    - analysis done in HLM software
  6). Residuals test/Predicted values (graphs and tables)
  7). Export data for sensitivity analysis (axillary models)
    - analysis done in HLM software
  8). Sensitivity test
    8.1. Missing data
    8.2. Bernoulli model
  */

  man log

cmdlog using master.do
log using masterlog, text

*1). Variable exploration & variable transformation
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
  gen happy2 = happy if happy<11
    lab val happy2 happy
  tab happy2

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

  gen satisfaction = stflife if stflife<11
    lab val satisfaction stflife
  tab satisfaction

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
  ***group level info imported
    /*
    Alternatively, group level data can be imported from my CONSTRUCTED stata/excle file.
      file name: ess_uk_grouplvl.dta
    */
  save "/Users/wanleaf/Documents/Projects/QP/Data/ess_uk_newvars.dta", replace
    help merge
      pwd
        ls
        use ess_uk_grouplvl.dta, clear
        codebook
        /*
        extract newborn_k; population_k using yrbrn
          optional: cohort_cbr; cbr; groupid
        */
        use "ess_uk_newvars.dta"

    merge m:m yrbrn using "ess_uk_grouplvl.dta", keepus(newborn_k population_k cbr_per) keep(match) nogen
      tab _merge, nolab m
      drop if _merge==2

      rename _merge _merge_grouplvl

    tab1 population_k newborn_k
      codebook newborn_k population_k, d

  ***age/period variables
  ****age
    br *age*
    codebook age
    su age, d
      di as text "average age =" as result round(r(mean),0.1)
      *average age in the sample is around 50 years old - people from the baby boomers cohorts.
      hist age, freq
      kdensity age, nor
    ta age, m
      ta age, nol m

    /*gen an age var that use 15 years old as its reference group;
    and an age squared variable to adjust for the nonlinear age effect on happiness
    */
    gen age_15 = age-15
      tab age_15

    gen age_15_sq = age_15^2
      tab age_15_sq

  ****year born
    br *yr*
    codebook yrbrn
    ta yrbrn, m
      ta yrbrn, nol m
      su yrbrn if yrbrn<7777, d
      di as text "average birth year =" as result round(r(mean),0.1)

  ****period
    br period
    ta period, m

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
    replace cohortsize=1.043 if cohortid==100
    replace cohortsize=0.897 if cohortid==101
    replace cohortsize=0.926 if cohortid==102
    replace cohortsize=0.771 if cohortid==103
    replace cohortsize=0.717 if cohortid==104
    replace cohortsize=0.775 if cohortid==105
    replace cohortsize=0.892 if cohortid==106
    replace cohortsize=0.809 if cohortid==107
    replace cohortsize=0.941 if cohortid==108
    replace cohortsize=0.944 if cohortid==109
    replace cohortsize=0.731 if cohortid==110
    replace cohortsize=0.734 if cohortid==111
    replace cohortsize=0.781 if cohortid==112
    replace cohortsize=0.763 if cohortid==113
    replace cohortsize=0.781 if cohortid==114
    replace cohortsize=0.781 if cohortid==115
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

  ***cohort size every 5 years
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
  **end

  **independent variables (individual level)
    **social economic status variables
    /*
    measurements of social economic status include household income class (proxy for income),
    occupation type/classification (proxy for occupational prestiage),
    and education years (prxoy for level of education/education status).
    */
  ***household income
  br hinctnta hinctnt
    codebook hinctnta hinctnt
  ta hinctnta hinctnt, m

  gen income = hinctnta if hinctnta<13
	  replace income = hinctnt if hinctnt<13
	   lab val income hinctnt
	tab income, m
  	ta income, m nolab
    hist income, discrete frequency
      kdensity income, normal
    sum income, d
      di as text "average income class = " as result round(r(mean),0.1)
    /*
    comments:
    make income based group to zero, and label income with econ classes according to Dennis Gilbert (2002), Beeghly (2004).
    */
		gen hincome = income-1
		lab def hincome 0 "0: The Poorest" 1 "1: Very Poor" 2 "2: Poor" 3 "3: Working Poor" /*
			*/ 4 "4: Working Class" 5 "5: Almost Middle Class" 6 "6: Lower Middle Class" 7 "Middle Class" /*
			*/ 8 "8: Solid Middle Class" 9 "9: Upper Middle Class" 10 "10: Upper Class" 11 "11: Super-Rich", replace
		lab val hincome hincome
		tab hincome, m

  ***occupation/occupation classes
  /*
  combine the two variables into one (job); import CONSTRUCTED
  */
  labvalcombine iscoco isco08, lblname(job)
  gen job = iscoco
    replace job = isco08 if iscoco==.
    lab val job job
  tab job, m
    pwd
      ls
      use ess_uk_newjobs.dta, clear
      codebook, compact
      /*
      [CONTINGENCY NOTE]: I constracted job class based on ESS job title/type and Goldthorpe classification.
      for now we will be using the simple 7 job class I created. The complex will be used for sensitivity analysis.
      merge job_class variable into ess_uk_newvars (current master data set).
      */

    use ess_uk_newvars.dta, clear

  merge 1:1 _n using "ess_uk_newjobs.dta", keepus(job_class) keep(match) nogen
    tab _merge, nolab m

  tab job_class, m
    drop if _merge==2
    *compared that with -> http://www.nomisweb.co.uk/reports/lmp/gor/2092957698/report.aspx#defs

  ***education level
  br eduyrs
  ta eduyrs
    su eduyrs

  recode eduyrs /*
    */(1/10 = 0 "0: 1-10 yrs Less than High School") (11/12 = 1 "1: 11-12 yrs High School")/*
      UK complusory education is on average 11 years, i.e. 5 yrs old to 16 yrs old.
    */(13/14 = 2 "2: 13-14 A-Level or Some Colleges")/*
      The years to degree for UK's BA/MA/PHD are 3, 1, 3 respectively.
      https://www.internationalstudent.com/study-abroad/guide/uk-usa-education-system/
      For OECD data: go to https://stats.oecd.org/#
      "OECD.Stat Education and Training > Education at a Glance
      > Educational attainment and labor-force status
      > Educational attainment of 25-64 year-olds"
    */(15/17 = 3 "3: 15-17 College") (18/100=4 "4: Advance Degree"), gen(edu)
  tab1 edu educ

  ***employment status
  br unemp*
  ta uempla, nolab m
  ta uempli, nolab m

  gen unemploy =.
    replace unemploy = 2 if uempli == 1
    replace unemploy = 1 if uempla == 1
    replace unemploy = 0 if uempla == 0 & uempli == 0
    lab def unemploy 1 "1: unemployed, active" 2 "2: unemployed, inactive" 0 "0: employed"
    lab val unemploy unemploy
    lab var unemploy "Unemployment Status"
  tab unemploy, m
    /*
    Comments: uempla indicates unemployed ppl. who are actively working for jobs;
    uempli indicates unemployed ppl. who are not actively looking for jobs;
    test if uempla is significantly different from uempli.

    Three individuals are marked as both active and inactive.
    I catergorized them as active.
    One possible explaination is that they are looking for job in the long run but not for the moment.
    If that's the case, I think we should consider them as active,
    because these people would be actively looking for jobs if condition allowed.
    */

  ***marital status
  br mar*
  tab1 marital maritala marsts, m nolab
  lab dir
    lab list marital maritala marsts
    /*
    Note 1.: After 2013 UK Marriage Act, Civil Partnership (2004 Act) discontinue,
    maritala (7) - "Formerly in civil partnership, now dissolved" -> divorced
    maritala (8) - "Formerly in civil partnership, partner died" -> widowed
    a civil partnership is able to convert into a marriage.
    Thus we treat same-sex civil partnership as marriage couples.
    Use labels from marital1 as the reference catergory for var marriage

    Note 2.: if there's conflict between "marital" and "maritala", use maritala
    because maritala is more current (ESS4) than marital (ESS1). Respondent probably
    */

  recode marital (1 = 0 "0: Married") (2 = 1 "1: Seperated") (3 = 2 "2: Divorced")/*
    */(4 = 3 "3: Widowed") (5 = 4 "4: Never married") if marital<10, gen(marital1)
  recode maritala (1/2 = 0 "0: Married") (3/4 =1 "1: Seperated") (5 7 =2 "2: Divorced")/*
    */(6 8 = 3 "3: Widowed") (9 = 4 "4: Never married") if maritala<10, gen(marital2)
  recode marsts (1/2=0 "0: Married") (3 =1 "1: Seperated") (4 =2 "2: Divorced")/*
    */(5 = 3 "3: Widowed") (6 = 4 "4: Never married") if marsts<10, gen(marital3)
  tab1 marital1 marital2 marital3, nolab

  gen marriage=.
    replace marriage=0 if marital1==0 | marital2==0 | marital3==0
    replace marriage=1 if marital1==1 | marital2==1 | marital3==1
    replace marriage=2 if marital1==2 | marital2==2 | marital3==2
    replace marriage=3 if marital1==3 | marital2==3 | marital3==3
    replace marriage=4 if marital1==4 | marital2==4 | marital3==4
    lab val marriage marital1
    lab var marriage "marital status"
  tab marriage, m

  ***gender
  tab gndr, nolab
    recode gndr (1 = 0 "0: Male") (2 = 1 "1: Female") if gndr<3, gen(female)
  tab female,m

  ***minority status
  tab blgetmg, nolab
	gen minority=.
		replace minority=0 if blgetmg==2
		replace minority=1 if blgetmg==1
	   lab val minority binary
	    lab var minority "Belong to a minority ethnic group"
	tab minority, m

  ***foriegn born status [Sensitivity Analysis]
    ***proxy for people who migranted to the UK adjust the cohort size effect for these people.
  br BrnCntr
    /*
    were respondents born in the UK?
    */
  br BrnCntr
    /*
    if no, which country were they born?
    */
  br LiveCntr
    /*
    how long age did they first come to live in the UK?
    */

  ***sociality
		tab sclmeet, nolab

		gen sociality = sclmeet-1 if sclmeet<10
		  lab def sociality 0 "0: Never" 1 "1: <1 a month" 2 "2: Once a month" 3 "3: Many times a month" 4 "4: Once a week" 5 "5: Many times a week" 6 "6: Everyday"
		    lab val sociality sociality
    tab sociality

  ***religiousity
  tab rlgdgr

  gen religion = rlgdgr if rlgdgr<11
    lab val religion rlgdgr
  tab religion

  anova age religion
    graph bar (mean) age, by(religion)
    /*religiousity is sign. different across age group*/

  gen notrelig=.
    replace notrelig=0 if religion>0 & religion<.
    replace notrelig=1 if religion==0
    lab val notrelig binary
      lab var notrelig "If not at all religious"
  tab notrelig, m

  ***health status
  tab health, nolab
  br hltp*
    /*
    If pepole are bad health, assume people have good health by default.
    This is subjective health, which correlated with actual health program.
    Use hltp* vars for model robustness check.
    */
  recode health (1/3 = 0) (4/5 = 1) if health<=5, gen(badhealth)
    lab def badhealth 0 "0: Good Health" 1 "1: Bad Health", replace
    lab val badhealth badhealth
    lab var badhealth "If respondent think they have bad health in general"
  tab badhealth, m

  ***Auxilairy variables
  ****panel data set - individuals who have been interviewed before
    duplicates report idno
      duplicates tag idno, gen(flag)
    tab flag, m
    /*
    There are same individuals being studied for more than one cohort.
    flag duplicate observations: individuals who are in the survey more than one time in a different survey year.
    */
      recode flag (0 = 0 "0: First Time Respondent") (1/2 = 1 "1: Returning Respondent"), gen(panel)
    tab panel, m

  ****sampling weights
  su pweight,
    /*
    pweight: Population size weight (must be combined with dweight or pspwght).
    pspwght: Post-stratification weight including design weight.
    dweight: design weight
    */
  su pspwght, d
  su dweight, d

  **End

*Bivariate visualization
  ** Bivariate visualization

  *** Happiness by cohortid_5y
  tab cohortid happy, row col all exact

  bysort cohortid: sum happy
    bysort cohortid: egen avg_happy = mean(happy)
      tab avg_happy, m



*2). Descriptive statistics

*3). OLS modeling
reg happy r_cohortsize age_c age_c_sq i.period

reg happy r_cohortsize age_c age_c_sq i.period hincome i.job_class i.educ

reg happy r_cohortsize age_c age_c_sq i.period hincome i.job_class i.educ i.marriage female minority

reg happy2 r_cohortsize age_c age_c_sq i.period ib7.hincome ib4.job_class ib3.educ i.marriage female minority sociality religion badhealth

*5). HLM Output
  ** save a seperate version for HLM readied data set
  pwd
  save "/Users/wanleaf/Documents/Projects/QP/Data/ess_uk_hlm.dta", replace

** HLM variable transformation
  /*
  1. transform catergorical variables into dummy variables if necessary.
  */
  ***dependent variables:
  ****happiness
  tab happy2, m nolab

  ****life satisfaction
  tab satisfaction, m nolab
  ***ready!

  ***group level independent variables & key predicting variable
  **** relative cohort sizes [key predicting variable]
  tab1 r_cohortsize, m nolab
  su cbr_per, d /*relative cohort size percentage point by year*/

  **** cohort identification
  tab1 cohortid, m nolab

  ***individual level independent variables
  ****income
  tab1 hincome, m nolab

  ****education
  tab1 edu, m nolab
    recode edu (0 = 1 "1: Less than High School") (1/4 = 0 "0: More than High School"), gen (lesshs)
    recode edu (1 = 1 "1: High School Graduates") (0 2/4 = 0 "0: No"), gen (highschool)
    recode edu (2 = 1 "1: A-Level or Some Colleges") (0/1 3/4 = 0 "0: No"), gen (alevel)
    recode edu (3 = 1 "1: College Graduates") (0/2 4 = 0 "0: No"), gen (college)
    recode edu (4 = 1 "1: Advanced Degree") (0/3 = 0 "0: No"), gen (advanced)
  tab1 lesshs highschool alevel college advanced

  ****occupation
  tab1 job_class, m nolab
    tab job_class
    recode job_class (0 = 1 "1: Unskilled workers") (1/6 = 0 "0: No"), gen (unskilled)
    recode job_class (1 = 1 "1: Farm workers") (0 2/6 = 0 "0: No"), gen (farm)
    recode job_class (2 = 1 "1: Skilled workers") (0/1 3/6 = 0 "0: No"), gen (skilled)
    recode job_class (3 = 1 "1: Pink-collar workers") (0/2 4/6 = 0 "0: No"), gen (pinkcollar)
    recode job_class (4 = 1 "1: White-collar workers") (0/3 5/6 = 0 "0: No"), gen (whitecollar)
    recode job_class (5 = 1 "1: Professionals/officials") (0/4 6 = 0 "0: No"), gen (professional)
    recode job_class (6 = 1 "1: Unspecified workers/Unkown/Refuse/Unemployed") (0/5 = 0 "0: No"), gen (unknownjob)
  tab1 unskilled farm skilled pinkcollar whitecollar professional unknownjob

  ****employment status
  tab1 unemploy, m nolab
    recode unemploy (1 = 1 "1: Actively unemployed") (0 2 = 0 "0: No"), gen (unemploy_active)
    recode unemploy (2 = 1 "1: Inactively unemployed") (0/1 = 0 "0: No"), gen (unemploy_inact)

  ****marital Status
  tab1 marriage, m nolab
    recode marriage (0 = 1 "1: Married") (1/4 = 0 "0: No"), gen (married)
    recode marriage (1 = 1 "1: Seperated") (0 2/4 = 0 "0: No"), gen (seperated)
    recode marriage (2 = 1 "1: Divorced") (0/1 3/4 = 0 "0: No"), gen (divorced)
    recode marriage (3 = 1 "1: Widowed") (0/2 4 = 0 "0: No"), gen (widowed)
    recode marriage (4 = 1 "1: Single") (0/3 = 0 "0: No"), gen (single)
  tab1

  ****Sociality
  tab1 sociality, m nolab
    /*
    Not a crucial variable -> collapase the var into 4 catergories to reduce variables
    */
    recode sociality (0 = 1 "1: Never") (1/4 = 0 "0: No"), gen (neversocial)
    recode sociality (1/3 = 1 "1: Sometimes") (0 4/6 = 0 "0: No"), gen (sometimessocial)
    recode sociality (4/5 = 1 "1: Often") (0/3 6 = 0 "0: No"), gen (oftensocial)
    recode sociality (6 = 1 "1: Everyday") (0/5 = 0 "0: No"), gen (socialeveryday)
  tab1 neversocial sometimessocial oftensocial socialeveryday
  ***ready!

  **Order & Sort & Clean
  order idno/*
    */ happy2 satisfaction /*
    */r_cohortsize cbr_per cohortid cohortid_5y /*
    */age_c age_c_sq period yrbrn /*
    */hincome unemploy_active unemploy_inact /*
    */lesshs highschool alevel college advanced /*
    */unskilled farm skilled pinkcollar whitecollar professional unknownjob /*
    */married seperated divorced widowed single /*
    */female minority /*
    */neversocial sometimessocial oftensocial socialeveryday /*
    */notrelig badhealth /*
    */pweight pspwght panel

  sort cohortid yrbrn

  keep idno/*
    */ happy2 satisfaction /*
    */r_cohortsize cbr_per cohortid cohortid_5y /*
    */age_c age_c_sq period yrbrn /*
    */hincome unemploy_active unemploy_inact /*
    */lesshs highschool alevel college advanced /*
    */unskilled farm skilled pinkcollar whitecollar professional unknownjob /*
    */married seperated divorced widowed single /*
    */female minority /*
    */neversocial sometimessocial oftensocial socialeveryday /*
    */notrelig badhealth /*
    */pweight pspwght panel

  export sasxport "/Users/wanleaf/Documents/Projects/QP/Data/ess_uk_hlm.xpt", rename

  **save a different HLM version with no missing values
  save "/Users/wanleaf/Documents/Projects/QP/Data/ess_uk_hlm_nm.dta"

  foreach v of var * {
  drop if missing(`v')
  }

  save "/Users/wanleaf/Documents/Projects/QP/Data/ess_uk_hlm_nm.dta", replace

  export sasxport "/Users/wanleaf/Documents/Projects/QP/Data/ess_uk_hlm_nm.xpt", rename
  **End HLM ouput

*End code
  log off masterlog.txt

  log on masterlog

log close _all
