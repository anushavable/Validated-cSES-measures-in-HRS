/*************************************************************************************************** 	
	Project: 		Validation of a theoretically motivated approach to measuring childhood socioeconomic 
					circumstances in the Health and Retirement Study 

	Programmer: 	Anusha M. Vable

	Description: 	This code performs the human capital imputations. First, I pull in variables from 
					the Rand and tracker data set, as well as the cleaned data on chidhood social and financial capital and 
					the demographic variables for the imputations.  Then, I determine which social variables to use in the 
					imputations based on which variables are correlated with parents education, and then dummy out
					the necessary variables.  I perfrom the imputations in 5 different subgroups: a) missing data, 
					b) ahead mothers < 8 years ed, c) ahead fathers < 8 years ed, d) ahead mothers >= 8 years ed, 
					and e) ahead fathers >= 8 years ed.  I check that the imputations are in the correct range after each 
					imputation, and then save only the imputed observations.  At the end, I merge the imputed values with 
					the continuous values, and create the human capital scale by a) z-scoring mothers and father's education, 
					b) adding the two variables together, and c) z-scoring the data again.  
/***************************************************************************************************/ 	


/* Libname statements for the location of your data */ 

%let drivename = Z:\Dropbox; * Anusha;
*%let drivename= C:\Users\Paoventure\Dropbox;

run;

libname rawdata "&drivename.\HRSPublicUseData\HRSRawData\RAND";
libname rawexit "&drivename.\HRSPublicUseData\HRSRawData\Exits";
libname rawcore "&drivename.\HRSPublicUseData\HRSRawData\Core";
libname hrsclean "&drivename.\HRSPublicUseData\HRSCleanData";
libname CDI "&drivename.\Research Projects\Childhood SES in HRS";
libname created "&drivename.\HRS created data sets";
libname net 	"&drivename.\HRSPublicUseData\Internet Surveys";	* libname for internet surveys; 
*libname FS "&drivename.\Childhood SES in HRS\Paola\Finalized Outcome documentation";


/* Variable Lists for Importation */ 
%let varlist_rand = 
			HHID PN  HHIDPN 
			RAMEDUC  RAFEDUC	/* parental education */ 
			RABPLACE 			/* birth place */ 
			RARACEM RAHISPAN 	/* race variables */ 
			;
run;

%let varlist_tkr = 
			HHID PN birthyr
			gender 
			;
run; 

options fmtsearch=(rawdata) nofmterr;


/* Import Rand data set */
data rand;
	set libname.rndhrs_o (keep = &varlist_rand);

		* set missing values of parental education to missing; 
			if RAMEDUC = .D then RAMEDUC = .;  
			if RAMEDUC = .M then RAMEDUC = .;  
			if RAMEDUC = .R then RAMEDUC = .; 

			if RAFEDUC = .D then RAFEDUC = .; 
			if RAFEDUC = .M then RAFEDUC = .; 
			if RAFEDUC = .R then RAFEDUC = .; 

		* also set missing values of race / ethnicity to missing;  
			if RAHISPAN = .M then RAHISPAN = .;  
			if RARACEM = .M then RARACEM = .; 

	proc sort; by hhid pn;
run; 
proc freq data = rand; table rameduc rafeduc RAHISPAN RARACEM / missing; run; 


/* Import Tracker data set  */
	data tracker10;
		set libname.trk2010 (keep = &varlist_tkr);
		proc sort; by hhid pn;
	run;


/* Import childhood social and financial capital variables, cleaned in file 01 */ 
	data child; 
		set libname.c_vars;
		proc sort; by hhid pn; 
	run; 


/* Import childhood health variables across different waves */ 
	/* Import 2006 internet survey */
	data net06;
		set libname.net06_r;
		keep hhid pn
			/* HQ001 childhood health */ 
				I2_CHDHLTH; 
		proc sort; by hhid pn;
	run; 

/* Import 2007 internet survey */
	data net07;
		set libname.net07_r;
		keep hhid pn 
			/*HQ001 childhood health */ 
				I3_CHDHLTH;
		proc sort; by hhid pn;
	run; 

/*1996 core file*/
	data h96m_r;  
		set libname.h96m_r;
		keep hhid pn 
			E5648   /* childhood health  */
			; 
		proc sort; by hhid pn;
	run;

/*1998 core file*/ 
	data h98a_r;  
		set libname.h98a_r;
		keep hhid pn 
			F992 	 /* childhood health */ 
			; 
		proc sort; by hhid pn;
	run;

/*2000 core file*/
	data h00a_r;  
		set libname.h00a_r;
		keep hhid pn  
			G1079 	/* childhood health */ 
			; 
		proc sort; by hhid pn;
	run;

