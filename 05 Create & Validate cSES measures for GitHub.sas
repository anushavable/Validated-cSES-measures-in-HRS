/*************************************************************************************************** 	
	Project: 		Validation of a theoretically motivated approach to measuring childhood socioeconomic 
					circumstances in the Health and Retirement Study 

	Programmer: 	Anusha M. Vable

	Description: 	This code creates a permanent data set for the childhood social circumstances variables using 
					the factor analysis results from MPLUS and the human capital imputations, which were done in SAS, 
					& validates the component measures. 

					For social capital, there are 2 factors: maternal investment, and family structure.  Confusingly, 
					family structure variable (with an underscore) reflects the number of parent figures, and the family 
					structure factor score (no underscore) reflects the number of adults in the household.  

					For financial capital, there are 2 factors: average financial resources, and financial instability. 

					For human capital, we didn't do factor analysis because we concpetualized human capital as in index. 
					The human capital index was created in file 02. 
/***************************************************************************************************/ 	



/* Libname statements for the location of your data */  



options fmtsearch=(rawdata) nofmterr;




/* Tracker variables */ 
	%let varlist_tkr = 
				HHID PN  
				;
	run; 

/* Import Tracker */
	data tracker10;
		set libname.trk2010 (keep = &varlist_tkr);
		HHIDPN2=1000*HHID + PN;
		proc sort; by HHIDPN2;
	run;

/* Import cleaned variables used to check that the factor scores are coded properly  */
	data c_vars; 
		retain hhidpn2 
				m_atten m_effort m_life f_absent
				focc_cat famses finmove finhelp f_work;
		set CDI.for_mplus_rnr;
		drop hhid pn; 
		proc sort; by HHIDPN2;
	run; 
				
/* Import measured height in 2008 */ 
	data h08;
		set libname.h08i_r (keep = hhid pn LI834); 
		HHIDPN2=1000*HHID + PN;
		drop hhid pn; 
		proc sort; by HHIDPN2; 
	run; 

/* Import self-reported height in 2008 */ 
	data rand;
		set libname.rndhrs_n (keep = hhid pn R10HEIGHT); 
		HHIDPN2=1000*HHID + PN;
		drop hhid pn; 
		proc sort; by HHIDPN2; 
	run; 

/* Import measured height in 2010 */ 
	data h10;
		set libname.h10i_r (keep = hhid pn MI834); 
		HHIDPN2=1000*HHID + PN;
		drop hhid pn; 
		proc sort; by HHIDPN2; 
	run; 

/* Import cleaned demographics -- the validation variables are in here */
	data demo; 
		set libname.demo;
		HHIDPN2=1000*HHID + PN;
		drop hhid pn; 
		proc sort; by HHIDPN2; 
	run;

/* cSES measures */ 
	data cses; 
		set libname.cSES_measures; 
		HHIDPN2=1000*HHID + PN;
		drop hhid pn; 
		proc sort; by HHIDPN2; 
	run;

options fmtsearch=(rawdata) nofmterr;



/* Import childhood human (imputed)  */ 
	data humcap; 
		set libname.humcap;
		proc sort; by HHIDPN2; 
	run; 

/* SOCIAL CAPITAL */
/* Import Childhood Social Capital Factor Scores (full information maximum likihood confirmatory factor analysis) */
	data soccap;
	 	infile ; * insert file path for location of social capital scale;  
	  	input v1 v2 v3 v4 v5 v6 v7 hhidpn2 famstr2 maternal2; /* 	v1 = gramps	
															v2 = m_life
															v3 = m_effort
															v4 = m_atten
															v5 = number of parents
															v6 = f_absent
															v7 = mom 
															famstr = factor score for family structure factor 
															maternal = factor score for maternal investment factor */
					
	run;
	* sort by hhidpn2; 
		data soccap; 
			set soccap;
			proc sort; by HHIDPN2;
		run; 

	* see if variable is reverse coded -- correlations to see if higher numbers = higher capital; 
		proc corr data = soccap; 
			var famstr2 v5; * positively correlated with number of parents, which is coded so lower numbers are better, so need to reverse code; 
		run; 
		proc corr data = soccap ;
			var maternal2 v2; * positively correlated with amount mom taught about life (where lower numbers are better), so need to reverse code; 
		run;
	
		* reverse code; 
			data soccap; 
				set soccap; 
				famstr = -1*famstr2; 
				maternal = -1*maternal2; 
			run; 

			* check reverse coding done properly; 
				proc means data = soccap;
					var famstr famstr2
						maternal maternal2; 
				run; 

			* check factors properly coded with each other; 
				proc corr data = soccap; 
					var famstr maternal; * looks fine;
					title "cSC factor correlation"; 
				run; 


	* add factor scores together to get social capital latent variable; 
		data soccap; 
			set soccap;
			soccap = famstr + maternal; 
		run; 
		proc means data = soccap;
			var soccap famstr maternal; 
		run; 
		proc univariate data = soccap; 
			histogram; 
			var soccap famstr maternal; 
		run; 



