/*************************************************************************************************** 	
	Project: 		Validation of a theoretically motivated approach to measuring childhood socioeconomic 
					circumstances in the Health and Retirement Study 

	Programmer: 	Anusha M. Vable

	Description: 	This code pulls in the validated measures and then replicates the measures that 
					Luo, Glymour, and Hargrove used in previous analyses using HRS data.  I compare 
					the validated measures to the compairson mesureas in terms of amount of variability 
					explained and achievable sample size. 
/***************************************************************************************************/ 	

/* Libname statements for the location of your data */  



options fmtsearch=(rawdata) nofmterr;

/* Variable Lists for Importation */
%let varlist_rand = HHID PN
			HHIDPN 
			R10SHLT r10cesd 	/* outcomes */ 
			RAMEDUC  RAFEDUC 	/* to create Luo / Glymour / Hargrove measures */ 
			;
run; 

/* Tracker variables */ 
%let varlist_tkr = 
			HHID PN  
			gender 
			malive
			birthyr
			;
run; 



/* Import Rand data set */
	data rand;
		set libname.rndhrs_l (keep = &varlist_rand);

		* set missing values to missing; 
		if RAMEDUC = .D then RAMEDUC = .;  
		if RAMEDUC = .M then RAMEDUC = .;  
		if RAMEDUC = .R then RAMEDUC = .; 

		if RAFEDUC = .D then RAFEDUC = .; 
		if RAFEDUC = .M then RAFEDUC = .; 
		if RAFEDUC = .R then RAFEDUC = .; 
		proc sort; by hhid pn;
	run; 

/* Import Tracker data set  */
	data tracker10;
		set libname.trk2010 (keep = &varlist_tkr);
		proc sort; by hhid pn;
	run;

/* Import cleaned demographic variables */ 
	data demo; 
		set libname.demo;
		proc sort; by hhid pn; 
	run;

/* Import childhood SES variables -- these are the variables developed in this paper */ 
	data cses;
		set libname.cSES_measures; 
		proc sort; by hhid pn; 
	run; 

/* Import cleaned variables used to create the factor scores */ 
	data c_vars; 
		set libname.c_vars;
		proc sort; by hhid pn;
	run;

/* Merge Datasets */ 
	data merged;
		merge 	tracker10 (in = keep) /* only keep people before the 2010 cohort was added b/c those are the peole in the factor analysis */
				rand
				demo
				cses
				c_vars
				; 
		by hhid pn;
		if keep; 
	run;
	proc means data = merged; var fincap humcap soccap; run; 
options fmtsearch=(rawdata) nofmterr;