/* 2002 core file */ 
	data h02b_r;  
		set libname.h02b_r;
		keep hhid pn  
			HB019	/* childhood health */ 
			; 
		proc sort; by hhid pn;
	run;

/* 2002 exit file */ 
	data x02b_r;  
		set libname.x02b_r;
		keep hhid pn 
			SB019	/* childhood health */ 
			;
		proc sort; by hhid pn;
	run;

/* 2004 core files, Section B */
	data h04b_r;  
		set libname.h04b_r;
		keep hhid pn 
			JB019	/* childhood health */ 	
			; 
		proc sort; by hhid pn;
	run; 

/*2004 exit file*/   
	data x04b_r;  
		set libname.x04b_r;
		keep hhid pn 
			TB019	/* childhood health */ 
			;
		proc sort; by hhid pn;
	run;

/* 2006 core file */ 
	data h06b_r;  
		set libname.h06b_r;
		keep hhid pn 
			KB019 	/* childhood health */ 
			; 
		proc sort; by hhid pn;
	run; 

/* 2006 exit file */
	data x06b_r;  
		set libname.x06b_r;
		keep hhid pn 
			UB019  	/* childhood health */ 
			; 
		proc sort; by hhid pn;
	run; 

	
options fmtsearch=(rawdata) nofmterr;
/*2008 core file, section B*/  
	data h08b_r;  
		set libname.h08b_r;
		keep hhid pn 
			LB019	/* childhood health */ 
			; 
		proc sort; by hhid pn;
	run;

/*2010 core file */
	data h10b_r;  
		set libname.h10b_r;
		keep hhid pn 
			MB019	/* childhood health */ 
			; 
		proc sort; by hhid pn;
	run;


/* merge data sets */
	data merged; 
		merge 	rand
				tracker10 (in = keep)
				child
				net06
				net07
				h96m_r 
				h98a_r 
				h00a_r 
				h02b_r 
				x02b_r 
				h04b_r 
				x04b_r
				h06b_r 
				x06b_r 
				h08b_r 
				h10b_r
				;
		by hhid pn; 
		if keep; 
	run; 

	data merged2; 
		set merged;

		/* clean RAND education variables */ 
			myrs = RAMEDUC; 
			if myrs = 7.5 then myrs = .; *ahead low education moms set to missing; 
			if myrs = 8.5 then myrs = .; *ahead high educaton moms set to missing; 

			fyrs = RAFEDUC; 
			if fyrs = 7.5 then fyrs = .; *ahead low education dads set to missing; 
			if fyrs = 8.5 then fyrs = .; *ahead high education dads set to missing;

			/* now myrs and fyrs are variables that have only the continuous values for education;  
			the dichotomized data from the ahead cohort is set to missing for these variables */ 


		/* clean race / ethnicity indicators */
	   			select;
					when(RARACEM=1 and RAHISPAN = 0) r_racenew = 10; *NHW; 
					when(RARACEM=2 and RAHISPAN = 0) r_racenew = 1; *NHB;
					when(RAHISPAN=1) r_racenew = 2; *Hispanic;
					when(RARACEM=3 and RAHISPAN = 0) r_racenew = 3; *Other;
					otherwise r_racenew=.;
				end;

				* race dummies; 
					nhw = (r_racenew = 10); if r_racenew = . then nhw = .;
					nhb = (r_racenew = 1); if r_racenew = . then nhb = .;
					hisp = (r_racenew = 2); if r_racenew = . then hisp = .;
					oth = (r_racenew = 3); if r_racenew = . then oth = .;

		/* Indicator for gender */ 
				female = .  ; 
				if gender = 1 then female = 0; 
				if gender = 2 then female = 1; 

		/* clean birthyr */ 
				if birthyr = 0 then birthyr = .; 

		/* clean birth place */ 
				if RABPLACE = .M then RABPLACE = .; 

				* south birth includes following states: DE, MD, DC, VA, WV, NC, SC, GA FL, KT, TN, MS, AL, OK, TX, AR, LA;
					if RABPLACE = 5 or RABPLACE = 6 or RABPLACE = 7 then s_birth = 1; 
					if RABPLACE in (1, 2, 3, 4, 8, 9, 10, 11) then s_birth = 0;

				* foreign born; 
					f_birth = (RABPLACE = 11); if RABPLACE = . then f_birth = .;

		/* self-reported childhood health: use first self report, then proxy report if still missing */
			* self report; 
				chealth =  E5648; if chealth > 6 then chealth = .;  
				if chealth = . then chealth = F992; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = G1079; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = HB019; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = JB019; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = KB019; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = I2_CHDHLTH; if chealth > 6 then chealth = .; * 2006 internet survey; 
				if chealth = . then chealth = I3_CHDHLTH; if chealth > 6 then chealth = .; * 2008 internet survey; 
				if chealth = . then chealth = LB019; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = MB019; if chealth > 6 then chealth = .; 
			
			* childhood health by proxy report; 
				if chealth = . then chealth = SB019; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = TB019; if chealth > 6 then chealth = .; 
				if chealth = . then chealth = UB019; if chealth > 6 then chealth = .; 
	
			* childhealth dummies; 
				c_excel = (chealth = 1); if chealth = . then c_excel = .; 
				c_vgood = (chealth = 2); if chealth = . then c_vgood = .; 
				c_good = (chealth = 3); if chealth = . then c_good = .; 
				c_fair = (chealth = 4); if chealth = . then c_fair = .; 
				c_poor = (chealth = 5); if chealth = . then c_poor =.; 

	run;

