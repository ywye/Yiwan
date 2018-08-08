//ESS Prelim Data Analysis
use "UK_Prelim.dta"

set more off

codebook, compact

//Data Transformation

	//Dependent Var. Happy!!
	//Overall happy
			//still need the old var happy as independent var if dataset does not have var happy.
			merge 1:1 _n using "UK_Prelim.dta", keepusing(happy)

				tab _merge, nolab m
				drop if _merge==2

	//Occupation
			//save dta 7.2
				//In old full data
				labvalcombine iscoco isco08, lblname(job)
				lab val job job

			cd "/Users/wanleaf/Documents/Projects/UK Population/Data/Prelim"

			merge 1:1 _n using "UK_Prelim_v2.0.dta", keepusing(job)



		tab happy, nolab

		gen happy_all = happy if happy<=10

		lab val happy_all happy


		//logistic form: ifhappy, 5 is neutral -> not happy nor sad, so in this case it's consider not happy.
		recode happy_all (0/5 = 0) (6/10 = 1), gen(ifhappy)

		lab def ifhappy 1 "1: Happy" 0 "0: Not Happy & Nuetral", replace
		lab val ifhappy ifhappy
		lab var ifhappy "If Respondent is happy in general (>5)"

		tab ifhappy

				recode happy_all (0/6 = 0) (7/10 = 1), gen(ifhappy2)


	//There are same individuals being studied for more than one cohort.

		duplicates report idno
		duplicates tag idno, gen(idno_flag)

			tab idno_flag, m

		//flag duplicate observations: individuals who are in the survey more than one time in a different survey year.

		recode idno_flag (0 = 0 "0: First Time Respondent") (1/2 = 1 "1: Returning Respondent"), gen(panel)

			tab panel, m


	//HAPPY Version 2 or very happy
		//UK in general is "happy" - median happiness is 8, average happiness is 7.5 round. Having a strict 5 as neutral happiness is not culturally realistic.
		//Since average happy is at least 7 and above, thus a person with a 6 is considered "not content but not misearble", thus anything below 6 should consider low bar.
		//For cross countries analysis, we want to use relative happiness (country specific median/average) to measure happiness, because the fixed happiness point are country specific.
		//Thus both 5/6 is considered a netural state.
		//A very happy var will exclude items that seems moderate happy i.e. 6,7, 8, or ppl above 75 percentile.
		sum happy_all, d
			//25% of pop. (a quarter) rate 9 and above, so 9 and 10 will consider very happy. Moderately happy is difficult to define and speculate.

		recode happy (0/8 = 0) (9/10 = 1) if happy<=10, gen(veryhappy)

			tab ifhappy veryhappy, m

		recode happy_all (0/6 = 0) (7/10 = 1) if happy_all<=10, gen(ifhappy2)

			tab ifhappy2, m

//tab stflife ifhappy if , chi

		stflife



	//Time/Group ID Var.
	//Birth Cohort
		tab yrbrn, m
		tab yrbrn, nolab m

		list agea gndr if bcohort==1885

		hist bcohort if bcohort>1900
		kdensity bcohort

		/*For the sake for this prelim analysis, I excluded people born before 1911
		(Pre WW1 Stable Econ) and born afer 2000 (9/11)
		& make a Birth Cohort var for every 5 years.
		Sorry for excluding that one girl who is 123 yr old*/

		gen prelim_cohort = yrbrn if yrbrn<=2001 & yrbrn>=1911
		tab prelim_cohort, m

		//This is one of the most important string of code, label your cat. wisely!
		//The Greatest 1900 to 25, Silience: 1926 to 1945, BabyB: 1946 to 1960, Gen X: 1961 to 1980. Gen Y: 1981 to 1995. Gen Z: 1996 onward.
		//A coming-of-age cohort variable. Match the birth cohort to the period when they turn 20s until 40s.

		recode prelim_cohort (1911/1915 = 1 "1: THE GREATEST 11-15") (1916/1920 = 2 "2: WW1 16-20") /*
			*/(1921/1925 = 3 "3: Great Depression 21-25") (1926/1930 = 4 "4: Consumer Boom? 26-30") /*Silence, anti communist, children are withdrawn and cautious.
			*/(1931/1935 = 5 "5: Great Slump 31-35") (1936/1940 = 6 "6: Recover & WW2 36-40")/*
			*/(1941/1945 = 7 "7: WW2 Victory 41-45") (1946/1950 = 8 "8: Baby Boom 46-50") /* late 40s UK continue rationing to rebuild, royal marriage, Olympics.
			*/(1951/1955 = 9 "9: Fall of Empire 51-55") (1956/1960 = 10 "10: Golden Age 56-60") /*De-ration, late 50s true consumer Boom. Labour party lost its seat. UK deregulated market. 3% Econ growth rate. Wages increases. Taxes on gentry, more equality.
			*/(1961/1965 = 11 "11: Gen X 2nd Boom 61-65") (1966/1970 = 12 "12: Stagnation 66-70")/* 1961 has a small recession.
			*/(1971/1975 = 13 "13: Pop Bust & Recess 71-75") (1976/1980 = 14 "14: Nationalisation 76-80")/* 73 Oil crisis. Moderate recession 73 to 75. Government controlled by Labour
			*/(1981/1985 = 15 "15: Gen Y Recess 81-85") (1986/1990 = 16 "16: 3rd Pop Boom 86-90")/*UK switched from manufacture to services economy, since 1985 population increase onto until 2010. UK won Falklands War.
			*/(1991/1995 = 17 "17: Recess & Recover 91-96") (1996/2000 = 18 "18: Gen Z 96-00")/* 1997 New Labour, regulate interest rate.
			*/,gen(cohort_5y)

		lab var cohort_5y "5-Year Birth Cohort of ESS United Kingdom Population"

		tab cohort_5y, m

		hist cohort_5y, frequency addlabels

	//Age Group
		tab agea
		gen age = agea if agea<130 & cohort5y!=.

		tab age
		hist age, frequency addlabels

			//Square age, for non-linear distribution
			gen age_sq = age*age

			//center age around minimun respondent age->15
				gen age_c = age-15
				gen age_c_sq = (age_c)^2


//Use # of Births as the Cohort ID in ks
	gen birth_id = round(births)

	codebook birth_id cohort

		tab birth_id
		kdensity birth_id