/* FINANCIAL CAPITAL */ 
		/* Import childhood financial capital factor scores (full information maximum likihood confirmatory factor analysis) */
				data fincap2; 
					infile ; * insert file path for location of financial capital scale;  
					input v1 v2 v3 v4 v5 v6 v7 v8 hhidpn2 ave_fin_re2 fin_instability2; /* 	v1 = focc_cat
																								v2 = famses
																								v3 = famses_n
																								v4 = finmove
																								v5 = finhelp
																								v6 = f_work
																								v7 = lose_bus
																								v8 = bankrup */
				run;
					
				* sort by hhidpn; 
				data fincap2; 
					set fincap2;
					proc sort; by HHIDPN2;
				run; 

				* correlations to see if higher numbers = higher capital; 
				proc corr data = fincap2; 
					var ave_fin_re2 v2; * ave financial resources postively correlated with famses, which has lower numbers = better SES, so need to reverse code; 
				run; 
				proc corr data = fincap2; 
					var fin_instability2 v7; * financial instability postively correlated with famses, which has lower numbers = better SES, so need to reverse code; 
				run; 
				data fincap2; 
					set fincap2; 
					ave_fin_re = -1*ave_fin_re2; 
					fin_instability = -1*fin_instability2; 
				run; 
				proc means data = fincap2;
					var ave_fin_re ave_fin_re2
						fin_instability fin_instability2; 
				run;  
				proc corr data = fincap2; 
					var ave_fin_re v2; * correctly correlated; 
				run; 
				proc corr data = fincap2; 
					var fin_instability v7; * correctly correlated; 
				run; 

				* check factors are correlated with each other; 
				proc corr data = fincap2; 
					var fin_instability ave_fin_re; * correctly correlated; 
					title "cFC factor correlation";
				run; 

				* create fincap latent variable by combining two factor scores; 
				data fincap2;
					set fincap2; 
					fincap_2fac = ave_fin_re + fin_instability; 
				run; 
				proc means data = fincap2; 
					var fincap_2fac ave_fin_re fin_instability; 
				run; 
				proc univariate data = fincap2; 
					histogram; 
					var fincap_2fac ave_fin_re fin_instability2; 
				run; 


/* Merge tracker with factor scores and variables used to create the factor scores */ 			
	data merged;
		merge 	rand
				demo
				tracker10 (in = keep) /* only keep people before the 2010 cohort was added b/c those are the peole we did the factor analysis on */
				humcap 
				soccap
				fincap2
				all_vars
				h08
				h10
				; 
		by HHIDPN2;
		if keep; 
	run;



	data merged2; 
		set merged; 

		* set the 2 factor soultion to fincap to avoid later confusion; 
		fincap = fincap_2fac; 

		* get a single height variable for measured height;  
			ht = LI834; if ht > 200 then ht = .; 
			if ht = . then ht = MI834; if ht > 200 then ht = .; 

			if ht < 30 then ht = .; 
	run; 
	proc means data = merged2 n min p10 p90 max; 
		var ht LI834 MI834 r10height;
	run;
	proc corr data = merged2; 
		var ht r10height; 
	run; 

	* Ns for all scales (Figure 2); 
	proc means data = merged2; 
		var soccap fincap humcap;
		title "Ns of scales for Figure 2";
	run; 

options fmtsearch=(rawdata) nofmterr;