/* check that setting parental education to missing was done properly -- I'm not sure why, but when I table RAMEDUC the 7.5 and 8.5 don't
	show up, and if I look at the data set, the 7.5 and 8.5 aren't there either; however, when I set them to missing as I do 
	above, it works fine.  This may be somethink flukey with my version of SAS, but I wanted to give a heads up */ 

	proc freq data = merged2;
		table RAMEDUC myrs RAFEDUC fyrs; 
	run; 
	proc freq data = merged2;
		where RAFEDUC = . ;
		table RAMEDUC / missing; 
	run; 
	proc means data = merged2; 
		var myrs fyrs;
		title "means before imputations";
	run; 

options fmtsearch=(rawdata) nofmterr;
/* Correlation of childhood variables with mom and dad's education to determine 
	which variables are included in the imputation */

	* mother; 
	proc corr data = merged2; 
		var myrs gramps; 
		title "social correlations with myrs"; 
	run; 
	proc corr data = merged2; 
		var myrs nomom; 
	run; 
	proc corr data = merged2; 
		var myrs focc_cat; 
	run; 
	proc corr data = merged2; 
		var myrs famses; 
	run; 
	proc corr data = merged2; 
		var myrs finmove; 
	run; 
	proc corr data = merged2; 
		var myrs finhelp; 
	run; 
	proc corr data = merged2; 
		var myrs f_work; 
	run; 
	proc corr data = merged2; 
		var myrs f_absent; 
	run; 
	proc corr data = merged2; 
		var myrs m_work; 
	run; 
	proc corr data = merged2; 
		var myrs m_life; 
	run; 
	proc corr data = merged2; 
		var myrs m_effort; 
	run; 
	proc corr data = merged2; 
		var myrs m_atten; 
	run;  
	proc corr data = merged2; 
		var myrs fam_str; 
	run;
	proc corr data = merged2; 
		var myrs bankrup; 
	run;
	proc corr data = merged2; 
		var myrs lose_bus; 
	run; 

	* father; 
	proc corr data = merged2; 
		var fyrs gramps; 
		title "social correlations with fyrs"; 
	run; 
	proc corr data = merged2; 
		var fyrs nomom; 
	run; 
	proc corr data = merged2; 
		var fyrs focc_cat; 
	run; 
	proc corr data = merged2; 
		var fyrs famses; 
	run; 
	proc corr data = merged2; 
		var fyrs finmove; 
	run; 
	proc corr data = merged2; 
		var fyrs finhelp; 
	run; 
	proc corr data = merged2; 
		var fyrs f_work; 
	run; 
	proc corr data = merged2; 
		var fyrs f_absent; 
	run; 
	proc corr data = merged2; 
		var fyrs m_work; 
	run; 
	proc corr data = merged2; 
		var fyrs m_life; 
	run; 
	proc corr data = merged2; 
		var fyrs m_effort; 
	run; 
	proc corr data = merged2; 
		var fyrs m_atten; 
	run;  
	proc corr data = merged2; 
		var fyrs fam_str; 
	run;
	proc corr data = merged2; 
		var fyrs bankrup; 
	run;
	proc corr data = merged2; 
		var fyrs lose_bus; 
	run; 

	/* Include the following social variables which are significantly correlated with either 
		mother's or father's education in the imputations:
		gramps nomom focc_cat (dummy out) famses (dummy out)
		finmove finhelp f_work (dummy out)
		f_absent m_work (dummy out) m_life (dummy out) m_effort (dummy out) m_atten (dummy out) 
		lose_bus
		*/