data merged2; 
	set merged; 

		/* clean outcomes */ 
			if r10shlt = .D then r10shlt = .; 
			if r10cesd = .M then r10cesd = .; 

		/* clean birth year */ 
			if birthyr = 0 then birthyr = .; 

		/* make an age squared term */ 
			mage2 = mage*mage; 

		/* Create comparison variables -- the Luo measure takes more than one step */ 

			* luo measures;
				* parents ed, dichotomized at 8, missing included with low status; 
				luo_momed = (RAMEDUC >= 8); if RAMEDUC = . then luo_momed = 0; 
				luo_daded = (RAFEDUC >= 8); if RAFEDUC = . then luo_daded = 0; 

				* father had a while collar job -- assume that's the same as our father's occupation cateogory of 
						1: executives & managers, and 
						2: professional specialty; 
				luo_job = 0; 
				if focc_cat in (1,2) then luo_job = 1; 
				if focc_cat = . then luo_job = 0; 

				*family self-rated SES: Personal communication from Luo: In the results we presented we coded these [who reported that cSES varied]  
				as missing data.  As the result, their scores on the childhood SES index were derived from the other variables used to construct 
				that index.  We also experimented with assigning into the mode category “about average” and found similar results. 

				luo_cses = .; 
				if famses2 = 6 then luo_cses = .; * varied; 
				if famses2 = 1 then luo_cses = 3; * well-off; 
				if famses2 = 3 then luo_cses = 2; * average; 
				if famses2 = 5 then luo_cses = 1; * poor;

				* All the Luo measures are standardized, then summed which requires different procedures; 

			* glymour measures;
				* parents ed dichotomized; 
				gly_momed = (RAMEDUC < 8); if RAMEDUC = . then gly_momed = 0 ; * indiactor for known mother's eduation < 8 years, missing = 0; 
				gly_daded = (RAFEDUC < 8); if RAFEDUC = . then gly_daded = 0 ; * indicator for known father's education < 8 years, missing = 0; 
		
				* indicator for father's occupation manual, missing = 0.  I assume this is the same as our categories of: 
						5: cleaning, builiding, food prep, and pesonal services, and 
				 		6: production, consruction, and operation occupations; 
				gly_manual = focc_cat in (5,6); if focc_cat = . then gly_manual = 0; * indicator for father's occupation manual; 

				* create glymour summary index; 
				gly = .; 
				gly = gly_momed + gly_daded + gly_manual; 
				glymour_r = gly / 3; * the paper originally had this variable coded 0 = best, 1 = worst, but we want it the other way; 
					 
				* recode the glymour index for consistency with other cSES measures; 
				if glymour_r = 0 then gly_index = 1; 
				if glymour_r = 1 then gly_index = 0;
				if glymour_r = 2/3 then gly_index = 1/3; 
				if glymour_r = 1/3 then gly_index = 2/3; 

			* hargrove adjusted for mother ed >= 12, father ed >= 12, childhood poverty, financial move, father white collar job.  They say they only use ; 
				har_mom = (RAMEDUC >= 12); 	if  RAMEDUC = . then har_mom = .; if RAMEDUC = 7.5 then har_mom = .; if RAMEDUC = 8.5 then har_mom = .; 
				har_dad = (RAFEDUC >=12); 	if RAFEDUC = . then har_dad = .; if RAFEDUC = 7.5 then har_dad = .; if RAFEDUC = 8.5 then har_dad = .; 
				har_poor = (famses = 3);	if famses = . then har_poor = .;
				har_move = finmove; 		if finmove = . then har_move = .; 
				har_focc = (focc_cat <3);	if focc_cat = . then har_focc = .;  * assume white collar job is the same as the categories 
																				1 and 2, listed in the Luo index above.; 
		run; 
				/* check if hargrove deleted AHEAD and used a complete case apporach */
					data har_check; 
						set merged2; 

						* remove AHEAD cohort; 
						if RAMEDUC = 7.5 then delete; 
						if RAMEDUC = 8.5 then delete; 
						if RAFEDUC = 7.5 then delete; 
						if RAFEDUC = 8.5 then delete; 

						har_elig = 0; 
						if har_mom = . then har_elig = -1; 
						if har_dad = . then har_elig = -1; 
						if har_poor = . then har_elig = -1;  
						if har_move = . then har_elig = -1;  
						if har_focc = . then har_elig = -1;  

						if female = 0 then har_elig = -2; 
					run; 
					proc freq data = har_check; 
						where har_elig = 0; 
						table nhw nhb hisp oth / missing; 
					run; 
					/* N similar to what Hargrove reported in her paper */

	
	* Finish creating the Luo index; 
		* investigate Luo measures before standardizing; 
		proc freq data = merged2;
			table luo_momed luo_daded luo_job luo_cses;
		run; 
		* standardize all the variables; 
		proc standard data = merged2 mean = 0 std = 1 out = lou_clean;
			var glymour_r luo_momed luo_daded luo_job luo_cses;
		run; 
		proc freq data = lou_clean; 
			table luo_cses famses2;
		run; 

	data clean;
		set lou_clean; 

		* create luo index by averaging the component variables. Only the cses measure has missing data (Luo, personal communication)
			so, I use two lines of code to create the index -- one if we have data on self-reported, and once when self-reporte data are missing. 
			The Luo measure is used both dichotmously and continuously in thier paper -- we're going to use it continously both because it'll have more 
			variability and beccause the dichotomization point will change with different sample sizes so using it continuously is easier.  ; 
		if luo_cses ne . then luo_index = (luo_momed + luo_daded + luo_job + luo_cses)/4;
		if luo_cses = . then luo_index = (luo_momed + luo_daded + luo_job)/3; 

	run; 