/* RELIABILITY */ 
	/* Human capital: not appropriate to check reliability of an index */ 
	
	/* Financial Capital: all the variables are coded so lower numbers = better financial capital except for f_work, so I'll reverse code that */ 
		data merged2; 
			set merged2; 

			f_work2 = .; 
			if f_work = 0 then f_work2 = 2; 
			if f_work = 1 then f_work2 = 1; 
			if f_work = 2 then f_work2 = 0; 
		run; 
		proc freq data = merged2; 
			table 	f_work f_work2
					lose_bus; 
		run; 

		proc corr data = merged2 alpha nomiss;
			var focc_cat famses famses_n finmove finhelp f_work2 lose_bus bankrup;
			title "reliability cFC";
		run; 
		proc corr data = merged2 alpha nomiss;
			var focc_cat famses famses_n f_work2;
			title "reliability average fin resources";
		run;
		proc corr data = merged2 alpha nomiss;
			var finmove finhelp  lose_bus bankrup;
			title "reliability fin instability";
		run; 

			/* excluding variables to see if reliabilty changes; */
				proc corr data = merged2 alpha nomiss;
					var focc_cat famses famses_n finmove finhelp f_work2 lose_bus bankrup;
					title "all vars";
				run; 
				proc corr data = merged2 alpha nomiss;
					var  famses famses_n finmove finhelp f_work2 lose_bus bankrup;
					title "var excluded:focc_cat ";
				run; 
				proc corr data = merged2 alpha nomiss;
					var focc_cat  famses_n finmove finhelp f_work2 lose_bus bankrup;
					title "var excluded:famses ";
				run; 
				proc corr data = merged2 alpha nomiss;
					var focc_cat famses  finmove finhelp f_work2 lose_bus bankrup;
					title "var excluded: famses_n";
				run; 
				proc corr data = merged2 alpha nomiss;
					var focc_cat famses famses_n  finmove finhelp  lose_bus bankrup;
					title "var excluded: f_work2";
				run; 
				proc corr data = merged2 alpha nomiss;
					var focc_cat famses famses_n finmove  f_work2 lose_bus bankrup;
					title "var excluded: finhelp";
				run; 
				proc corr data = merged2 alpha nomiss;
					var focc_cat famses famses_n  finhelp f_work2 lose_bus bankrup;
					title "var excluded: finmove";
				run; 
				proc corr data = merged2 alpha nomiss;
					var focc_cat famses famses_n finmove finhelp f_work2  bankrup;
					title "var excluded: lose_bus";
				run; 
				proc corr data = merged2 alpha nomiss;
					var focc_cat famses famses_n finmove finhelp f_work2 lose_bus ;
					title "var excluded: bankrup";
				run; 


	/* Social capital */
		proc corr data = merged2 alpha nomiss;
			var m_effort m_atten m_life
				fam_str gramps nomom f_absent;
			title "Reliability for soccap";
		run; 
		proc corr data = merged2 alpha nomiss;
			var m_effort m_atten m_life; 
			title "Reliability for maternal factor";
		run; 
		proc corr data = merged2 alpha nomiss;
			var fam_str gramps nomom f_absent;
			title "Reliability for family structure factor ";
		run; 

			/* excluding variables to see if reliabilty changes; */
				proc corr data = merged2 alpha nomiss;
					var m_effort m_atten m_life
						fam_str gramps nomom f_absent;
					title "Reliability for soccap";
				run; 
				proc corr data = merged2 alpha nomiss;
					var  m_atten m_life
						fam_str gramps nomom f_absent;
					title "Var excluded: m_effort";
				run; 
				proc corr data = merged2 alpha nomiss;
					var m_effort  m_life
						fam_str gramps nomom f_absent;
					title "Var excluded: m_atten";
				run; 
				proc corr data = merged2 alpha nomiss;
					var m_effort m_atten 
						fam_str gramps nomom f_absent;
					title "Var excluded: m_life";
				run; 
				proc corr data = merged2 alpha nomiss;
					var m_effort m_atten m_life
						 gramps nomom f_absent;
					title "Var excluded: fam_str";
				run; 
				proc corr data = merged2 alpha nomiss;
					var m_effort m_atten m_life
						fam_str  nomom f_absent;
					title "Var excluded:gramps ";
				run; 
				proc corr data = merged2 alpha nomiss;
					var m_effort m_atten m_life
						fam_str gramps  f_absent;
					title "Var excluded: nomom";
				run; 
				proc corr data = merged2 alpha nomiss;
					var m_effort m_atten m_life
						fam_str gramps nomom ;
					title "Var excluded: f_absent";
				run; 