options fmtsearch=(rawdata) nofmterr;

/* Correlation of demographic variables with mom and dad's education to determine 
	which variables are included in the imputation */

	* mother; 
	proc corr data = merged2; 
		var myrs birthyr; 
		title "demographic correlations with myrs"; 
	run; 
	proc corr data = merged2; 
		var myrs nhw; 
	run; 
	proc corr data = merged2; 
		var myrs nhb; 
	run; 
	proc corr data = merged2; 
		var myrs hisp; 
	run; 
	proc corr data = merged2; 
		var myrs oth; 
	run; 
	proc corr data = merged2; 
		var myrs female; 
	run; 
	proc corr data = merged2; 
		var myrs s_birth; 
	run; 
	proc corr data = merged2; 
		var myrs f_birth; 
	run; 
	proc corr data = merged2; 
		var myrs chealth; 
	run; 

	* father; 
	proc corr data = merged2; 
		var fyrs birthyr; 
		title "demographic correlations with fyrs"; 
	run; 
	proc corr data = merged2; 
		var fyrs nhw; 
	run; 
	proc corr data = merged2; 
		var fyrs nhb; 
	run; 
	proc corr data = merged2; 
		var fyrs hisp; 
	run; 
	proc corr data = merged2; 
		var fyrs oth; 
	run; 
	proc corr data = merged2; 
		var fyrs female; 
	run; 
	proc corr data = merged2; 
		var fyrs s_birth; 
	run; 
	proc corr data = merged2; 
		var fyrs f_birth; 
	run; 
	proc corr data = merged2; 
		var fyrs chealth; 
	run; 
 

	/* Include the following demographic variables which are significantly correlated with either 
		mother's or father's education in the imputations:
		birthyr race (dummied out above) female chealth (dummied out above) */


/* dummy out categorical variables for imputations */ 
	data merged3;
		set merged2; 
			
		/* dummy out ordinal variables from factor analysis */ 
		* father's occuapation; 
			fcat1 = .; 
			fcat2 = .; 
			fcat3 = .; 
			fcat4 = .; 
			fcat5 = .; 
			fcat6 = .; 
			
			if focc_cat > . then fcat1 = 0; if focc_cat = 1 then fcat1 = 1; 
			if focc_cat > . then fcat2 = 0; if focc_cat = 2 then fcat2 = 1; 
			if focc_cat > . then fcat3 = 0; if focc_cat = 3 then fcat3 = 1; 
			if focc_cat > . then fcat4 = 0; if focc_cat = 4 then fcat4 = 1; 
			if focc_cat > . then fcat5 = 0; if focc_cat = 5 then fcat5 = 1; 
			if focc_cat > . then fcat6 = 0; if focc_cat = 6 then fcat6 = 1; 

		* father's employment; 
			wrk1 = .; 
			wrk2 = .;
			wrk3 = .;

			if f_work > . then wrk1 = 0; if f_work = 0 then wrk1 = 1; 
			if f_work > . then wrk2 = 0; if f_work = 1 then wrk2 = 1; 
			if f_work > . then wrk3 = 0; if f_work = 2 then wrk3 = 1; 

		* family SES; 
			ses1 = .;  
			ses2 = .;
			ses3 = .; 

			if famses > . then ses1 = 0; if famses = 1 then ses1 = 1; 
			if famses > . then ses2 = 0; if famses = 2 then ses2 = 1; 
			if famses > . then ses3 = 0; if famses = 3 then ses3 = 1; 

		* mom effort; 
			eff1 = .; 
			eff2 = .; 
			eff3 = .; 
			eff4 = .; 

			if m_effort > . then eff1 = 0; if m_effort = 1 then eff1 = 1; 
			if m_effort > . then eff2 = 0; if m_effort = 2 then eff2 = 1; 
			if m_effort > . then eff3 = 0; if m_effort = 3 then eff3 = 1; 
			if m_effort > . then eff4 = 0; if m_effort = 4 then eff4 = 1; 

		* mom attention; 
			att1 = .; 
			att2 = .; 
			att3 = .; 
			att4 = .; 

			if m_atten > . then att1 = 0; if m_atten = 1 then att1 = 1; 
			if m_atten > . then att2 = 0; if m_atten = 2 then att2 = 1; 
			if m_atten > . then att3 = 0; if m_atten = 3 then att3 = 1; 
			if m_atten > . then att4 = 0; if m_atten = 4 then att4 = 1; 

		* mom life; 
			lif1 = .; 
			lif2 = .; 
			lif3 = .; 
			lif4 = .; 

			if m_life > . then lif1 = 0; if m_life = 1 then lif1 = 1; 
			if m_life > . then lif2 = 0; if m_life = 2 then lif2 = 1; 
			if m_life > . then lif3 = 0; if m_life = 3 then lif3 = 1; 
			if m_life > . then lif4 = 0; if m_life = 4 then lif4 = 1; 

		* mother's employment; 
			mwrk1 = .; 
			mwrk2 = .;
			mwrk3 = .;

			if m_work > . then mwrk1 = 0; if m_work = 0 then mwrk1 = 1; 
			if m_work > . then mwrk2 = 0; if m_work = 1 then mwrk2 = 1; 
			if m_work > . then mwrk3 = 0; if m_work = 2 then mwrk3 = 1; 
	run; 