/* Create analytic samples for compairson analyses */ 
	data clean2; 
		set clean; 

			/* Create sample for the complete case (cc) analysis*/ 
				elig_cc = 1; 

				* missing data on other measures; 
				if luo_index = . then elig_cc = -2;
				if gly_index = . then elig_cc = -2; 
				if har_mom = . then elig_cc = -2; 
				if har_dad = . then elig_cc = -2; 
				if har_poor = . then elig_cc = -2; 
				if har_move = . then elig_cc = -2; 
				if har_focc = . then elig_cc = -2; 
		 
				* missing data on validated measures;
				if humcap = . then elig_cc = -3; 
				if fincap = . then elig_cc = -3; 
				if soccap = . then elig_cc = -3;

				* missing covariate data; 
				if mage = . then elig_cc = -1;
				if s_birth = . then elig_cc = -1; 
				if female = . then elig_cc = -1; 
				if nhb = . then elig_cc = -1;

				* missing outcome data; 
				if r10shlt = . then elig_cc = -4; 
				if r10cesd = . then elig_cc = -4; 

				* not alive or in the data set in 2010; 
				if malive = . then elig_cc = -5;  	* not in data set in 2010; 
				if malive > 2 then elig_cc = -5; 	* not alive in 2010; 


			/* Create sample for achievable N (an) analysis  */ 
				elig_an = 1; 

				* missing covariate data; 
				if mage = . then elig_an = -1;
				if s_birth = . then elig_an = -1; 
				if female = . then elig_an = -1; 
				if nhb = . then elig_an = -1;

				* missing data on all cSES measures; 
				if luo_index = . & gly_index = . 
					& humcap = . & fincap = . 
					& har_mom = . & har_dad = . & har_poor = . & har_move = . & har_focc = . 
					then elig_an = -2;

				* missing data on both outcomes -- for sample section of the paper, I don't actually delete these observations; 
				*if r10shlt = . then elig_an = -3; 
				*if r10cesd = . then elig_an = -4; 

				* not alive or in the data set in 1998; 
				if malive = . then elig_an = -5;  		* not in data set in 1998; 
				if malive > 2 then elig_an = -5; 		* not alive in 1998;

	run; 
	proc means data = clean2; 
		var cses_index fincap humcap soccap;
	run; 

	proc freq data = clean2;
		table elig_cc elig_an / missing; 
		title "number ineligible in both analytic samples for the sample section of the methods";
	run;
			/* I use the flowchart dataset to figure out the numbers for the flowchart by moving the run statement; 
				this dataset isn't used for any analyses */ 
			data flowchart;
				set clean2; 

				if malive = . then delete; 
				if malive > 2 then delete; 

				if r10shlt = . then delete; 
				if r10cesd = . then delete; 

				if mage = . then delete; 
				if s_birth = . then delete; 
				if female = . then delete; 
				if nhb = . then delete;  

				if humcap = . then delete; 
				if fincap = . then delete; 
				if soccap = . then delete; 

				if luo_index = . then delete; 

				if gly_index = . then delete; 

				if har_mom = . then delete; 
				if har_dad = . then delete; 
				if har_poor = . then delete; 
				if har_move = . then delete; 
				if har_focc = . then delete; /**/

			run; 
 
	
	/* Create complete case analytical data set */ 
	data clean_cc; 
		set clean2; 
		if elig_cc < 0 then delete; 
	run; 
	
	/* Create achievable N analytical data set */ 	
	data clean_an;  
		set clean2;
		if elig_an < 0 then delete; 
	run; 

	proc freq data = clean_an;
		table r10shlt r10cesd / missing; 
		title "need this for comparision section - sample section of the methods"; 
	run; 
			
	/* Standardize validated measures and Luo index in both analytic data sets for comparison analyses */ 			
	* complete case; 
			proc standard data = clean_cc mean = 0 std = 1 out = cc_std; 
				var cses_index fincap humcap soccap luo_index myrs fyrs; * standardize myrs and fyrs so the point estimates are comparable to
																				the humcap measure, which is standardized;
			run;
					* check measures are created properly; 
					proc means data = cc_std mean min max; 
						var cses_index luo_index fincap humcap soccap myrs fyrs;
					run;
					proc univariate data = cc_std; 
						histogram;
						var cses_index luo_index fincap humcap soccap myrs fyrs;
					run; 

	* acheivable N; 
		proc standard data = clean_an mean = 0 std = 1 out = an_std; 
			var cses_index fincap humcap soccap luo_index myrs fyrs;
		run;
					* check measures are created properly; 
					proc means data = an_std; 
						var cses_index luo_index fincap humcap soccap myrs fyrs;
					run;
					proc univariate data = an_std; 
						histogram;
						var cses_index luo_index fincap humcap soccap myrs fyrs;
					run; 
		