//Generation divided into 3 cohorts: bigger 3rd cohort.
	gen cohort_3p=.
	replace cohort_3p=1000 if yrbrn>=1914 & yrbrn<=1920
	replace cohort_3p=1001 if yrbrn>=1921 & yrbrn<=1927
	replace cohort_3p=1002 if yrbrn>=1928 & yrbrn<=1935
	replace cohort_3p=1003 if yrbrn>=1936 & yrbrn<=1939
	replace cohort_3p=1004 if yrbrn>=1940 & yrbrn<=1943
	replace cohort_3p=1005 if yrbrn>=1944 & yrbrn<=1948
	replace cohort_3p=1006 if yrbrn>=1949 & yrbrn<=1954
	replace cohort_3p=1007 if yrbrn>=1955 & yrbrn<=1960
	replace cohort_3p=1008 if yrbrn>=1961 & yrbrn<=1967
	replace cohort_3p=1009 if yrbrn>=1968 & yrbrn<=1971
	replace cohort_3p=1010 if yrbrn>=1972 & yrbrn<=1975
	replace cohort_3p=1011 if yrbrn>=1976 & yrbrn<=1979
	replace cohort_3p=1012 if yrbrn>=1980 & yrbrn<=1984
	replace cohort_3p=1013 if yrbrn>=1985 & yrbrn<=1989
	replace cohort_3p=1014 if yrbrn>=1990 & yrbrn<=1994
	replace cohort_3p=1015 if yrbrn>=1995 & yrbrn<=2001



	la de cohort_3p 1000 "Greatest I: 14-20" 1001 "Greatest II: 21-27" 1002 "Greatest III: 28-35" 1003 "Silence I:36-39" 1004 "Silence II:40-43" /*
	*/ 1005 "Silence III: 44-48" 1006 "Baby Boomer I: 49-54" 1007 "Baby Boomer II: 55-60" 1008 "Baby Boomer III: 61-67" 1009 "Gen X I:68-71" /*
	*/ 1010 "Gen X II: 72-75" 1011 "Gen X III:76-79" 1012 "Gen Y I: 80-84" 1013 "Gen Y II: 85-89" 1014 "Gen Y III: 90-94" 1015 "Gen Z I: 95-00", replace

	/*14-20: WW1; 21-27 Interwar Unemployment; 28-35 Great Depression;
	36-39 Prewar Stability; 40-43 WW2; 44-48 Postwar Consensus (Welfare);
	49-54 End of Rationing; 55-60 Fall of Empire; 61-67 Baby Boom;
	68-71 Baby Bust; 72-75 Stagnation; 76-79 Winter of Discontent;
	80-84 Thatcher Era; 85-89 Privatization 90-94 Small Boom
	95-00 New Labour*/

	//http://www.bbc.co.uk/history/british/timeline/worldwars_timeline_noflash.shtml
	//https://www.jstor.org/stable/136920?seq=1#page_scan_tab_contents
	//http://www.bbc.co.uk/history/british/modern/thatcherism_01.shtml

	label var cohort_3p "3-year cohort id"

	la val cohort_3p cohort_3p

	tab cohort_3p

	gen size_3p=.
	replace size_3p=0.93 if cohort_3p==1000
	replace size_3p=0.845 if cohort_3p==1001
	replace size_3p=0.732 if cohort_3p==1002
	replace size_3p=0.721 if cohort_3p==1003
	replace size_3p=0.789 if cohort_3p==1004
	replace size_3p=0.92 if cohort_3p==1005
	replace size_3p=0.807 if cohort_3p==1006
	replace size_3p=0.881 if cohort_3p==1007
	replace size_3p=0.987 if cohort_3p==1008
	replace size_3p=0.918 if cohort_3p==1009
	replace size_3p=0.762 if cohort_3p==1010
	replace size_3p=0.701 if cohort_3p==1011
	replace size_3p=0.731 if cohort_3p==1012
	replace size_3p=0.771 if cohort_3p==1013
	replace size_3p=0.776 if cohort_3p==1014
	replace size_3p=0.714 if cohort_3p==1015

//Generation divided into 3 cohorts: bigger 1st cohort.

	gen cohort_3pv2=.
	replace cohort_3pv2=1000 if yrbrn>=1914 & yrbrn<=1921
	replace cohort_3pv2=1001 if yrbrn>=1922 & yrbrn<=1928
	replace cohort_3pv2=1002 if yrbrn>=1929 & yrbrn<=1935
	replace cohort_3pv2=1003 if yrbrn>=1936 & yrbrn<=1940
	replace cohort_3pv2=1004 if yrbrn>=1941 & yrbrn<=1944
	replace cohort_3pv2=1005 if yrbrn>=1945 & yrbrn<=1948
	replace cohort_3pv2=1006 if yrbrn>=1949 & yrbrn<=1955
	replace cohort_3pv2=1007 if yrbrn>=1956 & yrbrn<=1961
	replace cohort_3pv2=1008 if yrbrn>=1962 & yrbrn<=1967
	replace cohort_3pv2=1009 if yrbrn>=1968 & yrbrn<=1971
	replace cohort_3pv2=1010 if yrbrn>=1972 & yrbrn<=1975
	replace cohort_3pv2=1011 if yrbrn>=1976 & yrbrn<=1979
	replace cohort_3pv2=1012 if yrbrn>=1980 & yrbrn<=1984
	replace cohort_3pv2=1013 if yrbrn>=1985 & yrbrn<=1989
	replace cohort_3pv2=1014 if yrbrn>=1990 & yrbrn<=1994
	replace cohort_3pv2=1015 if yrbrn>=1995 & yrbrn<=2001

	gen size_3pv2=.
	replace size_3pv2=0.92 if cohort_3pv2==1000
	replace size_3pv2=0.876 if cohort_3pv2==1001
	replace size_3pv2=0.738 if cohort_3pv2==1002
	replace size_3pv2=0.726 if cohort_3pv2==1003
	replace size_3pv2=0.744 if cohort_3pv2==1004
	replace size_3pv2=0.912 if cohort_3pv2==1005
	replace size_3pv2=0.81 if cohort_3pv2==1006
	replace size_3pv2=0.855 if cohort_3pv2==1007
	replace size_3pv2=0.98 if cohort_3pv2==1008
	replace size_3pv2=0.918 if cohort_3pv2==1009
	replace size_3pv2=0.762 if cohort_3pv2==1010
	replace size_3pv2=0.701 if cohort_3pv2==1011
	replace size_3pv2=0.731 if cohort_3pv2==1012
	replace size_3pv2=0.771 if cohort_3pv2==1013
	replace size_3pv2=0.776 if cohort_3pv2==1014
	replace size_3pv2=0.714 if cohort_3pv2==1015

	tab1 size_3pv2 size_3p


	//Relabel group ID
	gen cohort_5yr=cohort_5y+1000

		label def cohort_5yr 1001 "1: THE GREATEST 11-15" 1002 "2: WW1 16-20" /*
			*/1003 "3: Great Depression 21-25" 1004 "4: Consumer Boom? 26-30" /*Silence, anti communist, children are withdrawn and cautious.
			*/1005 "5: Great Slump 31-35" 1006 "6: Recover & WW2 36-40"/*
			*/1007 "7: WW2 Victory 41-45" 1008 "8: Baby Boom 46-50" /* late 40s UK continue rationing to rebuild, royal marriage, Olympics.
			*/1009 "9: Fall of Empire 51-55" 1010 "10: Golden Age 56-60" /*De-ration, late 50s true consumer Boom. Labour party lost its seat. UK deregulated market. 3% Econ growth rate. Wages increases. Taxes on gentry, more equality.
			*/1011 "11: Gen X 2nd Boom 61-65" 1012 "12: Stagnation 66-70"/* 1961 has a small recession.
			*/1013 "13: Pop Bust & Recess 71-75" 1014 "14: Nationalisation 76-80"/* 73 Oil crisis. Moderate recession 73 to 75. Government controlled by Labour
			*/1015 "15: Gen Y Recess 81-85" 1016 "16: 3rd Pop Boom 86-90"/*UK switched from manufacture to services economy, since 1985 population increase onto until 2010. UK won Falklands War.
			*/1017 "17: Recess & Recover 91-96" 1018 "18: Gen Z 96-00"
		lab val cohort_5yr cohort_5yr
		tab cohort_5yr