/* VALIDITY */ 	
* Validate social capital scale;  
		proc reg data = merged2; 
			model soccap = fincap; 
			title "Validity: social capital";
		run;
		proc reg data = merged2; 
			model soccap = humcap; 
		run; 
		proc reg data = merged2; 
			model soccap = learning; 
		run; 
		proc reg data = merged2; 
			model soccap = chealth;
		run; 
		proc reg data = merged2; 
			model soccap = drug;
		run; 
		proc reg data = merged2; 
			model soccap = SCHLYRS;
		run; 
		proc reg data = merged2; 
			model soccap = ht; * measured height;
		run;
		proc reg data = merged2; 
			model soccap = r10height; * self-reported heithg; 
		run;


* Validate financial capital scale;  
		proc reg data = merged2; 
			model fincap = humcap; 
			title "Validity: financial capital";
		run;
		proc reg data = merged2; 
			model fincap = learning; 
		run; 
		proc reg data = merged2; 
			model fincap = chealth;
		run; 
		proc reg data = merged2; 
			model fincap = drug;
		run; 
		proc reg data = merged2; 
			model fincap = SCHLYRS;
		run; 
		proc reg data = merged2; 
			model fincap = ht;	* measured height; 
		run;
		proc reg data = merged2; 
			model fincap = r10height; * self-reported height; 
		run;


* Validate human capital scale;  
		proc reg data = merged2; 
			model humcap = learning;
			title "Validity: human capital"; 
		run; 
		proc reg data = merged2; 
			model humcap = chealth;
		run; 
		proc reg data = merged2; 
			model humcap = drug;
		run; 
		proc reg data = merged2; 
			model humcap = SCHLYRS;
		run; 
		proc reg data = merged2; 
			model humcap = ht;
		run;
		proc reg data = merged2; 
			model humcap = r10height;
		run;
 

/* Create cSES index by combining meaures; if an individual is missing data on one measure, the index score is created by adding the other scores */ 
	data index; 
		set merged2;

			/* create cses index with validated measures -- average of number of non-missing values */

			* if data on all measures; 
				cses_index3 = (fincap + humcap + soccap)/3; 

			* if missing data on one measure; 
				if fincap = . then cses_index2 = (humcap + soccap)/2; 
				if humcap = . then cses_index2 = (fincap + soccap)/2; * everyone has data on humcap; 
				if soccap = . then cses_index2 = (fincap + humcap)/2; 

			* if missing data on two measures; 
				if fincap = . & humcap = . then cses_index1 = soccap; 
				if fincap = . & soccap = . then cses_index1 = humcap; 
				if humcap = . & soccap = . then cses_index1 = fincap; 

			* combine indicies; 
				cses_index = cses_index3; 
				if cses_index = . then cses_index = cses_index2; 
				if cses_index = . then cses_index = cses_index1; 
	run;
	proc means data = index; 
		var cses_index3 cses_index2 cses_index1 cses_index; 
	run; 

/* Standardize index */ 
	PROC STANDARD DATA=index MEAN=0 STD=1 OUT=index2;
	  VAR soccap humcap fincap cses_index;
	RUN;

* reverse code financial instabilty so higher number reflect more instability; 
	data last; 
		set index2;
		fin_inst = -1*fin_instability;
	run; 
	proc univariate data = last; 
		histogram; 
		var fin_inst fin_instability;
		title "Distribution of the cSES Index"; 
	run;

/* Histograms */ 
	proc univariate data = last; 
		histogram; 
		var soccap;
		title "Distribution of Social Capital";  
	run; 
	proc univariate data = last; 
		histogram; 
		var humcap;
		title "Distribution of Human Capital";  
	run;
	proc univariate data = last; 
		histogram; 
		var fincap;
		title "Distribution of Financial Capital"; 
	run;
	proc univariate data = last; 
		histogram; 
		var cses_index;
		title "Distribution of the cSES Index"; 
	run;




/* Create permanent data set for childhood social circumstances variables*/
	data libname.cSES_measures; 
		set last; 
		keep hhid pn 

			soccap
				famstr
				maternal 

			fincap
				ave_fin_re 
				fin_inst

			humcap
				myrs
				fyrs  

			cses_index
			;
	run; 