/* create macros for comparison analyses */
	%let demo = female nhb hisp oth mage mage2 
				s_birth ma_birth en_birth wn_birth mt_birth pa_birth f_birth ; run;  			* demographic vraibles, birth in the north east is the reference; 
	%let us = humcap fincap soccap; run; 														* the validated measures;  
	%let us_exp = maternal famstr ave_fin_re fin_inst myrs fyrs; run; 							* the validated measures with all factor scores;  
	%let hargrove = har_mom har_dad har_poor har_move har_focc; run; 							* hargrove model; 
		
	* the Luo and Glymour models only have one variable,so I didn't create macros for them; 



					/* R1 analysis to assess increase in variability: 
						age + gender explained 0.46% (R2 = 0.0046) of the variablity in self-repoted health */ 
						proc reg data = cc_std; 
							model r10shlt = mage mage2 female / clb;
						run; 

	* Complete Case: Self-Rated Health, Validated Measures; 									
		proc reg data = cc_std;
			model R10SHLT = cses_index &demo / clb;
			title "CC: combined measure, Model 1";
		run; 
		proc reg data = cc_std;
			model R10SHLT = &us &demo  / clb;
			title "CC: expanded scales, Model 2";
		run; 
		proc reg data = cc_std;
			model R10SHLT = &us_exp &demo  / clb;
			title "CC: expanded factors, Model 3";
		run; 
	
	* Complete Case: Self-Rated Health, Comparison Measures; 
		proc reg data = cc_std; 
			model r10shlt = luo_index &demo  / clb;
			title "CC: Luo model";
		run; 
		proc reg data = cc_std; 
			model r10shlt = gly_index &demo  / clb; 
			title "CC: Glymour model";
		run; 
		proc reg data = cc_std; 
			model r10shlt = &hargrove &demo  / clb;
			title "CC: Hargrove model";
		run; 

	* Acheivable N: Self-Rated Health, Validated Measures;  
		proc reg data = an_std;
			model r10shlt = cses_index &demo / clb;
			title "AN: combined measure, Model 1";
		run; 
		proc reg data = an_std;
			model r10shlt = &us &demo  / clb;
			title "AN: exapanded scales, Model 2";
		run; 
		proc reg data = an_std;
			model R10SHLT = &us_exp &demo  / clb;
			title "AN: expanded factors, Model 3";
		run; 
	
	* Acheivable N: Self-Rated Health, Comparison Measures;  
		proc reg data = an_std; 
			model r10shlt = luo_index &demo  / clb;
			title "AN: Luo model";
		run; 
		proc reg data = an_std; 
			model r10shlt = gly_index &demo  / clb; 
			title "AN: Glymour model";
		run; 
		proc reg data = an_std; 
			model r10shlt = &hargrove &demo  / clb;
			title "AN: Hargrove model";
		run; 


	* Complete Case: CESD, Validated Measures; 									
		proc reg data = cc_std;
			model R10cesd = cses_index &demo / clb;
			title "CC: combined measure, Model 1";
		run; 
		proc reg data = cc_std;
			model R10cesd = &us &demo  / clb;
			title "CC: expanded scales, Model 2";
		run; 
		proc reg data = cc_std;
			model R10cesd = &us_exp &demo  / clb;
			title "CC: expanded factors, Model 3";
		run; 
	
	* Complete Case: CESD, Comparison Measures; 
		proc reg data = cc_std; 
			model R10cesd = luo_index &demo  / clb;
			title "CC: Luo model";
		run; 
		proc reg data = cc_std; 
			model R10cesd = gly_index &demo  / clb; 
			title "CC: Glymour model";
		run; 
		proc reg data = cc_std; 
			model R10cesd = &hargrove &demo  / clb;
			title "CC: Hargrove model";
		run; 

	* Acheivable N: CESD, Validated Measures;  
		proc reg data = an_std;
			model R10cesd = cses_index &demo / clb;
			title "AN: combined measure, Model 1";
		run; 
		proc reg data = an_std;
			model R10cesd = &us &demo  / clb;
			title "AN: exapanded scales, Model 2";
		run; 
		proc reg data = an_std;
			model R10cesd = &us_exp &demo  / clb;
			title "AN: expanded factors, Model 3";
		run; 
	
	* Acheivable N: CESD, Comparison Measures;  
		proc reg data = an_std; 
			model R10cesd = luo_index &demo  / clb;
			title "AN: Luo model";
		run; 
		proc reg data = an_std; 
			model R10cesd = gly_index &demo  / clb; 
			title "AN: Glymour model";
		run; 
		proc reg data = an_std; 
			model R10cesd = &hargrove &demo  / clb;
			title "AN: Hargrove model";
		run; 