//Birth Rates instead of cohort size, use

	gen birth_r = round(birth_m/.569259-1, .0001)

		tab birth_m

	gen birth_5y =.
		replace birth_5y=.846855 if cohort_5y==1
		replace birth_5y=.753349 if cohort_5y==2
		replace birth_5y=.765517 if cohort_5y==3
		replace birth_5y=.660297 if cohort_5y==4
		replace birth_5y=.604573 if cohort_5y==5
		replace birth_5y=.608330 if cohort_5y==6
		replace birth_5y=.669269 if cohort_5y==7
		replace birth_5y=.780933 if cohort_5y==8
		replace birth_5y=.675420 if cohort_5y==9
		replace birth_5y=.739587 if cohort_5y==10
		replace birth_5y=.848554 if cohort_5y==11
		replace birth_5y=.816657 if cohort_5y==12
		replace birth_5y=.685576 if cohort_5y==13
		replace birth_5y=.608842 if cohort_5y==14
		replace birth_5y=.636558 if cohort_5y==15
		replace birth_5y=.685994 if cohort_5y==16
		replace birth_5y=.675041 if cohort_5y==17
		replace birth_5y=.630959 if cohort_5y==18


//Crude Birth rate: average births in millions per 5-year-cohort (since 1911 to 2000) over total population in millions times 1000. Cohort 1 only include year 1914 & 1915. The rest of cohorts include 5 years.

	gen birthrate=.
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==1
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==2
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==3
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==4
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==5
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==6
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==7
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==8
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==9
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==10
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==11
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==12
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==13
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==14
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==15
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==16
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==17
		replace birthrate=birth_5y*1000/cohort_pop if cohort_5y==18

		tab birthrate

//Baby Boomer 1946-1950 cohort no.8 as the reference group for birthrate

	 gen br = birthrate-15.43346

	//Period or interview year group *indent shortcut is"control + ]"
		tab essround

		gen period = essround-1
		lab def period 0 "2002" 1 "2004" 2 "2006" 3 "2008" 4 "2010" 5 "2012" 6 "2014" 7 "2016", replace
		lab val period period
		lab var period "Period: ESS Interview Year"

		tab period, nolab

//Every 3 yr cohort, divide each generation into smaller 3-year cohorts
	//some cohorts have 4 year.
	gen cohort_3yr=.
	replace cohort_3yr=. if yrbrn>=1900 & yrbrn<=1913
	replace cohort_3yr=1000 if yrbrn>=1914 & yrbrn<=1916
	replace cohort_3yr=1001 if yrbrn>=1917 & yrbrn<=1919
	replace cohort_3yr=1002 if yrbrn>=1920 & yrbrn<=1922
	replace cohort_3yr=1003 if yrbrn>=1923 & yrbrn<=1925
	replace cohort_3yr=1004 if yrbrn>=1926 & yrbrn<=1928
	replace cohort_3yr=1005 if yrbrn>=1929 & yrbrn<=1931
	replace cohort_3yr=1006 if yrbrn>=1932 & yrbrn<=1935
	replace cohort_3yr=1007 if yrbrn>=1936 & yrbrn<=1938
	replace cohort_3yr=1008 if yrbrn>=1939 & yrbrn<=1941
	replace cohort_3yr=1009 if yrbrn>=1942 & yrbrn<=1945
	replace cohort_3yr=1010 if yrbrn>=1946 & yrbrn<=1948
	replace cohort_3yr=1011 if yrbrn>=1949 & yrbrn<=2051
	replace cohort_3yr=1012 if yrbrn>=1952 & yrbrn<=1954
	replace cohort_3yr=1013 if yrbrn>=1955 & yrbrn<=1957
	replace cohort_3yr=1014 if yrbrn>=1958 & yrbrn<=1960
	replace cohort_3yr=1015 if yrbrn>=1961 & yrbrn<=1964
	replace cohort_3yr=1016 if yrbrn>=1965 & yrbrn<=1967
	replace cohort_3yr=1017 if yrbrn>=1968 & yrbrn<=1970
	replace cohort_3yr=1018 if yrbrn>=1971 & yrbrn<=1973
	replace cohort_3yr=1019 if yrbrn>=1974 & yrbrn<=1976
	replace cohort_3yr=1020 if yrbrn>=1977 & yrbrn<=1979
	replace cohort_3yr=1021 if yrbrn>=1980 & yrbrn<=1982
	replace cohort_3yr=1022 if yrbrn>=1983 & yrbrn<=1985
	replace cohort_3yr=1023 if yrbrn>=1986 & yrbrn<=1988
	replace cohort_3yr=1024 if yrbrn>=1989 & yrbrn<=1991
	replace cohort_3yr=1025 if yrbrn>=1992 & yrbrn<=1994
	replace cohort_3yr=1026 if yrbrn>=1995 & yrbrn<=1997
	replace cohort_3yr=1027 if yrbrn>=1998 & yrbrn<=2000


		// UK's Baby Boom lagged 1 cohort after WW2 than the U.S. due to postwar reconstruction. The entire 60s is baby boomers cohort.
		//https://www.careerplanner.com/Career-Articles/Generations.cfm
	la de cohort_3yr 1000 "Greatest: 14-16" 1001 "Greatest: 17-19" 1002 "Greatest: 20-22" 1003 "Greatest: 23-25" 1004 "Greatest: 26-28" 1005 "Greatest: 29-31" /*
	*/ 1006 "Greatest: 32-35" 1007 "Silence: 36-38" 1008 "Silence: 39-41" 1009 "Silence: 42-45" 1010 "Silence: 46-48" 1011 "Baby Boomers: 49-51" 1012 "Baby Boomers: 52-54" /*
	*/ 1013 "Baby Boomers: 55-57" 1014 "Baby Boomers: 58-60" 1015 "Baby Boomers: 61-64" 1016 "Baby Boomers: 65-67" 1017 "Gen X: 68-70" 1018 "Gen X: 71-73" 1019 "Gen X: 74-76" /*
	*/ 1020 "Gen X: 77-79" 1021 "Gen Y: 80-82" 1022 "Gen Y: 83-85" 1023 "Gen Y: 86-88" 1024 "Gen Y: 89-91" 1025 "Gen Y: 92-94" 1026 "Gen Z: 95-97" 1027 "Gen Z: 98-00", replace

	label var cohort "3-year cohort id"
		la val cohort_3yr cohort_3yr

	//Every 3yr cohort birth size
	gen birth_3yr=.
		replace birth_3yr=0.97 if cohort_3yr==0
		replace birth_3yr=0.801 if cohort_3yr==1
		replace birth_3yr=1.017 if cohort_3yr==2
		replace birth_3yr=0.869 if cohort_3yr==3
		replace birth_3yr=0.795 if cohort_3yr==4
		replace birth_3yr=0.76 if cohort_3yr==5
		replace birth_3yr=0.711 if cohort_3yr==6
		replace birth_3yr=0.726 if cohort_3yr==7
		replace birth_3yr=0.707 if cohort_3yr==8
		replace birth_3yr=0.814 if cohort_3yr==9
		replace birth_3yr=0.962 if cohort_3yr==10
		replace birth_3yr=0.823 if cohort_3yr==11
		replace birth_3yr=0.797 if cohort_3yr==12
		replace birth_3yr=0.822 if cohort_3yr==13
		replace birth_3yr=0.889 if cohort_3yr==14
		replace birth_3yr=0.981 if cohort_3yr==15
		replace birth_3yr=0.98 if cohort_3yr==16
		replace birth_3yr=0.923 if cohort_3yr==17
		replace birth_3yr=0.839 if cohort_3yr==18
		replace birth_3yr=0.703 if cohort_3yr==19
		replace birth_3yr=0.709 if cohort_3yr==20
		replace birth_3yr=0.735 if cohort_3yr==21
		replace birth_3yr=0.734 if cohort_3yr==22
		replace birth_3yr=0.772 if cohort_3yr==23
		replace birth_3yr=0.793 if cohort_3yr==24
		replace birth_3yr=0.764 if cohort_3yr==25
		replace birth_3yr=0.73 if cohort_3yr==26
		replace birth_3yr=0.698 if cohort_3yr==27