/* check dummy variables were created correctly */
	proc freq data = merged3; 
		table 	focc_cat 	fcat1 fcat2 fcat3 fcat4 fcat5 fcat6
				f_work 		wrk1 wrk2 wrk3
				famses 		ses1 ses2 ses3 
				m_effort 	eff1 eff2 eff3 eff4
				m_atten 	att1 att2 att3 att4
				m_life 		lif1 lif2 lif3 lif4
				m_work 		mwrk1 mwrk2 mwrk3; 
	run;


options fmtsearch=(rawdata) nofmterr;


/* create 5 separate imputation data sets */ 

	* Missing data on parents education. There are some people in the ahead cohort 
	who are missing data on parent's education for one of their parents but not the other. 
	For those people, I'll use the missing data imputation for the parent with mising data, and use 
	the ahead imputation if they reported dichotomized data for that parent.; 
	data merged4;
		set merged3;
		
		keep = .; 
		if RAMEDUC = . then keep = 1; 
		if RAFEDUC = . then keep = 1;

		if myrs > . then keep = 1; 
		if fyrs > . then keep = 1; 
	run; 
	proc freq data = merged4;
		table keep;
	run; 
	data missed; 	/* stands for missing education */ 
		set merged4;
		if keep = . then delete; 
	run;
	proc freq data = missed; where RAMEDUC = .;  table myrs / missing; title "moms with missing data"; run; 
	proc freq data = missed; where RAFEDUC = .;  table fyrs / missing; title "dads with missing data"; run; 

options fmtsearch=(rawdata) nofmterr;

* mom adhead low; 
	data momlow;
		set merged4;
		if RAMEDUC >= 8 then delete; * remove people with >= 8 years ed; 
		if RAMEDUC = . then delete; * remove people missing mother's ed; 
	run; 
	proc freq data = momlow; table myrs / missing; title "mom ahead low"; run; 

* mom adhead high; 
	data momhi;
		set merged4;
		if RAMEDUC < 8 then delete; * remove people with less than 8 years ed; 
		if RAMEDUC = . then delete; * remove popele missing mother's ed;
	run; 
	proc freq data = momhi; table myrs / missing; title "mom ahead hi"; run; 

* dad adhead low; 
	data dadlow;
		set merged4;
		if RAFEDUC >= 8 then delete;
		if RAFEDUC = . then delete; 
	run; 
	proc freq data = dadlow; table fyrs / missing; title "dad ahead low";run; 

* dad adhead high; 
	data dadhi;
		set merged4;
		if RAFEDUC < 8 then delete;
		if RAFEDUC = . then delete; 
	run; 
	proc freq data = dadhi; table fyrs / missing; title "dad ahead hi"; run; 

options fmtsearch=(rawdata) nofmterr;

/* Human Capital Imputations: used proc mi with expectation maximization */ 