/* what is going on with aveage financial resources and CESD score?! 
	in the complete case analysis (beta = 0.38;95%CI: -0.12, 0.89; p = 0.137, Table 3, Model 3) vs. the achievable N analysis 
	(beta = 0.13; 95%CI: -0.26, 0.53; p = 0.508, Table A4, Model 3); it’s weird because with the larger sample size the point 
	estimate gets smaller and the p-value gets bigger. */ 

	* first, i'll create a data set with people who were included in the AN analysis but not in the cc analysis; 
	data check;
		set clean2;
		inan = .; * indicator for in an sample but not cc; 
		if elig_cc < 0 and elig_an > 0 then inan = 1; 
		if R10cesd = . then inan = .; 
		if ave_fin_re = . then inan =.; 
	run; 
	proc means data = check;
		where inan = 1; 
		var ave_fin_re /*fin_inst*/ R10cesd;
		title "excluded from cc but in an";
	run; 
	proc means data = clean_cc;
		var ave_fin_re /*fin_inst*/ R10cesd;
		title "all included in cc";
	run; 
	proc means data = clean_an;
		where r10cesd >.;  
		var ave_fin_re /*fin_inst*/ R10cesd;
		title "all included in an";
	run; 
		/* those excluded from cc but in an have lower ave_fin_re and higher CESD, indicating that there maybe influencial points in the
		left tail of the ave_fin_re distribution */ 

	proc univariate data = check; 
		histogram / endpoints = -1.5 to 1.5 by .05; 
		where inan = 1; 
		var ave_fin_re  R10cesd; *fin_inst;
		title "cc cFC factors";
	run;
	proc univariate data = clean_cc; 
		histogram / endpoints = -1.5 to 1.5 by .05; 
		var ave_fin_re  R10cesd; *fin_inst;
		title "cc cFC factors";
	run;
	proc univariate data = clean_an; 
		histogram / endpoints = -1.5 to 1.5 by .05; 
		var ave_fin_re  R10cesd; *fin_inst;
		title "an cFC factors";
	run; 

		proc reg data = check;
			where inan = 1; 
			model R10cesd = &us_exp &demo  / clb;
			title "included in an but not cc";
		run; 
		proc sgplot data=check;
		  scatter x=ave_fin_re y=R10cesd / group=inan;
		  title "Scatterplot of average financial resources and number of depressive symptoms";
		run;

	/* scatter plot shows that people in the left tail of ave_fin_re were excluded from the cc analysis. Here's what I think is going on: 
	the complete case analysis was inducing a relationship between childhood financial resources and depressive symptoms 
	such that MORE financial resources predicted MORE depressive symptoms, which is contrary to all the literature.  The achievable N analysis, 
	on the other hand, included socially vulnerable individuals who were excluded from the complete case analysis; those individuals also had 
	more depressive symptoms, which pushed the relationship between average financial resources and depressive symptoms towards the null.  
	So, there were some influential observations, and they generated a point estimate that is closer to the literature. */


					/************/
					/* Appendix */
					/************/

/* Appendix Figure 1: hypothesized factor structure */ 

/* Appendix Table 1: Father occupation classifications */ 

/* Appendix Table 2: EFA variable loadings -- Table came from Paola */ 

/* Appendix Table 3: Human capital imputations */

/* Appendix Table 4: Achievable N analysis, results above */ 

/* Appendix Figure 2: Distribution of the human capital, financial capital, social capital scales, and the combined index */ 
	proc standard data = clean mean = 0 std = 1 out = clean_std; 
		var fincap humcap soccap cses_index;
	run; 
	proc univariate data = clean_std; 
		histogram; 
		var fincap humcap soccap cses_index maternal famstr ave_fin_re fin_inst;
		title "cSES Histograms";
	run; 

/* Appendix Table 5: is the Hargrove measure excluding the most vulnerable? */
	data hargrove;
		set clean; 
		
		har_mi = 0; 

		if har_mom = . then har_mi = 1; 
		if har_dad = . then har_mi = 1; 
		if har_poor = . then har_mi = 1;  
		if har_move = . then har_mi = 1;  
		if har_focc = . then har_mi = 1;  

	run; 
	proc freq data = hargrove; 
		table har_mi; 
	run; 

	proc ttest data = hargrove;
		class har_mi;
		var birthyr nhw nhb hisp oth c_excel c_vgood c_good c_fair c_poor s_birth f_birth			/* demographics */ 
			maternal famstr ave_fin_re fin_inst  myrs fyrs 									/* validated measures */ 		
			;	
		title "social variables of peeps excluded by Hargrove"; 
	run; 