//Centeralizing birth size
		//The average number of birth between 1900 to 2016 is about 0.84 millions.
		//Round to the nearest 1 decimal for simplief calculation.
		gen c_birth_3yr = birth_3yr-0.8
			tab c_birth_3yr ifhappy, row

		//generation 6 gens, including gen z
		recode cohort_3yr (1000/1006 = 0 "The Greatest") (1007/1010 = 1 "The Silence") (1011/1016 = 2 "Baby Boomers") (1017/1020 = 3 "Gen X") (1021/1025 = 4 "Gen Y") (1026/1027 = 5 "Gen Z"), gen(generation)
			tab generation

		//For now use the last year population size for each 5-year generation. Unit in millions. E.g. use 1920's population for cohort 1916 to 1920
		//http://www.populstat.info/Europe/unkingdc.htm
		//https://data.worldbank.org/indicator/SP.POP.TOTL?end=2016&locations=GB&start=1960&view=chart
		gen cohort_pop =.
		replace cohort_pop = 40.1 if cohort_5y==1
		replace cohort_pop = 42.4 if cohort_5y==2
		replace cohort_pop = 45 if cohort_5y==3
		replace cohort_pop = 45.9 if cohort_5y==4
		replace cohort_pop = 46.9 if cohort_5y==5
		replace cohort_pop = 48.2 if cohort_5y==6
		replace cohort_pop = 49.2 if cohort_5y==7
		replace cohort_pop = 50.6 if cohort_5y==8
		replace cohort_pop = 51.4 if cohort_5y==9
		replace cohort_pop = 52.4 if cohort_5y==10
		replace cohort_pop = 54.4 if cohort_5y==11
		replace cohort_pop = 55.4 if cohort_5y==12
		replace cohort_pop = 55.9 if cohort_5y==13
		replace cohort_pop = 56.3 if cohort_5y==14
		replace cohort_pop = 56.8 if cohort_5y==15
		replace cohort_pop = 57.7 if cohort_5y==16
		replace cohort_pop = 58.5 if cohort_5y==17
		replace cohort_pop = 59.5 if cohort_5y==18

		tab1 cohort_5y cohort_pop, m
		sum cohort_pop, d

		//cohort new birth
		gen date = yrbrn

		cd "/Volumes/Silver/Docs/GSA/QP/UK Population/Data/Prelim"

		merge m:1 date using "births and deaths.dta"

		save "/Volumes/Silver/Docs/GSA/QP/UK Population/Analysis/UK_Prelim_Merge.dta", replace

			//Center the 5-yr-cohort pop size, fertility rate
			gen cohort_size = round(cohort_pop-51.4, 0.1)

			tab cohort_size

		//gen var for per million new birth

			gen birth_m = births/1000000

			sum birth_m, d

	///Objective controls
	//Household income

		sum hinctnta, d
		sum hinctnt, d

		tab1 hinctnt hinctnta
		tab1 hinctnt hinctnta, m

		gen income_raw = hinctnta if hinctnta!=.
		replace income_raw = hinctnt if hinctnt!=.
		lab val income_raw hinctnt

		tab income_raw, m

			gen income = income_raw if income_raw<13
			lab val income hinctnt

			tab income, m nolab

				/*Based on prior research that older & highly educated people more income,
				we know higher the income # means higher income.*/

				tab income ifhappy, r
				reg income age age_sq
				reg income eduyr if eduyr<60

			//Make income based group to zero, and label income with econ classes according to Dennis Gilbert (2002), Beeghly (2004).
			gen hincome = income-1
			lab def hincome 0 "0: The Poorest" 1 "1: Very Poor" 2 "2: Underclass" 3 "3: Working Poor" /*
				*/ 4 "4: Working Class" 5 "5: Almost Middle Class" 6 "6: Lower Middle Class" 7 "Middle Class" /*
				*/ 8 "8: Upper Middle Class" 9 "9: Upper Class" 10 "10: Capitalists" 11 "11: the Super-Rich", replace
			lab val hincome hincome

			tab hincome, m

	//Education
		tab eduyrs, m nolab

		gen edu = eduyrs if eduyrs<77

			tab edu
			sum edu, d
			kdensity edu
			/* kurtosis is greater than 3, then the dataset has heavier tails than a normal distribution
			(more in the tails)skewed to the right. If the skewness is less than -1 or greater than 1, the data are highly skewed
			see more at https://www.spcforexcel.com/knowledge/basic-statistics/are-skewness-and-kurtosis-useful-statistics*/

			//Treament: exponentiate
			gen edu_log = log(edu)

			kdensity edu_log
			sum edu_log, d //Better, skewness less than -1.

			//de_log education, and gen a cat. edu.

			gen edu = round(exp(edu_log))
			tab edu

			recode edu (1/8=0 "Less than Lower School") (9/10=1 "Lower School") (11/12=2 "Upper School") (13 = 3 "Six Form") (14/15.000001 = 4 "Some Colleges") (16/18 = 5 "College") (19/23=6 "Advance Degree") (23/100=7 "Phd"), gen(education)

			replace edu=13 if edu==12.999999
			replace edu=15 if edu==15.000001

			tab education, m nolab

			ttest hincome  if education==4 | education==5, by(education)
			ttest hincome  if education==1 | education==2, by(education)

			recode education (0/1 = 0 "0: Less than Upper School") (2/3 = 1 "1: Upper School") (4 = 2 "2: Some College") (5 = 3 "3: College Degree") (6/7=4 "4: Advance Degree"), gen(educ)

			tab educ, m

	//umemployment indicator
		tab uempla, nolab
		tab uempli, nolab

		//Umemployed active - assume to have low happiness
			gen unemploy_active = uempla
			lab val unemploy_active binary
			lab var unemploy_active "unemployed, actively looking for job"

			tab unemploy_active, m

		//Umemployed noactive - no diff in happiness from employed
			gen unemploy_inact = uempli
			lab val unemploy_inact binary
			lab var unemploy_inact "unemployed, not actively looking for job"

			tab unemploy_inact, m

		//Put employed into one catergories
			gen unemploy =.
			replace unemploy=1 if unemploy_inact==1 | unemploy_active==1
			replace unemploy=0 if unemploy_inact==0 & unemploy_active==0

			lab val unemploy binary
			lab var unemploy "Unemploy in the last 7 days"

			tab unemploy, m

		//Gen a unemploy var with 3 outcomes
			gen unemploy_c = unemploy
			replace unemploy_c = 1 if unemploy_active==1
			replace unemploy_c = 2 if unemploy_inact==1

			lab def unemploy_c 0 "0: Employed" 1 "1: Unemployed - Active" 2 "2: Unemployed - Inactive"
			lab val unemploy_c unemploy_c

		tab unemploy_c, m

	//ESS UK marital status variable
		tab1 marital maritala marsts, m
		tab1 marital maritala marsts, m nolab

				gen marital1 = marital if marital<10
				gen marital2 = maritala if maritala<10
				gen marital3 = marsts if marsts<10

				lab val marital1 marital
				lab val marital2 maritala
				lab val marital3 marsts

				tab1 marital1 marital2 marital3, m

			/*After 2013 UK Marriage Act, Civil Partnership (2004 Act) discontinue,
			maritala (7) - "Formerly in civil partnership, now dissolved" -> divorced
			maritala (8) - "Formerly in civil partnership, partner died" -> widowed
			a civil partnership is able to convert into a marriage.
			Thus we treat same-sex civil partnership as marriage couples.
			Use marrital1 as the reference catergory for var marriage*/

				recode marital1 (1 =0 "0: Married") (2 =1 "1: Seperated") (3 =2 "2: Divorced") (4 =3 "3: Widowed") (5 =4 "4: Never married"), gen(marriage1)
				recode marital2 (1/2=0 "0: Married") (3/4=1 "1: Seperated") (5 7 =2 "2: Divorced") (6 8 =3 "3: Widowed") (9 =4 "4: Never married"), gen(marriage2)
				recode marital3 (1/2=0 "0: Married") (3 =1 "1: Seperated") (4 =2 "2: Divorced") (5 =3 "3: Widowed") (6 =4 "4: Never married"), gen(marriage3)
				tab1 marriage1 marriage2 marriage3

				gen marriage_raw=.
				replace marriage_raw=0 if marriage1==0 | marriage2==0 | marriage3==0
				replace marriage_raw=1 if marriage1==1 | marriage2==1 | marriage3==1
				replace marriage_raw=2 if marriage1==2 | marriage2==2 | marriage3==2
				replace marriage_raw=3 if marriage1==3 | marriage2==3 | marriage3==3
				replace marriage_raw=4 if marriage1==4 | marriage2==4 | marriage3==4

				lab val marriage_raw marriage1
				tab marriage_raw, m

					//Need imputation for non-applicable, with multinomial impute, seed->100
						tab ifhappy if marsts!=.a
						mi set wide
						mi register impute marriage ifhappy yrbrn age eduyr minority female notrelig

						//Predict marriage using variable that are emperically/theoritcally correlated and have few missing value.
						//MICE

						mi impute mlogit marriage ifhappy age eduyr female notrelig, add(10) rseed(100) force
							/*note: variables ifhappy age hincome unemploy badhealth educ minority female notrelig registered as imputed and used to model variable
							marriage; this may cause some observations to be omitted from the estimation and may lead to missing imputed values
							imputed 3093
							*/

						mi estimate

						//Use egen median to guess the most frequent imputed value for marriage
						rename _*_marriage marriage_*
							///Use the last 10 imputation, Only marriage_45 to marriage_54 are exhausted.
						egen marriage_median = rowmedian(marriage_45-marriage_54)
							///non-intergers (individuals whose marital status are more unpreditable)
							///are round to the next catergories. E.g. separate are less likely
							///to reveal their marital status than married people i assume.
							///we put these groups
							gen marriage_ip = round(marriage_median,1)

							lab val marriage_ip marriage
							tab marriage_median marriage_ip

					//drop unnecessary imputed vars.
							drop marriage_1-marriage_54

		//Imputation for hincome!
					//Need imputaion for hincome 3K missings
					pwcorr hincome ifhappy marriage yrbrn age educ minority female unemploy

					table hincome, con(mean eduyr sd eduyr)

					tab hincome marriage, chi


					//Use monotone in longitudinal data.
					mi set wide

						mi unregister ifhappy marriage yrbrn age educ minority female notrelig
						mi register imputed hincome ifhappy marriage yrbrn age educ female unemploy

						mi impute chained (regress) eduyr age (logit) unemploy (ologit) hincome (mlogit) marriage, add(10) rseed(100) force
						gen hincome_ip = _1_hincome

					//Post imputation
					rename _*_hincome hincome_*
					egen hincome_median = rowmedian(hincome_45-hincome_54)

						gen hincome_ip = round(hincome_median, 1)

						lab val hincome_ip hincome

					tab hincome_ip

						//drop unnecessary imputed vars.
							drop hincome_1-hincome_54

	//Health
		tab health, nolab

		//If bad health, assume people have good health by default.
		recode health (1/3 = 0) (4/5 = 1) if health<=5, gen(badhealth)
		lab def badhealth 0 "0: Good Health" 1 "1: Bad Health", replace
		lab val badhealth badhealth
		lab var badhealth "If respondent think they have bad health in general"

		tab badhealth, m