/*********************************************************************************** Imputations for missing parents' education */ 
	proc mi data = missed simple nimpute = 1; /* single imputations, gives descriptive stats */ 
		em itprint out = missed_imp maxiter = 5000; 
		var myrs fyrs /* human capital */
			fcat2 fcat3 fcat4 fcat5 fcat6 ses2 ses3 finmove finhelp wrk2 wrk3 
 			eff2 eff3 eff4 att2 att3 att4 lif2 lif3 lif4 nomom  
			f_absent mwrk2 mwrk3 gramps /*lose_bus: model won't converge if this var is included */ 
			birthyr nhb hisp oth female s_birth f_birth c_vgood c_good c_fair c_poor
			;
	run; 

	* check if imputations are reasonable; 
		proc means data = missed_imp; 
			where RAMEDUC = .; 
			var myrs; 
			title "mean for moms with missing data";
		run;
		proc means data = missed_imp; 
			where RAFEDUC = .; 
			var fyrs; 
			title "mean for dads with missing data"; /* are values < 0 and > 17, which are the min and max, so needs to be fixed */ 
		run; 
		proc freq data = missed_imp;
			where fyrs > 17; 
			table fyrs;
			title "number of dads with education above eligible range"; 
		run;  *There are two dads with education above 17, so I'll set to 17 in the data step below; 
		proc freq data = missed_imp;
			where fyrs < 0; 
			table fyrs;
			title "number of dads with education below eligible range"; 
		run; *There is one dad with education below 0, so I'll set to 0 in the data step below; 

	* create dataset for merge; 
	* need to rename variables so if same person has ahead coding and missing data, can tell 
		the difference in the imputed data sets; 
		data missed_imp2;
			set missed_imp; 
			myrs_imp_tot = myrs;
			fyrs_imp_tot = fyrs; 

			if RAMEDUC > . then myrs_imp_tot = .; * myrs_imp_tot only has imputed values; 
			if RAFEDUC > . then fyrs_imp_tot = .; * fyrs_imp_tot only has imputed values;

			if fyrs_imp_tot > 17 then fyrs_imp_tot = 17; 
			if -5 < fyrs_imp_tot < 0  then fyrs_imp_tot = 0; 
		run; 
		proc means data = missed_imp2;
			var myrs_imp_tot fyrs_imp_tot;
		run;
		data missed_imp2;
			set missed_imp2; 
			keep hhid pn myrs_imp_tot fyrs_imp_tot;
			proc sort; by hhid pn;  
		run; 
				

/*********************************************************************************** Ahead imputations for low education mothers 
	The model for low education moms isn't converging, so I look to see, among low education moms specifically, 
	which social and demographic  factors are the strongest correlates and therefore should be included in the imputation model */
	
		* social; 
			proc corr data = momlow; 
				var myrs gramps; 
				title "social correlations with myrs among low education moms"; 
			run; 
			proc corr data = momlow; 
				var myrs nomom; 
			run; 
			proc corr data = momlow; 
				var myrs focc_cat; 
			run; 
			proc corr data = momlow; 
				var myrs famses; 
			run; 
			proc corr data = momlow; 
				var myrs finmove; 
			run; 
			proc corr data = momlow; 
				var myrs finhelp; 
			run; 
			proc corr data = momlow; 
				var myrs f_work; 
			run; 
			proc corr data = momlow; 
				var myrs f_absent; 
			run; 
			proc corr data = momlow; 
				var myrs m_work; 
			run; 
			proc corr data = momlow; 
				var myrs m_life; 
			run; 
			proc corr data = momlow; 
				var myrs m_effort; 
			run; 
			proc corr data = momlow; 
				var myrs m_atten; 
			run;  
			proc corr data = momlow; 
				var myrs fam_str; 
			run;
			proc corr data = momlow; 
				var myrs bankrup; 
			run;
			proc corr data = momlow; 
				var myrs lose_bus; 
			run; 

		* demographic; 
			proc corr data = momlow; 
				var myrs birthyr; 
				title "demographic correlations with myrs for low ed moms"; 
			run; 
			proc corr data = momlow; 
				var myrs nhw; 
			run; 
			proc corr data = momlow; 
				var myrs nhb; 
			run; 
			proc corr data = momlow; 
				var myrs hisp; 
			run; 
			proc corr data = momlow; 
				var myrs oth; 
			run; 
			proc corr data = momlow; 
				var myrs female; 
			run; 
			proc corr data = momlow; 
				var myrs s_birth; 
			run; 
			proc corr data = momlow; 
				var myrs f_birth; 
			run; 
			proc corr data = momlow; 
				var myrs chealth; 
			run; 

		/* variables that are most correlated with years of education among low ed moms are: 
				gramps, focc_cat famses finmove f_absent m_effort
				birthyr nhw nhb hisp oth s_birth f_birth chealth
			so I will try the imputations using only these variables */ 
		

		options fmtsearch=(rawdata) nofmterr;
		proc mi data = momlow simple nimpute = 1; /* single imputations, gives descriptive stats */
			em itprint out = momlow_imp maxiter = 5000; 
			var myrs  fyrs /*human capital */
				fcat2 fcat3 fcat4 fcat5 fcat6 ses2 ses3 finmove /*finhelp  wrk2 wrk3 */
	 			eff2 eff3 eff4 /*att2 att3 att4 lif2 lif3 lif4 nomom  */
				f_absent /*mwrk2 mwrk3*/ gramps /*lose_bus */
				birthyr nhb hisp oth /* female */ s_birth f_birth c_vgood c_good c_fair c_poor
				;
		run; 

		* check if imputations are reasonable; 
			proc means data = momlow_imp; 
				where RAMEDUC ne 7.5; 
				var myrs; 
				title "mean for all low ed moms";
			run; 
			proc means data = momlow_imp; 
				where RAMEDUC = 7.5; 
				var myrs; 
				title "mean for low ahead moms";
			run;  

		* create dataset for merge; 
			data momlow_imp;
				set momlow_imp;
				myrs_imp_low = myrs; 
				if RAMEDUC ne 7.5 then myrs_imp_low = .; * myrs_imp_low only has imputed values; 
			run; 
			proc means data = momlow_imp; 
				var myrs_imp_low; 
			run;
			data momlow_imp;
				set momlow_imp;
				keep hhid pn myrs_imp_low;
				proc sort; by hhid pn; 
			run; 