//Other demographic groups: gender, minority, religiousity

	lab def binary 1 "1: Yes" 0 "0: No"

	//gender
	tab gndr, nolab
		gen female=.
			replace female=0 if gndr==1
			replace female=1 if gndr==2
		lab val female binary

	tab female,m

	//minority status
	tab blgetmg, nolab

		gen minority=.
			replace minority=0 if blgetmg==2
			replace minority=1 if blgetmg==1

	lab val minority binary
	lab var minority "Belong to a minority ethnic group"

	tab minority, m

	//religion - a measure of social cohesion & having a belief system.
	tab rlgdgr

	gen religion = rlgdgr if rlgdgr<11
		lab val religion rlgdgr

	tab religion

		anova age religion
		graph bar (mean) age, by(religion)

		gen notrelig=.
			replace notrelig=0 if religion>0 & religion<.
			replace notrelig=1 if religion==0

		lab val notrelig binary
		lab var notrelig "If not at all religious"

	tab notrelig, m

	//Sociality
		tab sclmeet
		tab sclmeet, nolab

		gen sociality = sclmeet-1 if sclmeet<10

		tab sociality
		lab def sociality 0 "0: Never" 1 "1: <1 a month" 2 "2: Once a month" 3 "3: Many times a month" 4 "4: Once a week" 5 "5: Many times a week" 6 "6: Everyday"
		lab val sociality sociality

		//Reduce cats to 5, putting never with <1 per month, b/c their odds ratio on happiness shows no diff.

		gen friend=sociality-1
			replace friend=0 if sociality==0

			lab def friend 0 "0: <1 a month" 1 "1: Once a month" 2 "2: Many times a month" 3 "3: Once a week" 4 "4: Many times a week" 5 "5: Everyday"
			lab val friend sociality

		tab friend, m