/*********************************************************************************** Ahead imputations for high education mothers */ 
		options fmtsearch=(rawdata) nofmterr;
		proc mi data = momhi simple nimpute = 1; /* single imputations, gives descriptive stats */ 
			em itprint out = momhi_imp maxiter = 5000; 
			var myrs fyrs /* human capital */
				fcat2 fcat3 fcat4 fcat5 fcat6 ses2 ses3 finmove finhelp wrk2 wrk3 
	 			eff2 eff3 eff4 att2 att3 att4 lif2 lif3 lif4 nomom  
				f_absent mwrk2 mwrk3 gramps /*lose_bus*/ 
				birthyr nhb hisp oth female s_birth f_birth c_vgood c_good c_fair c_poor
				;
		run; 

		* check if imputations are reasonable; 
			proc means data = momhi_imp; 
				where RAMEDUC ne 8.5; 
				var myrs; 
				title "mean for high ed moms"; 
			run; 
			proc means data = momhi_imp; 
				where RAMEDUC = 8.5; 
				var myrs; 
				title "mean for high ed ahead moms"; /* some values < 8 should be set to 8 */ 
			run; 

		* create dataset for merge; 
			data momhi_imp;
				set momhi_imp;
				myrs_imp_hi = myrs; 
				if RAMEDUC ne 8.5 then myrs_imp_hi = .; * myrs_imp_hi only has imputed values; 
			run; 
			proc means data = momhi_imp ; 
				where myrs_imp_hi < 8;
				var myrs_imp_hi;  /* one obs with an imputed values < 8 was set to 8 */ 
			run; 
			data momhi_imp;
				set momhi_imp; 
				if 7.5 < myrs_imp_hi < 8 then myrs_imp_hi = 8; 
			run; 
			proc means data = momhi_imp; 
				var myrs_imp_hi; 
				title "mean for high ed moms";
			run;
			data momhi_imp;
				set momhi_imp;
				keep hhid pn myrs_imp_hi;
				proc sort; by hhid pn; 
			run; 


/*********************************************************************************** Ahead imputations for low education fathers */ 
		options fmtsearch=(rawdata) nofmterr;
		proc mi data = dadlow simple nimpute = 1; /* single imputations, gives descriptive stats */ 
			em itprint out = dadlow_imp maxiter = 5000; 
			var myrs fyrs /* human capital */
				fcat2 fcat3 fcat4 fcat5 fcat6 ses2 ses3 finmove finhelp wrk2 wrk3 
		 		eff2 eff3 eff4 att2 att3 att4 lif2 lif3 lif4 nomom  
				f_absent mwrk2 mwrk3 gramps /* lose_bus */
				birthyr nhb hisp oth female s_birth f_birth c_vgood c_good c_fair c_poor
				;
		run; 

		* check if imputations are reasonable; 
			proc means data = dadlow_imp; 
				var fyrs; 
				title "mean for low ed dads";
			run; 
			proc means data = dadlow_imp; 
				where RAFEDUC = 7.5; 
				var fyrs; 
				title "mean for low ahead dads";
			run; 

		* create dataset for merge; 
			data dadlow_imp;
				set dadlow_imp;
				fyrs_imp_low = fyrs; 
				if RAFEDUC ne 7.5 then fyrs_imp_low = .; * fyrs_imp_low only has imputed values; 
			run; 
			proc means data = dadlow_imp; 
				where RAFEDUC = 7.5; 
				var fyrs_imp_low; 
				title "mean for low ahead dads";
			run;
			data dadlow_imp;
				set dadlow_imp;
				keep hhid pn fyrs_imp_low;
				proc sort; by hhid pn; 
			run;
	

/*********************************************************************************** Ahead imputations for high education fathers */ 
		options fmtsearch=(rawdata) nofmterr;
		proc mi data = dadhi simple nimpute = 1; /* single imputations, gives descriptive stats */ 
			em itprint out = dadhi_imp maxiter = 5000; 
			var myrs fyrs /* human capital */
				fcat2 fcat3 fcat4 fcat5 fcat6 ses2 ses3 finmove finhelp wrk2 wrk3 
			 	eff2 eff3 eff4 att2 att3 att4 lif2 lif3 lif4 nomom  
				f_absent mwrk2 mwrk3 gramps /* lose_bus */
				birthyr nhb hisp oth female s_birth f_birth c_vgood c_good c_fair c_poor
				;
		run; 

		* check if imputations are reasonable; 
			proc means data = dadhi_imp; 
				var fyrs; 
				title "mean for high ed dads";
			run; 
			proc means data = dadhi_imp; 
				where RAFEDUC = 8.5; 
				var fyrs; 
				title "mean for high ahead dads";
			run;		
			proc means data = dadhi_imp;
				where RAFEDUC = 8.5;
				where fyrs < 8;
				var fyrs; * there is one person whose years of education is less than 8 and will be set to 8 in the data step below; 
			run;

		* create dataset for merge; 
		data dadhi_imp;
			set dadhi_imp;
			fyrs_imp_hi = fyrs; 

			if RAFEDUC ne 8.5 then fyrs_imp_hi = .;

			* set imputed value below 8 to 8; 
			if 0 < fyrs_imp_hi < 8 then fyrs_imp_hi = 8; 

		run; 
		proc means data = dadhi_imp; 
			var fyrs_imp_hi; 
		run;
		data dadhi_imp;
			set dadhi_imp;
			keep hhid pn fyrs_imp_hi;
			proc sort; by hhid pn; 
		run; 



/* Merge all imputed data together and create human capital scale */  
options fmtsearch=(rawdata) nofmterr;
	
	* merge data sets; 
		data merge_imp;
		retain 	myrs myrs_imp_tot myrs_imp_low myrs_imp_hi
				fyrs fyrs_imp_tot fyrs_imp_low fyrs_imp_hi
				RAMEDUC RAFEDUC;
			merge 	merged 
					missed_imp2
					momlow_imp
					momhi_imp
					dadlow_imp
					dadhi_imp; 
			by hhid pn; 
		run; 
	
	data merge_imp2;
		set merge_imp;

		myrs = RAMEDUC; 
		if RAMEDUC = 7.5 then myrs = .; 
		if RAMEDUC = 8.5 then myrs = .; 

		fyrs = RAFEDUC; 
		if RAFEDUC = 7.5 then fyrs = .; 
		if RAFEDUC = 8.5 then fyrs = .;

		proc sort; by rameduc; 
	run; 
	data merge_imp3;
		retain 	myrs myrs_imp_tot myrs_imp_low myrs_imp_hi
			fyrs fyrs_imp_tot fyrs_imp_low fyrs_imp_hi
			RAMEDUC RAFEDUC;
		set merge_imp2; 

		if myrs = . then myrs = myrs_imp_tot; 
		if myrs = . then myrs = myrs_imp_low;
		if myrs = . then myrs = myrs_imp_hi;  
		
		if fyrs = . then fyrs = fyrs_imp_tot; 
		if fyrs = . then fyrs = fyrs_imp_low;
		if fyrs = . then fyrs = fyrs_imp_hi;

		myrs_std = myrs;
		fyrs_std = fyrs;
	run;
	proc means data = merge_imp3;
		var myrs fyrs; 
		title "Means after imputations"; 
	run; 
	proc univariate data = merge_imp3;
		histogram; 
		var myrs fyrs; 
	run; 

	proc standard data = merge_imp3 mean = 0 std = 1 out = humcap_std;
		var myrs_std fyrs_std;
	run; 
		proc means data = humcap_std;
			var myrs_std fyrs_std; 
			title "means of standardized imputed education"; 
		run; 
	data humcap_std;
		set humcap_std; 

		humcap = myrs_std + fyrs_std;
	run; 
		proc means data = humcap_std;
			var humcap; 
		run;
		proc univariate data = humcap_std;
			histogram; 
			var humcap; 
		run;
		proc standard data = humcap_std mean = 0 std = 1 out = humcap_std2;
			var humcap;
		run; 
		proc means data = humcap_std2;
			var humcap; 
		run;
		proc univariate data = humcap_std2;
			histogram; 
			var humcap; 
		run;

* Create permanent data set; 
	data libname.humcap;
		set humcap_std2;

		keep hhid pn HHIDPN2
		myrs fyrs
		myrs_std fyrs_std
		humcap
		;
		proc sort; by hhid pn;
	run; 