///Prelim Analy.

		//IMPORTANT, SAVE FIRST, turn cohort_5yr into a group ID
		tab happy if agea>90
		//Exclude people who are prior 1909, group
		replace cohort=. if cohort<1909
		tab cohort, m

















///HLM Analy.
		sort cohort_3yr
		order cohort_3yr


//Prepare data for HLM software. SAVE before moving on
		//making dummies for factorial var

		tab friend, nolab

			recode friend (0 = 1) (1/5 =0), gen (friend0)
				lab var friend0 "Meeting Friends <1 a Month"
			recode friend (1=1) (0 2/5 = 0), gen (friend1)
				lab var friend1 "Meeting Friends Once a Month"
			recode friend (2=1) (0/1 3/5 =0), gen(friend2)
				lab var friend2 "Meeting Friends Few Times a Month"
			recode friend (3=1) (0/2 4/5 =0), gen(friend3)
				lab var friend3 "Meeting Friends Once a Week"
			recode friend (4=1) (0/3 5 =0), gen(friend4)
				lab var friend4 "Meeting Friends Few Times a Week"
			recode friend (5=1) (0/4 =0), gen(friend5)
				lab var friend5 "Meeting Friends Everyday!"

			tab1 friend*, m


		tab educ

			recode educ (0 = 1) (1/4 =0), gen (educ0)
				lab var educ0 "Less than Upper School"
			recode educ (1=1) (0 2/4 = 0), gen (educ1)
				lab var educ1 "Upper School"
			recode educ (2=1) (0/1 3/4 =0), gen(educ2)
				lab var educ2 "Some College"
			recode educ (3=1) (0/2 4 =0), gen(educ3)
				lab var educ3 "College Degree"
			recode educ (4=1) (0/3 = 0), gen(educ4)
				lab var educ4 "Advanced Degree"

			tab1 educ*, m

			gen eduyr = eduyrs if eduyrs<70

		tab marriage_ip

			recode marriage_ip (0 = 1) (1/4 =0), gen (marriage0)
				lab var marriage0 "Married"
			recode marriage_ip (1=1) (0 2/4 = 0), gen (marriage1)
				lab var marriage1 "Seperated"
			recode marriage_ip (2=1) (0/1 3/4 =0), gen(marriage2)
				lab var marriage2 "Divorced"
			recode marriage_ip (3=1) (0/2 4 =0), gen(marriage3)
				lab var marriage3 "Widowed"
			recode marriage_ip (4=1) (0/3 = 0), gen(marriage4)
				lab var marriage4 "Never married"

			tab1 marriage*, m

		recode educ (3/4=1)(0/2=0),gen(ifcollege)

		lab var ifcollege "if respondent has a college degree"

		gen ifmarried = marriage0
			tab ifmarried, m


		recode hincome (7/11=1)(0/6=0),gen(welloff)

		lab var welloff "if respondent is middle class and above"


		//cohort size compare to 0.8 mill. (medium), change unit to 100k.

		gen size = round(((size_3p-0.8)*10),0.001)

//Pre-HLM sample, exclude all missings, save new version dta.
		keep size veryhappy ifhappy ifhappy2 happy_all yrbrn cohort_3p size_3p cohort_3yr /*
		*/ generation cohort_pop cohort_size period essround age age_c age_c_sq yrbrn  /*
		*/hincome_ip unemploy unemploy_c /*
		*/educ eduyrs educ0 educ1 educ2 educ3 educ4 ifcollege marriage_ip /*
		*/marriage0 marriage1 marriage2 marriage3 marriage4 sociality /*
		*/ifmarried friend friend0 friend1 friend2 friend3 friend4 friend5 female minority /*
		*/badhealth health notrelig religion panel pweight idno

		//Exclude all missing cases from all vars!!! Just for test
		foreach v of var * {
		drop if missing(`v')
		}
	//


	//Diff. unit measurer for cohort size
		gen c_birth_3yr_10k = c_birth_3yr*100

		gen c_birth_3yr_100k = c_birth_3yr*10


	//Gen 2nd happy var for sensitivity test
		gen satisfied = stflife if stflife<12

			lab val satisfied stflife

		tab satisfied

	//L1 Var: idno ifhappy age age_sq bcohort badhealth hincome
		order cohort period id ifhappy age age_sq badhealth hincome edu_log

		keep cohort period id ifhappy age age_sq badhealth hincome edu_log

		sort cohort

		save "UK_Prelim_L1.dta", replace
		use "UK_Prehlm.dta", replace

	//L2 Var: idno cohort_5y cohort_pop cohort_size period
		sort cohort
		order cohort period id cohort_pop cohort_size period

		keep cohort period id cohort_pop cohort_size period

		save "UK_Prelim_L2.dta", replace

		//remove all labels
		label drop period


//Descriptive Stat

	tab cohort_5y, m nolab

	gen mbirth_m = birth-.7104059

	/*Based on cohort_5y:
	1. Greatest (WWI) 1911 - 1935 (1-5), 2. Silence (WW2) 1936-1945 (6-7)
	3. Baby Boom (Golden Age) 1946-1965 (8-11), 4. Gen X 1966-1975 (12-13)
	5. Gen Y&Z 1976-2000 (14-18)*/
	tab gen

	estpost summ cohort period ifhappy age badhealth hincome educ cohort_pop cohort_size minority female notrelig birth_m deaths unemploy_c unemploy if generation==0
	esttab using destacrip_gen0.csv, cells("mean sd") noobs nomtitle nonumber gaps parentheses replace

	estpost summ cohort period ifhappy age badhealth hincome edu_log cohort_pop cohort_size minority female notrelig birth_m deaths unemploy_c unemploy if gen==1
	esttab using descrip_gen1.csv, cells("mean sd") noobs nomtitle nonumber gaps parentheses replace

	estpost summ cohort period ifhappy age badhealth hincome edu_log cohort_pop cohort_size minority female notrelig birth_m deaths unemploy_c unemploy if gen==2
	esttab using descrip_gen2.csv, cells("mean sd") noobs nomtitle nonumber gaps parentheses replace

	estpost summ cohort period ifhappy age badhealth hincome edu_log cohort_pop cohort_size minority female notrelig birth_m deaths unemploy_c unemploy if gen==3
	esttab using descrip_gen3.csv, cells("mean sd") noobs nomtitle nonumber gaps parentheses replace

	estpost summ cohort period ifhappy age badhealth hincome edu_log cohort_pop cohort_size minority female notrelig birth_m deaths unemploy_c unemploy if gen==4
	esttab using descrip_gen4.csv, cells("mean sd") noobs nomtitle nonumber gaps parentheses replace

	//ttest predictors by gen1 vs gen2 baby boomers
		//happy
		ttest ifhappy if gen==0 | gen==2, by(gen)
		ttest ifhappy if gen==1 | gen==2, by(gen)
		ttest ifhappy if gen==3 | gen==2, by(gen)
		ttest ifhappy if gen==4 | gen==2, by(gen)

		//population

		ttest cohort_pop if gen==0 | gen==2, by(gen)
		ttest cohort_pop if gen==1 | gen==2, by(gen)
		ttest cohort_pop if gen==3 | gen==2, by(gen)
		ttest cohort_pop if gen==4 | gen==2, by(gen)

		//birth
		ttest cohort_pop if gen==0 | gen==2, by(gen)
		ttest cohort_pop if gen==1 | gen==2, by(gen)
		ttest cohort_pop if gen==3 | gen==2, by(gen)
		ttest cohort_pop if gen==4 | gen==2, by(gen)

		//
		ttest badhealth if gen==0 | gen==2, by(gen)
		ttest badhealth if gen==1 | gen==2, by(gen)
		ttest badhealth if gen==3 | gen==2, by(gen)
		ttest badhealth if gen==4 | gen==2, by(gen)

		//
		ttest hincome if gen==0 | gen==2, by(gen)
		ttest hincome if gen==1 | gen==2, by(gen)
		ttest hincome if gen==3 | gen==2, by(gen)
		ttest hincome if gen==4 | gen==2, by(gen)

		//
		ttest minority if gen==0 | gen==2, by(gen)
		ttest minority if gen==1 | gen==2, by(gen)
		ttest minority if gen==3 | gen==2, by(gen)
		ttest minority if gen==4 | gen==2, by(gen)


//Flat Logit model
		//births on happiness
		logit ifhappy birth_m, or //loss of w/t group variance.

			estat ic
			estimates store logit_0

		//Logit model w/t levels, or nested model
		logit ifhappy birth_m age age_sq hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, or

		estat ic
    estimates store logit_1

		//Active vs inactive unemplyed
		logit ifhappy birth_m age age_sq hincome i.unemploy_c badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, or

		//Everything looks "normal", except for female, age_sq
		logit ifhappy birth_m age age_sq badhealth hincome edu_log minority female notrelig if age>50, or
		logit ifhappy birth_m age age_sq badhealth hincome edu_log minority female notrelig if age<=50, or

		//adding period effect w/t HLM
		logit ifhappy birth_m age age_sq period hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, or

			estat ic
			estimates store logit_2

		//adding cohort effect w/t HLM
		logit ifhappy birth_m age age_sq cohort hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, or
			//violation of reg. assumptions, individual's happiness is not idependent of other individuals (covariance).
			//individuals happiness influence by non exegenious factor e.g. other people's happiness in their birth cohort.
			//misconceive structural vs individual influence on happiness.

			estat ic
			estimates store logit_3

		//adding cohort-period w/t HLM
		logit ifhappy birth_m age age_sq cohort period hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, or

			estat ic
			estimates store logit_4

	      estout logit_0 logit_1 logit_2 logit_3 logit_4, cell(b se _star) stats(bic)

        esttab logit_0 logit_1 logit_2 logit_3 logit_4 using happy_logit.csv, eform nogaps bic onecell label replace

		//treat cohort-period as factors w/t hlm
		logit ifhappy birth_m age age_sq i.cohort i.period hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, or

			//too much interations

//Adjust weights, centering, ...
		//add pweight to Logit model 1
		logit ifhappy birth_m age age_sq hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig [pweight=pweight], or

				//make a more useful reference group

				//mean cohort size is approx 710000
				gen birth_c = birth_m-0.710

				kdensity birth_c
				sum birth_c, d


		logit ifhappy birth_ age_c age_c_sq hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig i.cohort period [pweight=pweight]

				estat ic
				estimates store logit_1


///HLM Analysis

		//Level-1 Data-set, SAVE as and Reopen Prelim

		keep gen ifhappy veryhappy birth_m birth_c cohort_5y birth_5y period age_c age_c_sq hincome unemploy educ educ0 educ1 educ2 educ3 educ4 marriage_ip marriage_ip marriage_ip0 marriage_ip1 marriage_ip2 marriage_ip3 marriage_ip4 friend friend0 friend1 friend2 friend3 friend4 friend5 female minority badhealth notrelig pweight cohort_pop	cohort_size

		//Level-2 Row

		keep gen period cohort_5y birth_c birth_m birth_5y cohort_pop	cohort_size pweight yrbrn essround

		//Level-2 Column

		keep period gen cohort_5y birth_c birth_m birth_5y cohort_pop	cohort_size pweight yrbrn essround

///HLM on STATA
		xtmixed ifhappy birth_m, || cohort:|| period:
				estat ic
				    estimates store hlm1

		xtmixed ifhappy birth_m  age_c age_c_sq hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, || _all: cohort|| _all:period
				estat ic
				    estimates store hlm2

		xtmixed ifhappy  age_c age_c_sq c.birth_m##c.hincome unemploy badhealth i.friend i.educ i.marriage_ip c.birth_m##i.minority c.birth_m##i.female i.notrelig, || _all: cohort|| _all:period
				estat ic
				    estimates store hlm3

///Sensitivity analy.

	//Diff. happiness dep. var.
	reg satisfied birth_m age age_sq hincome unemploy badhealth i.friend i.educ i.marriage_ip i.minority i.female i.notrelig, robust

		estat ic
    estimates store satisfied


	//Level-1 Data-set, SAVE as and Reopen Prelim
		rename cohort_pop_5y pop_5y

		keep gen ifhappy br birthrate birth_id birth_m birth_5y pop_5y period age_c age_c_sq hincome unemploy educ educ0 educ1 educ2 educ3 educ4 marriage_ip marriage_ip marriage_ip0 marriage_ip1 marriage_ip2 marriage_ip3 marriage_ip4 friend friend0 friend1 friend2 friend3 friend4 friend5 female minority badhealth notrelig pweight

		order gen period ifhappy br birthrate birth_id birth_m birth_5y pop_5y age_c age_c_sq hincome unemploy educ educ0 educ1 educ2 educ3 educ4 marriage_ip marriage_ip marriage_ip0 marriage_ip1 marriage_ip2 marriage_ip3 marriage_ip4 friend friend0 friend1 friend2 friend3 friend4 friend5 female minority badhealth notrelig pweight

		sort gen period

		//Level-2 Row

		keep gen period br birthrate birth_id birth_m birth_5y pop_5y pweight

		sort gen period br birthrate birth_id birth_m birth_5y pop_5y pweight

		sort gen

		//Level-2 Column

		keep period gen br birthrate birth_id birth_m birth_5y pop_5y pweight

		sort period gen br birthrate birth_id birth_m birth_5y pop_5y pweight

		sort period

//APCC Model, Use population characteristic - size as the group ID.

		keep gen ifhappy br birthrate birth_id birth_m birth_5y pop_5y period age_c age_c_sq hincome unemploy educ educ0 educ1 educ2 educ3 educ4 marriage_ip marriage_ip marriage_ip0 marriage_ip1 marriage_ip2 marriage_ip3 marriage_ip4 friend friend0 friend1 friend2 friend3 friend4 friend5 female minority badhealth notrelig pweight

		order birth_id period ifhappy br birthrate birth_m birth_5y pop_5y gen age_c age_c_sq hincome unemploy educ educ0 educ1 educ2 educ3 educ4 marriage_ip marriage_ip marriage_ip0 marriage_ip1 marriage_ip2 marriage_ip3 marriage_ip4 friend friend0 friend1 friend2 friend3 friend4 friend5 female minority badhealth notrelig pweight

		sort birth_id period

		//Level-2 Row

		keep birth_id period gen br birthrate birth_m birth_c birth_5y pop_5y

		sort birth_id period gen br birthrate birth_m birth_c birth_5y pop_5y

		sort birth_id period

		//Level-2 Column

		keep period birth_id gen br birthrate birth_m birth_c birth_5y pop_5y

		sort period birth_id gen br birthrate birth_m birth_c birth_5y pop_5y

		sort birth_id period


// 3.8/2018

/* With Low middle class: jobs that are often associated with high school completion but no college degree.
for example cashiers in stores, retail workers.
With Middle class, jobs are often associted with some college, college or training.
for example teachers, store managers, car dealers*/

logit ifhappy age age_sq period unemploy i.educ minority female notrelig i.friend panel marriage_ip hincome_ip, or


	keep ifhappy veryhappy cohort_3p period age age_sq period unemploy educ minority female notrelig friend panel marriage_ip hincome_ip


		order idno cohort_3p yrbrn size veryhappy ifhappy ifhappy2 happy_all yrbrn cohort_3p size_3p cohort_3yr /*
		*/cohort_pop cohort_size period essround age age_sq yrbrn  /*
		*/hincome_ip unemploy unemploy_c /*
		*/educ eduyrs educ0 educ1 educ2 educ3 educ4 ifcollege marriage_ip /*
		*/marriage0 marriage1 marriage2 marriage3 marriage4 sociality /*
		*/ifmarried friend friend0 friend1 friend2 friend3 friend4 friend5 female minority /*
		*/badhealth health notrelig religion panel pweight

		sort cohort_3p yrbrn

		//Level-1 Data-set, SAVE as and Reopen Prelim

		rename c_birth_3yr_100k b_size

		keep veryhappy ifhappy ifhappy2 happy_all size cohort_3p cohort_3yr size_3p yrbrn generation period age age_c age_c_sq hincome_ip welloff unemploy unemploy_c eduyrs educ educ0 educ1 educ2 educ3 educ4 ifcollege marriage_ip marriage0 marriage1 marriage2 marriage3 marriage4 ifmarried friend friend0 friend1 friend2 friend3 friend4 friend5 female minority badhealth notrelig panel pweight

		//Level-2 Row

		keep gen period cohort_5y birth_c birth_m birth_5y cohort_pop	cohort_size pweight yrbrn essround

		//Level-2 Column

		keep period gen cohort_5y birth_c birth_m birth_5y cohort_pop	cohort_size pweight yrbrn essround



//IF RICH

	logit welloff age_c age_c_sq period c_birth_3yr veryhappy
